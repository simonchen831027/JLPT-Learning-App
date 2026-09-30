import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/features/content/domain/content_models.dart';
import 'package:jlpt_learning_app/features/practice/domain/practice_failure.dart';
import 'package:jlpt_learning_app/features/practice/domain/practice_models.dart';

void main() {
  final now = DateTime.utc(2026, 10, 1);
  ReadingText text(String value) => ReadingText(
    id: value,
    surface: value,
    segments: [ReadingSegment(id: value, ordinal: 0, surface: value)],
  );
  final question = QuestionContent(
    revision: ContentRevision(
      id: 'revision',
      contentId: 'logical-question',
      contentVersionId: 'version',
      kind: ContentKind.question,
      reviewStatus: ContentReviewStatus.published,
      createdBy: 'synthetic-test',
      updatedBy: 'synthetic-test',
      createdAt: now,
      updatedAt: now,
    ),
    prompt: text('prompt'),
    readingAidPolicy: ReadingAidPolicy.inherit,
    explanation: 'stored explanation',
    options: [
      QuestionOption(id: 'option-a', ordinal: 0, content: text('a')),
      QuestionOption(id: 'option-b', ordinal: 1, content: text('b')),
    ],
    correctOptionId: 'option-a',
  );
  QuizSession session({bool completed = false, DateTime? completedAt}) =>
      QuizSession(
        id: 'session',
        contextContentId: 'lesson',
        mode: QuizMode.practice,
        status: completed
            ? QuizSessionStatus.completed
            : QuizSessionStatus.inProgress,
        contentVersionId: 'version',
        questionCount: 1,
        currentOrdinal: 0,
        createdAt: now,
        startedAt: now,
        completedAt: completedAt,
      );
  final item = QuizSessionQuestion(
    id: 'snapshot',
    sessionId: 'session',
    ordinal: 0,
    question: question,
  );
  QuizAnswer answer({String revision = 'revision', bool correct = true}) =>
      QuizAnswer(
        id: 'answer',
        sessionId: 'session',
        sessionQuestionId: 'snapshot',
        questionRevisionId: revision,
        submittedOptionId: 'option-a',
        isCorrect: correct,
        submittedAt: now,
        createdAt: now,
      );

  test(
    'singleChoice uses option identity; invalid input is never incorrect',
    () {
      expect(evaluatePracticeAnswer(question, 'option-a'), isTrue);
      expect(evaluatePracticeAnswer(question, 'option-b'), isFalse);
      for (final input in [null, '', 'a']) {
        expect(
          () => evaluatePracticeAnswer(question, input),
          throwsA(isA<PracticeFailure>()),
        );
      }
    },
  );
  test('completion timestamps must agree with lifecycle', () {
    expect(() => session(completed: true), throwsA(isA<PracticeFailure>()));
    expect(() => session(completedAt: now), throwsA(isA<PracticeFailure>()));
  });
  test('inconsistent snapshots and false correctness cannot become Result', () {
    for (final submitted in [
      [answer(revision: 'other-revision')],
      [answer(correct: false)],
      [answer(), answer()],
    ]) {
      expect(
        () => PracticeState(
          session: session(),
          questions: [item],
          answers: submitted,
        ),
        throwsA(isA<PracticeFailure>()),
      );
    }
    final pending = PracticeState(
      session: session(),
      questions: [item],
      answers: [answer()],
    );
    expect(pending.currentProgress, QuestionProgress.answeredAwaitingContinue);
    expect(() => PracticeResult(pending), throwsA(isA<PracticeFailure>()));
    expect(() => pending.answers.clear(), throwsUnsupportedError);
    expect(() => pending.questions.clear(), throwsUnsupportedError);
    final complete = PracticeState(
      session: session(completed: true, completedAt: now),
      questions: [item],
      answers: [answer()],
    );
    expect(PracticeResult(complete).correctCount, 1);
  });
}
