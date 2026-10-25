import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessments_overview.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_progress_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/entities/domain_progress.dart';
import 'package:kid_matix/features/classroom/domain/entities/program_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_report_row.dart';
import 'package:kid_matix/features/classroom/domain/services/report_anonymizer.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_class_assessments_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_class_report_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_program_report_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/select_pupil_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/report/class_report_files.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

import '../features/classroom/helpers/classroom_device.dart';
import '../helpers/in_memory_local_storage.dart';
import 'helpers/assessment_journey.dart';
import 'helpers/test_app.dart';

/// Lot F31 "done when": two assessments one month apart give a class PDF
/// report that shows the progress, with no nickname in its anonymous
/// version; over the real wiring, an on-disk database and a fake clock.
void main() {
  late Directory databaseFolder;
  late MovableClock clock;

  setUpAll(() => initializeDateFormatting('fr'));

  setUp(() async {
    databaseFolder = await Directory.systemTemp.createTemp('kid_matix_');
    clock = MovableClock(DateTime(2026, 10, 1, 8));
    await TestApp.start(
      databasesPath: databaseFolder.path,
      storage: InMemoryLocalStorage(),
      clock: clock,
    );
  });

  tearDown(() async {
    await TestApp.stop();
    await databaseFolder.delete(recursive: true);
  });

  /// Each pupil of [roster] takes [assessment]: the placement test right
  /// on its first [rightPlacement] questions, [rightWords] words.
  Future<void> assess(
    ClassroomRoster roster,
    ClassAssessment assessment, {
    required int rightPlacement,
    required int rightWords,
  }) async {
    for (final PupilEntity pupil in roster.pupils) {
      clock.current = clock.current.add(const Duration(minutes: 10));
      await AssessmentJourney.take(
        pupilId: pupil.id,
        assessmentId: assessment.id,
        rightPlacement: rightPlacement,
        rightWords: rightWords,
        clock: clock,
      );
    }
  }

  /// Each pupil of [roster] plays the Discovery of the table of 2.
  Future<void> practise(ClassroomRoster roster) async {
    for (final PupilEntity pupil in roster.pupils) {
      await sl<SelectPupilUseCase>()(params: pupil.id);
      final QuizBloc bloc = TestApp.quizBloc(completedAt: clock);
      await TestApp.startQuiz(
        bloc,
        TestApp.stageRequest(
          profileId: pupil.id,
          unitKey: 'mul:2',
          stage: StageKind.discovery,
        ),
      );
      await TestApp.playToEnd(bloc);
      await bloc.close();
    }
  }

  test('two assessments a month apart give a report of the progress, '
      'anonymous without any nickname', () async {
    // Arrange: a class of 3, assessed on 1 October.
    final ClassroomRoster roster = await AssessmentJourney.createClass(
      'CE1 B',
      3,
      nicknames: <String>['Awa', 'Moussa', 'Fatou'],
    );
    final ClassAssessment start = await AssessmentJourney.open(
      roster.classroom.id,
      'Début de période',
    );
    await assess(roster, start, rightPlacement: 2, rightWords: 3);
    // Practice during the month, then the end of period on 1 November.
    clock.current = DateTime(2026, 10, 15, 9);
    await practise(roster);
    clock.current = DateTime(2026, 11, 1, 8);
    final ClassAssessment end = await AssessmentJourney.open(
      roster.classroom.id,
      'Fin de période',
    );
    await assess(roster, end, rightPlacement: 15, rightWords: 9);
    // Act
    final ClassAssessmentsOverview overview =
        ((await sl<GetClassAssessmentsUseCase>()(
          params: roster.classroom.id,
        )) as DataSuccess<ClassAssessmentsOverview>).data;
    final List<AssessmentPeriod> periods = overview.periods;
    final ClassProgressReport actual = ((await sl<GetClassReportUseCase>()(
      params: (
        classroomId: roster.classroom.id,
        fromKey: periods.first.key,
        toKey: periods.last.key,
      ),
    )) as DataSuccess<ClassProgressReport>).data;
    final List<SharedFile> actualFiles = await ClassReportFiles(
      l10n: lookupAppLocalizations(const Locale('fr')),
    ).filesOf(actual, ReportFileKind.pdf);
    final List<SharedFile> actualTables = await ClassReportFiles(
      l10n: lookupAppLocalizations(const Locale('fr')),
    ).filesOf(actual, ReportFileKind.csv);
    // Assert: the progress between the two periods, a month apart.
    expect(actual.from?.label, 'Début de période');
    expect(actual.to.label, 'Fin de période');
    expect(
      actual.to.startedAt.difference(actual.from!.startedAt).inDays,
      31,
    );
    final DomainProgress actualAddition = actual.domains.firstWhere(
      (DomainProgress domain) => domain.domainId == 'addition',
    );
    expect(actualAddition.gain, greaterThan(0));
    expect(actualAddition.progressedCount, 3);
    expect(actual.wordsTo, greaterThan(actual.wordsFrom!));
    expect(actual.sessionCount, greaterThanOrEqualTo(3));
    expect(actual.pupils.map((PupilReportRow row) => row.nickname), <String>[
      'Awa',
      'Moussa',
      'Fatou',
    ]);
    // Assert: a PDF and its anonymous version, with no nickname.
    expect(actualFiles.map((SharedFile file) => file.name), <String>[
      'KidMatix-Rapport-CE1-B-2026-11-01.pdf',
      'KidMatix-Rapport-CE1-B-2026-11-01-anonyme.pdf',
    ]);
    for (final SharedFile file in actualFiles) {
      expect(ascii.decode(file.bytes.take(5).toList()), '%PDF-');
    }
    final ClassProgressReport actualAnonymous = ReportAnonymizer.anonymize(
      actual,
    );
    expect(
      actualAnonymous.pupils.every(
        (PupilReportRow row) => row.nickname == null,
      ),
      isTrue,
    );
    final String actualAnonymousTable = utf8.decode(actualTables.last.bytes);
    for (final PupilEntity pupil in roster.pupils) {
      expect(actualAnonymousTable, isNot(contains(pupil.nickname)));
      expect(actualAnonymousTable, isNot(contains(pupil.id)));
    }
    expect(actualAnonymousTable, contains('Élève 1;'));
    expect(utf8.decode(actualTables.first.bytes), contains('Awa;'));
  });

  test('a coordinator consolidates the classes of the device', () async {
    // Arrange: two classes, each assessed once at the start and once at
    // the end.
    for (final String name in <String>['CE1 A', 'CE1 B']) {
      final ClassroomRoster roster = await AssessmentJourney.createClass(
        name,
        2,
      );
      clock.current = DateTime(2026, 10, 1, 8);
      final ClassAssessment start = await AssessmentJourney.open(
        roster.classroom.id,
        'Début',
      );
      await assess(roster, start, rightPlacement: 2, rightWords: 2);
      clock.current = DateTime(2026, 11, 1, 8);
      final ClassAssessment end = await AssessmentJourney.open(
        roster.classroom.id,
        'Fin',
      );
      await assess(roster, end, rightPlacement: 15, rightWords: 8);
    }
    // Act
    final ProgramReport actual = ((await sl<GetProgramReportUseCase>()(
      params: (fromKey: 'debut', toKey: 'fin'),
    )) as DataSuccess<ProgramReport>).data;
    // Assert
    expect(
      actual.classes.map((ProgramReportRow row) => row.name),
      <String>['CE1 A', 'CE1 B'],
    );
    expect(actual.total.pupilCount, 4);
    expect(actual.total.assessedToCount, 4);
    expect(actual.total.domainOf('numbers')?.progressedCount, isNotNull);
    expect(actual.total.wordsTo, greaterThan(actual.total.wordsFrom!));
  });
}
