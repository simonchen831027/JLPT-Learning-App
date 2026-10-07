#ifndef RUNNER_LEARNING_AUDIO_ENGINE_H_
#define RUNNER_LEARNING_AUDIO_ENGINE_H_

#include <cstdint>
#include <functional>
#include <memory>
#include <string>

// Runner 私有實作；所有 WinRT 物件只在單一、常駐 MTA worker 建立及釋放。
class LearningAudioEngine {
 public:
  enum class Outcome { available, unavailable, accepted, failed };
  using Completion = std::function<void(Outcome)>;

  LearningAudioEngine();
  ~LearningAudioEngine();
  LearningAudioEngine(const LearningAudioEngine&) = delete;
  LearningAudioEngine& operator=(const LearningAudioEngine&) = delete;

  // Completion 在 worker 上執行；不得直接呼叫 Flutter messenger。
  void GetCapability(Completion completion);
  void Play(std::wstring text, Completion completion);
  // 禁止新工作、取消合成、排空工作並 join；可重複呼叫。
  void Shutdown();

#ifdef LEARNING_AUDIO_TESTING
  struct PlaybackObservation {
    bool playing;
    bool failed;
    int64_t position;
    uint32_t worker_thread;
  };
  void ObservePlayback(std::function<void(PlaybackObservation)> completion);
#endif

 private:
  struct Impl;
  std::unique_ptr<Impl> impl_;
};

#endif  // RUNNER_LEARNING_AUDIO_ENGINE_H_
