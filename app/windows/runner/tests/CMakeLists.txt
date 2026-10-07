cmake_minimum_required(VERSION 3.14)
project(learning_audio_native_tests LANGUAGES CXX)

# 獨立 Windows／日語 voice 診斷 target；不加入一般跨平台 Unit CI。
set(WRAPPER "${CMAKE_CURRENT_SOURCE_DIR}/../../flutter/ephemeral/cpp_client_wrapper")
add_executable(learning_audio_native_tests
  learning_audio_native_tests.cpp
  ../learning_audio_engine.cpp
  ../learning_audio_channel.cpp
  "${WRAPPER}/standard_codec.cc"
  "${WRAPPER}/core_implementations.cc"
)
target_include_directories(learning_audio_native_tests PRIVATE
  .. "${WRAPPER}/include" "${WRAPPER}/..")
target_compile_features(learning_audio_native_tests PRIVATE cxx_std_20)
target_compile_definitions(learning_audio_native_tests PRIVATE
  UNICODE _UNICODE NOMINMAX _HAS_EXCEPTIONS=1 LEARNING_AUDIO_TESTING)
target_compile_options(learning_audio_native_tests PRIVATE /W4 /WX /utf-8 /EHsc)
target_link_libraries(learning_audio_native_tests PRIVATE
  windowsapp runtimeobject user32 "${WRAPPER}/../flutter_windows.dll.lib")
add_custom_command(TARGET learning_audio_native_tests POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "${WRAPPER}/../flutter_windows.dll" "$<TARGET_FILE_DIR:learning_audio_native_tests>")

option(LEARNING_AUDIO_ASAN "Enable MSVC AddressSanitizer diagnostics" OFF)
if(LEARNING_AUDIO_ASAN)
  target_compile_options(learning_audio_native_tests PRIVATE /fsanitize=address /Zi)
  target_link_options(learning_audio_native_tests PRIVATE /DEBUG /INCREMENTAL:NO)
endif()
