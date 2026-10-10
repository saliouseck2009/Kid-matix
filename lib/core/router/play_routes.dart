import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';
import 'package:kid_matix/features/challenge/presentation/challenge_pages.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/presentation/learning_path_pages.dart';
import 'package:kid_matix/features/quiz/presentation/quiz_pages.dart';
import 'package:kid_matix/features/reward/presentation/reward_pages.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// The full-screen routes without the tab bar: the detail of a table, its
/// whole table, the quiz of a stage, a training or a challenge, and its
/// results.
List<RouteBase> createPlayRoutes({
  required ProfileSessionService session,
  required LearningPathPages pathPages,
  required QuizPages quizPages,
  required RewardPages rewardPages,
  required ChallengePages challengePages,
}) {
  final _Origins origins = _Origins(pathPages, challengePages);
  return <RouteBase>[
    GoRoute(
      path: AppRoutes.tableDetail,
      builder: (BuildContext context, GoRouterState state) {
        final String? profileId = session.activeProfileId;
        if (profileId == null) return const SizedBox.shrink();
        final String unitKey =
            state.pathParameters[AppRoutes.unitKeyParameter]!;
        return pathPages.buildTableDetailPage(
          profileId: profileId,
          unitKey: unitKey,
          onBack: () => context.go(AppRoutes.learningPath),
          onPlay: (StageSource source) => playStage(context, pathPages, source),
          onShowTable: () => context.go(AppRoutes.tableViewOf(unitKey)),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.tableView,
      builder: (BuildContext context, GoRouterState state) {
        final String unitKey =
            state.pathParameters[AppRoutes.unitKeyParameter]!;
        return pathPages.buildDiscoveryPage(
          unitKey: unitKey,
          onClose: () => context.go(AppRoutes.tableDetailOf(unitKey)),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.discovery,
      builder: (BuildContext context, GoRouterState state) {
        final String unitKey =
            state.pathParameters[AppRoutes.unitKeyParameter]!;
        final String sourceKey = StageSource(
          unitKey: unitKey,
          stage: StageKind.discovery,
        ).toKey();
        return pathPages.buildDiscoveryPage(
          unitKey: unitKey,
          onClose: () => context.go(AppRoutes.tableDetailOf(unitKey)),
          onPlay: () => context.go(AppRoutes.playOf(sourceKey)),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.play,
      builder: (BuildContext context, GoRouterState state) {
        final String? profileId = session.activeProfileId;
        final String sourceKey =
            state.pathParameters[AppRoutes.sourceKeyParameter]!;
        final QuizSpec? spec =
            pathPages.specOf(sourceKey) ?? challengePages.specOf(sourceKey);
        if (profileId == null || spec == null) return const SizedBox.shrink();
        return quizPages.buildQuizPage(
          profileId: profileId,
          spec: spec,
          onCompleted: (String sessionId) =>
              context.go(AppRoutes.quizResultsOf(sessionId)),
          onLeft: () => context.go(origins.of(sourceKey)),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.quizResults,
      builder: (BuildContext context, GoRouterState state) {
        final String sessionId =
            state.pathParameters[AppRoutes.sessionIdParameter]!;
        return quizPages.buildResultsPage(
          sessionId: sessionId,
          onContinue: (String? sourceKey) => context.go(origins.of(sourceKey)),
          onReplay: (String sourceKey) =>
              context.go(AppRoutes.playOf(sourceKey)),
          describeSource: (String? sourceKey, AppLocalizations l10n) =>
              pathPages.describeSource(sourceKey, l10n) ??
              challengePages.describeSource(sourceKey, l10n),
          recordCard: challengePages.buildRecordCard(sessionId: sessionId),
          rewardsScope: (Widget child) => rewardPages.buildSessionRewardsScope(
            sessionId: sessionId,
            child: child,
          ),
          xpTile: rewardPages.buildSessionXpTile(),
          rewardsCard: rewardPages.buildSessionLevelCard(),
        );
      },
    ),
  ];
}

/// Opens [source]: the whole table first for a Discovery stage, the quiz
/// at once otherwise.
void playStage(
  BuildContext context,
  LearningPathPages pathPages,
  StageSource source,
) {
  context.go(
    pathPages.startsWithTable(source)
        ? AppRoutes.discoveryOf(source.unitKey)
        : AppRoutes.playOf(source.toKey()),
  );
}

/// Where a quiz goes back to once left or finished.
final class _Origins {
  const _Origins(this._pathPages, this._challengePages);

  final LearningPathPages _pathPages;
  final ChallengePages _challengePages;

  /// The origin of a quiz played for [sourceKey]: its table, the training
  /// or challenges tab, or the map.
  String of(String? sourceKey) {
    final String? table = _pathPages.tableOf(sourceKey);
    if (table != null) return AppRoutes.tableDetailOf(table);
    return switch (_challengePages.originOf(sourceKey)) {
      ChallengeOrigin.training => AppRoutes.training,
      ChallengeOrigin.challenges => AppRoutes.challenges,
      null => AppRoutes.learningPath,
    };
  }
}
