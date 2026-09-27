import '../../../core/database/local_store.dart';
import '../domain/startup_failure.dart';
import '../domain/startup_repository.dart';

class LocalStartupRepository implements StartupRepository {
  const LocalStartupRepository(this._store);
  final LocalStore _store;

  @override
  Future<void> initialize() async {
    try {
      await _store.initialize();
    } catch (_) {
      // 不把資料庫路徑、SQL 或原始 exception 暴露到 UI/log。
      throw const StartupFailure();
    }
  }
}
