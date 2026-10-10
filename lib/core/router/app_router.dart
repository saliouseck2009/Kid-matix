import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/router/app_shell.dart';
import 'package:kid_matix/core/router/play_routes.dart';
import 'package:kid_matix/core/router/profile_session_redirect.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';
import 'package:kid_matix/features/challenge/presentation/challenge_pages.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/presentation/learning_path_pages.dart';
import 'package:kid_matix/features/mascot/presentation/mascot_pages.dart';
import 'package:kid_matix/features/mastery/presentation/mastery_pages.dart';
import 'package:kid_matix/features/profile/presentation/profile_pages.dart';
import 'package:kid_matix/features/quiz/presentation/quiz_pages.dart';
import 'package:kid_matix/features/reward/presentation/reward_pages.dart';

/// Builds the router of the app: the player selection, then a shell with
/// one branch per tab; the learning path is the home.
///
/// The router listens to [session]: while nobody is playing it shows "Qui
/// joue ?" or the profile creation (see [redirectForProfileSession]).
GoRouter createAppRouter({
  required ProfileSessionService session,
  required ProfilePages profilePages,
  required QuizPages quizPages,
  required LearningPathPages pathPages,
  required RewardPages rewardPages,
  required MascotPages mascotPages,
  required ChallengePages challengePages,
  required MasteryPages masteryPages,
}) {
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.learningPath,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: session,
    redirect: (BuildContext context, GoRouterState state) {
      return redirectForProfileSession(
        session: session,
        location: state.matchedLocation,
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.whoIsPlaying,
        builder: (BuildContext context, GoRouterState state) {
          return profilePages.buildWhoIsPlayingPage(
            footerOf: (String profileId) =>
                rewardPages.buildStreakPill(profileId: profileId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profileCreation,
        builder: (BuildContext context, GoRouterState state) {
          return profilePages.buildProfileCreationPage(
            canGoBack: session.hasProfiles,
          );
        },
      ),
      ...createPlayRoutes(
        session: session,
        pathPages: pathPages,
        quizPages: quizPages,
        rewardPages: rewardPages,
        challengePages: challengePages,
      ),
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) => AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.learningPath,
                builder: (BuildContext context, GoRouterState state) {
                  final String? profileId = session.activeProfileId;
                  if (profileId == null) return const SizedBox.shrink();
                  return pathPages.buildLearningPathPage(
                    profileId: profileId,
                    onOpenTable: (String unitKey) =>
                        context.go(AppRoutes.tableDetailOf(unitKey)),
                    onPlay: (StageSource source) =>
                        playStage(context, pathPages, source),
                    mascot: mascotPages.buildMapMascot(
                      bubble: rewardPages.buildGoalReminder(
                        profileId: profileId,
                      ),
                    ),
                    header: (
                      player: profilePages.buildPlayerBadge(
                        profileId: profileId,
                      ),
                      streak: rewardPages.buildStreakPill(
                        profileId: profileId,
                      ),
                      dailyGoal: rewardPages.buildDailyGoalCard(
                        profileId: profileId,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          _createChallengeBranch(
            session: session,
            path: AppRoutes.training,
            build: (String profileId, ValueChanged<String> onPlay) =>
                challengePages.buildTrainingPage(
                  profileId: profileId,
                  onLaunch: onPlay,
                ),
          ),
          _createChallengeBranch(
            session: session,
            path: AppRoutes.challenges,
            build: (String profileId, ValueChanged<String> onPlay) =>
                challengePages.buildChallengesPage(
                  profileId: profileId,
                  onPlay: onPlay,
                ),
          ),
          _createProfileBranch(
            session: session,
            profilePages: profilePages,
            mascotPages: mascotPages,
            sectionsOf: (String profileId) => <Widget>[
              masteryPages.buildGridCard(profileId: profileId),
              rewardPages.buildBadgesCard(profileId: profileId),
              pathPages.buildMonstersCard(profileId: profileId),
            ],
            rootNavigatorKey: rootNavigatorKey,
          ),
        ],
      ),
    ],
  );
}

/// Profile tab, with the edition of the player opened over the tab bar.
StatefulShellBranch _createProfileBranch({
  required ProfileSessionService session,
  required ProfilePages profilePages,
  required MascotPages mascotPages,
  required List<Widget> Function(String profileId) sectionsOf,
  required GlobalKey<NavigatorState> rootNavigatorKey,
}) {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.profile,
        builder: (BuildContext context, GoRouterState state) {
          final String? profileId = session.activeProfileId;
          if (profileId == null) return const SizedBox.shrink();
          return profilePages.buildProfileTabPage(
            profileId: profileId,
            mascotCard: mascotPages.buildProfileCard(
              onOpen: () => context.go(AppRoutes.mascot),
            ),
            sections: sectionsOf(profileId),
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: _lastSegment(AppRoutes.profileEdit),
            parentNavigatorKey: rootNavigatorKey,
            builder: (BuildContext context, GoRouterState state) {
              final String? profileId = session.activeProfileId;
              if (profileId == null) return const SizedBox.shrink();
              return profilePages.buildProfileEditPage(profileId: profileId);
            },
          ),
          GoRoute(
            path: _lastSegment(AppRoutes.settings),
            parentNavigatorKey: rootNavigatorKey,
            builder: (BuildContext context, GoRouterState state) {
              final String? profileId = session.activeProfileId;
              if (profileId == null) return const SizedBox.shrink();
              return profilePages.buildSettingsPage(
                profileId: profileId,
                onBack: () => context.go(AppRoutes.profile),
              );
            },
          ),
          GoRoute(
            path: _lastSegment(AppRoutes.mascot),
            parentNavigatorKey: rootNavigatorKey,
            builder: (BuildContext context, GoRouterState state) {
              return mascotPages.buildMascotPage(
                onBack: () => context.go(AppRoutes.profile),
              );
            },
          ),
        ],
      ),
    ],
  );
}

/// Path of a sub-route, relative to its parent route.
String _lastSegment(String path) => path.split('/').last;

/// A tab of the challenge feature at [path], whose page plays a quiz by
/// its source key.
StatefulShellBranch _createChallengeBranch({
  required ProfileSessionService session,
  required String path,
  required Widget Function(String profileId, ValueChanged<String> onPlay) build,
}) {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(
        path: path,
        builder: (BuildContext context, GoRouterState state) {
          final String? profileId = session.activeProfileId;
          if (profileId == null) return const SizedBox.shrink();
          return build(
            profileId,
            (String sourceKey) => context.go(AppRoutes.playOf(sourceKey)),
          );
        },
      ),
    ],
  );
}
