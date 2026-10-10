import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_quiz_result_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_use_cases.dart';
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

  final QuizUseCases _useCases;
  final GetQuizResultUseCase _getResult;
  final Ticker _ticker;
  final DomainRegistry _domains;

  /// Quiz of [profileId] described by [spec].
  Widget buildQuizPage({
    required String profileId,
    required QuizSpec spec,
    required ValueChanged<String> onCompleted,
    required VoidCallback onLeft,
  }) {
    return QuizPage(
      request: QuizRequest.fromSpec(profileId: profileId, spec: spec),
      useCases: _useCases,
      ticker: _ticker,
      domains: _domains,
      onCompleted: onCompleted,
      onLeft: onLeft,
    );
  }

  /// Results of the session [sessionId]; [describeSource] names what the
  /// session was played for, and the reward slots show what it earned.
  Widget buildResultsPage({
    required String sessionId,
    required ValueChanged<String?> onContinue,
    required ValueChanged<String> onReplay,
    SourceDescriber? describeSource,
    Widget Function(Widget child)? rewardsScope,
    Widget? xpTile,
    Widget? rewardsCard,
  }) {
    return ResultsPage(
      sessionId: sessionId,
      getResult: _getResult,
      domains: _domains,
      onContinue: onContinue,
      onReplay: onReplay,
      describeSource: describeSource,
      rewardsScope: rewardsScope,
      xpTile: xpTile,
      rewardsCard: rewardsCard,
    );
  }
}
