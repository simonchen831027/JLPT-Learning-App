import 'package:sqflite_common/sqlite_api.dart';

import '../../../core/database/persistence_values.dart';
import '../../../core/identity/entity_id_generator.dart';
import '../../content/data/b0_content_ids.dart';
import '../../content/data/sqlite_content_repository.dart';
import '../../content/domain/content_models.dart';
import '../domain/practice_failure.dart';
import '../domain/practice_models.dart';
import '../domain/practice_repository.dart';

/// All reads and transitions use coherent SQLite transactions. The only
/// current curriculum mapping is the approved L01/B0 manifest.
final class SqlitePracticeRepository implements PracticeRepository {
  SqlitePracticeRepository(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final Database _database;
  final EntityIdGenerator _ids = const EntityIdGenerator();
  final DateTime Function() _now;

  Future<T> _transaction<T>(Future<T> Function(Transaction tx) action) async {
    // FFI connections can report SQLITE_BUSY instead of waiting for another
    // writer. Yield between bounded retries so its transaction can finish.
    const delays = [10, 25, 50, 100, 200];
    for (var attempt = 0; ; attempt++) {
      try {
        return await _database.transaction(action);
      } on DatabaseException catch (error) {
        final code = error.getResultCode();
        final primaryCode = code == null ? null : code & 0xff;
        if ((primaryCode != 5 && primaryCode != 6) ||
            attempt == delays.length) {
          rethrow;
        }
        await Future<void>.delayed(Duration(milliseconds: delays[attempt]));
      }
    }
  }

  Future<T> _run<T>(Future<T> Function(Transaction tx) action) async {
    try {
      return await _transaction(action);
    } on DatabaseException {
      throw const PracticeFailure(PracticeFailureReason.persistence);
    }
  }

  @override
  Future<PracticeState> startOrResume(
    String contextContentId,
    QuizMode mode,
  ) async {
    if (contextContentId != B0ContentIds.lesson) {
      throw const PracticeFailure(PracticeFailureReason.unknownContext);
    }
    try {
      return await _transaction((tx) async {
        final active = await _activeId(tx, contextContentId, mode);
        // Resolve active context before touching current content. A withdrawn
        // or superseded release cannot replace an existing session snapshot.
        if (active != null) return _load(tx, active);
        final content = SqliteContentRepository(tx);
        final version = await content.currentVersion();
        final lesson = await content.currentPublishedByContentId(
          contextContentId,
        );
        if (version == null ||
            lesson is! LessonContent ||
            lesson.revision.contentVersionId != version.id) {
          throw const PracticeFailure(PracticeFailureReason.contentUnavailable);
        }
        final questions = <QuestionContent>[];
        for (final logicalId in B0ContentIds.questions) {
          final question = await content.currentPublishedByContentId(logicalId);
          if (question is! QuestionContent ||
              question.revision.contentVersionId != version.id) {
            throw const PracticeFailure(
              PracticeFailureReason.contentUnavailable,
            );
          }
          questions.add(question);
        }
        final sessionId = _ids.generate();
        final at = PersistenceValues.encodeInstant(_now());
        await tx.insert('quiz_sessions', {
          'id': sessionId,
          'context_content_id': contextContentId,
          'mode': mode.name,
          'status': 'in_progress',
          'content_version_id': version.id,
          'question_count': questions.length,
          'current_ordinal': 0,
          'created_at': at,
          'started_at': at,
        });
        for (var index = 0; index < questions.length; index++) {
          await tx.insert('quiz_session_questions', {
            'id': _ids.generate(),
            'session_id': sessionId,
            'question_revision_id': questions[index].revision.id,
            'ordinal': index,
          });
        }
        return _load(tx, sessionId);
      });
    } on DatabaseException {
      // The unique index is authoritative even for different repository /
      // database connections. After a constraint race, return the winner.
      return _run((tx) async {
        final active = await _activeId(tx, contextContentId, mode);
        if (active == null) {
          throw const PracticeFailure(PracticeFailureReason.persistence);
        }
        return _load(tx, active);
      });
    }
  }

  Future<String?> _activeId(
    DatabaseExecutor tx,
    String context,
    QuizMode mode,
  ) async {
    final rows = await tx.query(
      'quiz_sessions',
      columns: ['id'],
      where: "context_content_id = ? AND mode = ? AND status = 'in_progress'",
      whereArgs: [context, mode.name],
    );
    return rows.isEmpty ? null : rows.single['id']! as String;
  }

  @override
  Future<PracticeState> getSession(String sessionId) =>
      _run((tx) => _load(tx, sessionId));

  @override
  Future<QuizAnswer> submitAnswer(
    String sessionId,
    String sessionQuestionId,
    String? optionId,
  ) async {
    if (optionId == null || optionId.isEmpty) {
      throw const PracticeFailure(PracticeFailureReason.missingSelection);
    }
    return _run((tx) async {
      final state = await _load(tx, sessionId);
      final item = _question(state, sessionQuestionId);
      final existing = state.answerFor(sessionQuestionId);
      if (existing != null) {
        if (existing.submittedOptionId != optionId) {
          throw const PracticeFailure(PracticeFailureReason.conflictingAnswer);
        }
        return existing;
      }
      _requireActive(state);
      if (item.ordinal != state.session.currentOrdinal) {
        throw const PracticeFailure(PracticeFailureReason.outOfOrder);
      }
      final correct = evaluatePracticeAnswer(item.question, optionId);
      final now = _now().toUtc();
      final answer = QuizAnswer(
        id: _ids.generate(),
        sessionId: sessionId,
        sessionQuestionId: sessionQuestionId,
        questionRevisionId: item.question.revision.id,
        submittedOptionId: optionId,
        isCorrect: correct,
        submittedAt: now,
        createdAt: now,
      );
      await tx.insert('quiz_answers', {
        'id': answer.id,
        'session_id': answer.sessionId,
        'session_question_id': answer.sessionQuestionId,
        'question_revision_id': answer.questionRevisionId,
        'submitted_option_id': answer.submittedOptionId,
        'is_correct': answer.isCorrect ? 1 : 0,
        'submitted_at': PersistenceValues.encodeInstant(answer.submittedAt),
        'created_at': PersistenceValues.encodeInstant(answer.createdAt),
      });
      // At the persisted current ordinal, a durable answer means awaiting
      // Continue. It never advances that ordinal or completes the session.
      return answer;
    });
  }

  @override
  Future<PracticeState> continueQuestion(
    String sessionId,
    String sessionQuestionId,
  ) => _run((tx) async {
    final state = await _load(tx, sessionId);
    final item = _question(state, sessionQuestionId);
    _requireActive(state);
    // A retry carries the original question identity and cannot advance twice.
    if (item.ordinal < state.session.currentOrdinal) return state;
    if (item.ordinal != state.session.currentOrdinal) {
      throw const PracticeFailure(PracticeFailureReason.outOfOrder);
    }
    if (state.answerFor(item.id) == null) {
      throw const PracticeFailure(PracticeFailureReason.incompleteSession);
    }
    if (item.ordinal == state.questions.length - 1) {
      throw const PracticeFailure(PracticeFailureReason.completionRequired);
    }
    await tx.update(
      'quiz_sessions',
      {'current_ordinal': item.ordinal + 1},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    return _load(tx, sessionId);
  });

  @override
  Future<PracticeState> completeSession(String sessionId) => _run((tx) async {
    final state = await _load(tx, sessionId);
    if (state.session.status == QuizSessionStatus.completed) return state;
    if (state.answers.length != state.questions.length ||
        state.session.currentOrdinal != state.questions.length - 1) {
      throw const PracticeFailure(PracticeFailureReason.incompleteSession);
    }
    await tx.update(
      'quiz_sessions',
      {
        'status': 'completed',
        'completed_at': PersistenceValues.encodeInstant(_now()),
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    return _load(tx, sessionId);
  });

  @override
  Future<PracticeResult> getResult(String sessionId) =>
      _run((tx) async => PracticeResult(await _load(tx, sessionId)));

  void _requireActive(PracticeState state) {
    if (state.session.status != QuizSessionStatus.inProgress) {
      throw const PracticeFailure(PracticeFailureReason.invalidState);
    }
  }

  QuizSessionQuestion _question(PracticeState state, String id) {
    final found = state.questions.where((item) => item.id == id);
    if (found.isEmpty) {
      throw const PracticeFailure(PracticeFailureReason.questionNotFound);
    }
    return found.single;
  }

  Future<PracticeState> _load(DatabaseExecutor tx, String sessionId) async {
    final rows = await tx.query(
      'quiz_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    if (rows.isEmpty) {
      throw const PracticeFailure(PracticeFailureReason.sessionNotFound);
    }
    final row = rows.single;
    final session = QuizSession(
      id: row['id']! as String,
      contextContentId: row['context_content_id']! as String,
      mode: QuizMode.values.byName(row['mode']! as String),
      status: row['status'] == 'completed'
          ? QuizSessionStatus.completed
          : QuizSessionStatus.inProgress,
      contentVersionId: row['content_version_id']! as String,
      questionCount: row['question_count']! as int,
      currentOrdinal: row['current_ordinal']! as int,
      createdAt: PersistenceValues.decodeInstant(row['created_at']! as String),
      startedAt: PersistenceValues.decodeInstant(row['started_at']! as String),
      completedAt: row['completed_at'] == null
          ? null
          : PersistenceValues.decodeInstant(row['completed_at']! as String),
    );
    final snapshot = await tx.query(
      'quiz_session_questions',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'ordinal',
    );
    final content = SqliteContentRepository(tx);
    final questions = <QuizSessionQuestion>[];
    for (final item in snapshot) {
      final question = await content.getRevision(
        item['question_revision_id']! as String,
      );
      if (question is! QuestionContent) {
        throw const PracticeFailure(PracticeFailureReason.invalidState);
      }
      questions.add(
        QuizSessionQuestion(
          id: item['id']! as String,
          sessionId: sessionId,
          ordinal: item['ordinal']! as int,
          question: question,
        ),
      );
    }
    final answers = await tx.rawQuery(
      '''SELECT a.* FROM quiz_answers a
         JOIN quiz_session_questions q ON q.session_id = a.session_id
           AND q.id = a.session_question_id
         WHERE a.session_id = ? ORDER BY q.ordinal''',
      [sessionId],
    );
    return PracticeState(
      session: session,
      questions: questions,
      answers: [
        for (final answer in answers)
          QuizAnswer(
            id: answer['id']! as String,
            sessionId: sessionId,
            sessionQuestionId: answer['session_question_id']! as String,
            questionRevisionId: answer['question_revision_id']! as String,
            submittedOptionId: answer['submitted_option_id']! as String,
            isCorrect: answer['is_correct'] == 1,
            submittedAt: PersistenceValues.decodeInstant(
              answer['submitted_at']! as String,
            ),
            createdAt: PersistenceValues.decodeInstant(
              answer['created_at']! as String,
            ),
          ),
      ],
    );
  }
}
