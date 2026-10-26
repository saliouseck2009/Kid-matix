import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_rules.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/services/assessment_periods.dart';

ClassAssessment _assessment(String id, String label, int day) {
  return ClassAssessment(
    id: id,
    classroomId: 'c1',
    periodLabel: label,
    openedAt: DateTime(2026, 10, day),
    updatedAt: DateTime(2026, 10, day),
  );
}

AssessmentResult _result(String assessmentId, String pupilId, int day) {
  return AssessmentResult(
    assessmentId: assessmentId,
    pupilId: pupilId,
    takenAt: DateTime(2026, 10, day),
    levels: const [],
    words: const [],
  );
}

void main() {
  group('AssessmentRules', () {
    test('cleans a label and refuses an empty or long one', () {
      // Assert
      expect(
        AssessmentRules.cleanLabel('  Début   d\'année '),
        "Début d'année",
      );
      expect(AssessmentRules.cleanLabel('   '), isNull);
      expect(AssessmentRules.cleanLabel('x' * 31), isNull);
      expect(AssessmentRules.cleanLabel('x' * 30), 'x' * 30);
    });

    test('gives one period key to the same label written twice', () {
      // Assert
      expect(
        AssessmentRules.periodKeyOf("Début d'année"),
        AssessmentRules.periodKeyOf(" debut  D'ANNEE "),
      );
      expect(
        AssessmentRules.periodKeyOf('Début'),
        isNot(AssessmentRules.periodKeyOf('Fin')),
      );
      for (final String apostrophe in <String>['’', '‘', 'ʼ']) {
        expect(
          AssessmentRules.periodKeyOf('Fin d${apostrophe}année'),
          AssessmentRules.periodKeyOf("Fin d'année"),
        );
      }
    });

    test('reads back the assessment of its word check only', () {
      // Act
      final String actualKey = AssessmentRules.sourceKeyOf('a-1');
      // Assert
      expect(AssessmentRules.assessmentIdOf(actualKey), 'a-1');
      expect(AssessmentRules.assessmentIdOf('path:mul:5:speed'), isNull);
      expect(AssessmentRules.assessmentIdOf('assessment:'), isNull);
      expect(AssessmentRules.assessmentIdOf(null), isNull);
    });
  });

  group('AssessmentPeriods', () {
    test('groups the assessments of one period, earliest first', () {
      // Arrange
      final List<ClassAssessment> inputAssessments = <ClassAssessment>[
        _assessment('a3', 'Fin', 28),
        _assessment('a1', 'Début', 1),
        _assessment('a2', 'début', 2),
      ];
      // Act
      final List<AssessmentPeriod> actual = AssessmentPeriods.of(
        inputAssessments,
      );
      // Assert
      expect(actual.map((AssessmentPeriod p) => p.label), <String>[
        'Début',
        'Fin',
      ]);
      expect(actual.first.assessmentIds, <String>['a1', 'a2']);
      expect(actual.first.startedAt, DateTime(2026, 10));
    });

    test('keeps the latest result of a pupil in a period', () {
      // Arrange
      final AssessmentPeriod inputPeriod = AssessmentPeriods.of(
        <ClassAssessment>[
          _assessment('a1', 'Début', 1),
          _assessment('a2', 'Début', 2),
        ],
      ).single;
      // Act
      final Map<String, AssessmentResult> actual = AssessmentPeriods.resultsIn(
        inputPeriod,
        <AssessmentResult>[
          _result('a2', 'p1', 5),
          _result('a1', 'p1', 3),
          _result('a1', 'p2', 3),
          _result('other', 'p3', 3),
        ],
      );
      // Assert
      expect(actual.keys, unorderedEquals(<String>['p1', 'p2']));
      expect(actual['p1']!.assessmentId, 'a2');
    });
  });
}
