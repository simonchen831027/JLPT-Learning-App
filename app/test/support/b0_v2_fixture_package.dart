// 歷史測試 fixture：取自 HEAD 69745bd02069bb716d65224871ed509d1abc857b.
// v2 原文及來源保留；legacy 僅模擬既有 v1 release 的升級入口。
import 'package:jlpt_learning_app/core/identity/entity_id_generator.dart';

import 'package:jlpt_learning_app/features/content/domain/content_models.dart';
import 'package:jlpt_learning_app/features/content/data/sqlite_content_repository.dart';

/// Compiled import of N5_L01_B0_CONTENT_PACKAGE_APPROVED.md.
///
/// Source IDs and revision IDs are created once, within the atomic import.
/// Logical content and option IDs remain stable across installations.
final class B0V2FixturePackage {
  const B0V2FixturePackage(this._ids, {this.legacy = false});

  final bool legacy;
  String get _versionId =>
      legacy ? B0V2FixtureIds.previousVersion : B0V2FixtureIds.version;

  final EntityIdGenerator _ids;

  static const releaseLabel = 'n5-l01-b0-v2';
  static const _creator = 'jlpt-app-03-approved-b0';
  static const _publisher = 'slice-1c-canonical-import';

  Future<void> install(SqliteContentRepository repository) =>
      repository.transaction((tx) async {
        final existing = await tx.getVersion(_versionId);
        if (existing != null) {
          if (!existing.isCurrent ||
              await tx.publishedCountByVersion(_versionId) !=
                  B0V2FixtureIds.allContent.length) {
            throw StateError('Existing B0 release is incomplete.');
          }
          final lesson = await tx.currentPublishedByContentId(
            B0V2FixtureIds.lesson,
          );
          if (lesson == null ||
              (await tx.sourceIdsForRevision(lesson.revision.id)).length !=
                  _sources.length) {
            throw StateError('Existing B0 provenance is incomplete.');
          }
          return;
        }
        final previous = await tx.currentVersion();
        final sourceIds = previous == null
            ? <String>[]
            : await _previousSourceIds(tx, previous);
        if (previous == null &&
            await tx.getVersion(B0V2FixtureIds.previousVersion) != null) {
          throw StateError('Previous B0 release is not current.');
        }

        final now = DateTime.now().toUtc();
        await tx.insertVersion(
          ContentVersion(
            id: _versionId,
            label: legacy ? 'n5-l01-b0-v1' : releaseLabel,
            createdAt: now,
          ),
        );
        if (previous == null) {
          for (final source in _sources) {
            final id = _ids.generate();
            sourceIds.add(id);
            await tx.insertSource(
              SourceReference(
                id: id,
                sourceName: source.name,
                sourceUrl: source.url,
                sourceTitle: source.title,
                topic: source.topic,
                referenceLevel: source.level,
                note: source.note,
                contentUsageStatus: ContentUsageStatus.referenceOnly,
                reviewStatus: SourceReviewStatus.approved,
                createdAt: now,
                updatedAt: now,
              ),
            );
          }
        }

        for (final entry in _entries(now)) {
          await tx.insertDraft(
            entry.body,
            sourceIds: [
              for (final number in entry.sourceNumbers) sourceIds[number - 1],
            ],
          );
          await tx.markReviewed(entry.body.revision.id, _publisher, now);
          await tx.publish(entry.body.revision.id, _publisher, now);
        }
        await tx.setCurrentVersion(_versionId);
      });

