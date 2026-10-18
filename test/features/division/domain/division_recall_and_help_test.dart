import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/item_help.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/features/division/domain/entities/division_fact.dart';
import 'package:kid_matix/features/division/domain/entities/division_unit.dart';
import 'package:kid_matix/features/division/domain/services/division_domain.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_fact.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_table.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/l10n/app_localizations_fr.dart';

void main() {
  final DivisionDomain domain = DivisionDomain();
  final MultiplicationDomain multiplication = MultiplicationDomain();
  final DivisionFact fact = domain.findItem('div:56/7')!;

  group('recall of the multiplication', () {
    test('recalls 7 × 8 = 56 after a mistake on 56 ÷ 7', () {
      // Act
      final LearningItem actual = domain.mirrorOf(fact);
      // Assert
      expect(domain.describeItem(actual).toDisplayText(), '7 × 8 = 56');
    });
    test('says the recall in words for a screen reader', () {
      // Act
      final String actual = domain
          .describeItem(domain.mirrorOf(fact))
          .toSpokenText(AppLocalizationsFr());
      // Assert
      expect(actual, '7 fois 8 égale 56');
    });
    test(
      'recalls the multiplication fact of the same numbers, for all 120',
      () {
        for (final MultiplicationTable table in multiplication.tables) {
          for (final MultiplicationFact product in table.facts) {
            // Act
            final DivisionFact division = domain.findItem(
              'div:${product.product}/${product.table}',
            )!;
            final String actual = domain
                .describeItem(domain.mirrorOf(division))
                .toDisplayText();
            // Assert
            expect(
              actual,
              multiplication.describeItem(product).toDisplayText(),
              reason: division.key,
            );
          }
        }
      },
    );
    test('keeps the recall out of the items that have a progress', () {
      // Act
      final LearningItem actual = domain.mirrorOf(fact);
      // Assert
      expect(actual.key, 'recall:div:56/7');
      expect(domain.findItem(actual.key), isNull);
    });
    test('describes a division with its quotient', () {
      // Assert
      expect(domain.describeItem(fact).toDisplayText(), '56 ÷ 7 = 8');
      expect(
        domain.describeItem(fact).toSpokenText(AppLocalizationsFr()),
        '56 divisé par 7 égale 8',
      );
    });
    test('refuses to recall an item that is not a division', () {
      // Assert
      expect(
        () => domain.mirrorOf(multiplication.tables.first.facts.first),
        throwsArgumentError,
      );
    });
  });

  group('help', () {
    test('shares 56 into 7 equal rows of 8 dots', () {
      // Act
      final ItemHelp actual = domain.helpOf(fact);
      // Assert
      expect(actual.dotGrid, const DotGrid(rows: 7, columns: 8));
    });
    test('lists the divisions by 7 and highlights 56 ÷ 7', () {
      // Act
      final ItemHelp actual = domain.helpOf(fact);
      // Assert
      expect(actual.unitFacts, hasLength(10));
      expect(
        domain.describeItem(domain.units[6].facts[actual.itemIndex]),
        actual.unitFacts[actual.itemIndex],
      );
      expect(actual.itemIndex, 7);
    });
    test('gives a help card to every division', () {
      for (final DivisionUnit unit in domain.units) {
        for (final DivisionFact each in unit.facts) {
          // Act
          final ItemHelp actual = domain.helpOf(each);
          // Assert
          expect(
            actual.dotGrid,
            DotGrid(rows: each.divisor, columns: each.quotient),
          );
          expect(actual.itemIndex, each.quotient - 1);
        }
      }
    });
  });
}
