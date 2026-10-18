import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/usecases/build_quiz_params.dart';

/// How a [QuizRequest] is handed to the use case that draws the questions.
extension QuizRequestParams on QuizRequest {
  /// The parameters to build this quiz with the [timeLimit] of the player.
  BuildQuizParams toBuildParams({Duration? timeLimit}) {
    return BuildQuizParams(
      profileId: profileId,
      domainId: domainId,
      mode: mode,
      itemKeys: itemKeys,
      selection: selection,
      questionCount: questionCount,
      sourceKey: sourceKey,
      followUpItemKeys: followUpItemKeys,
      followUpQuestionCount: followUpQuestionCount,
      isBossFight: isBossFight,
      totalTimeLimit: totalTimeLimit,
      lives: lives,
      timeSchedule: timeSchedule,
      seededDraw: seededDraw,
      questionTypeIds: questionTypeIds,
      timeLimit: timeLimit,
    );
  }
}
