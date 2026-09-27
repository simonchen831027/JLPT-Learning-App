import 'startup_repository.dart';

class InitializeApp {
  const InitializeApp(this._repository);
  final StartupRepository _repository;
  Future<void> call() => _repository.initialize();
}
