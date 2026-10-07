#include "learning_audio_engine.h"

#include <windows.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Media.Core.h>
#include <winrt/Windows.Media.Playback.h>
#include <winrt/Windows.Media.SpeechSynthesis.h>
#include <winrt/Windows.Storage.Streams.h>

#include <atomic>
#include <chrono>
#include <condition_variable>
#include <deque>
#include <mutex>
#include <stdexcept>
#include <thread>
#include <utility>

namespace {
using namespace winrt::Windows::Foundation;
using namespace winrt::Windows::Media::Core;
using namespace winrt::Windows::Media::Playback;
using namespace winrt::Windows::Media::SpeechSynthesis;
using Outcome = LearningAudioEngine::Outcome;

VoiceInformation JapaneseVoice() {
  VoiceInformation selected{nullptr};
  for (const auto& voice : SpeechSynthesizer::AllVoices()) {
    // 固定 request locale；依 metadata 選擇，不依 display name 或預設語音。
    if (voice.Language() == L"ja-JP" &&
        (!selected || voice.Id() < selected.Id())) {
      selected = voice;
    }
  }
  return selected;
}

// 只隔離 OS provider 的 HRESULT；logic_error／allocation 等程式錯誤不轉
// failed。
template <typename Action>
bool TryProvider(Action action) {
  try {
    action();
    return true;
  } catch (const winrt::hresult_error&) {
    return false;
  }
}

struct NativePlayback {
  SpeechSynthesizer synthesizer{nullptr};
  SpeechSynthesisStream stream{nullptr};
  MediaPlayer player{nullptr};

  bool Close() {
    bool ok = true;
    if (player) {
      // 各步獨立清理；一個 OS error 不得略過其餘 native resource。
      ok = TryProvider([&] { player.Pause(); }) && ok;
      ok = TryProvider([&] { player.Source(nullptr); }) && ok;
      ok = TryProvider([&] { player.Close(); }) && ok;
      player = nullptr;
    }
    if (stream) {
      ok = TryProvider([&] { stream.Close(); }) && ok;
      stream = nullptr;
    }
    if (synthesizer) {
      ok = TryProvider([&] { synthesizer.Close(); }) && ok;
      synthesizer = nullptr;
    }
    return ok;
  }

  ~NativePlayback() { Close(); }

  Outcome Play(const std::wstring& text, const std::atomic<bool>& stopping) {
    // replacement 先釋放前次 playback，任何失敗也不留下舊語音繼續播放。
    if (!Close()) return Outcome::failed;
    const auto voice = JapaneseVoice();
    if (!voice) return Outcome::unavailable;
    synthesizer = SpeechSynthesizer();
    synthesizer.Voice(voice);
    const auto readback = synthesizer.Voice();
    if (!readback || readback.Id() != voice.Id() ||
        readback.Language() != L"ja-JP") {
      return Outcome::failed;
    }
    auto operation = synthesizer.SynthesizeTextToStreamAsync(text);
    struct Signal {
      std::mutex mutex;
      std::condition_variable wake;
      bool completed = false;
    };
    const auto signal = std::make_shared<Signal>();
    // WinRT Completed 只註冊一次。callback 只持有 signal，絕不存取
    // owner／Dart。
    operation.Completed([signal](const auto&, const auto&) {
      std::lock_guard lock(signal->mutex);
      signal->completed = true;
      signal->wake.notify_one();
    });
    bool canceled = false;
    std::unique_lock lock(signal->mutex);
    while (!signal->completed) {
      lock.unlock();
      if (stopping.load() && !canceled) {
        operation.Cancel();
        canceled = true;
      }
      lock.lock();
      signal->wake.wait_for(lock, std::chrono::milliseconds(20),
                            [&] { return signal->completed; });
    }
    lock.unlock();
    if (stopping.load()) return Outcome::failed;
    stream = operation.GetResults();
    if (!stream || stream.Size() == 0) return Outcome::failed;
    player = MediaPlayer();
    player.AutoPlay(false);
    player.Source(MediaSource::CreateFromStream(stream, stream.ContentType()));
    player.Play();
    // 不註冊 playback event callback，也不將播放完成視為第二次 method
    // response。 accepted 僅表示提交成功；stream 保留至
    // replacement／shutdown，不寫檔。
    return Outcome::accepted;
  }
};
}  // namespace

struct LearningAudioEngine::Impl {
  using Job = std::function<void(NativePlayback&, bool)>;
  std::mutex mutex;
  std::condition_variable wake;
  std::deque<Job> jobs;
  std::atomic<bool> stopping{false};
  std::thread worker;

  Impl() : worker([this] { Run(); }) {}

  void Submit(Job job) {
    {
      std::lock_guard lock(mutex);
      if (stopping.load()) {
        throw std::logic_error("Learning Audio work submitted after shutdown.");
      }
      jobs.push_back(std::move(job));
    }
    wake.notify_one();
  }

  void Run() {
    const bool initialized = TryProvider(
        [] { winrt::init_apartment(winrt::apartment_type::multi_threaded); });
    {
      NativePlayback native;
      for (;;) {
        Job job;
        {
          std::unique_lock lock(mutex);
          wake.wait(lock, [&] { return stopping.load() || !jobs.empty(); });
          if (jobs.empty()) break;
          job = std::move(jobs.front());
          jobs.pop_front();
        }
        // 此 queue 只序列化 method 工作；從不等待前次語音播放完畢。
        if (stopping.load()) native.Close();
        job(native, initialized && !stopping.load());
      }
    }  // native 物件先於 factory cache／MTA 銷毀。
    if (initialized) {
      winrt::clear_factory_cache();
      winrt::uninit_apartment();
    }
  }
};

LearningAudioEngine::LearningAudioEngine() : impl_(std::make_unique<Impl>()) {}
LearningAudioEngine::~LearningAudioEngine() { Shutdown(); }

void LearningAudioEngine::GetCapability(Completion completion) {
  impl_->Submit([completion = std::move(completion)](NativePlayback&,
                                                     bool ready) {
    Outcome outcome = Outcome::failed;
    if (ready) {
      TryProvider([&] {
        outcome = JapaneseVoice() ? Outcome::available : Outcome::unavailable;
      });
    }
    completion(outcome);
  });
}

void LearningAudioEngine::Play(std::wstring text, Completion completion) {
  impl_->Submit(
      [this, text = std::move(text), completion = std::move(completion)](
          NativePlayback& native, bool ready) {
        Outcome outcome = Outcome::failed;
        if (ready) {
          TryProvider([&] { outcome = native.Play(text, impl_->stopping); });
          if (outcome != Outcome::accepted) native.Close();
        }
        completion(outcome);
      });
}

void LearningAudioEngine::Shutdown() {
  {
    std::lock_guard lock(impl_->mutex);
    impl_->stopping.store(true);
  }
  impl_->wake.notify_one();
  if (impl_->worker.joinable()) impl_->worker.join();
}

#ifdef LEARNING_AUDIO_TESTING
void LearningAudioEngine::ObservePlayback(
    std::function<void(PlaybackObservation)> completion) {
  impl_->Submit(
      [completion = std::move(completion)](NativePlayback& native, bool ready) {
        PlaybackObservation observation{false, false, 0, GetCurrentThreadId()};
        if (ready && native.player) {
          observation.failed = !TryProvider([&] {
            auto session = native.player.PlaybackSession();
            observation.playing =
                session.PlaybackState() == MediaPlaybackState::Playing;
            observation.position = session.Position().count();
          });
        }
        completion(observation);
      });
}
#endif