  Future<List<String>> _previousSourceIds(
    SqliteContentRepository repository,
    ContentVersion previous,
  ) async {
    if (previous.id != B0V2FixtureIds.previousVersion ||
        await repository.publishedCountByVersion(previous.id) !=
            B0V2FixtureIds.allContent.length) {
      throw StateError('Another content release is already current.');
    }
    final lesson = await repository.currentPublishedByContentId(
      B0V2FixtureIds.lesson,
    );
    if (lesson is! LessonContent) {
      throw StateError('Previous B0 lesson is unavailable.');
    }
    final ids = await repository.sourceIdsForRevision(lesson.revision.id);
    if (ids.length != _sources.length) {
      throw StateError('Previous B0 provenance is incomplete.');
    }
    final byUrl = <String, String>{};
    for (final id in ids) {
      final source = await repository.getSource(id);
      if (source == null ||
          source.reviewStatus != SourceReviewStatus.approved ||
          source.contentUsageStatus != ContentUsageStatus.referenceOnly ||
          source.sourceUrl == null) {
        throw StateError('Previous B0 source is ineligible.');
      }
      byUrl[source.sourceUrl!] = id;
    }
    if (byUrl.length != _sources.length ||
        _sources.any((source) => !byUrl.containsKey(source.url))) {
      throw StateError('Previous B0 source set has changed.');
    }
    return [for (final source in _sources) byUrl[source.url]!];
  }

