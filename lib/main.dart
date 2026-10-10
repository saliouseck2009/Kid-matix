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
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_use_cases.dart';
import 'package:kid_matix/features/profile/presentation/profile_pages.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_use_cases.dart';
import 'package:kid_matix/features/quiz/presentation/quiz_pages.dart';
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
  runApp(KidMatixApp(router: _createRouter(session)));
}

/// Builds the router with the pages of each feature, their dependencies
/// resolved here at the composition root.
GoRouter _createRouter(ProfileSessionService session) {
  return createAppRouter(
    session: session,
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
  const KidMatixApp({required this.router, super.key});

  /// Router built at the composition root.
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      onGenerateTitle: (BuildContext context) => context.l10n.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
