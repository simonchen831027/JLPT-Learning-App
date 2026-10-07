#ifndef RUNNER_LEARNING_AUDIO_CHANNEL_H_
#define RUNNER_LEARNING_AUDIO_CHANNEL_H_

#include <flutter/binary_messenger.h>

#include <memory>

// 必須在 Flutter platform thread 建立／銷毀，且早於 messenger 銷毀。
class LearningAudioChannel {
 public:
  explicit LearningAudioChannel(flutter::BinaryMessenger* messenger);
  ~LearningAudioChannel();
  LearningAudioChannel(const LearningAudioChannel&) = delete;
  LearningAudioChannel& operator=(const LearningAudioChannel&) = delete;

 private:
  struct Impl;
  std::unique_ptr<Impl> impl_;
};

#endif  // RUNNER_LEARNING_AUDIO_CHANNEL_H_
