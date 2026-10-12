import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/features/challenge/presentation/code_challenge_pages.dart';

/// « J'ai un code » under the challenges tab, and « Défier un ami » with
/// its code under it, both over the tab bar; a valid code plays its game.
GoRoute createChallengeCodeRoute({
  required CodeChallengePages codePages,
  required GlobalKey<NavigatorState> rootNavigatorKey,
}) {
  Widget buildPage(BuildContext context, String? code) {
    return codePages.buildCodePage(
      code: code,
      onBack: () => context.go(AppRoutes.challenges),
      onPlay: (String sourceKey) => context.go(AppRoutes.playOf(sourceKey)),
    );
  }

  return GoRoute(
    path: AppRoutes.challengeCodeEntry.split('/').last,
    parentNavigatorKey: rootNavigatorKey,
    builder: (BuildContext context, GoRouterState state) =>
        buildPage(context, null),
    routes: <RouteBase>[
      GoRoute(
        path: ':${AppRoutes.codeParameter}',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) => buildPage(
          context,
          state.pathParameters[AppRoutes.codeParameter],
        ),
      ),
    ],
  );
}
