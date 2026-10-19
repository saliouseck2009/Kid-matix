import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/item_help.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_pair.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/sentence_part.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word_catalog.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word_family.dart';
import 'package:kid_matix/features/math_word/domain/entities/operation_statement.dart';
import 'package:kid_matix/features/math_word/domain/services/math_word_domain.dart';

import '../helpers/math_word_fixtures.dart';

/// Keys released with the first version of the domain: they never change,
/// since the stored progress and the recordings refer to them.
const List<String> _pinnedWordKeys = <String>[
  'ajouter',
  'en_plus',
  'en_tout',
  'ensemble',
  'gagner',
  'recevoir',
  'augmenter',
  'enlever',
  'il_reste',
  'retirer',
  'vendre',
  'donner',
  'perdre',
  'acheter',
  'de_plus_que',
  'de_moins_que',
  'autant_que',
  'le_plus_grand',
  'le_plus_petit',
  'difference',
  'egal',
  'par_paquets_de',
  'chacun',
  'fois',
  'dans_chaque',
  'rangee',
  'double',
  'partager',
  'partager_egalement',
  'repartir',
  'par_personne',
  'diviser',
  'moitie',
  'quart',
  'combien',
  'combien_de_fois',
  'total',
  'au_depart',
  'a_la_fin',
  'apres',
];

const List<String> _pinnedFamilySlugs = <String>[
  'add',
  'remove',
  'compare',
  'group',
  'share',
  'ask',
];

MathWord _word(String key, {String notion = 'n', String example = 'Un test.'}) {
  return MathWord(
    wordKey: key,
    familySlug: 'add',
    notion: notion,
    text: key,
    meaning: 'Sens.',
    example: example,
    surface: key,
  );
}

