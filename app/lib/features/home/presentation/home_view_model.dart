import 'package:flutter/foundation.dart';

import '../domain/initialize_app.dart';
import '../domain/startup_failure.dart';

enum StartupStatus { loading, ready, failed }

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._initializeApp);
  final InitializeApp _initializeApp;
  StartupStatus _status = StartupStatus.loading;
  bool _inFlight = false;
  bool _disposed = false;

  StartupStatus get status => _status;
  String get errorMessage => const StartupFailure().message;

  Future<void> initialize() async {
    if (_inFlight || _disposed) return;
    _inFlight = true;
    _status = StartupStatus.loading;
    notifyListeners();
    try {
      await _initializeApp();
      if (!_disposed) _status = StartupStatus.ready;
    } catch (_) {
      if (!_disposed) _status = StartupStatus.failed;
    } finally {
      _inFlight = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
