import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kid_matix/core/entities/domain_placement.dart';
import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_progress_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/domain_progress.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_report_row.dart';
import 'package:kid_matix/features/classroom/presentation/report/class_report_files.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

ClassProgressReport _report() {
  return ClassProgressReport(
    classroomName: 'CE1 B',
    from: AssessmentPeriod(
      key: 'debut',
      label: "Début d'année",
      startedAt: DateTime(2026, 10, 1),
      assessmentIds: const <String>['a1'],
    ),
    to: AssessmentPeriod(
      key: 'fin',
      label: 'Fin',
      startedAt: DateTime(2026, 11, 1),
      assessmentIds: const <String>['a2'],
    ),
    generatedAt: DateTime(2026, 11, 2),
    domains: const <DomainProgress>[
      DomainProgress(
        domainId: 'addition',
        averageFrom: 0.5,
        averageTo: 1,
        assessedFromCount: 1,
        assessedToCount: 1,
        progressedCount: 1,
      ),
    ],
    pupils: <PupilReportRow>[
      PupilReportRow(
        number: 1,
        nickname: 'Awa',
        levelsFrom: const <String, DomainPlacement>{
          'addition': DomainPlacement(
            domainId: 'addition',
            level: 1,
            skillCount: 2,
          ),
        },
        levelsTo: const <String, DomainPlacement>{
          'addition': DomainPlacement(
            domainId: 'addition',
            level: 2,
            skillCount: 2,
          ),
        },
        wordsFrom: (understood: 4, asked: 12),
        wordsTo: (understood: 9, asked: 12),
        practiceTime: const Duration(minutes: 75),
        sessionCount: 6,
        acquiredItemCount: 14,
      ),
    ],
    practiceTime: const Duration(minutes: 75),
    sessionCount: 6,
    acquiredItemCount: 14,
    wordsFrom: 4 / 12,
    wordsTo: 9 / 12,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final AppLocalizations l10n = lookupAppLocalizations(const Locale('fr'));

  setUpAll(() => initializeDateFormatting('fr'));

  test('prints the report as a PDF with the app fonts', () async {
    // Act
    final SharedFile actual = await ClassReportFiles(
      l10n: l10n,
    ).fileOf(_report(), ReportFileKind.pdf);
    // Assert
    expect(actual.name, 'KidMatix-Rapport-CE1-B-2026-11-02.pdf');
    expect(actual.mimeType, SharedFile.pdfType);
    expect(ascii.decode(actual.bytes.take(5).toList()), '%PDF-');
  });

  test('writes the pupils as a CSV table for spreadsheets', () async {
    // Act
    final SharedFile actual = await ClassReportFiles(
      l10n: l10n,
    ).fileOf(_report(), ReportFileKind.csv);
    // Assert
    final List<String> actualLines = utf8
        .decode(actual.bytes)
        .replaceFirst('﻿', '')
        .trim()
        .split('\r\n');
    expect(actual.name, 'KidMatix-Rapport-CE1-B-2026-11-02.csv');
    expect(
      actualLines.first,
      'Élève;+ et − début;+ et − fin;Mots début;Mots fin;'
      'Pratique (min);Acquis;Séances',
    );
    expect(actualLines[1], 'Awa;50;100;4;9;75;14;6');
  });
}
