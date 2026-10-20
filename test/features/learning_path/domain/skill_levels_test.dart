import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/features/learning_path/domain/entities/skill_level.dart';
import 'package:kid_matix/features/learning_path/domain/entities/skill_levels.dart';

import '../../quiz/helpers/quiz_fixtures.dart';

void main() {
  final DomainRegistry domains = buildDomainRegistry();

  group('SkillLevels', () {
    test('climb numbers, addition, subtraction, multiplication, division', () {
      // Assert
      expect(
        SkillLevels.all.map((SkillLevel skill) => skill.id),
        <String>[
          'numbers',
          'addition',
          'subtraction',
          'multiplication',
          'division',
        ],
      );
      expect(SkillLevels.domainIds, <String>[
        'numbers',
        'addition',
        'multiplication',
        'division',
      ]);
    });

    test('name only units of their domain, in the order of its path', () {
      for (final SkillLevel skill in SkillLevels.all) {
        // Arrange
        final LearningDomain domain = domains.find(skill.domainId)!;
        final List<String> pathKeys = <String>[
          for (final LearningUnit unit in domain.path) unit.key,
        ];
        // Assert
        for (final String key in skill.unitKeys) {
          expect(domain.findUnit(key), isNotNull, reason: key);
        }
        final List<String> actualOrder = <String>[
          for (final String key in pathKeys)
            if (skill.unitKeys.contains(key)) key,
        ];
        expect(skill.unitKeys, actualOrder, reason: skill.id);
      }
    });

    test('together cover every unit of the multiplication and division', () {
      for (final SkillLevel skill in <SkillLevel>[
        SkillLevels.multiplication,
        SkillLevels.division,
      ]) {
        // Assert
        expect(
          skill.unitKeys,
          domains.find(skill.domainId)!.path.map((LearningUnit u) => u.key),
        );
      }
    });

    test('ask only questions the keypad can answer', () {
      for (final SkillLevel skill in SkillLevels.all) {
        final LearningDomain domain = domains.find(skill.domainId)!;
        for (final String key in skill.probeUnitKeys) {
          for (final LearningItem item in domain.findUnit(key)!.items) {
            // Assert
            expect(
              domain.questionTypeIdsOf(item),
              contains(QuestionTypeIds.typedAnswer),
              reason: item.key,
            );
          }
        }
      }
    });

    test('keep a typical question in each of their units, easy to hard', () {
      for (final SkillLevel skill in SkillLevels.all) {
        final List<int> actualRanks = <int>[
          for (final String key in skill.probeUnitKeys)
            skill.unitKeys.indexOf(key),
        ];
        // Assert
        expect(actualRanks, everyElement(isNonNegative), reason: skill.id);
        expect(actualRanks, <int>[...actualRanks]..sort(), reason: skill.id);
        expect(actualRanks.toSet(), hasLength(actualRanks.length));
      }
    });
  });

  group('SkillLevel', () {
    test('lists the units up to one, and none for an unknown unit', () {
      // Assert
      expect(SkillLevels.addition.unitKeysUpTo('addsub:add9'), <String>[
        'addsub:add5',
        'addsub:add7',
        'addsub:add9',
      ]);
      expect(SkillLevels.addition.unitKeysUpTo('mul:7'), isEmpty);
    });

    test('is missed after two wrong answers among three', () {
      // Assert
      expect(SkillLevels.numbers.failureMark, 2);
      expect(SkillLevel.passMark, 2);
    });
  });
}
