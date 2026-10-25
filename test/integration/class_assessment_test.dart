import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/entities/domain_placement.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessments_overview.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assessment_repository.dart';
import 'package:kid_matix/features/classroom/domain/usecases/close_assessment_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_class_assessments_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_pending_assessment_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/reset_pupil_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';

import '../helpers/in_memory_local_storage.dart';
import 'helpers/assessment_journey.dart';
import 'helpers/test_app.dart';

/// F31-01: an assessment opened from the teacher area is taken by a
/// pupil (placement test, then word check) and kept, dated, over the
/// real wiring and an on-disk database; the pupil's reset keeps it.
void main() {
  late Directory databaseFolder;

  setUp(() async {
    databaseFolder = await Directory.systemTemp.createTemp('kid_matix_');
    await TestApp.start(
      databasesPath: databaseFolder.path,
      storage: InMemoryLocalStorage(),
    );
  });

  tearDown(() async {
    await TestApp.stop();
    await databaseFolder.delete(recursive: true);
  });

  Future<ClassAssessment?> pendingOf(String pupilId) async {
    return ((await sl<GetPendingAssessmentUseCase>()(
      params: pupilId,
    )) as DataSuccess<ClassAssessment?>).data;
  }

  Future<List<AssessmentResult>> resultsOf(String classroomId) async {
    return ((await sl<AssessmentRepository>().getResults(
      classroomId: classroomId,
    )) as DataSuccess<List<AssessmentResult>>).data;
  }

  test('keeps the levels and the words of a pupil, dated', () async {
    // Arrange
    final ClassroomRoster roster = await AssessmentJourney.createClass(
      'CE1',
      3,
    );
    final String pupilId = roster.pupils.first.id;
    final ClassAssessment assessment = await AssessmentJourney.open(
      roster.classroom.id,
      "Début d'année",
    );
    expect((await pendingOf(pupilId))?.id, assessment.id);
    // Act: the numbers are right, nothing else; 5 words understood.
    final QuizState actualEnd = await AssessmentJourney.take(
      pupilId: pupilId,
      assessmentId: assessment.id,
      rightPlacement: 3,
      rightWords: 5,
    );
    // Assert
    expect(actualEnd, isA<QuizCompleted>());
    final AssessmentResult actual = (await resultsOf(
      roster.classroom.id,
    )).single;
    expect(actual.pupilId, pupilId);
    expect(actual.words, hasLength(12));
    expect(actual.understoodWordCount, 5);
    expect(actual.levelIn('numbers')?.share, 1);
    expect(actual.levelIn('addition')?.level, 0);
    expect(
      actual.levels.map((DomainPlacement level) => level.domainId),
      containsAll(<String>['numbers', 'addition', 'division']),
    );
    expect(actual.levelIn('division')?.level, isNull);
    expect(actual.takenAt.isBefore(assessment.openedAt), isFalse);
    expect(await pendingOf(pupilId), isNull);
    expect((await pendingOf(roster.pupils[1].id))?.id, assessment.id);
    final ClassAssessmentsOverview overview =
        ((await sl<GetClassAssessmentsUseCase>()(
          params: roster.classroom.id,
        )) as DataSuccess<ClassAssessmentsOverview>).data;
    expect(overview.assessments.single.takenCount, 1);
    expect(overview.periods.single.label, "Début d'année");
  });

  test('a pupil\'s reset keeps their assessment results', () async {
    // Arrange
    final ClassroomRoster roster = await AssessmentJourney.createClass(
      'CE1',
      2,
    );
    final String pupilId = roster.pupils.first.id;
    final ClassAssessment assessment = await AssessmentJourney.open(
      roster.classroom.id,
      'Début',
    );
    await AssessmentJourney.take(
      pupilId: pupilId,
      assessmentId: assessment.id,
      rightPlacement: 15,
      rightWords: 12,
    );
    // Act
    await sl<ResetPupilUseCase>()(params: pupilId);
    // Assert
    final AssessmentResult actual = (await resultsOf(
      roster.classroom.id,
    )).single;
    expect(actual.understoodWordCount, 12);
    expect(actual.levelIn('division')?.share, 1);
  });

  test('a closed assessment is no longer offered', () async {
    // Arrange
    final ClassroomRoster roster = await AssessmentJourney.createClass(
      'CE1',
      2,
    );
    final ClassAssessment assessment = await AssessmentJourney.open(
      roster.classroom.id,
      'Début',
    );
    // Act
    await sl<CloseAssessmentUseCase>()(params: assessment.id);
    // Assert
    expect(await pendingOf(roster.pupils.first.id), isNull);
  });
}
