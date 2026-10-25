import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';
import 'package:kid_matix/features/classroom/presentation/class_assessment_pages.dart';
import 'package:kid_matix/features/learning_path/presentation/learning_path_pages.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/placement_slots.dart';
import 'package:kid_matix/features/quiz/presentation/quiz_pages.dart';

/// The route of an assessment taken by the active pupil (lot F31): the
/// placement test of the learning path, in its assessment variant (no
/// « Passer »; owner: it opens units and changes the home domain like a
/// retake), then the word check of the class mode, a quiz whose end keeps
/// the result of the assessment.
GoRoute createAssessmentRoute({
  required ProfileSessionService session,
  required LearningPathPages pathPages,
  required QuizPages quizPages,
  required ClassAssessmentPages assessmentPages,
}) {
  return GoRoute(
    path: AppRoutes.classAssessment,
    builder: (BuildContext context, GoRouterState state) {
      final String? profileId = session.activeProfileId;
      final String assessmentId =
          state.pathParameters[AppRoutes.assessmentIdParameter] ?? '';
      if (profileId == null) return const SizedBox.shrink();
      return pathPages.buildPlacementTestPage(
        profileId: profileId,
        slots: PlacementSlots(
          keypad: quizPages.buildKeypad,
          questionCard: quizPages.buildQuestionCard,
        ),
        isAssessment: true,
        onDone: () => context.go(
          AppRoutes.playOf(assessmentPages.wordCheckSourceKeyOf(assessmentId)),
        ),
        // Left midway: back home, the assessment still waits there.
        onLeave: () => context.go(AppRoutes.learningPath),
      );
    },
  );
}
