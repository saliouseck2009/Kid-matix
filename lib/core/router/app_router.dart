import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/router/app_shell.dart';
import 'package:kid_matix/core/router/profile_session_redirect.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';
import 'package:kid_matix/core/widgets/coming_soon_page.dart';
import 'package:kid_matix/features/profile/presentation/profile_pages.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

typedef _TitleResolver = String Function(AppLocalizations l10n);

/// Builds the router of the app: the player selection, then a shell with
/// one branch per tab.
///
/// The router listens to [session]: while nobody is playing it shows "Qui
/// joue ?" or the profile creation (see [redirectForProfileSession]). Each
/// tab shows a placeholder until its feature is delivered.
GoRouter createAppRouter({
  required ProfileSessionService session,
  required ProfilePages profilePages,
}) {
  return GoRouter(
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
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) => AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          _createPlaceholderBranch(
            path: AppRoutes.learningPath,
            resolveTitle: (AppLocalizations l10n) => l10n.tabLearningPath,
          ),
          _createPlaceholderBranch(
            path: AppRoutes.training,
            resolveTitle: (AppLocalizations l10n) => l10n.tabTraining,
          ),
          _createPlaceholderBranch(
            path: AppRoutes.challenges,
            resolveTitle: (AppLocalizations l10n) => l10n.tabChallenges,
          ),
          _createPlaceholderBranch(
            path: AppRoutes.profile,
            resolveTitle: (AppLocalizations l10n) => l10n.tabProfile,
          ),
        ],
      ),
    ],
  );
}

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
