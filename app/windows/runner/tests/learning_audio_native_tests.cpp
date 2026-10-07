#include <flutter/encodable_value.h>
#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <atomic>
#include <chrono>
#include <future>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>

#include "learning_audio_channel.h"
#include "learning_audio_engine.h"

namespace {
using namespace std::chrono_literals;
using Outcome = LearningAudioEngine::Outcome;
using Value = flutter::EncodableValue;

void Require(bool condition, const char* message) {
  if (!condition) throw std::runtime_error(message);
}

template <typename T>
T Await(std::future<T> future) {
  Require(future.wait_for(20s) == std::future_status::ready, "Worker timeout");
  return future.get();
}

Outcome Capability(LearningAudioEngine& engine) {
  std::promise<Outcome> promise;
  auto future = promise.get_future();
  engine.GetCapability([&](Outcome value) { promise.set_value(value); });
  return Await(std::move(future));
}

Outcome Play(LearningAudioEngine& engine, const std::wstring& text) {
  std::promise<Outcome> promise;
  auto future = promise.get_future();
  engine.Play(text, [&](Outcome value) { promise.set_value(value); });
  return Await(std::move(future));
}

void ObservePlaying(LearningAudioEngine& engine, DWORD& worker_thread) {
  const auto deadline = std::chrono::steady_clock::now() + 5s;
  while (std::chrono::steady_clock::now() < deadline) {
    std::promise<LearningAudioEngine::PlaybackObservation> promise;
    auto future = promise.get_future();
    engine.ObservePlayback([&](auto value) { promise.set_value(value); });
    const auto value = Await(std::move(future));
    Require(!value.failed, "Playback observation failed");
    Require(value.worker_thread != GetCurrentThreadId(),
            "Worker used STA thread");
    if (worker_thread == 0) worker_thread = value.worker_thread;
    Require(value.worker_thread == worker_thread, "MTA worker was replaced");
    if (value.playing && value.position > 0) {
      std::cout << "actual_playing=1 position_100ns=" << value.position << '\n';
      return;
    }
    std::this_thread::sleep_for(20ms);
  }
  throw std::runtime_error(
      "Actual Playing and advancing position not observed");
}

void EngineLifecycle() {
  for (int round = 0; round < 6; ++round) {
    LearningAudioEngine engine;
    Require(Capability(engine) == Outcome::available,
            "Japanese voice required");
    DWORD worker_thread = 0;
    for (int replacement = 0; replacement < 3; ++replacement) {
      Require(Play(engine, L"にほんご。きょう。たべる。") == Outcome::accepted,
              "Production playback not accepted");
      ObservePlaying(engine, worker_thread);
    }
    engine.Shutdown();
    engine.Shutdown();
    bool rejected = false;
    try {
      engine.GetCapability([](Outcome) {});
    } catch (const std::logic_error&) {
      rejected = true;
    }
    Require(rejected, "Post-shutdown programming error was hidden");
    std::cout << "round=" << round << " replacement=PASS shutdown_join=PASS\n";
  }
  // 合成／工作排程期間關閉：每一項 accepted invocation 均結算一次。
  for (int round = 0; round < 6; ++round) {
    auto engine = std::make_unique<LearningAudioEngine>();
    Require(Capability(*engine) == Outcome::available, "Capability changed");
    std::atomic<int> replies{0};
    std::wstring longer;
    for (int i = 0; i < 100; ++i) longer += L"にほんご。きょう。たべる。";
    engine->Play(longer, [&](Outcome value) {
      Require(value == Outcome::accepted || value == Outcome::failed,
              "Unexpected shutdown playback result");
      replies++;
    });
    for (int i = 0; i < 10; ++i) {
      engine->GetCapability([&](Outcome value) {
        Require(value == Outcome::available || value == Outcome::failed,
                "Unexpected shutdown capability result");
        replies++;
      });
    }
    std::this_thread::sleep_for(20ms);
    engine.reset();
    Require(replies == 11, "Shutdown lost a completion");
    std::this_thread::sleep_for(40ms);
    Require(replies == 11, "Completion after owner destruction");
    std::cout << "cancel_round=" << round << " drained=11 owner_destroyed=1\n";
  }
}

struct Response {
  int count = 0;
  std::string status;
  std::string error;
  bool missing = false;
};

class TestMessenger : public flutter::BinaryMessenger {
 public:
  flutter::BinaryMessageHandler handler;
  DWORD platform_thread = GetCurrentThreadId();
  void Send(const std::string&, const uint8_t*, size_t,
            flutter::BinaryReply) const override {
    throw std::logic_error("Unexpected outbound method");
  }
  void SetMessageHandler(const std::string& name,
                         flutter::BinaryMessageHandler value) override {
    Require(name == "jlpt_learning_app/learning_audio", "Wrong channel name");
    handler = std::move(value);
  }
  std::shared_ptr<Response> Invoke(const std::string& method, Value args = {}) {
    Require(static_cast<bool>(handler), "Channel not registered");
    auto response = std::make_shared<Response>();
    const auto& codec = flutter::StandardMethodCodec::GetInstance();
    auto bytes = codec.EncodeMethodCall(flutter::MethodCall<Value>(
        method, std::make_unique<Value>(std::move(args))));
    handler(
        bytes->data(), bytes->size(),
        [this, response](const uint8_t* reply, size_t size) {
          Require(GetCurrentThreadId() == platform_thread,
                  "Reply on wrong thread");
          Require(++response->count == 1, "Duplicate reply");
          if (size == 0) {
            response->missing = true;
            return;
          }
          flutter::MethodResultFunctions<Value> result(
              [&](const Value* value) {
                Require(value && std::holds_alternative<std::string>(*value),
                        "Non-string native result");
                response->status = std::get<std::string>(*value);
              },
              [&](const std::string& code, const std::string&, const Value*) {
                response->error = code;
              },
              [&] { response->missing = true; });
          Require(flutter::StandardMethodCodec::GetInstance()
                      .DecodeAndProcessResponseEnvelope(reply, size, &result),
                  "Malformed native response");
        });
    return response;
  }
};

Value Request(const std::string& text = "にほんご",
              const std::string& language = "ja-JP") {
  return Value(flutter::EncodableMap{{Value("text"), Value(text)},
                                     {Value("languageTag"), Value(language)}});
}

void PumpUntil(const std::shared_ptr<Response>& response) {
  const auto deadline = std::chrono::steady_clock::now() + 20s;
  while (!response->count && std::chrono::steady_clock::now() < deadline) {
    MSG message;
    while (PeekMessage(&message, nullptr, 0, 0, PM_REMOVE)) {
      TranslateMessage(&message);
      DispatchMessage(&message);
    }
    MsgWaitForMultipleObjects(0, nullptr, false, 10, QS_ALLINPUT);
  }
  Require(response->count == 1, "Channel response timeout");
}

void ChannelLifecycle() {
  for (int round = 0; round < 6; ++round) {
    TestMessenger messenger;
    auto channel = std::make_unique<LearningAudioChannel>(&messenger);
    auto capability = messenger.Invoke("getCapability");
    PumpUntil(capability);
    Require(capability->status == "available",
            "Channel capability unavailable");
    for (const Value& args : {Value(), Value("bad"), Request("", "ja-JP"),
                              Request("にほんご", "en-US"), Request("\xFF")}) {
      auto response = messenger.Invoke("play", args);
      Require(response->count == 1 && response->error == "invalid_arguments",
              "Malformed request did not retain protocol error semantics");
    }
    auto invalid_capability = messenger.Invoke("getCapability", Value(1));
    Require(invalid_capability->error == "invalid_arguments",
            "Invalid args accepted");
    Require(messenger.Invoke("unknown")->missing,
            "Unknown method was accepted");
    for (int i = 0; i < 3; ++i) {
      auto response = messenger.Invoke("play", Request());
      PumpUntil(response);
      Require(response->status == "accepted", "Channel playback failed");
    }
    std::vector<std::shared_ptr<Response>> pending;
    for (int i = 0; i < 12; ++i) {
      pending.push_back(messenger.Invoke("play", Request()));
    }
    // 不 pump；驗證 teardown 會在 messenger 有效時主動排空結果。
    channel.reset();
    Require(!messenger.handler,
            "Channel remained registered after destruction");
    for (const auto& response : pending) {
      Require(response->count == 1, "Shutdown did not settle exactly once");
      Require(response->status == "accepted" || response->status == "failed",
              "Unexpected shutdown status");
    }
    std::cout
        << "channel_round=" << round
        << " platform_thread=PASS exactly_once=PASS drain=12 unregister=PASS\n";
  }
}
}  // namespace

int main() {
  std::cout << std::unitbuf;
  const auto initialized = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
  if (FAILED(initialized)) return 2;
  int result = 0;
  try {
    EngineLifecycle();
    ChannelLifecycle();
    std::cout << "production_native_lifecycle=PASS "
                 "audible_observation=NOT_VERIFIED\n";
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    result = 1;
  }
  CoUninitialize();
  return result;
}
