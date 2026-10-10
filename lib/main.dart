import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/router/app_router.dart';
import 'package:kid_matix/core/services/crash_reporter.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';
import 'package:kid_matix/core/theme/app_theme.dart';
import 'package:kid_matix/core/utils/app_bloc_observer.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_use_cases.dart';
import 'package:kid_matix/features/mascot/presentation/bloc/mascot_use_cases.dart';
import 'package:kid_matix/features/mascot/presentation/mascot_pages.dart';
import 'package:kid_matix/features/learning_path/presentation/learning_path_pages.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_use_cases.dart';
import 'package:kid_matix/features/profile/presentation/profile_pages.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_use_cases.dart';
import 'package:kid_matix/features/quiz/presentation/quiz_pages.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_use_cases.dart';
import 'package:kid_matix/features/reward/presentation/reward_pages.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Entry point: wires dependencies and error reporting, then starts the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  final CrashReporter crashReporter = sl<CrashReporter>();
  Bloc.observer = AppBlocObserver(crashReporter: crashReporter);
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    crashReporter.recordError(
      details.exception,
      details.stack ?? StackTrace.current,
    );
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    crashReporter.recordError(error, stackTrace);
    return true;
  };
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  final ProfileSessionService session = sl<ProfileSessionService>();
  await session.restore();
  final MascotPages mascotPages = MascotPages(
    useCases: MascotUseCases(
      getMascot: sl(),
      update: sl(),
      watchChanges: sl(),
    ),
  );
  runApp(
    KidMatixApp(
      router: _createRouter(session, mascotPages),
      scope: (Widget child) => ListenableBuilder(
        listenable: session,
        child: child,
        builder: (BuildContext context, Widget? child) {
          final String? profileId = session.activeProfileId;
          if (profileId == null) return child!;
          return mascotPages.buildScope(profileId: profileId, child: child!);
        },
      ),
    ),
  );
}

/// Builds the router with the pages of each feature, their dependencies
/// resolved here at the composition root.
GoRouter _createRouter(
  ProfileSessionService session,
  MascotPages mascotPages,
) {
  return createAppRouter(
    session: session,
    mascotPages: mascotPages,
    profilePages: ProfilePages(
      getProfiles: sl(),
      getProfile: sl(),
      createProfile: sl(),
      updateProfile: sl(),
      selectProfile: sl(),
      tabUseCases: ProfileTabUseCases(
        getProfile: sl(),
        watchChanges: sl(),
        clearActiveProfile: sl(),
        deleteProfile: sl(),
      ),
    ),
    pathPages: LearningPathPages(
      useCases: LearningPathUseCases(
        getLearningPath: sl(),
        watchChanges: sl(),
      ),
      domains: sl(),
    ),
    rewardPages: RewardPages(
      useCases: RewardUseCases(
        getStreak: sl(),
        getDailyGoal: sl(),
        getSessionRewards: sl(),
        watchChanges: sl(),
      ),
      domains: sl(),
    ),
    quizPages: QuizPages(
      useCases: QuizUseCases(
        getTimeLimit: sl(),
        buildQuiz: sl(),
        submitAnswer: sl(),
        completeSession: sl(),
        abandonSession: sl(),
      ),
      getResult: sl(),
      ticker: sl(),
      domains: sl(),
    ),
  );
}

/// Root widget: router, theme and localization of the app.
class KidMatixApp extends StatelessWidget {
  /// Creates the app around [router].
  const KidMatixApp({required this.router, this.scope, super.key});

  /// Router built at the composition root.
  final GoRouter router;

  /// Wraps every screen, to give them the active player's mascot, or
  /// `null`.
  final Widget Function(Widget child)? scope;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      onGenerateTitle: (BuildContext context) => context.l10n.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (BuildContext context, Widget? child) {
        final Widget screen = child ?? const SizedBox.shrink();
        return scope?.call(screen) ?? screen;
      },
    );
  }
}
