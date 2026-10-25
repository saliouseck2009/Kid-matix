import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kid_matix/core/entities/domain_placement.dart';
import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_progress_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/domain_progress.dart';
import 'package:kid_matix/features/classroom/domain/entities/program_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_report_row.dart';
import 'package:kid_matix/features/classroom/domain/services/class_progress_calculator.dart';
import 'package:kid_matix/features/classroom/domain/services/program_report_calculator.dart';
import 'package:kid_matix/features/classroom/presentation/report/class_report_files.dart';
import 'package:kid_matix/features/classroom/presentation/report/program_report_files.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

PupilReportRow _row(int number, String nickname, int from, int to) {
  return PupilReportRow(
    number: number,
    nickname: nickname,
    levelsFrom: <String, DomainPlacement>{
      'addition': DomainPlacement(
        domainId: 'addition',
        level: from,
        skillCount: 2,
      ),
    },
    levelsTo: <String, DomainPlacement>{
      'addition': DomainPlacement(
        domainId: 'addition',
        level: to,
        skillCount: 2,
      ),
    },
    wordsFrom: (understood: from * 3, asked: 12),
    wordsTo: (understood: to * 6, asked: 12),
    practiceTime: const Duration(minutes: 30),
    sessionCount: 3,
    acquiredItemCount: 10,
  );
}

ClassProgressReport _class(String name, List<PupilReportRow> pupils) {
  return ClassProgressReport(
    classroomName: name,
    to: AssessmentPeriod(
      key: 'fin',
      label: 'Fin',
      startedAt: DateTime(2026, 11),
      assessmentIds: const <String>['a2'],
    ),
    generatedAt: DateTime(2026, 11, 2),
    domains: <DomainProgress>[
      ClassProgressCalculator.progressIn('addition', pupils),
    ],
    pupils: pupils,
    practiceTime: Duration.zero,
    sessionCount: 0,
    acquiredItemCount: 0,
  );
}

ProgramReport _report() {
  return ProgramReportCalculator.compute(
    classes: <ClassProgressReport>[
      _class('CE1 A', <PupilReportRow>[
        _row(1, 'Awa', 0, 1),
        _row(2, 'Moussa', 1, 1),
      ]),
      _class('CE1 B', <PupilReportRow>[_row(1, 'Fatou', 0, 2)]),
    ],
    fromLabel: 'Début',
    toLabel: 'Fin',
    generatedAt: DateTime(2026, 11, 2),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => initializeDateFormatting('fr'));

  test('consolidates the classes, the total over every pupil', () {
    // Act
    final ProgramReport actual = _report();
    // Assert
    expect(actual.classes.map((ProgramReportRow r) => r.name), <String>[
      'CE1 A',
      'CE1 B',
    ]);
    expect(actual.domainIds, <String>['addition']);
    final ProgramReportRow actualTotal = actual.total;
    expect(actualTotal.name, isNull);
    expect(actualTotal.pupilCount, 3);
    expect(actualTotal.assessedToCount, 3);
    expect(actualTotal.domainOf('addition')?.averageFrom, closeTo(1 / 6, 1e-9));
    expect(actualTotal.domainOf('addition')?.averageTo, closeTo(4 / 6, 1e-9));
    expect(actualTotal.domainOf('addition')?.progressedCount, 2);
    expect(actualTotal.practiceTime, const Duration(minutes: 90));
    expect(actualTotal.acquiredItemCount, 30);
    expect(actual.classes.first.domainOf('addition')?.averageTo, 0.5);
  });

  test('writes an anonymous table: classes and figures, no pupil', () async {
    // Act
    final List<SharedFile> actual = await ProgramReportFiles(
      l10n: lookupAppLocalizations(const Locale('fr')),
    ).filesOf(_report(), ReportFileKind.csv);
    // Assert
    final String actualText = utf8.decode(actual.single.bytes);
    expect(
      actual.single.name,
      'KidMatix-Rapport-Programme-2026-11-02-anonyme.csv',
    );
    expect(actualText, contains('CE1 A;2;2;2;25;50;'));
    expect(actualText, contains('Toutes les classes;3;3;3;'));
    for (final String nickname in <String>['Awa', 'Moussa', 'Fatou']) {
      expect(actualText, isNot(contains(nickname)));
    }
  });

  test('prints the program report as a PDF', () async {
    // Act
    final List<SharedFile> actual = await ProgramReportFiles(
      l10n: lookupAppLocalizations(const Locale('fr')),
    ).filesOf(_report(), ReportFileKind.pdf);
    // Assert
    expect(ascii.decode(actual.single.bytes.take(5).toList()), '%PDF-');
  });
}