  Iterable<_Entry> _entries(DateTime now) sync* {
    yield _Entry(
      LessonContent(
        revision: _revision(B0V2FixtureIds.lesson, ContentKind.lesson, now),
        title: _plain('L01 — 身分／自我介紹'),
        sections: [
          _section(0, 'Learning Goal', '''完成本課後，學習者應能：
看懂非常簡單的人物姓名與身分資訊。
理解 N1 は N2 です 是對 N1 做基本身分／分類描述。
理解句尾 か 可以把這類丁寧句變成問句。
辨識 学生、日本人、日本語 等本課核心詞。
回答非常簡單的 singleChoice Practice。'''),
          _section(1, 'Step 1 — Vocabulary', '''本課先學：
わたし
人（ひと）
名前（なまえ）
学生（がくせい）
日本人（にほんじん）
日本語（にほんご）

其中：
学生、日本人 很適合描述一個人的身分。
名前、日本語 本課也會出現在人物資料中。
不需要一次記住每個漢字的所有讀法。'''),
          _section(2, 'Support Expression Note — さん', '''さん：
接在別人的名字後面的一種基本敬稱。
本課只需要看懂即可：
不列為正式 Vocabulary target。
不建立完整敬稱教材。
自己的名字後通常不加 さん。'''),
          _section(3, 'Step 2 — G01', '''N1 は N2 です
先看：
ミオさんは学生です。
意思是：
Mio 是學生。
但句子的理解方式不要只背成中文「是」。
可以想成：
現在談的是「ミオさん」 → 關於 Mio，我們說明這個人是「学生」。
所以：
ミオさん：現在談的人
は：告訴我們「現在談這個人」
学生：對這個人的身分描述
です：丁寧的句尾'''),
          _section(4, 'Step 3 — Original G01 Examples', '''參見 §8：
EX-B0-01
EX-B0-02
EX-B0-03'''),
          _section(5, 'Step 4 — G02', '''か
如果原本是：
ミオさんは学生です。
在最後加入：
か
就得到：
ミオさんは学生ですか。
也就是：
Mio 是學生嗎？
日文不需要把前面的詞重新排列。'''),
          _section(6, 'Step 5 — Very Basic Response', '''問：
ミオさんは学生ですか。
如果答案符合：
はい。
或：
はい、学生です。
如果不符合，目前先學：
いいえ。
完整否定句留到後續已核准的文法批次，不在 B0 提前加入。'''),
          _sectionReading(
            7,
            'Step 6 — Mini Comprehension',
            _reading([
              ('人物卡\n姓名　', null),
              ('名前', 'なまえ'),
              ('：', null),
              ('ミオ', null),
              ('\n身分　', null),
              ('学生', 'がくせい'),
              ('\n國籍　', null),
              ('日本人', 'にほんじん'),
              ('\n語言　', null),
              ('日本語', 'にほんご'),
              ('\n\n', null),
              ('ミオ', null),
              ('的身分是什麼？ → ', null),
              ('学生', 'がくせい'),
              ('\n人物卡中表示「日語」的是哪個詞？ → ', null),
              ('日本語', 'にほんご'),
              ('\n這裡只要求辨識資訊，不新增「國籍是～」「會說～」等後續句型。', null),
            ]),
          ),
          _section(8, 'Step 7 — Summary / Review Point', '''今天最重要的兩個形式：
N1 は N2 です。
→ 對 N1 做最基本的身分／類別描述。
N1 は N2 ですか。
→ 詢問這個描述是否正確。
記住：
助詞 は 在這裡讀 わ。
不要把 は 直接背成「是」。
不要把任何中文「是」都機械換成 です。
か 本課只負責最基本句尾問句。'''),
        ],
      ),
      List.generate(17, (index) => index + 1),
    );

    final words = [
      (_reading([('わたし', null)]), '我；說話者自己', [1, 2, 3, 10]),
      (_reading([('人', 'ひと')]), '人；人物', [1, 2, 11, 16]),
      (_reading([('名前', 'なまえ')]), '姓名／名字', [1, 2, 12]),
      (_reading([('学生', 'がくせい')]), '學生', [1, 2, 13, 17]),
      (_reading([('日本人', 'にほんじん')]), '日本人', [1, 2, 14, 16]),
      (_reading([('日本語', 'にほんご')]), '日語；日本語言', [1, 2, 15]),
    ];
    for (var index = 0; index < words.length; index++) {
      final (written, meaning, sources) = words[index];
      yield _Entry(
        VocabularyContent(
          revision: _revision(
            B0V2FixtureIds.vocabulary[index],
            ContentKind.vocabulary,
            now,
          ),
          written: written,
          meaning: meaning,
        ),
        sources,
      );
    }

    yield _Entry(
      GrammarContent(
        revision: _revision(
          B0V2FixtureIds.grammar[0],
          ContentKind.grammar,
          now,
        ),
        pattern: _plain('N1 は N2 です。'),
        explanation: '''先提出 N1 是我們現在要談的人或事物，再用 N2 說明 N1 是什麼、屬於什麼身分或類別。

中文常會翻成「N1 是 N2」，但這只是方便理解的翻譯。
不要學成：は = 是；或 です = 是。

N1：現在正在談的人／事物
は：告訴聽者「現在要說的是 N1」
N2：對 N1 提供的身分、名稱或分類
です：讓名詞描述形成丁寧、完整的句尾

本批主要使用：
人名 → 身分
人 → 國籍／身分類別
自己 → 名字
自己／人物 → 學生

わたし 很適合做 N1；学生、日本人 很適合做 N2。
名前 本批主要當人物資訊 label，不導入 の。
日本語 本批主要當語言 label；不能拿來把「人」判定成「語言」。
人 是人物辨識詞；不強迫進入 G01 例句。

助詞 は 在本句發音為 わ，不要念成 は / ha。
は 的工作不是等號，而是提示「現在談 N1」。
B0 只教「名詞對名詞」的肯定描述；不能由此推導動詞或形容詞規則。
若想用「わたしは日本語です。」表達「我會日文」，語意不成立。
さん 可接在別人的名字後作敬稱，但自己的名字後通常不加。

B0 G01 不教：
否定 ではありません、過去 でした、だ、も、の、形容詞述語、動詞述語、は／が 完整比較。''',
      ),
      const [1, 2, 3, 4, 5, 7, 8],
    );
    yield _Entry(
      GrammarContent(
        revision: _revision(
          B0V2FixtureIds.grammar[1],
          ContentKind.grammar,
          now,
        ),
        pattern: _plain('N1 は N2 ですか。'),
        explanation: '''在丁寧句的句尾加入 か，形成最基本的問句。

N1 は N2 です。
↓
N1 は N2 ですか。

不需要像英文一樣把語序重新排列。
改變重點是句尾增加 か。

本批採最小回答：
はい。
いいえ。
若為肯定，可再重複已知內容：はい、学生です。
完整否定句不在 B0 scope。

か 位於句尾。本批只理解為「問句標記」。
不改變前面的基本語序。
ですか 可作為基本問句結尾熟悉。
本批不教授其他 か 用法。''',
      ),
      const [1, 2, 6, 7, 9],
    );

    yield _Entry(
      KanjiContent(
        revision: _revision(B0V2FixtureIds.kanji[0], ContentKind.kanji, now),
        character: '人',
        context: _reading([('人', 'ひと'), ('／', null), ('日本人', 'にほんじん')]),
        meaning: '人；～人 中表示某國／某類別的人。',
      ),
      const [1, 2, 11, 14, 16],
    );
    yield _Entry(
      KanjiContent(
        revision: _revision(B0V2FixtureIds.kanji[1], ContentKind.kanji, now),
        character: '学',
        context: _reading([('学生', 'がくせい')]),
        meaning: '學習、學問；形成「學生」概念的一部分。学生（がくせい）中的 学 讀 がく。',
      ),
      const [1, 2, 13, 17],
    );

    final examples = [
      (_sentence('わたし', 'ミオ', question: false, self: true), '我是 Mio。'),
      (_sentence('ミオ', '学生', question: false), 'Mio 是學生。'),
      (_sentence('レン', '日本人', question: false), 'Ren 是日本人。'),
      (_sentence('ミオ', '学生', question: true), 'Mio 是學生嗎？'),
      (_sentence('レン', '日本人', question: true), 'Ren 是日本人嗎？'),
    ];
    for (var index = 0; index < examples.length; index++) {
      final (sentence, translation) = examples[index];
      yield _Entry(
        ExampleSentenceContent(
          revision: _revision(
            B0V2FixtureIds.examples[index],
            ContentKind.exampleSentence,
            now,
          ),
          sentence: sentence,
          translation: translation,
        ),
        index < 3 ? const [1, 2, 4, 5, 7] : const [1, 2, 6, 7, 9],
      );
    }

    yield _Entry(
      _question(
        now: now,
        index: 0,
        prompt: _plain('哪一句表示「Mio 是學生」？'),
        options: [
          _sentence('ミオ', '学生', question: false),
          _sentence('ミオ', '学生', question: true),
          _sentence('レン', '学生', question: false),
          _sentence('ミオ', '日本人', question: false),
        ],
        explanation: '''ミオさんは学生です。 的主題是 Mio，学生です 是對 Mio 的身分描述，因此完整意思是「Mio 是學生」。
Q-B0-01-B 錯在句尾有 か，變成「Mio 是學生嗎？」而不是陳述。
Q-B0-01-C 描述的是 Ren，不是 Mio。
Q-B0-01-D 描述 Mio 是 日本人，不是 学生。''',
      ),
      const [1, 2, 4, 5, 6, 7, 8, 9, 13, 14],
    );
    yield _Entry(
      _question(
        now: now,
        index: 1,
        prompt: _plain('如果要確認「Ren 是不是日本人」，哪一句最合適？'),
        options: [
          _sentence('レン', '日本人', question: true),
          _sentence('レン', '日本人', question: false),
          _sentence('ミオ', '日本人', question: true),
          _sentence('レン', '学生', question: true),
        ],
        explanation: '''要確認某個判斷，在本課的丁寧名詞句中可把：
レンさんは日本人です。
改成：
レンさんは日本人ですか。
因此 Q-B0-02-A 正確。
Q-B0-02-B 沒有 か，是陳述句。
Q-B0-02-C 問的是 Mio。
Q-B0-02-D 問的是 Ren 是否為學生，而不是是否為日本人。''',
      ),
      const [1, 2, 4, 5, 6, 7, 9, 13, 14],
    );
    yield _Entry(
      _question(
        now: now,
        index: 2,
        // The approved card and prompt are one normalized prompt ReadingText.
        // Japanese word segments retain their approved whole-word readings.
        prompt: _reading([
          ('姓名　', null),
          ('名前', 'なまえ'),
          ('：', null),
          ('ミオ', null),
          ('\n身分　', null),
          ('学生', 'がくせい'),
          ('\n國籍　', null),
          ('日本人', 'にほんじん'),
          ('\n語言　', null),
          ('日本語', 'にほんご'),
          ('\n\n根據人物卡，哪一項是 Mio 的「身分」？', null),
        ]),
        options: [
          _reading([('学生', 'がくせい')]),
          _reading([('日本人', 'にほんじん')]),
          _reading([('日本語', 'にほんご')]),
          _reading([('名前', 'なまえ')]),
        ],
        explanation: '''人物卡中：
学生 = 學生，是身分。
日本人 = 日本人，這裡表示國籍／人物身分類別。
日本語 = 日語，是語言。
名前 = 姓名／名字，是資料欄位。
所以唯一正確答案是 Q-B0-03-A。''',
      ),
      const [1, 2, 3, 12, 13, 14, 15],
    );
  }

