import '../../../core/database/local_store.dart';
import '../domain/startup_failure.dart';
import '../domain/startup_repository.dart';

class LocalStartupRepository implements StartupRepository {
  const LocalStartupRepository(this._store, {this.afterInitialize});
  final LocalStore _store;
  final Future<void> Function()? afterInitialize;

  @override
  Future<void> initialize() async {
    try {
      await _store.initialize();
      await afterInitialize?.call();
    } catch (_) {
      // 不把資料庫路徑、SQL 或原始 exception 暴露到 UI/log。
      throw const StartupFailure();
    }
  }
}
