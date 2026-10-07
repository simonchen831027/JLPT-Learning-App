#include "learning_audio_channel.h"

#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <deque>
#include <limits>
#include <mutex>
#include <stdexcept>
#include <string>
#include <utility>

#include "learning_audio_engine.h"

namespace {
using Value = flutter::EncodableValue;
using Result = flutter::MethodResult<Value>;
using Outcome = LearningAudioEngine::Outcome;
constexpr UINT kReplyReady = WM_APP + 1;
constexpr wchar_t kWindowClass[] = L"JlptLearningAudioReplyWindow";

const char* Status(Outcome outcome) {
  switch (outcome) {
    case Outcome::available:
      return "available";
    case Outcome::unavailable:
      return "unavailable";
    case Outcome::accepted:
      return "accepted";
    case Outcome::failed:
      return "failed";
  }
  throw std::logic_error("Invalid Learning Audio outcome.");
}

bool DecodeText(const Value* arguments, std::wstring& text) {
  const auto* map =
      arguments ? std::get_if<flutter::EncodableMap>(arguments) : nullptr;
  if (!map || map->size() != 2) return false;
  const auto text_entry = map->find(Value("text"));
  const auto language_entry = map->find(Value("languageTag"));
  if (text_entry == map->end() || language_entry == map->end()) return false;
  const auto* utf8 = std::get_if<std::string>(&text_entry->second);
  const auto* language = std::get_if<std::string>(&language_entry->second);
  if (!utf8 || !language || *language != "ja-JP" || utf8->empty() ||
      utf8->size() > static_cast<size_t>((std::numeric_limits<int>::max)())) {
    return false;
  }
  const int size = static_cast<int>(utf8->size());
  const int length = MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS,
                                         utf8->data(), size, nullptr, 0);
  if (length == 0) return false;
  text.resize(length);
  return MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, utf8->data(), size,
                             text.data(), length) == length;
}
}  // namespace

struct LearningAudioChannel::Impl {
  struct Reply {
    std::shared_ptr<Result> result;
    Outcome outcome;
  };

  const DWORD platform_thread = GetCurrentThreadId();
  HWND window = nullptr;
  std::mutex mutex;
  std::deque<Reply> replies;
  flutter::MethodChannel<Value> channel;
  LearningAudioEngine engine;

  explicit Impl(flutter::BinaryMessenger* messenger)
      : channel(messenger, "jlpt_learning_app/learning_audio",
                &flutter::StandardMethodCodec::GetInstance()) {
    WNDCLASSW window_class{};
    window_class.lpfnWndProc = WindowProcedure;
    window_class.hInstance = GetModuleHandle(nullptr);
    window_class.lpszClassName = kWindowClass;
    if (!RegisterClassW(&window_class) &&
        GetLastError() != ERROR_CLASS_ALREADY_EXISTS) {
      throw std::runtime_error("Cannot register Learning Audio reply window.");
    }
    window = CreateWindowExW(0, kWindowClass, L"", 0, 0, 0, 0, 0, HWND_MESSAGE,
                             nullptr, window_class.hInstance, this);
    if (!window) {
      throw std::runtime_error("Cannot create Learning Audio reply window.");
    }
    channel.SetMethodCallHandler([this](const flutter::MethodCall<Value>& call,
                                        std::unique_ptr<Result> result) {
      Handle(call, std::move(result));
    });
  }

  ~Impl() {
    RequirePlatformThread();
    channel.SetMethodCallHandler(nullptr);
    // worker 只持有仍存活的 Impl；join 後不可能再排入 callback。
    engine.Shutdown();
    DrainReplies();  // Flutter engine 尚存活，逐一且恰好一次回覆。
    // 訊息只作喚醒，沒有 LPARAM heap pointer；銷毀前移除殘留訊息。
    MSG message;
    while (PeekMessage(&message, window, kReplyReady, kReplyReady, PM_REMOVE)) {
    }
    DestroyWindow(window);
  }

  void RequirePlatformThread() const {
    if (GetCurrentThreadId() != platform_thread) {
      // 接線錯誤不能偽裝成 provider failed；release 也保留 invariant。
      std::terminate();
    }
  }

  static LRESULT CALLBACK WindowProcedure(HWND hwnd, UINT message,
                                          WPARAM wparam, LPARAM lparam) {
    if (message == WM_NCCREATE) {
      auto create = reinterpret_cast<CREATESTRUCT*>(lparam);
      SetWindowLongPtr(hwnd, GWLP_USERDATA,
                       reinterpret_cast<LONG_PTR>(create->lpCreateParams));
    }
    auto* self = reinterpret_cast<Impl*>(GetWindowLongPtr(hwnd, GWLP_USERDATA));
    if (self && message == kReplyReady) {
      self->DrainReplies();
      return 0;
    }
    return DefWindowProc(hwnd, message, wparam, lparam);
  }

  void DrainReplies() {
    RequirePlatformThread();
    std::deque<Reply> ready;
    {
      std::lock_guard lock(mutex);
      ready.swap(replies);
    }
    for (const auto& reply : ready) {
      reply.result->Success(Value(Status(reply.outcome)));
    }
  }

  LearningAudioEngine::Completion Complete(std::unique_ptr<Result> result) {
    return [this, result = std::shared_ptr<Result>(std::move(result))](
               Outcome outcome) {
      std::lock_guard lock(mutex);
      const bool needs_wakeup = replies.empty();
      replies.push_back({result, outcome});
      // 合併喚醒，避免大量請求用盡 Windows message queue。
      if (needs_wakeup && !PostMessage(window, kReplyReady, 0, 0)) {
        // 無法送回 platform thread 是基礎接線故障，不能遺失 reply 或回 failed。
        std::terminate();
      }
    };
  }

  void Handle(const flutter::MethodCall<Value>& call,
              std::unique_ptr<Result> result) {
    RequirePlatformThread();
    if (call.method_name() == "getCapability") {
      if (call.arguments() && !call.arguments()->IsNull()) {
        result->Error("invalid_arguments", "getCapability takes no arguments.");
        return;
      }
      engine.GetCapability(Complete(std::move(result)));
    } else if (call.method_name() == "play") {
      std::wstring text;
      if (!DecodeText(call.arguments(), text)) {
        result->Error("invalid_arguments", "Invalid Learning Audio request.");
        return;
      }
      engine.Play(std::move(text), Complete(std::move(result)));
    } else {
      result->NotImplemented();
    }
  }
};

LearningAudioChannel::LearningAudioChannel(flutter::BinaryMessenger* messenger)
    : impl_(std::make_unique<Impl>(messenger)) {}
LearningAudioChannel::~LearningAudioChannel() = default;