  QuestionContent _question({
    required DateTime now,
    required int index,
    required ReadingText prompt,
    required List<ReadingText> options,
    required String explanation,
  }) => QuestionContent(
    revision: _revision(
      B0V2FixtureIds.questions[index],
      ContentKind.question,
      now,
    ),
    prompt: prompt,
    readingAidPolicy: ReadingAidPolicy.inherit,
    explanation: explanation,
    options: [
      for (var ordinal = 0; ordinal < options.length; ordinal++)
        QuestionOption(
          id: B0V2FixtureIds.questionOptions[index][ordinal],
          ordinal: ordinal,
          content: options[ordinal],
        ),
    ],
    correctOptionId: B0V2FixtureIds.questionOptions[index][0],
  );

  ContentRevision _revision(String contentId, ContentKind kind, DateTime now) =>
      ContentRevision(
        id: _ids.generate(),
        contentId: contentId,
        contentVersionId: _versionId,
        kind: kind,
        reviewStatus: ContentReviewStatus.draft,
        createdBy: _creator,
        updatedBy: _creator,
        createdAt: now,
        updatedAt: now,
      );

  LessonSection _section(int ordinal, String title, String body) =>
      _sectionReading(ordinal, title, _plain(body));

  LessonSection _sectionReading(int ordinal, String title, ReadingText body) =>
      LessonSection(
        id: _ids.generate(),
        ordinal: ordinal,
        title: _plain(title),
        body: body,
      );

