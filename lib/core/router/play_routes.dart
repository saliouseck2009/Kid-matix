import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/presentation/learning_path_pages.dart';
import 'package:kid_matix/features/quiz/presentation/quiz_pages.dart';
import 'package:kid_matix/features/reward/presentation/reward_pages.dart';

/// The full-screen routes without the tab bar: the detail of a table, its
/// whole table, the quiz of a stage and its results.
List<RouteBase> createPlayRoutes({
  required ProfileSessionService session,
  required LearningPathPages pathPages,
  required QuizPages quizPages,
  required RewardPages rewardPages,
}) {
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
        final QuizSpec? spec = pathPages.specOf(sourceKey);
        if (profileId == null || spec == null) return const SizedBox.shrink();
        return quizPages.buildQuizPage(
          profileId: profileId,
          spec: spec,
          onCompleted: (String sessionId) =>
              context.go(AppRoutes.quizResultsOf(sessionId)),
          onLeft: () => context.go(_originOf(pathPages, sourceKey)),
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
          onContinue: (String? sourceKey) =>
              context.go(_originOf(pathPages, sourceKey)),
          onReplay: (String sourceKey) =>
              context.go(AppRoutes.playOf(sourceKey)),
          describeSource: pathPages.describeSource,
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

/// Where a quiz played for [sourceKey] goes back to: its table, or the
/// map.
String _originOf(LearningPathPages pathPages, String? sourceKey) {
  final String? table = pathPages.tableOf(sourceKey);
  return table == null
      ? AppRoutes.learningPath
      : AppRoutes.tableDetailOf(table);
}
