import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_time_limits.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_quiz_result_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_use_cases.dart';
import 'package:kid_matix/features/quiz/presentation/pages/provisional_quiz_launcher_page.dart';
import 'package:kid_matix/features/quiz/presentation/pages/quiz_page.dart';
import 'package:kid_matix/features/quiz/presentation/pages/results_page.dart';

/// Builds the pages of the quiz feature for the router.
///
/// Created at the composition root with the dependencies resolved there,
/// so no widget ever reads the service locator.
final class QuizPages {
  /// Creates the factory.
  const QuizPages({
    required this._useCases,
    required this._getResult,
    required this._ticker,
    required this._domains,
  });

  /// Unit of the temporary home button; removed with lot F5.
  static const String provisionalUnitKey = 'mul:5';

  /// Scored questions of a free training quiz.
  static const int freeTrainingQuestionCount = 10;

  final QuizUseCases _useCases;
  final GetQuizResultUseCase _getResult;
  final Ticker _ticker;
  final DomainRegistry _domains;

  /// Temporary home tab with a button that starts a quiz.
  Widget buildProvisionalLauncher({required VoidCallback onStart}) {
    return ProvisionalQuizLauncherPage(onStart: onStart);
  }

  /// Free training quiz of [profileId] drawn among the items of the unit
  /// [unitKey], with every question type of its domain.
  Widget buildQuizPage({
    required String profileId,
    required String unitKey,
    required ValueChanged<String> onCompleted,
    required VoidCallback onLeft,
  }) {
    return QuizPage(
      request: _buildRequest(profileId, unitKey),
      useCases: _useCases,
      ticker: _ticker,
      domains: _domains,
      onCompleted: onCompleted,
      onLeft: onLeft,
    );
  }

  /// Results of the session [sessionId].
  Widget buildResultsPage({
    required String sessionId,
    required VoidCallback onContinue,
    required ValueChanged<String> onReplay,
  }) {
    return ResultsPage(
      sessionId: sessionId,
      getResult: _getResult,
      domains: _domains,
      onContinue: onContinue,
      onReplay: onReplay,
    );
  }

  /// The request of a quiz on [unitKey]; empty when no domain has it, so
  /// the quiz screen shows its error.
  QuizRequest _buildRequest(String profileId, String unitKey) {
    for (final LearningDomain domain in _domains.domains) {
      final LearningUnit? unit = domain.findUnit(unitKey);
      if (unit == null) continue;
      return QuizRequest(
        profileId: profileId,
        domainId: domain.id,
        mode: QuizMode.freeTraining,
        itemKeys: unit.items.map((LearningItem item) => item.key).toList(),
        questionCount: freeTrainingQuestionCount,
        questionTypeIds: domain.questionTypeIds,
        baseTimeLimit: QuizTimeLimits.freeTraining,
      );
    }
    return QuizRequest(
      profileId: profileId,
      domainId: '',
      mode: QuizMode.freeTraining,
      itemKeys: const <String>[],
      questionTypeIds: const <String>[],
    );
  }
}
