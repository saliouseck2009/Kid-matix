import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/domain_placement.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_progress_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_report_row.dart';
import 'package:kid_matix/features/classroom/domain/services/report_anonymizer.dart';

void main() {
  test('keeps every figure and replaces each nickname by a number', () {
    // Arrange
    final ClassProgressReport inputReport = ClassProgressReport(
      classroomName: 'CE1',
      to: AssessmentPeriod(
        key: 'fin',
        label: 'Fin',
        startedAt: DateTime(2026, 11),
        assessmentIds: const <String>['a2'],
      ),
      generatedAt: DateTime(2026, 11, 2),
      domains: const [],
      pupils: <PupilReportRow>[
        for (final (int number, String nickname) in <(int, String)>[
          (1, 'Awa'),
          (2, 'Moussa'),
        ])
          PupilReportRow(
            number: number,
            nickname: nickname,
            levelsFrom: const <String, DomainPlacement>{},
            levelsTo: const <String, DomainPlacement>{
              'numbers': DomainPlacement(
                domainId: 'numbers',
                level: 1,
                skillCount: 1,
              ),
            },
            wordsTo: (understood: number, asked: 12),
            practiceTime: Duration(minutes: number),
            sessionCount: number,
            acquiredItemCount: number,
          ),
      ],
      practiceTime: const Duration(minutes: 3),
      sessionCount: 3,
      acquiredItemCount: 3,
    );
    // Act
    final ClassProgressReport actual = ReportAnonymizer.anonymize(inputReport);
    // Assert
    expect(actual.isAnonymous, isTrue);
    expect(actual.pupils.map((PupilReportRow r) => r.nickname), <String?>[
      null,
      null,
    ]);
    expect(actual.pupils.map((PupilReportRow r) => r.number), <int>[1, 2]);
    expect(actual.pupils.last.wordsTo, (understood: 2, asked: 12));
    expect(actual.pupils.last.levelsTo['numbers']?.level, 1);
    expect(actual.sessionCount, inputReport.sessionCount);
    expect(inputReport.pupils.first.nickname, 'Awa');
  });
}
