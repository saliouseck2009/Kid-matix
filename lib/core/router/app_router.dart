import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/router/app_shell.dart';
import 'package:kid_matix/core/router/play_routes.dart';
import 'package:kid_matix/core/router/profile_session_redirect.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';
import 'package:kid_matix/core/widgets/coming_soon_page.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/presentation/learning_path_pages.dart';
import 'package:kid_matix/features/profile/presentation/profile_pages.dart';
import 'package:kid_matix/features/quiz/presentation/quiz_pages.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

typedef _TitleResolver = String Function(AppLocalizations l10n);

/// Builds the router of the app: the player selection, then a shell with
/// one branch per tab; the learning path is the home.
///
/// The router listens to [session]: while nobody is playing it shows "Qui
/// joue ?" or the profile creation (see [redirectForProfileSession]). The
/// tabs not delivered yet show a placeholder.
GoRouter createAppRouter({
  required ProfileSessionService session,
  required ProfilePages profilePages,
  required QuizPages quizPages,
  required LearningPathPages pathPages,
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
          return profilePages.buildWhoIsPlayingPage();
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
                  );
                },
              ),
            ],
          ),
          _createPlaceholderBranch(
            path: AppRoutes.training,
            resolveTitle: (AppLocalizations l10n) => l10n.tabTraining,
          ),
          _createPlaceholderBranch(
            path: AppRoutes.challenges,
            resolveTitle: (AppLocalizations l10n) => l10n.tabChallenges,
          ),
          _createProfileBranch(
            session: session,
            profilePages: profilePages,
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
  required GlobalKey<NavigatorState> rootNavigatorKey,
}) {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.profile,
        builder: (BuildContext context, GoRouterState state) {
          final String? profileId = session.activeProfileId;
          if (profileId == null) return const SizedBox.shrink();
          return profilePages.buildProfileTabPage(profileId: profileId);
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
        ],
      ),
    ],
  );
}

/// Path of a sub-route, relative to its parent route.
String _lastSegment(String path) => path.split('/').last;

StatefulShellBranch _createPlaceholderBranch({
  required String path,
  required _TitleResolver resolveTitle,
}) {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(
        path: path,
        builder: (BuildContext context, GoRouterState state) {
          return ComingSoonPage(title: resolveTitle(context.l10n));
        },
      ),
    ],
  );
}
