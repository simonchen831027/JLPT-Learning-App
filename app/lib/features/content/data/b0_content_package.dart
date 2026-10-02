import 'package:jlpt_learning_app/core/identity/entity_id_generator.dart';

import '../domain/content_models.dart';
import 'b0_content_ids.dart';
import 'sqlite_content_repository.dart';

/// 核准 Candidate 02 的靜態 Content import（不在 runtime 解析 handoff）。
/// SHA-256: 8B698FDDE858B6BFEF76CC39F23412ADAD621B2BB5A53E0CD98DD8DF25744C8B
/// 保留 logical contentId 與舊 release；新 revisions/options 使用獨立 identity。
final class B0ContentPackage {
  const B0ContentPackage(this._ids);

  final EntityIdGenerator _ids;

  static const releaseLabel = 'n5-l01-b0-v3';
  static const _creator = 'jlpt-app-03-approved-b0';
  static const _publisher = 'approved-b0-learner-facing-integration';

  Future<void> install(SqliteContentRepository repository) =>
      repository.transaction((tx) async {
        final existing = await tx.getVersion(B0ContentIds.version);
        if (existing != null) {
          if (!existing.isCurrent ||
              await tx.publishedCountByVersion(B0ContentIds.version) !=
                  B0ContentIds.allContent.length) {
            throw StateError('Existing B0 release is incomplete.');
          }
          final lesson = await tx.currentPublishedByContentId(
            B0ContentIds.lesson,
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
            (await tx.getVersion(B0ContentIds.previousVersion) != null ||
                await tx.getVersion(B0ContentIds.legacyVersion) != null)) {
          throw StateError('Previous B0 release is not current.');
        }

        final now = DateTime.now().toUtc();
        await tx.insertVersion(
          ContentVersion(
            id: B0ContentIds.version,
            label: releaseLabel,
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
        await tx.setCurrentVersion(B0ContentIds.version);
      });

  Future<List<String>> _previousSourceIds(
    SqliteContentRepository repository,
    ContentVersion previous,
  ) async {
    if ((previous.id != B0ContentIds.previousVersion &&
            previous.id != B0ContentIds.legacyVersion) ||
        await repository.publishedCountByVersion(previous.id) !=
            B0ContentIds.allContent.length) {
      throw StateError('Another content release is already current.');
    }
    final lesson = await repository.currentPublishedByContentId(
      B0ContentIds.lesson,
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
          !source.isPublicationEligible ||
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
        revision: _revision(B0ContentIds.lesson, ContentKind.lesson, now),
        title: _reading([("自我介紹：姓名與身分", null)]),
        sections: [
          _sectionReading(
            0,
            _reading([("學習目標", null)]),
            _reading([
              (
                "學完這一課，你可以：\n用簡單的日文介紹姓名與身分。\n分辨「是學生」與「是學生嗎？」的說法。\n看懂人物資料中的名字、學生身分與語言資訊。\n\n例句中的ミオ（Mio）與レン（Ren）是兩個人的名字。",
                null,
              ),
            ]),
          ),
          _sectionReading(
            1,
            _reading([("先認識六個單字", null)]),
            _reading([
              ("わたし：我。\n", null),
              ("人", "ひと"),
              ("：人。\n", null),
              ("名前", "なまえ"),
              ("：名字。\n", null),
              ("学生", "がくせい"),
              ("：學生。\n", null),
              ("日本人", "にほんじん"),
              ("：日本人。\n", null),
              ("日本語", "にほんご"),
              ("：日語、日文。\n\n", null),
              ("学生", "がくせい"),
              ("和", null),
              ("日本人", "にほんじん"),
              ("可以用來介紹一個人的身分；", null),
              ("名前", "なまえ"),
              ("和", null),
              ("日本語", "にほんご"),
              ("則分別表示名字與語言。\n先記住這些詞在本課中的讀音與意思，再看它們如何出現在句子裡。", null),
            ]),
          ),
          _sectionReading(
            2,
            _reading([("稱呼別人時的さん", null)]),
            _reading([
              (
                "さん接在別人的名字後面，是一種有禮貌的稱呼。\n例如，稱呼ミオ可以說ミオさん。\n介紹自己的名字時，通常不在名字後面加さん。",
                null,
              ),
            ]),
          ),
          _sectionReading(
            3,
            _reading([("用名詞介紹姓名與身分", null)]),
            _reading([
              ("名詞① は 名詞② です。\n\n名詞①放要談的人，名詞②放這個人的名字或身分。\nミオさんは", null),
              ("学生", "がくせい"),
              ("です。\n意思是「Mio是學生」。\n\nミオさん：現在要談的人。\nは：提示接下來要談的是ミオさん。\n", null),
              ("学生", "がくせい"),
              (
                "：說明Mio的學生身分。\nです：讓這個名詞描述成為禮貌的說法。\n\n這裡的は讀作わ。它的作用是提示談論的對象，不是中文「是」的逐字對應。",
                null,
              ),
            ]),
          ),
          _sectionReading(
            4,
            _reading([("讀讀姓名與身分的例句", null)]),
            _reading([
              ("閱讀下方三個例句，找出「現在談的是誰」以及「後面介紹的是名字還是身分」。\n讀到は時，記得念わ。", null),
            ]),
          ),
          _sectionReading(
            5,
            _reading([("加上か，變成問句", null)]),
            _reading([
              ("想確認對方的姓名或身分，可以在剛才的です後面加か。\n\nミオさんは", null),
              ("学生", "がくせい"),
              ("です。\nMio是學生。\n\nミオさんは", null),
              ("学生", "がくせい"),
              (
                "ですか。\nMio是學生嗎？\n\n前面的詞順序相同，句尾的か讓這個陳述變成詢問。\n讀讀下方兩個問句，留意它們在問誰、確認哪一種身分。",
                null,
              ),
            ]),
          ),
          _sectionReading(
            6,
            _reading([("用はい與いいえ回答", null)]),
            _reading([
              ("有人問：\nミオさんは", null),
              ("学生", "がくせい"),
              (
                "ですか。\nMio是學生嗎？\n\n如果Mio是學生，可以回答：\nはい。\n是的。\n\n也可以說得更完整：\nはい、",
                null,
              ),
              ("学生", "がくせい"),
              ("です。\n是的，是學生。\n\n如果Mio不是學生，可以先簡短回答：\nいいえ。\n不是。", null),
            ]),
          ),
          _sectionReading(
            7,
            _reading([("看懂一張人物卡", null)]),
            _reading([
              ("人物卡\n", null),
              ("名前", "なまえ"),
              ("：ミオ\n", null),
              ("学生", "がくせい"),
              ("\n", null),
              ("日本人", "にほんじん"),
              ("\n", null),
              ("日本語", "にほんご"),
              (
                "\n\n先在卡片中找出答案，再閱讀下方說明：\n哪個詞表示Mio的學生身分？\n哪個詞表示日語？\n\n答案與說明\n",
                null,
              ),
              ("学生", "がくせい"),
              ("表示學生，讓我們知道Mio的學生身分。\n", null),
              ("日本語", "にほんご"),
              ("表示日語，是語言的名稱。\n", null),
              ("名前", "なまえ"),
              ("表示名字；", null),
              ("日本人", "にほんじん"),
              ("表示日本人。它們與學生、語言提供的是不同資訊。", null),
            ]),
          ),
          _sectionReading(
            8,
            _reading([("重點複習", null)]),
            _reading([
              (
                "介紹姓名與身分：\n名詞① は 名詞② です。\n\n確認姓名或身分：\n名詞① は 名詞② ですか。\n\n記住三個重點：\nは提示現在談論的對象，在這些句子裡讀作わ。\nです是這類名詞描述的禮貌句尾。\n句尾加上か，就能詢問這個描述是否正確。\n\n讀句子時，先找出談的是誰，再看名字或身分，最後留意句尾是在陳述還是詢問。",
                null,
              ),
            ]),
          ),
        ],
      ),
      const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
    );
    yield _Entry(
      VocabularyContent(
        revision: _revision(
          B0ContentIds.vocabulary[0],
          ContentKind.vocabulary,
          now,
        ),
        written: _reading([("わたし", null)]),
        meaning: "我；說話的人用來稱呼自己。",
      ),
      const [1, 2, 3, 10],
    );
    yield _Entry(
      VocabularyContent(
        revision: _revision(
          B0ContentIds.vocabulary[1],
          ContentKind.vocabulary,
          now,
        ),
        written: _reading([("人", "ひと")]),
        meaning: "人；指一個人。",
      ),
      const [1, 2, 11, 16],
    );
    yield _Entry(
      VocabularyContent(
        revision: _revision(
          B0ContentIds.vocabulary[2],
          ContentKind.vocabulary,
          now,
        ),
        written: _reading([("名前", "なまえ")]),
        meaning: "名字；人物資料中表示姓名。",
      ),
      const [1, 2, 12],
    );
    yield _Entry(
      VocabularyContent(
        revision: _revision(
          B0ContentIds.vocabulary[3],
          ContentKind.vocabulary,
          now,
        ),
        written: _reading([("学生", "がくせい")]),
        meaning: "學生。",
      ),
      const [1, 2, 13, 17],
    );
    yield _Entry(
      VocabularyContent(
        revision: _revision(
          B0ContentIds.vocabulary[4],
          ContentKind.vocabulary,
          now,
        ),
        written: _reading([("日本人", "にほんじん")]),
        meaning: "日本人。",
      ),
      const [1, 2, 14, 16],
    );
    yield _Entry(
      VocabularyContent(
        revision: _revision(
          B0ContentIds.vocabulary[5],
          ContentKind.vocabulary,
          now,
        ),
        written: _reading([("日本語", "にほんご")]),
        meaning: "日語；日文。",
      ),
      const [1, 2, 15],
    );
    yield _Entry(
      GrammarContent(
        revision: _revision(B0ContentIds.grammar[0], ContentKind.grammar, now),
        pattern: _reading([("名詞① は 名詞② です。", null)]),
        explanation: "這個句型可以用來介紹姓名與身分。「名詞①」與「名詞②」表示句型中兩個名詞的位置。\n\n先提出要談的人，再介紹名字或身分。\nミオさんは学生（がくせい）です。\n意思是「Mio是學生」。ミオさん是談論的對象，学生是對這個人的身分說明。\n\n助詞は在這裡讀作わ，提示「現在要談的是……」。在表示姓名或身分的名詞後面加上です，就形成禮貌的說法。中文常翻成「是」，但不要把は或です各自當成中文「是」的逐字替換。\n\n介紹自己的姓名也可以說「わたしはミオです。」：我是Mio。自己的名字後通常不加さん；稱呼他人時可以說ミオさん。\n\n選詞時也要注意意思。日本人（にほんじん）可以介紹人的身分；日本語（にほんご）是語言的名稱。「わたしは日本語です。」不能用來表達「我會說日文」。",
      ),
      const [1, 2, 3, 4, 5, 7, 8],
    );
    yield _Entry(
      GrammarContent(
        revision: _revision(B0ContentIds.grammar[1], ContentKind.grammar, now),
        pattern: _reading([("名詞① は 名詞② ですか。", null)]),
        explanation: "想確認姓名或身分，在這個名詞句的です後面加か，就能形成禮貌的問句。\n\nミオさんは学生（がくせい）です。\nMio是學生。\n\nミオさんは学生（がくせい）ですか。\nMio是學生嗎？\n\n兩句前面的詞順序相同。句尾的か讓陳述變成詢問，所以讀句子時要留意結尾。\n\n回答「ミオさんは学生ですか。」時，如果Mio是學生，可以說「はい。」或「はい、学生です。」；如果Mio不是學生，可以先說「いいえ。」。這裡的はい與いいえ是在回答這個肯定形式的問句。",
      ),
      const [1, 2, 6, 7, 9],
    );
    yield _Entry(
      KanjiContent(
        revision: _revision(B0ContentIds.kanji[0], ContentKind.kanji, now),
        character: "人",
        context: _reading([("人", "ひと"), ("／", null), ("日本人", "にほんじん")]),
        meaning: "「人」表示人。單獨作為「人」這個詞時讀ひと；在日本人（にほんじん）裡，人讀じん。漢字的讀法要跟著整個詞一起記。",
      ),
      const [1, 2, 11, 14, 16],
    );
    yield _Entry(
      KanjiContent(
        revision: _revision(B0ContentIds.kanji[1], ContentKind.kanji, now),
        character: "学",
        context: _reading([("学生", "がくせい")]),
        meaning: "「学」對應中文的「學」，有學習、學問的意思。在学生（がくせい）這個詞裡，学讀がく；整個詞表示學生。",
      ),
      const [1, 2, 13, 17],
    );
    yield _Entry(
      ExampleSentenceContent(
        revision: _revision(
          B0ContentIds.examples[0],
          ContentKind.exampleSentence,
          now,
        ),
        sentence: _reading([
          ("わたし", null),
          ("は", null),
          ("ミオ", null),
          ("です", null),
          ("。", null),
        ]),
        translation: "我是 Mio。",
      ),
      const [1, 2, 4, 5, 7],
    );
    yield _Entry(
      ExampleSentenceContent(
        revision: _revision(
          B0ContentIds.examples[1],
          ContentKind.exampleSentence,
          now,
        ),
        sentence: _reading([
          ("ミオ", null),
          ("さん", null),
          ("は", null),
          ("学生", "がくせい"),
          ("です", null),
          ("。", null),
        ]),
        translation: "Mio 是學生。",
      ),
      const [1, 2, 4, 5, 7],
    );
    yield _Entry(
      ExampleSentenceContent(
        revision: _revision(
          B0ContentIds.examples[2],
          ContentKind.exampleSentence,
          now,
        ),
        sentence: _reading([
          ("レン", null),
          ("さん", null),
          ("は", null),
          ("日本人", "にほんじん"),
          ("です", null),
          ("。", null),
        ]),
        translation: "Ren 是日本人。",
      ),
      const [1, 2, 4, 5, 7],
    );
    yield _Entry(
      ExampleSentenceContent(
        revision: _revision(
          B0ContentIds.examples[3],
          ContentKind.exampleSentence,
          now,
        ),
        sentence: _reading([
          ("ミオ", null),
          ("さん", null),
          ("は", null),
          ("学生", "がくせい"),
          ("です", null),
          ("か", null),
          ("。", null),
        ]),
        translation: "Mio 是學生嗎？",
      ),
      const [1, 2, 6, 7, 9],
    );
    yield _Entry(
      ExampleSentenceContent(
        revision: _revision(
          B0ContentIds.examples[4],
          ContentKind.exampleSentence,
          now,
        ),
        sentence: _reading([
          ("レン", null),
          ("さん", null),
          ("は", null),
          ("日本人", "にほんじん"),
          ("です", null),
          ("か", null),
          ("。", null),
        ]),
        translation: "Ren 是日本人嗎？",
      ),
      const [1, 2, 6, 7, 9],
    );
    yield _Entry(
      _question(
        now: now,
        index: 0,
        prompt: _reading([("哪一句是在描述「Mio是學生」？", null)]),
        options: [
          _reading([
            ("ミオ", null),
            ("さん", null),
            ("は", null),
            ("学生", "がくせい"),
            ("です", null),
            ("か", null),
            ("。", null),
          ]),
          _reading([
            ("ミオ", null),
            ("さん", null),
            ("は", null),
            ("学生", "がくせい"),
            ("です", null),
            ("。", null),
          ]),
          _reading([
            ("ミオ", null),
            ("さん", null),
            ("は", null),
            ("日本人", "にほんじん"),
            ("です", null),
            ("。", null),
          ]),
          _reading([
            ("レン", null),
            ("さん", null),
            ("は", null),
            ("学生", "がくせい"),
            ("です", null),
            ("。", null),
          ]),
        ],
        explanation: "正解是「ミオさんは学生です。」：Mio是學生。ミオさん是談論的對象，学生（がくせい）表示學生，句尾です是在作禮貌的陳述。\n\n「ミオさんは学生ですか。」多了句尾か，意思是「Mio是學生嗎？」；它在詢問，沒有直接陳述Mio是學生。\n「ミオさんは日本人です。」說的是Mio是日本人，並未說明Mio是不是學生。\n「レンさんは学生です。」說的是Ren，而題目要描述的是Mio。\n\n判斷時要同時看談論的人、後面的身分，以及句尾是在陳述還是詢問。",
      ),
      const [1, 2, 4, 5, 6, 7, 8, 9, 13, 14],
    );
    yield _Entry(
      _question(
        now: now,
        index: 1,
        prompt: _reading([("想確認「Ren是不是日本人」，哪一句最合適？", null)]),
        options: [
          _reading([
            ("レン", null),
            ("さん", null),
            ("は", null),
            ("日本人", "にほんじん"),
            ("です", null),
            ("。", null),
          ]),
          _reading([
            ("ミオ", null),
            ("さん", null),
            ("は", null),
            ("日本人", "にほんじん"),
            ("です", null),
            ("か", null),
            ("。", null),
          ]),
          _reading([
            ("レン", null),
            ("さん", null),
            ("は", null),
            ("日本人", "にほんじん"),
            ("です", null),
            ("か", null),
            ("。", null),
          ]),
          _reading([
            ("レン", null),
            ("さん", null),
            ("は", null),
            ("学生", "がくせい"),
            ("です", null),
            ("か", null),
            ("。", null),
          ]),
        ],
        explanation: "正解是「レンさんは日本人ですか。」：Ren是日本人嗎？レンさん是要確認的人，日本人（にほんじん）是要確認的身分，句尾か表示詢問。\n\n「レンさんは日本人です。」是「Ren是日本人」的陳述，沒有提出問題。\n「ミオさんは日本人ですか。」問的是Mio，談論的對象不符合題目。\n「レンさんは学生ですか。」問Ren是不是學生，確認的是另一種身分。\n\n要問對問題，談論的人、要確認的身分與問句結尾都必須符合。",
      ),
      const [1, 2, 4, 5, 6, 7, 9, 13, 14],
    );
    yield _Entry(
      _question(
        now: now,
        index: 2,
        prompt: _reading([
          ("人物卡\n", null),
          ("名前", "なまえ"),
          ("：ミオ\n", null),
          ("学生", "がくせい"),
          ("\n", null),
          ("日本人", "にほんじん"),
          ("\n", null),
          ("日本語", "にほんご"),
          ("\n\n人物卡中，哪個詞表示Mio的學生身分？", null),
        ]),
        options: [
          _reading([("日本人", "にほんじん")]),
          _reading([("名前", "なまえ")]),
          _reading([("日本語", "にほんご")]),
          _reading([("学生", "がくせい")]),
        ],
        explanation: "正解是「学生（がくせい）」，意思是學生，表示Mio的學生身分。\n\n「日本人（にほんじん）」表示日本人，也可以介紹一個人的身分；但題目明確要找的是學生身分，因此不是這一題的答案。\n「名前（なまえ）」表示名字。人物卡的「名前：ミオ」告訴我們名字是Mio，沒有說明學生身分。\n「日本語（にほんご）」表示日語，是語言的名稱。\n\n先看題目要找哪一種資訊，再用單字的意思判斷，才能分辨名字、學生身分與語言。",
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
      B0ContentIds.questions[index],
      ContentKind.question,
      now,
    ),
    prompt: prompt,
    readingAidPolicy: ReadingAidPolicy.inherit,
    explanation: explanation,
    options: [
      for (var ordinal = 0; ordinal < options.length; ordinal++)
        QuestionOption(
          id: B0ContentIds.questionOptions[index][ordinal],
          ordinal: ordinal,
          content: options[ordinal],
        ),
    ],
    correctOptionId: B0ContentIds.questionOptions[index][index + 1],
  );

  ContentRevision _revision(String contentId, ContentKind kind, DateTime now) =>
      ContentRevision(
        id: _ids.generate(),
        contentId: contentId,
        contentVersionId: B0ContentIds.version,
        kind: kind,
        reviewStatus: ContentReviewStatus.draft,
        createdBy: _creator,
        updatedBy: _creator,
        createdAt: now,
        updatedAt: now,
      );

  LessonSection _sectionReading(
    int ordinal,
    ReadingText title,
    ReadingText body,
  ) => LessonSection(
    id: _ids.generate(),
    ordinal: ordinal,
    title: title,
    body: body,
  );

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
