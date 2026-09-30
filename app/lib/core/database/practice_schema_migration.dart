import 'schema_migration.dart';

/// CR-0004 User Learning State; Content Data remains owned by migration v2.
final practiceSchemaMigration = SchemaMigration(
  version: 3,
  name: 'phase_1_practice_user_state',
  statements: [
    '''CREATE TABLE quiz_sessions (
      id TEXT PRIMARY KEY NOT NULL,
      context_content_id TEXT NOT NULL REFERENCES content_items(id),
      mode TEXT NOT NULL CHECK (mode IN ('practice', 'review')),
      status TEXT NOT NULL CHECK (status IN ('in_progress', 'completed')),
      content_version_id TEXT NOT NULL REFERENCES content_versions(id),
      question_count INTEGER NOT NULL CHECK (question_count > 0),
      current_ordinal INTEGER NOT NULL CHECK (
        current_ordinal >= 0 AND current_ordinal < question_count),
      created_at TEXT NOT NULL CHECK (
        substr(created_at, -1) = 'Z' AND julianday(created_at) IS NOT NULL),
      started_at TEXT NOT NULL CHECK (
        substr(started_at, -1) = 'Z' AND julianday(started_at) IS NOT NULL),
      completed_at TEXT CHECK (
        completed_at IS NULL OR
        (substr(completed_at, -1) = 'Z' AND julianday(completed_at) IS NOT NULL)),
      CHECK ((status = 'in_progress' AND completed_at IS NULL) OR
             (status = 'completed' AND completed_at IS NOT NULL))
    )''',
    '''CREATE UNIQUE INDEX one_active_quiz_session
      ON quiz_sessions(context_content_id, mode)
      WHERE status = 'in_progress' ''',
    '''CREATE TABLE quiz_session_questions (
      id TEXT PRIMARY KEY NOT NULL,
      session_id TEXT NOT NULL REFERENCES quiz_sessions(id) ON DELETE CASCADE,
      question_revision_id TEXT NOT NULL REFERENCES questions(revision_id),
      ordinal INTEGER NOT NULL CHECK (ordinal >= 0),
      UNIQUE (session_id, ordinal),
      UNIQUE (session_id, question_revision_id),
      UNIQUE (session_id, id, question_revision_id)
    )''',
    '''CREATE TABLE quiz_answers (
      id TEXT PRIMARY KEY NOT NULL,
      session_id TEXT NOT NULL,
      session_question_id TEXT NOT NULL,
      question_revision_id TEXT NOT NULL,
      submitted_option_id TEXT NOT NULL,
      is_correct INTEGER NOT NULL CHECK (is_correct IN (0, 1)),
      submitted_at TEXT NOT NULL CHECK (
        substr(submitted_at, -1) = 'Z' AND julianday(submitted_at) IS NOT NULL),
      created_at TEXT NOT NULL CHECK (
        substr(created_at, -1) = 'Z' AND julianday(created_at) IS NOT NULL),
      UNIQUE (session_id, session_question_id),
      FOREIGN KEY (session_id, session_question_id, question_revision_id)
        REFERENCES quiz_session_questions(session_id, id, question_revision_id)
        ON DELETE CASCADE,
      FOREIGN KEY (question_revision_id, submitted_option_id)
        REFERENCES question_options(question_revision_id, id)
    )''',
    '''CREATE TRIGGER require_new_quiz_session
      BEFORE INSERT ON quiz_sessions
      WHEN NEW.status != 'in_progress' OR NEW.current_ordinal != 0
        OR NOT EXISTS (SELECT 1 FROM content_items
          WHERE id = NEW.context_content_id AND kind = 'lesson')
      BEGIN SELECT RAISE(ABORT, 'Invalid new quiz session'); END''',
    '''CREATE TRIGGER freeze_quiz_session_snapshot_metadata
      BEFORE UPDATE ON quiz_sessions
      WHEN NEW.id != OLD.id OR NEW.context_content_id != OLD.context_content_id
        OR NEW.mode != OLD.mode OR NEW.content_version_id != OLD.content_version_id
        OR NEW.question_count != OLD.question_count
        OR NEW.created_at != OLD.created_at OR NEW.started_at != OLD.started_at
        OR (OLD.status = 'completed' AND (
          NEW.status != OLD.status OR NEW.completed_at IS NOT OLD.completed_at
          OR NEW.current_ordinal != OLD.current_ordinal))
      BEGIN SELECT RAISE(ABORT, 'Quiz session evidence is immutable'); END''',
    '''CREATE TRIGGER require_durable_quiz_continue
      BEFORE UPDATE OF current_ordinal ON quiz_sessions
      WHEN NEW.current_ordinal != OLD.current_ordinal AND (
        OLD.status != 'in_progress' OR NEW.status != 'in_progress'
        OR NEW.current_ordinal != OLD.current_ordinal + 1
        OR NOT EXISTS (
          SELECT 1 FROM quiz_session_questions q JOIN quiz_answers a
            ON a.session_id = q.session_id AND a.session_question_id = q.id
          WHERE q.session_id = OLD.id AND q.ordinal = OLD.current_ordinal))
      BEGIN SELECT RAISE(ABORT, 'Continue requires a durable answer'); END''',
    '''CREATE TRIGGER require_complete_quiz_evidence
      BEFORE UPDATE OF status ON quiz_sessions
      WHEN NEW.status = 'completed' AND (
        NEW.current_ordinal != NEW.question_count - 1
        OR (SELECT COUNT(*) FROM quiz_session_questions
          WHERE session_id = NEW.id) != NEW.question_count
        OR (SELECT COUNT(*) FROM quiz_answers
          WHERE session_id = NEW.id) != NEW.question_count)
      BEGIN SELECT RAISE(ABORT, 'Completion requires the complete snapshot and answers'); END''',
    '''CREATE TRIGGER validate_quiz_snapshot_insert
      BEFORE INSERT ON quiz_session_questions
      WHEN NOT EXISTS (
        SELECT 1 FROM quiz_sessions s JOIN content_revisions r
          ON r.id = NEW.question_revision_id
        WHERE s.id = NEW.session_id AND s.status = 'in_progress'
          AND s.current_ordinal = 0 AND NEW.ordinal < s.question_count
          AND r.content_version_id = s.content_version_id
          AND r.review_status = 'published'
          AND NOT EXISTS (SELECT 1 FROM quiz_answers WHERE session_id = s.id))
      BEGIN SELECT RAISE(ABORT, 'Invalid frozen question snapshot'); END''',
    '''CREATE TRIGGER freeze_quiz_question_update
      BEFORE UPDATE ON quiz_session_questions
      BEGIN SELECT RAISE(ABORT, 'Quiz question snapshot is immutable'); END''',
    '''CREATE TRIGGER protect_quiz_question_delete
      BEFORE DELETE ON quiz_session_questions
      WHEN EXISTS (SELECT 1 FROM quiz_sessions WHERE id = OLD.session_id)
      BEGIN SELECT RAISE(ABORT, 'Delete quiz records through their session'); END''',
    '''CREATE TRIGGER validate_quiz_answer_insert
      BEFORE INSERT ON quiz_answers
      WHEN NOT EXISTS (
        SELECT 1 FROM quiz_sessions s JOIN quiz_session_questions q
          ON q.session_id = s.id JOIN questions c
          ON c.revision_id = q.question_revision_id
        WHERE s.id = NEW.session_id AND s.status = 'in_progress'
          AND q.id = NEW.session_question_id
          AND q.question_revision_id = NEW.question_revision_id
          AND q.ordinal = s.current_ordinal
          AND NEW.is_correct = (NEW.submitted_option_id = c.correct_option_id)
          AND (SELECT COUNT(*) FROM quiz_session_questions
            WHERE session_id = s.id) = s.question_count)
      BEGIN SELECT RAISE(ABORT, 'Invalid submitted answer evidence'); END''',
    '''CREATE TRIGGER freeze_quiz_answer_update
      BEFORE UPDATE ON quiz_answers
      BEGIN SELECT RAISE(ABORT, 'Submitted answer is immutable'); END''',
    '''CREATE TRIGGER protect_quiz_answer_delete
      BEFORE DELETE ON quiz_answers
      WHEN EXISTS (SELECT 1 FROM quiz_sessions WHERE id = OLD.session_id)
      BEGIN SELECT RAISE(ABORT, 'Delete quiz records through their session'); END''',
  ],
);