void main() {
  final MathWordDomain domain = buildMathWordDomain();
  final MathWordCatalog catalog = domain.catalog;
  final List<MathWord> words = catalog.words;

  group('MathWordCatalog', () {
    test('holds the 40 words of the table, with their keys pinned', () {
      // Assert
      expect(
        words.map((MathWord word) => word.wordKey).toList(),
        _pinnedWordKeys,
      );
      expect(
        words.map((MathWord word) => word.key),
        everyElement(startsWith('word:')),
      );
    });

    test('groups them in six families, in the order of the path', () {
      // Assert
      expect(
        catalog.families.map((MathWordFamily family) => family.slug).toList(),
        _pinnedFamilySlugs,
      );
      expect(
        catalog.families.map((MathWordFamily family) => family.number),
        <int>[1, 2, 3, 4, 5, 6],
      );
      expect(
        catalog.families.map((MathWordFamily family) => family.words.length),
        <int>[7, 7, 7, 6, 7, 6],
      );
      expect(catalog.families.first.key, 'word:add');
    });

    test('never gives a family the key of a word', () {
      // Assert
      final Set<String> itemKeys = words.map((MathWord w) => w.key).toSet();
      for (final MathWordFamily family in catalog.families) {
        expect(itemKeys, isNot(contains(family.key)));
      }
    });

    test('holds the 20 statements, each with a known operation and words', () {
      // Assert
      expect(catalog.statements, hasLength(20));
      expect(
        catalog.statements
            .map((OperationStatement statement) => statement.operation)
            .toSet(),
        OperationStatement.arithmetic,
      );
      for (final OperationStatement statement in catalog.statements) {
        expect(statement.wordKeys, isNotEmpty, reason: statement.id);
        for (final String key in statement.wordKeys) {
          expect(catalog.wordOf(key), isNotNull, reason: statement.id);
        }
      }
    });

    test('gives every word a notion, an example with its own form', () {
      for (final MathWord word in words) {
        // Assert
        expect(word.notion, isNotEmpty, reason: word.key);
        expect(
          word.example.toLowerCase(),
          contains(word.surface.toLowerCase()),
          reason: word.key,
        );
      }
    });

    test('refuses a duplicated key and a statement on an unknown word', () {
      // Assert
      expect(
        () => MathWordCatalog(
          words: <MathWord>[_word('a'), _word('a')],
          statements: const <OperationStatement>[],
        ),
        throwsFormatException,
      );
      expect(
        () => MathWordCatalog(
          words: <MathWord>[_word('a')],
          statements: <OperationStatement>[
            OperationStatement(
              id: 'OP-1',
              text: 'Texte.',
              operation: MathOperator.add,
              wordKeys: const <String>['b'],
            ),
          ],
        ),
        throwsFormatException,
      );
    });

    test('refuses a statement that asks for a comparison', () {
      // Assert
      for (final String operation in <String>['lessThan', 'equalTo', 'power']) {
        expect(
          () => MathWordCatalog.fromJson(<String, Object?>{
            'words': <Object?>[],
            'statements': <Object?>[
              <String, Object?>{
                'id': 'OP-1',
                'text': 'Texte.',
                'operation': operation,
                'keys': <String>[],
              },
            ],
          }),
          throwsFormatException,
          reason: operation,
        );
      }
    });

    test('refuses a data asset of the wrong shape', () {
      // Assert
      expect(
        () => MathWordCatalog.fromJson(<String, Object?>{'words': 3}),
        throwsFormatException,
      );
      expect(
        () => MathWordCatalog.fromJson(<String, Object?>{
          'words': <Object?>[
            <String, Object?>{'key': 'a'},
          ],
          'statements': <Object?>[],
        }),
        throwsFormatException,
      );
      expect(
        () => MathWordCatalog.fromJson(<String, Object?>{
          'words': <Object?>[],
          'statements': <Object?>[
            <String, Object?>{
              'id': 'OP-1',
              'text': 'Texte.',
              'operation': 'power',
              'keys': <String>[],
            },
          ],
        }),
        throwsFormatException,
      );
    });

    test('cuts the example so the word and the others can be touched', () {
      // Arrange
      final MathWord word = catalog.wordOf('en_plus')!;
      // Act
      final List<SentencePart> actualParts = catalog.sentenceOf(word);
      // Assert
      expect(
        actualParts.map((SentencePart part) => part.text).join(),
        word.example,
      );
      expect(
        actualParts
            .where((SentencePart part) => part.wordKey == 'en_plus')
            .map((SentencePart part) => part.text),
        <String>['en plus'],
      );
      for (final SentencePart part in actualParts) {
        if (part.wordKey != null) {
          expect(catalog.wordOf(part.wordKey!), isNotNull);
        }
      }
    });

    test('makes the word of every example touchable', () {
      for (final MathWord word in words) {
        // Act
        final List<SentencePart> actualParts = catalog.sentenceOf(word);
        // Assert
        expect(
          actualParts.map((SentencePart part) => part.text).join(),
          word.example,
          reason: word.key,
        );
        expect(
          actualParts.any((SentencePart part) => part.wordKey == word.wordKey),
          isTrue,
          reason: word.key,
        );
      }
    });
  });

  group('MathWordDomain', () {
    test('is the domain math_words, its units the families', () {
      // Assert
      expect(domain.id, 'math_words');
      expect(domain.units, same(domain.path));
      expect(
        domain.units.map((LearningUnit unit) => unit.key),
        _pinnedFamilySlugs.map((String slug) => 'word:$slug'),
      );
    });

    test('finds a word and a family by key, and nothing else', () {
      // Assert
      expect(domain.findItem('word:il_reste')?.wordKey, 'il_reste');
      expect(domain.findItem('word:remove'), isNull);
      expect(domain.findItem('mul:7x8'), isNull);
      expect(domain.findUnit('word:remove')?.slug, 'remove');
      expect(domain.findUnit('word:il_reste'), isNull);
      expect(domain.findUnit('num:compare'), isNull);
    });

    test('asks the operation only of the words a statement uses', () {
      // Arrange
      final Set<String> used = <String>{
        for (final OperationStatement statement in catalog.statements)
          ...statement.wordKeys,
      };
      for (final MathWord word in words) {
        // Act
        final List<String> actualTypes = domain.questionTypeIdsOf(word);
        // Assert
        expect(
          actualTypes.contains(QuestionTypeIds.whichOperation),
          used.contains(word.wordKey),
          reason: word.key,
        );
        expect(
          actualTypes,
          containsAll(<String>[
            QuestionTypeIds.listenAndTouch,
            QuestionTypeIds.wordAndImage,
            QuestionTypeIds.touchToUnderstand,
          ]),
        );
        expect(domain.questionTypeIds, containsAll(actualTypes));
      }
    });

    test('draws every word equally, with no mirror', () {
      for (final MathWord word in words) {
        // Assert
        expect(domain.drawWeightOf(word), 1);
        expect(domain.mirrorOf(word), isNull);
      }
    });

    test('describes a word and helps with the words of its family', () {
      // Arrange
      final MathWord word = catalog.wordOf('il_reste')!;
      // Act
      final ItemHelp actualHelp = domain.helpOf(word);
      // Assert
      expect(domain.describeItem(word), <PromptToken>[
        const TextToken('il reste'),
      ]);
      expect(actualHelp.unitFacts, hasLength(7));
      expect(actualHelp.unitFacts[actualHelp.itemIndex], <PromptToken>[
        const TextToken('il reste'),
      ]);
      expect(
        actualHelp.picture,
        const WordPicture(wordKey: 'il_reste', label: 'il reste'),
      );
    });

    test('refuses an item that is not a word', () {
      // Assert
      expect(
        () => domain.describeItem(const _Alien()),
        throwsArgumentError,
      );
    });

    test('refuses a format that does not fit the word', () {
      // Arrange
      final MathWord word = words.firstWhere(
        (MathWord word) => !domain
            .questionTypeIdsOf(word)
            .contains(QuestionTypeIds.whichOperation),
      );
      // Assert
      expect(
        () => domain.buildQuestion(
          item: word,
          questionTypeId: QuestionTypeIds.whichOperation,
          random: DartRandomSource(seed: 1),
        ),
        throwsArgumentError,
      );
    });
  });

  group('Listen and touch', () {
    test('offers four drawings of four notions, never one of the same', () {
      for (final MathWord word in words) {
        for (int seed = 0; seed < 25; seed++) {
          // Act
          final Question actualQuestion = domain.buildQuestion(
            item: word,
            questionTypeId: QuestionTypeIds.listenAndTouch,
            random: DartRandomSource(seed: seed),
          );
          // Assert
          final List<MathWord> offered = <MathWord>[
            for (final Answer choice in actualQuestion.choices)
              catalog.wordOf((choice as WordAnswer).wordKey)!,
          ];
          expect(offered, hasLength(4), reason: word.key);
          expect(
            offered.map((MathWord other) => other.notion).toSet(),
            hasLength(4),
            reason: '${word.key} seed $seed',
          );
          expect(offered, contains(word));
          expect(actualQuestion.expectedAnswer, MathWordDomain.answerOf(word));
          expect(actualQuestion.prompt, <PromptToken>[TextToken(word.text)]);
          expect(actualQuestion.itemKey, word.key);
          expect(
            actualQuestion.unitKey,
            'word:${word.familySlug}',
          );
        }
      }
    });

    test('builds the same question from the same seed', () {
      // Arrange
      final MathWord word = words.first;
      Question build() => domain.buildQuestion(
        item: word,
        questionTypeId: QuestionTypeIds.listenAndTouch,
        random: DartRandomSource(seed: 9),
      );
      // Assert
      expect(build(), build());
    });
  });

  group('Word and image', () {
    test('ties four words of four notions to their four drawings', () {
      for (final MathWord word in words) {
        for (int seed = 0; seed < 10; seed++) {
          // Act
          final Question actualQuestion = domain.buildQuestion(
            item: word,
            questionTypeId: QuestionTypeIds.wordAndImage,
            random: DartRandomSource(seed: seed),
          );
          // Assert
          expect(actualQuestion.pairs, hasLength(4), reason: word.key);
          expect(actualQuestion.itemKeys, contains(word.key));
          expect(
            actualQuestion.pairs
                .map(
                  (QuestionPair pair) =>
                      catalog.wordOf((pair.operation as WordAnswer).wordKey)!,
                )
                .map((MathWord other) => other.notion)
                .toSet(),
            hasLength(4),
          );
          for (final QuestionPair pair in actualQuestion.pairs) {
            expect(pair.operation, pair.result);
            expect(pair.itemKey, 'word:${(pair.result as WordAnswer).wordKey}');
          }
          expect(
            actualQuestion.choices.toSet(),
            actualQuestion.pairs
                .map((QuestionPair pair) => pair.result)
                .toSet(),
          );
          expect(actualQuestion.expectedAnswer, PairsAnswer());
        }
      }
    });
  });

  group('Touch to understand', () {
    test('shows the example and expects the word asked', () {
      // Arrange
      final MathWord word = catalog.wordOf('il_reste')!;
      // Act
      final Question actualQuestion = domain.buildQuestion(
        item: word,
        questionTypeId: QuestionTypeIds.touchToUnderstand,
        random: DartRandomSource(seed: 1),
      );
      // Assert
      expect(actualQuestion.prompt, <PromptToken>[TextToken(word.example)]);
      expect(actualQuestion.sentence, catalog.sentenceOf(word));
      expect(actualQuestion.choices, isEmpty);
      expect(actualQuestion.expectedAnswer, MathWordDomain.answerOf(word));
    });
  });

  group('Which operation', () {
    test('reads a statement of the word and expects its operation', () {
      final Set<MathOperator> seen = <MathOperator>{};
      for (final MathWord word in words) {
        if (!domain
            .questionTypeIdsOf(word)
            .contains(QuestionTypeIds.whichOperation)) {
          continue;
        }
        for (int seed = 0; seed < 10; seed++) {
          // Act
          final Question actualQuestion = domain.buildQuestion(
            item: word,
            questionTypeId: QuestionTypeIds.whichOperation,
            random: DartRandomSource(seed: seed),
          );
          // Assert
          final OperationStatement statement = catalog.statements.singleWhere(
            (OperationStatement s) =>
                actualQuestion.prompt.single == TextToken(s.text),
          );
          expect(statement.wordKeys, contains(word.wordKey));
          expect(
            actualQuestion.expectedAnswer,
            OperatorAnswer(statement.operation),
          );
          expect(actualQuestion.choices, OperatorAnswer.all);
          seen.add(statement.operation);
        }
      }
      expect(seen, OperationStatement.arithmetic);
    });
  });
}

final class _Alien implements LearningItem {
  const _Alien();

  @override
  String get key => 'mul:7x8';
}
