import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/item_help.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_pair.dart';
import 'package:kid_matix/core/quiz/recognition_cap.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word_catalog.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word_family.dart';
import 'package:kid_matix/features/math_word/domain/entities/operation_statement.dart';

/// The words of the problems: add, take away, compare, group, share, and
/// the questions. Six families of words, each word an item followed by the
/// spaced repetition.
///
/// A word is asked in four ways: hear it and touch its drawing, tie four
/// words to their drawings, touch it in a sentence, and, when a statement
/// uses it, pick the operation of that statement.
final class MathWordDomain implements LearningDomain, RecognitionCap {
  /// Creates the domain of [catalog].
  MathWordDomain({required this.catalog});

  /// Identifier of the domain.
  static const String domainId = LearningDomainIds.mathWords;

  /// Draw weight of every word: none is easier than the others.
  static const int drawWeight = 1;

  /// Words offered as drawings or pairs, the right one included.
  static const int choiceCount = 4;

  /// The words and the statements.
  final MathWordCatalog catalog;

  late final Map<String, MathWordFamily> _familiesBySlug =
      <String, MathWordFamily>{
        for (final MathWordFamily family in catalog.families)
          family.slug: family,
      };

  @override
  String get id => domainId;

  @override
  List<LearningUnit> get units => catalog.families;

  @override
  List<LearningUnit> get path => catalog.families;

  @override
  List<String> get questionTypeIds => const <String>[
    QuestionTypeIds.listenAndTouch,
    QuestionTypeIds.wordAndImage,
    QuestionTypeIds.touchToUnderstand,
    QuestionTypeIds.whichOperation,
  ];

  /// Every word can be heard, tied and touched; the operation is asked only
  /// of the words some statement uses.
  @override
  List<String> questionTypeIdsOf(LearningItem item) {
    final MathWord word = _requireWord(item);
    return <String>[
      QuestionTypeIds.listenAndTouch,
      QuestionTypeIds.wordAndImage,
      QuestionTypeIds.touchToUnderstand,
      if (catalog.statementsOf(word.wordKey).isNotEmpty)
        QuestionTypeIds.whichOperation,
    ];
  }

  @override
  MathWord? findItem(String key) {
    const String prefix = '${MathWord.keyPrefix}:';
    if (!key.startsWith(prefix)) return null;
    return catalog.wordOf(key.substring(prefix.length));
  }

  @override
  MathWordFamily? findUnit(String key) {
    const String prefix = '${MathWord.keyPrefix}:';
    if (!key.startsWith(prefix)) return null;
    return _familiesBySlug[key.substring(prefix.length)];
  }

  @override
  int drawWeightOf(LearningItem item) {
    _requireWord(item);
    return drawWeight;
  }

  @override
  LearningItem? mirrorOf(LearningItem item) {
    _requireWord(item);
    return null;
  }

  /// The words are learned by recognizing a drawing or an operation: a
  /// recognized answer has no cap, the word still needs right answers on
  /// spaced days to climb.
  @override
  int? get recognizedBoxCap => null;

  @override
  String? recordingKeyOf(LearningItem item) => _requireWord(item).wordKey;

  /// The words are French, whatever the language of the interface.
  @override
  String get contentLanguageCode => 'fr';

  @override
  ItemHelp helpOf(LearningItem item) {
    final MathWord word = _requireWord(item);
    final MathWordFamily family = _familiesBySlug[word.familySlug]!;
    return ItemHelp(
      unitFacts: <List<PromptToken>>[
        for (final MathWord other in family.words) describeItem(other),
      ],
      itemIndex: family.words.indexOf(word),
      picture: pictureOf(word),
    );
  }

  @override
  List<PromptToken> describeItem(LearningItem item) {
    return <PromptToken>[TextToken(_requireWord(item).text)];
  }

  /// The drawing of [word].
  static WordPicture pictureOf(MathWord word) {
    return WordPicture(wordKey: word.wordKey, label: word.text);
  }

  /// The answer that stands for [word].
  static WordAnswer answerOf(MathWord word) {
    return WordAnswer(wordKey: word.wordKey, text: word.text);
  }

