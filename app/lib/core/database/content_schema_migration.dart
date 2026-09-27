import 'schema_migration.dart';

final contentSchemaMigration = SchemaMigration(
  version: 2,
  name: 'phase_1_content_data',
  statements: [
    '''CREATE TABLE content_versions (
      id TEXT PRIMARY KEY NOT NULL,
      label TEXT NOT NULL UNIQUE,
      is_current INTEGER NOT NULL DEFAULT 0 CHECK (is_current IN (0, 1)),
      created_at TEXT NOT NULL
    )''',
    '''CREATE UNIQUE INDEX one_current_content_version
      ON content_versions(is_current) WHERE is_current = 1''',
    '''CREATE TABLE content_items (
      id TEXT PRIMARY KEY NOT NULL,
      kind TEXT NOT NULL CHECK (kind IN (
        'lesson', 'vocabulary', 'grammar', 'kanji', 'kana',
        'exampleSentence', 'question'
      ))
    )''',
    '''CREATE TABLE content_revisions (
      id TEXT PRIMARY KEY NOT NULL,
      content_id TEXT NOT NULL REFERENCES content_items(id),
      content_version_id TEXT NOT NULL REFERENCES content_versions(id),
      review_status TEXT NOT NULL CHECK (review_status IN (
        'draft', 'reviewed', 'published', 'withdrawn'
      )),
      created_by TEXT NOT NULL CHECK (length(trim(created_by)) > 0),
      updated_by TEXT NOT NULL CHECK (length(trim(updated_by)) > 0),
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      UNIQUE (content_id, content_version_id)
    )''',
    '''CREATE INDEX content_revisions_by_version
      ON content_revisions(content_version_id, review_status)''',
    '''CREATE TABLE source_references (
      id TEXT PRIMARY KEY NOT NULL,
      source_name TEXT NOT NULL CHECK (length(trim(source_name)) > 0),
      source_url TEXT,
      source_title TEXT,
      topic TEXT,
      reference_level TEXT,
      accessed_at TEXT,
      content_usage_status TEXT NOT NULL CHECK (content_usage_status IN (
        'reference-only', 'original-content', 'licensed',
        'needs-review', 'blocked'
      )),
      review_status TEXT NOT NULL CHECK (review_status IN (
        'pending', 'approved', 'rejected'
      )),
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      note TEXT
    )''',
    '''CREATE TABLE content_revision_sources (
      revision_id TEXT NOT NULL REFERENCES content_revisions(id),
      source_id TEXT NOT NULL REFERENCES source_references(id),
      PRIMARY KEY (revision_id, source_id)
    ) WITHOUT ROWID''',
    '''CREATE INDEX content_revision_sources_by_source
      ON content_revision_sources(source_id)''',
    '''CREATE TABLE reading_texts (
      id TEXT PRIMARY KEY NOT NULL,
      owner_revision_id TEXT NOT NULL REFERENCES content_revisions(id),
      field_ordinal INTEGER NOT NULL CHECK (field_ordinal >= 0),
      surface TEXT NOT NULL,
      UNIQUE (owner_revision_id, field_ordinal)
    )''',
    '''CREATE TABLE reading_segments (
      id TEXT PRIMARY KEY NOT NULL,
      reading_text_id TEXT NOT NULL REFERENCES reading_texts(id),
      ordinal INTEGER NOT NULL CHECK (ordinal >= 0),
      surface TEXT NOT NULL CHECK (length(surface) > 0),
      reading TEXT,
      UNIQUE (reading_text_id, ordinal)
    )''',
    '''CREATE TABLE lessons (
      revision_id TEXT PRIMARY KEY NOT NULL REFERENCES content_revisions(id),
      title_reading_text_id TEXT NOT NULL REFERENCES reading_texts(id)
    )''',
    '''CREATE TABLE lesson_sections (
      id TEXT PRIMARY KEY NOT NULL,
      lesson_revision_id TEXT NOT NULL REFERENCES lessons(revision_id),
      ordinal INTEGER NOT NULL CHECK (ordinal >= 0),
      title_reading_text_id TEXT NOT NULL REFERENCES reading_texts(id),
      body_reading_text_id TEXT NOT NULL REFERENCES reading_texts(id),
      UNIQUE (lesson_revision_id, ordinal)
    )''',
    '''CREATE TABLE vocabulary (
      revision_id TEXT PRIMARY KEY NOT NULL REFERENCES content_revisions(id),
      written_reading_text_id TEXT NOT NULL REFERENCES reading_texts(id),
      meaning TEXT NOT NULL
    )''',
    '''CREATE TABLE grammar (
      revision_id TEXT PRIMARY KEY NOT NULL REFERENCES content_revisions(id),
      pattern_reading_text_id TEXT NOT NULL REFERENCES reading_texts(id),
      explanation TEXT NOT NULL
    )''',
    '''CREATE TABLE kanji (
      revision_id TEXT PRIMARY KEY NOT NULL REFERENCES content_revisions(id),
      character TEXT NOT NULL,
      contextual_reading_text_id TEXT NOT NULL REFERENCES reading_texts(id),
      meaning TEXT NOT NULL
    )''',
    '''CREATE TABLE kana_content (
      revision_id TEXT PRIMARY KEY NOT NULL REFERENCES content_revisions(id),
      script_type TEXT NOT NULL CHECK (script_type IN ('hiragana', 'katakana')),
      written_kana TEXT NOT NULL CHECK (length(written_kana) > 0),
      pronunciation TEXT NOT NULL CHECK (length(pronunciation) > 0),
      reading_reference TEXT NOT NULL CHECK (length(reading_reference) > 0),
      learning_available INTEGER NOT NULL CHECK (learning_available IN (0, 1)),
      practice_available INTEGER NOT NULL CHECK (practice_available IN (0, 1))
    )''',
    '''CREATE TABLE example_sentences (
      revision_id TEXT PRIMARY KEY NOT NULL REFERENCES content_revisions(id),
      sentence_reading_text_id TEXT NOT NULL REFERENCES reading_texts(id),
      translation TEXT NOT NULL
    )''',
    '''CREATE TABLE questions (
      revision_id TEXT PRIMARY KEY NOT NULL REFERENCES content_revisions(id),
      prompt_reading_text_id TEXT NOT NULL REFERENCES reading_texts(id),
      answer_mode TEXT NOT NULL CHECK (answer_mode = 'singleChoice'),
      reading_aid_policy TEXT NOT NULL CHECK (reading_aid_policy IN (
        'inherit', 'show', 'hide'
      )),
      explanation TEXT NOT NULL CHECK (length(trim(explanation)) > 0),
      correct_option_id TEXT NOT NULL,
      FOREIGN KEY (revision_id, correct_option_id)
        REFERENCES question_options(question_revision_id, id)
        DEFERRABLE INITIALLY DEFERRED
    )''',
    '''CREATE TABLE question_options (
      id TEXT PRIMARY KEY NOT NULL,
      question_revision_id TEXT NOT NULL REFERENCES questions(revision_id)
        DEFERRABLE INITIALLY DEFERRED,
      ordinal INTEGER NOT NULL CHECK (ordinal >= 0),
      content_reading_text_id TEXT NOT NULL REFERENCES reading_texts(id),
      UNIQUE (question_revision_id, id),
      UNIQUE (question_revision_id, ordinal)
    )''',
    '''CREATE TRIGGER protect_published_revision_update
      BEFORE UPDATE ON content_revisions
      WHEN OLD.review_status IN ('published', 'withdrawn') AND (
        NEW.id != OLD.id OR NEW.content_id != OLD.content_id OR
        NEW.content_version_id != OLD.content_version_id OR
        NEW.created_by != OLD.created_by OR NEW.created_at != OLD.created_at OR
        NEW.review_status NOT IN ('published', 'withdrawn')
      )
      BEGIN SELECT RAISE(ABORT, 'Published revision is immutable'); END''',
    '''CREATE TRIGGER require_draft_revision_insert
      BEFORE INSERT ON content_revisions
      WHEN NEW.review_status != 'draft'
      BEGIN SELECT RAISE(ABORT, 'New revision must be a draft'); END''',
    '''CREATE TRIGGER enforce_review_transition
      BEFORE UPDATE OF review_status ON content_revisions
      WHEN NEW.review_status != OLD.review_status AND NOT (
        (OLD.review_status = 'draft' AND NEW.review_status = 'reviewed') OR
        (OLD.review_status = 'reviewed' AND NEW.review_status = 'published') OR
        (OLD.review_status = 'published' AND NEW.review_status = 'withdrawn')
      )
      BEGIN SELECT RAISE(ABORT, 'Invalid content review transition'); END''',
    '''CREATE TRIGGER protect_published_revision_delete
      BEFORE DELETE ON content_revisions
      WHEN OLD.review_status IN ('published', 'withdrawn')
      BEGIN SELECT RAISE(ABORT, 'Published revision cannot be deleted'); END''',
    '''CREATE TRIGGER require_published_provenance
      BEFORE UPDATE OF review_status ON content_revisions
      WHEN NEW.review_status = 'published' AND (
        NOT EXISTS (
          SELECT 1 FROM content_revision_sources WHERE revision_id = NEW.id
        ) OR EXISTS (
          SELECT 1 FROM content_revision_sources s
          LEFT JOIN source_references r ON r.id = s.source_id
          WHERE s.revision_id = NEW.id AND (
            r.id IS NULL OR r.review_status != 'approved' OR
            r.content_usage_status IN ('needs-review', 'blocked')
          )
        )
      )
      BEGIN SELECT RAISE(ABORT, 'Published revision needs approved provenance'); END''',
    for (final (table, ownerColumn) in [
      ('lessons', 'revision_id'),
      ('lesson_sections', 'lesson_revision_id'),
      ('vocabulary', 'revision_id'),
      ('grammar', 'revision_id'),
      ('kanji', 'revision_id'),
      ('kana_content', 'revision_id'),
      ('example_sentences', 'revision_id'),
      ('questions', 'revision_id'),
      ('question_options', 'question_revision_id'),
      ('reading_texts', 'owner_revision_id'),
    ]) ...[
      '''CREATE TRIGGER protect_${table}_insert
        BEFORE INSERT ON $table
        WHEN EXISTS (SELECT 1 FROM content_revisions
          WHERE id = NEW.$ownerColumn
            AND review_status IN ('published', 'withdrawn'))
        BEGIN SELECT RAISE(ABORT, 'Published content is immutable'); END''',
      '''CREATE TRIGGER protect_${table}_update
        BEFORE UPDATE ON $table
        WHEN EXISTS (SELECT 1 FROM content_revisions
          WHERE id IN (OLD.$ownerColumn, NEW.$ownerColumn)
            AND review_status IN ('published', 'withdrawn'))
        BEGIN SELECT RAISE(ABORT, 'Published content is immutable'); END''',
      '''CREATE TRIGGER protect_${table}_delete
        BEFORE DELETE ON $table
        WHEN EXISTS (SELECT 1 FROM content_revisions
          WHERE id = OLD.$ownerColumn
            AND review_status IN ('published', 'withdrawn'))
        BEGIN SELECT RAISE(ABORT, 'Published content is immutable'); END''',
    ],
    '''CREATE TRIGGER protect_reading_segments_insert
      BEFORE INSERT ON reading_segments
      WHEN EXISTS (SELECT 1 FROM reading_texts t
        JOIN content_revisions r ON r.id = t.owner_revision_id
        WHERE t.id = NEW.reading_text_id
          AND r.review_status IN ('published', 'withdrawn'))
      BEGIN SELECT RAISE(ABORT, 'Published reading is immutable'); END''',
    '''CREATE TRIGGER protect_reading_segments_update
      BEFORE UPDATE ON reading_segments
      WHEN EXISTS (SELECT 1 FROM reading_texts t
        JOIN content_revisions r ON r.id = t.owner_revision_id
        WHERE t.id IN (OLD.reading_text_id, NEW.reading_text_id)
          AND r.review_status IN ('published', 'withdrawn'))
      BEGIN SELECT RAISE(ABORT, 'Published reading is immutable'); END''',
    '''CREATE TRIGGER protect_reading_segments_delete
      BEFORE DELETE ON reading_segments
      WHEN EXISTS (SELECT 1 FROM reading_texts t
        JOIN content_revisions r ON r.id = t.owner_revision_id
        WHERE t.id = OLD.reading_text_id
          AND r.review_status IN ('published', 'withdrawn'))
      BEGIN SELECT RAISE(ABORT, 'Published reading is immutable'); END''',
    '''CREATE TRIGGER protect_revision_sources_insert
      BEFORE INSERT ON content_revision_sources
      WHEN EXISTS (SELECT 1 FROM content_revisions
        WHERE id = NEW.revision_id
          AND review_status IN ('published', 'withdrawn'))
      BEGIN SELECT RAISE(ABORT, 'Published provenance is immutable'); END''',
    '''CREATE TRIGGER protect_revision_sources_update
      BEFORE UPDATE ON content_revision_sources
      WHEN EXISTS (SELECT 1 FROM content_revisions
        WHERE id IN (OLD.revision_id, NEW.revision_id)
          AND review_status IN ('published', 'withdrawn'))
      BEGIN SELECT RAISE(ABORT, 'Published provenance is immutable'); END''',
    '''CREATE TRIGGER protect_revision_sources_delete
      BEFORE DELETE ON content_revision_sources
      WHEN EXISTS (SELECT 1 FROM content_revisions
        WHERE id = OLD.revision_id
          AND review_status IN ('published', 'withdrawn'))
      BEGIN SELECT RAISE(ABORT, 'Published provenance is immutable'); END''',
    '''CREATE TRIGGER protect_published_source_update
      BEFORE UPDATE ON source_references
      WHEN EXISTS (SELECT 1 FROM content_revision_sources s
        JOIN content_revisions r ON r.id = s.revision_id
        WHERE s.source_id = OLD.id
          AND r.review_status IN ('published', 'withdrawn'))
      BEGIN SELECT RAISE(ABORT, 'Published provenance is immutable'); END''',
    '''CREATE TRIGGER protect_published_source_delete
      BEFORE DELETE ON source_references
      WHEN EXISTS (SELECT 1 FROM content_revision_sources s
        JOIN content_revisions r ON r.id = s.revision_id
        WHERE s.source_id = OLD.id
          AND r.review_status IN ('published', 'withdrawn'))
      BEGIN SELECT RAISE(ABORT, 'Published provenance is immutable'); END''',
  ],
);
