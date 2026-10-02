/// Stable UUID v7 logical identities for the Developer-approved B0 release.
/// The ordered groups are the L01 curriculum manifest, not UUID sort order.
abstract final class B0ContentIds {
  static const g01ExamplesSectionOrdinal = 4;
  static const g02ExamplesSectionOrdinal = 5;
  static const legacyVersion = '01a0e831-72b8-701a-bbd7-f30092a6be3c';
  static const previousVersion = '01a0e86d-e662-7aca-9931-1d2527768b43';
  static const version = '01a0fbf6-2ffe-72c2-aab3-00cd733ea8ec';
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
  static const previousQuestionOptions = [
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

  // 新 revision 的 option row identities，依核准的 display order。
  static const questionOptions = [
    [
      '01a0fbf6-2ffe-71be-9275-65973f54cc1c', // Q-B0-01-B
      '01a0fbf6-2ffe-77f0-ada8-10a58aeecd3a', // Q-B0-01-A
      '01a0fbf6-2ffe-752b-92fa-a9b6f1550bc3', // Q-B0-01-D
      '01a0fbf6-2ffe-7a6e-b57d-e53cbb7e0b2c', // Q-B0-01-C
    ],
    [
      '01a0fbf6-2ffe-7f40-a3f7-d90a767c06fb', // Q-B0-02-B
      '01a0fbf6-2ffe-729a-ad6c-7d46952d958f', // Q-B0-02-C
      '01a0fbf6-2ffe-7cbe-890d-a4cfffb88b2d', // Q-B0-02-A
      '01a0fbf6-2ffe-75d9-8370-1b0bb012ae79', // Q-B0-02-D
    ],
    [
      '01a0fbf6-2ffe-7fc6-a57a-7ae0d19cbffe', // Q-B0-03-B
      '01a0fbf6-2ffe-7719-b809-4df0add4caa2', // Q-B0-03-D
      '01a0fbf6-2ffe-7bf4-a2d1-3af639d4f674', // Q-B0-03-C
      '01a0fbf6-2ffe-72fb-b88c-42e21d71c722', // Q-B0-03-A
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