  @override
  Question buildQuestion({
    required LearningItem item,
    required String questionTypeId,
    required RandomSource random,
  }) {
    final MathWord word = _requireWord(item);
    if (!questionTypeIdsOf(word).contains(questionTypeId)) {
      throw ArgumentError.value(
        questionTypeId,
        'questionTypeId',
        'Not fit for ${word.key}',
      );
    }
    return switch (questionTypeId) {
      QuestionTypeIds.listenAndTouch => _buildListenAndTouch(word, random),
      QuestionTypeIds.wordAndImage => _buildWordAndImage(word, random),
      QuestionTypeIds.touchToUnderstand => _buildTouchToUnderstand(word),
      _ => _buildWhichOperation(word, random),
    };
  }

  /// The word is heard (and written under the drawings when no voice
  /// exists); its drawing is picked among four.
  Question _buildListenAndTouch(MathWord word, RandomSource random) {
    return Question(
      itemKey: word.key,
      unitKey: _unitKeyOf(word),
      questionTypeId: QuestionTypeIds.listenAndTouch,
      prompt: <PromptToken>[TextToken(word.text)],
      choices: random.shuffled(<Answer>[
        answerOf(word),
        ..._otherWordsOf(word, choiceCount - 1, random).map(answerOf),
      ]),
      expectedAnswer: answerOf(word),
    );
  }

  /// Four words tied to their four drawings; each pair counts for its own
  /// word.
  Question _buildWordAndImage(MathWord word, RandomSource random) {
    final List<MathWord> words = random.shuffled(<MathWord>[
      word,
      ..._otherWordsOf(word, choiceCount - 1, random),
    ]);
    final List<QuestionPair> pairs = <QuestionPair>[
      for (final MathWord pairWord in words)
        QuestionPair(
          itemKey: pairWord.key,
          operation: answerOf(pairWord),
          result: answerOf(pairWord),
        ),
    ];
    return Question(
      itemKey: word.key,
      unitKey: _unitKeyOf(word),
      questionTypeId: QuestionTypeIds.wordAndImage,
      prompt: const <PromptToken>[],
      choices: random.shuffled(
        pairs.map((QuestionPair pair) => pair.result).toList(),
      ),
      pairs: pairs,
      expectedAnswer: PairsAnswer(),
    );
  }

  /// The example of the word, whose math words can be touched; the child
  /// has understood once the word asked has been touched.
  Question _buildTouchToUnderstand(MathWord word) {
    return Question(
      itemKey: word.key,
      unitKey: _unitKeyOf(word),
      questionTypeId: QuestionTypeIds.touchToUnderstand,
      prompt: <PromptToken>[TextToken(word.example)],
      sentence: catalog.sentenceOf(word),
      expectedAnswer: answerOf(word),
    );
  }

  /// A statement that uses the word, whose operation is picked among four.
  Question _buildWhichOperation(MathWord word, RandomSource random) {
    final List<OperationStatement> statements = catalog.statementsOf(
      word.wordKey,
    );
    final OperationStatement statement =
        statements[random.nextInt(statements.length)];
    return Question(
      itemKey: word.key,
      unitKey: _unitKeyOf(word),
      questionTypeId: QuestionTypeIds.whichOperation,
      prompt: <PromptToken>[TextToken(statement.text)],
      choices: OperatorAnswer.all,
      expectedAnswer: OperatorAnswer(statement.operation),
    );
  }

  /// [count] words other than [word], each of a different notion from
  /// [word]'s and from each other's: two words that mean the same thing
  /// are never offered as wrong answers to each other.
  List<MathWord> _otherWordsOf(MathWord word, int count, RandomSource random) {
    final List<MathWord> others = <MathWord>[];
    final Set<String> notions = <String>{word.notion};
    for (final MathWord other in random.shuffled(catalog.words)) {
      if (notions.add(other.notion)) others.add(other);
      if (others.length == count) break;
    }
    return others;
  }

  String _unitKeyOf(MathWord word) => _familiesBySlug[word.familySlug]!.key;

  MathWord _requireWord(LearningItem item) {
    final MathWord? word = findItem(item.key);
    if (word == null) {
      throw ArgumentError.value(item.key, 'item', 'Not a math word');
    }
    return word;
  }
}
