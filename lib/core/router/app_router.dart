import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/router/app_shell.dart';
import 'package:kid_matix/core/widgets/coming_soon_page.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

typedef _TitleResolver = String Function(AppLocalizations l10n);

/// Builds the router of the app: a shell with one branch per tab.
///
/// Each tab shows a placeholder until its feature is delivered. The redirect
/// to the player selection arrives with the profile feature (lot F1).
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.learningPath,
    debugLogDiagnostics: kDebugMode,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (
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
