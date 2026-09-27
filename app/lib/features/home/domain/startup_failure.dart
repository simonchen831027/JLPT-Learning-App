class StartupFailure implements Exception {
  const StartupFailure();
  String get message => '無法開啟本機資料。請重試；若問題持續，請保留資料並回報問題。';
}