  ReadingText _plain(String surface) => _reading([(surface, null)]);

  ReadingText _reading(List<(String, String?)> parts) => ReadingText(
    id: _ids.generate(),
    surface: parts.map((part) => part.$1).join(),
    segments: [
      for (var ordinal = 0; ordinal < parts.length; ordinal++)
        ReadingSegment(
          id: _ids.generate(),
          ordinal: ordinal,
          surface: parts[ordinal].$1,
          reading: parts[ordinal].$2,
        ),
    ],
  );

  ReadingText _sentence(
    String person,
    String noun, {
    required bool question,
    bool self = false,
  }) => _reading([
    (person, null),
    if (!self) ('さん', null),
    ('は', null),
    (
      noun,
      switch (noun) {
        '学生' => 'がくせい',
        '日本人' => 'にほんじん',
        _ => null,
      },
    ),
    ('です', null),
    if (question) ('か', null),
    ('。', null),
  ]);
}

final class _Entry {
  const _Entry(this.body, this.sourceNumbers);
  final ContentBody body;
  final List<int> sourceNumbers;
}

final class _SourceSpec {
  const _SourceSpec(
    this.name,
    this.title,
    this.url,
    this.topic,
    this.level,
    this.note,
  );
  final String name;
  final String title;
  final String url;
  final String topic;
  final String level;
  final String note;
}

