import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/core/database/local_store.dart';
import 'package:jlpt_learning_app/features/home/data/local_startup_repository.dart';
import 'package:jlpt_learning_app/features/home/domain/initialize_app.dart';
import 'package:jlpt_learning_app/features/home/domain/startup_failure.dart';
import 'package:jlpt_learning_app/features/home/presentation/home_view_model.dart';

class TestStore implements LocalStore {
  Future<void> Function() action = () async {};
  int calls = 0;
  @override
  Future<void> initialize() {
    calls++;
    return action();
  }
}

void main() {
  test(
    'repository translates raw storage errors into a safe failure',
    () async {
      final store = TestStore()
        ..action = () async => throw StateError('private path');
      await expectLater(
        LocalStartupRepository(store).initialize(),
        throwsA(isA<StartupFailure>()),
      );
    },
  );

  test('startup deduplicates loading and retries after failure', () async {
    final store = TestStore();
    final pending = Completer<void>();
    store.action = () => pending.future;
    final viewModel = HomeViewModel(
      InitializeApp(LocalStartupRepository(store)),
    );
    addTearDown(viewModel.dispose);
    final first = viewModel.initialize();
    await viewModel.initialize();
    expect(store.calls, 1);
    expect(viewModel.status, StartupStatus.loading);
    pending.completeError(StateError('private path'));
    await first;
    expect(viewModel.status, StartupStatus.failed);
    expect(viewModel.errorMessage, isNot(contains('private path')));
    store.action = () async {};
    await viewModel.initialize();
    expect(store.calls, 2);
    expect(viewModel.status, StartupStatus.ready);
  });

  test('completion after disposal does not notify listeners', () async {
    final pending = Completer<void>();
    final store = TestStore()..action = () => pending.future;
    final viewModel = HomeViewModel(
      InitializeApp(LocalStartupRepository(store)),
    );
    final loading = viewModel.initialize();
    viewModel.dispose();
    pending.complete();
    await loading;
  });
}
