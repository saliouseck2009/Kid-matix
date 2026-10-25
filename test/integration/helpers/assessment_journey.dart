import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_params.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classroom_roster_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/open_assessment_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/select_pupil_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_assessment_use_cases.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_report_use_cases.dart';
import 'package:kid_matix/features/classroom/presentation/class_assessment_pages.dart';
import 'package:kid_matix/features/classroom/presentation/report_pages.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_journey.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/answer_placement_question_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/build_placement_question_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/placement_answer_params.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/save_placement_result_use_case.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';

import 'test_app.dart';

/// What a pupil does in an assessment, played over the real wiring of
/// [TestApp]: the placement test, then the word check.
abstract final class AssessmentJourney {
  /// Creates the class [name] of [pupilCount] pupils « Élève 1 »... and
  /// returns it with its pupils.
  static Future<ClassroomRoster> createClass(
    String name,
    int pupilCount,
  ) async {
    final ClassroomEntity classroom = ((await sl<CreateClassroomUseCase>()(
      params: CreateClassroomParams(
        name: name,
        nicknames: <String>[
          for (int index = 1; index <= pupilCount; index++) 'Élève $index',
        ],
      ),
    )) as DataSuccess<ClassroomEntity>).data;
    return ((await sl<GetClassroomRosterUseCase>()(
      params: classroom.id,
    )) as DataSuccess<ClassroomRoster>).data;
  }

  /// Opens the assessment [label] of [classroomId] from the teacher area.
  static Future<ClassAssessment> open(String classroomId, String label) async {
    return ((await sl<OpenAssessmentUseCase>()(
      params: (classroomId: classroomId, periodLabel: label),
    )) as DataSuccess<ClassAssessment>).data;
  }

  /// The pages of the assessments, as `main` builds them.
  static ClassAssessmentPages pages() {
    return ClassAssessmentPages(
      useCases: ClassAssessmentUseCases(
        getAssessments: sl(),
        open: sl(),
        close: sl(),
        getPending: sl(),
        watchChanges: sl(),
      ),
      reports: ReportPages(
        useCases: ClassReportUseCases(
          getClassReport: sl(),
          getProgramReport: sl(),
          share: sl(),
        ),
      ),
      domains: sl(),
    );
  }

  /// The pupil [pupilId] takes the assessment [assessmentId]: the
  /// placement test, right on the first [rightPlacement] questions, then
  /// the word check, right on its first [rightWords] words; [clock] dates
  /// the end of the word check.
  static Future<QuizState> take({
    required String pupilId,
    required String assessmentId,
    required int rightPlacement,
    required int rightWords,
    Clock? clock,
  }) async {
    await sl<SelectPupilUseCase>()(params: pupilId);
    await takePlacement(pupilId, (int rank) => rank < rightPlacement);
    final QuizSpec spec = pages().specOf(
      pages().wordCheckSourceKeyOf(assessmentId),
    )!;
    final QuizBloc bloc = TestApp.quizBloc(completedAt: clock);
    await TestApp.startQuiz(
      bloc,
      QuizRequest.fromSpec(profileId: pupilId, spec: spec),
    );
    QuizState state = bloc.state;
    int rank = 0;
    while (state is QuizAsking) {
      state = rank++ < rightWords
          ? await TestApp.answerRight(bloc)
          : await answerWrong(bloc);
    }
    await bloc.close();
    return state;
  }

  /// Answers the current question with a wrong choice and waits for what
  /// comes next.
  static Future<QuizState> answerWrong(QuizBloc bloc) async {
    final Question question = (bloc.state as QuizAsking).turn.question;
    final Answer wrong = question.choices.firstWhere(
      (Answer choice) => choice != question.expectedAnswer,
    );
    final Future<QuizState> feedback = bloc.stream.firstWhere(
      (QuizState state) => state is QuizShowingFeedback,
    );
    bloc.add(AnswerSubmitted(answer: wrong));
    await feedback;
    final Future<QuizState> next = bloc.stream.firstWhere(
      (QuizState state) =>
          state is QuizAsking || state is QuizCompleted || state is QuizFailure,
    );
    bloc.add(const NextRequested());
    return next;
  }

  /// Takes the whole placement test as [profileId] with the real use
  /// cases: right while [isRight] says so for the question number, « Je
  /// ne sais pas » otherwise.
  static Future<void> takePlacement(
    String profileId,
    bool Function(int rank) isRight,
  ) async {
    PlacementJourney journey = PlacementJourney.start();
    int rank = 0;
    while (!journey.isOver) {
      final Question question = ((await sl<BuildPlacementQuestionUseCase>()(
        params: PlacementProbeParams(
          domainId: journey.skill!.domainId,
          unitKey: journey.probeUnitKey!,
        ),
      )) as DataSuccess<Question>).data;
      final DataState<bool> answered =
          await sl<AnswerPlacementQuestionUseCase>()(
            params: PlacementAnswerParams(
              profileId: profileId,
              domainId: journey.skill!.domainId,
              question: question,
              answer: isRight(rank++) ? question.expectedAnswer : null,
              answerTime: const Duration(seconds: 4),
              unitKeysToOpen: journey.unitKeysToOpen,
            ),
          );
      journey = journey.answered(
        isCorrect: (answered as DataSuccess<bool>).data,
      );
    }
    expect(
      await sl<SavePlacementResultUseCase>()(
        params: SavePlacementResultParams(
          profileId: profileId,
          outcome: journey.outcome,
        ),
      ),
      isA<DataSuccess<void>>(),
    );
  }
}