// SR-B0-01 through SR-B0-17, in the final approved order. Rejected goo
// references are review history only and never enter this active release.
const _sources = <_SourceSpec>[
  _SourceSpec(
    'JLPT Official',
    'N1–N5: Summary of Linguistic Competence Required for Each Level',
    'https://www.jlpt.jp/e/about/levelsummary.html',
    'N5 capability boundary',
    'official-capability',
    '僅支持能力方向，不支持逐項 Vocabulary / Grammar / Kanji 分級。',
  ),
  _SourceSpec(
    'JLPT Official',
    'FAQ',
    'https://www.jlpt.jp/e/faq/',
    'absence of official item list',
    'official-governance',
    '用於避免把 research-derived 條目描述為官方完整 N5 清單。',
  ),
  _SourceSpec(
    'The Japan Foundation — Marugoto',
    'Starter (A1) Katsudoo',
    'https://marugoto.jpf.go.jp/en/download/starter_a/',
    'self-introduction / beginner context',
    'institutional-A1',
    'A1 僅作初學情境參考，不等同 JLPT N5 官方分級。',
  ),
  _SourceSpec(
    '東京外国語大学言語モジュール',
    'NはNです',
    'https://www.coelang.tufs.ac.jp/mt/ja/gmod/courses/c01/lesson01/step2/explanation/002.html',
    'G01',
    'institutional-grammar',
    '支持 は 的基本主題功能與句型。',
  ),
  _SourceSpec(
    '東京外国語大学言語モジュール',
    'Nです／Nではありません',
    'https://www.coelang.tufs.ac.jp/mt/ja/gmod/courses/c01/lesson01/step1/explanation/001.html',
    'noun predicate / です',
    'institutional-grammar',
    'B0 只採 affirmative です。',
  ),
  _SourceSpec(
    '東京外国語大学言語モジュール',
    'Nですか',
    'https://www.coelang.tufs.ac.jp/mt/ja/gmod/contents/explanation/003.html',
    'G02 question か',
    'institutional-grammar',
    '支持 sentence-final か 與基本問答。',
  ),
  _SourceSpec(
    '時雨の町',
    'N5文法01「名詞—主題與描述句」～は～です',
    'https://www.sigure.tw/learn-japanese/grammar/n5/01',
    'G01/G02 Chinese-language cross-check',
    'teaching-reference',
    '規則交叉確認；不使用來源例句與題庫。',
  ),
  _SourceSpec(
    'JLPT Sensei',
    'は (wa) Topic Marker',
    'https://jlptsensei.com/learn-japanese-grammar/%E3%81%AF-wa-topic-marker-meaning/',
    'は',
    'teaching-reference',
    'Secondary cross-check；其 N5 label 非官方 item classification。',
  ),
  _SourceSpec(
    'JLPT Sensei',
    'か (ka) Question Particle',
    'https://jlptsensei.com/learn-japanese-grammar/%E3%81%8B-ka-question-particle-meaning/',
    'sentence-final question か',
    'teaching-reference',
    '其他 か 功能不納入 B0。',
  ),
  _SourceSpec(
    'Kotobank / 精選版 日本国語大辞典',
    '私',
    'https://kotobank.jp/word/%E7%A7%81-425153',
    'わたし reading / basic meaning / part of speech',
    'dictionary-reference',
    'replacement approved by Developer after goo dictionary service termination.',
  ),
  _SourceSpec(
    'Kotobank / デジタル大辞泉',
    '人',
    'https://kotobank.jp/word/%E4%BA%BA-536577',
    '人 vocabulary reading / B0 meaning',
    'dictionary-reference',
    'replacement approved by Developer after goo dictionary service termination.',
  ),
  _SourceSpec(
    'Kotobank / デジタル大辞泉',
    '名前',
    'https://kotobank.jp/word/%E5%90%8D%E5%89%8D-22836',
    '名前 reading / B0 meaning',
    'dictionary-reference',
    'replacement approved by Developer after goo dictionary service termination.',
  ),
  _SourceSpec(
    'Kotobank / デジタル大辞泉',
    '学生',
    'https://kotobank.jp/word/%E5%AD%A6%E7%94%9F-460366',
    '学生 reading / B0 meaning',
    'dictionary-reference',
    'replacement approved by Developer after goo dictionary service termination.',
  ),
  _SourceSpec(
    'Kotobank / デジタル大辞泉',
    '日本人',
    'https://kotobank.jp/word/%E6%97%A5%E6%9C%AC%E4%BA%BA-110194',
    '日本人 reading',
    'dictionary-reference',
    'replacement approved by Developer after goo dictionary service termination.',
  ),
  _SourceSpec(
    'Kotobank / デジタル大辞泉',
    '日本語',
    'https://kotobank.jp/word/%E6%97%A5%E6%9C%AC%E8%AA%9E-110148',
    '日本語 reading / meaning',
    'dictionary-reference',
    'B0 採 contextual reading にほんご。',
  ),
  _SourceSpec(
    '漢字ペディア / 公益財団法人 日本漢字能力検定協会',
    '人｜漢字一字',
    'https://www.kanjipedia.jp/kanji/0003678400',
    'Kanji 人 / contextual reading',
    'institutional-kanji-reference',
    'replacement approved by Developer after goo kanji dictionary service termination.',
  ),
  _SourceSpec(
    '漢字ペディア / 公益財団法人 日本漢字能力検定協会',
    '学｜漢字一字',
    'https://www.kanjipedia.jp/kanji/0000923700',
    'Kanji 学 / contextual reading',
    'institutional-kanji-reference',
    'replacement approved by Developer after goo kanji dictionary service termination.',
  ),
];

/// Stable UUID v7 logical identities for the Developer-approved B0 release.
/// The ordered groups are the L01 curriculum manifest, not UUID sort order.
abstract final class B0V2FixtureIds {
  static const g01ExamplesSectionOrdinal = 4;
  static const g02ExamplesSectionOrdinal = 5;
  static const previousVersion = '01a0e831-72b8-701a-bbd7-f30092a6be3c';
  static const version = '01a0e86d-e662-7aca-9931-1d2527768b43';
  static const lesson = '01a0e831-72b8-79e2-9331-0496be402d48';
  static const vocabulary = [
    '01a0e831-72b8-7013-b4f9-6f963ecac47c', // V-B0-01 わたし
    '01a0e831-72b8-7242-91c5-8248a568003b', // V-B0-02 人
    '01a0e831-72b8-7923-b51f-57de8c88345f', // V-B0-03 名前
    '01a0e831-72b8-7c70-937a-df9eebc5bc0f', // V-B0-04 学生
    '01a0e831-72b8-726d-91b7-3649fa5d7891', // V-B0-05 日本人
    '01a0e831-72b8-789a-93b8-d34cfc02f58c', // V-B0-06 日本語
  ];
  static const grammar = [
    '01a0e831-72b8-7d1d-a463-2dcf5cfa2bd6', // G01
    '01a0e831-72b8-74bc-be4e-554d32686349', // G02
  ];
  static const kanji = [
    '01a0e831-72b8-7132-8719-2a78ee798e80', // 人
    '01a0e831-72b8-79e5-b7e1-f6264b57d281', // 学
  ];
  static const examples = [
    '01a0e831-72b8-7983-af9d-76b5298d505e',
    '01a0e831-72b8-7506-bee8-c9214a0a9010',
    '01a0e831-72b8-7ed9-a5ca-fceca5087a2f',
    '01a0e831-72b8-76be-b8a1-ce6d04e942aa',
    '01a0e831-72b8-7c15-8995-02d420b0c9ee',
  ];
  static const questions = [
    '01a0e831-72b8-7f04-bc69-5131cee3c191',
    '01a0e831-72b8-7101-bb73-6cf8868d0cd4',
    '01a0e831-72b8-7084-92a1-1e75eadcb29d',
  ];
  static const questionOptions = [
    [
      '01a0e875-6c4b-7e19-b1b5-14ce66246cf8', // Q-B0-01-A
      '01a0e875-6c4e-7704-bd67-7d16ab6a7939', // Q-B0-01-B
      '01a0e875-6c4e-78d3-9e51-1ae53dfaec27', // Q-B0-01-C
      '01a0e875-6c4e-7f4f-9a1c-681fbf34f5d7', // Q-B0-01-D
    ],
    [
      '01a0e875-6c4e-74cf-b76d-89ed63ac270f', // Q-B0-02-A
      '01a0e875-6c4e-7ff0-9fda-0c689c2877b5', // Q-B0-02-B
      '01a0e875-6c4e-78df-90d5-1016aadc24b9', // Q-B0-02-C
      '01a0e875-6c4e-7cf9-b703-ce1d0dc39e20', // Q-B0-02-D
    ],
    [
      '01a0e875-6c4e-7e4d-8680-8ec96fbdbd0c', // Q-B0-03-A
      '01a0e875-6c4e-70e2-85b6-4803c5442cd2', // Q-B0-03-B
      '01a0e875-6c4e-7e51-8da5-87e2edf48079', // Q-B0-03-C
      '01a0e875-6c4e-7c74-8e35-d40001c53a2f', // Q-B0-03-D
    ],
  ];

  static const allContent = [
    lesson,
    ...vocabulary,
    ...grammar,
    ...kanji,
    ...examples,
    ...questions,
  ];
}
