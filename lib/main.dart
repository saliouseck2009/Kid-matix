import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:games_services/games_services.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/router/app_router.dart';
import 'package:kid_matix/core/services/crash_reporter.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';
import 'package:kid_matix/core/theme/app_theme.dart';
import 'package:kid_matix/core/utils/app_bloc_observer.dart';
import 'package:kid_matix/core/widgets/app_width_limit.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/challenge_use_cases.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/code_challenge_use_cases.dart';
import 'package:kid_matix/features/challenge/presentation/challenge_pages.dart';
import 'package:kid_matix/features/challenge/presentation/code_challenge_pages.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/duel_use_cases.dart';
import 'package:kid_matix/features/challenge/presentation/duel_pages.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_use_cases.dart';
import 'package:kid_matix/features/mascot/presentation/bloc/mascot_use_cases.dart';
import 'package:kid_matix/features/mascot/presentation/mascot_pages.dart';
import 'package:kid_matix/features/mastery/presentation/mastery_pages.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_use_cases.dart';
import 'package:kid_matix/features/learning_path/presentation/learning_path_pages.dart';
import 'package:kid_matix/features/profile/presentation/bloc/backup_use_cases.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_use_cases.dart';
import 'package:kid_matix/features/profile/presentation/bloc/settings_use_cases.dart';
import 'package:kid_matix/features/profile/presentation/profile_pages.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_read_aloud_use_cases.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_use_cases.dart';
import 'package:kid_matix/features/quiz/presentation/quiz_pages.dart';
import 'package:kid_matix/features/reward/presentation/bloc/leaderboard_use_cases.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_use_cases.dart';
import 'package:kid_matix/features/reward/presentation/leaderboard_pages.dart';
import 'package:kid_matix/features/reward/presentation/reward_pages.dart';
import 'package:kid_matix/features/setting/domain/entities/app_language.dart';
import 'package:kid_matix/features/setting/domain/usecases/reschedule_reminders_use_case.dart';
import 'package:kid_matix/features/setting/presentation/bloc/language_use_cases.dart';
import 'package:kid_matix/features/setting/presentation/language_pages.dart';
import 'package:kid_matix/features/setting/presentation/bloc/reminder_use_cases.dart';
import 'package:kid_matix/features/setting/presentation/reminder_pages.dart';
import 'package:kid_matix/features/shop/presentation/bloc/shop_use_cases.dart';
import 'package:kid_matix/features/shop/presentation/shop_pages.dart';
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
  // The daily reminder is planned again at every launch, without delaying
  // the first frame: the days ahead stay covered, clock changes included.
  unawaited(sl<RescheduleRemindersUseCase>()());
  final ProfilePages profilePages = _createProfilePages();
  final ShopPages shopPages = _createShopPages();
  final MascotPages mascotPages = MascotPages(
    useCases: MascotUseCases(
      getMascot: sl(),
      update: sl(),
      watchChanges: sl(),
    ),
    feedback: sl(),
  );
  final LanguagePages languagePages = LanguagePages(
    useCases: LanguageUseCases(getLanguage: sl(), setLanguage: sl()),
  );
  final AppLanguage language = await languagePages.readLanguage();
  final GoRouter router = _createRouter(
    session,
    mascotPages,
    profilePages,
    shopPages,
    languagePages,
  );
  runApp(
    languagePages.buildAppScope(
      initial: language,
      builder: (Locale? locale) => KidMatixApp(
        router: router,
        locale: locale,
        scope: (Widget child) => PlayerScope(
          session: session,
          profilePages: profilePages,
          mascotPages: mascotPages,
          shopPages: shopPages,
          child: child,
        ),
      ),
    ),
  );
  unawaited(_signInToGameServices());
}

/// Signs in to Google Play Games Services in the background, after the
/// first frame so the sign-in's few seconds never delay startup. The app
/// stays fully playable offline, so a missing Play Services, a signed-out
/// Google account or any other failure here is ignored.
///
/// Android only: `games_services` also covers Game Center, but no iOS
/// feature uses it, the capability is not enabled for the app and the app
/// is submitted to the Kids Category, where nothing may reach a service
/// behind the child's back. So the call never runs on iOS.
Future<void> _signInToGameServices() async {
  if (defaultTargetPlatform != TargetPlatform.android) {
    return;
  }
  try {
    await GamesServices.signIn();
  } catch (_) {
    // Ignored: see the function comment above.
  }
}

/// Builds the router with the pages of each feature, their dependencies
/// resolved here at the composition root.
GoRouter _createRouter(
  ProfileSessionService session,
  MascotPages mascotPages,
  ProfilePages profilePages,
  ShopPages shopPages,
  LanguagePages languagePages,
) {
  return createAppRouter(
    session: session,
    shopPages: shopPages,
    mascotPages: mascotPages,
    masteryPages: MasteryPages(
      getGrid: sl(),
      getMonsters: sl(),
      watchChanges: sl(),
      domains: sl(),
    ),
    challengePages: ChallengePages(
      useCases: ChallengeUseCases(
        getTrainingChoice: sl(),
        saveTrainingChoice: sl(),
        getTimeAttack: sl(),
        getSurvival: sl(),
        getRecords: sl(),
        getSessionRecord: sl(),
        watchRecordChanges: sl(),
        getDailyReview: sl(),
        getMonsterCount: sl(),
      ),
      domains: sl(),
    ),
    codePages: CodeChallengePages(
      useCases: CodeChallengeUseCases(
        encode: sl(),
        buildQuizFromCode: sl(),
      ),
      domains: sl(),
    ),
    duelPages: DuelPages(
      useCases: DuelUseCases(
        getPlayers: sl(),
        start: sl(),
        answer: sl(),
        elapse: sl(),
        finish: sl(),
      ),
      ticker: sl(),
      feedback: sl(),
    ),
    reminderPages: ReminderPages(
      useCases: ReminderUseCases(
        getSettings: sl(),
        setEnabled: sl(),
        setTime: sl(),
      ),
    ),
    languagePages: languagePages,
    leaderboardPages: LeaderboardPages(
      useCases: LeaderboardUseCases(
        getLeaderboard: sl(),
        watchRewardChanges: sl(),
        getVisibility: sl(),
        setVisibility: sl(),
        watchVisibility: sl(),
      ),
    ),
    profilePages: profilePages,
    pathPages: LearningPathPages(
      useCases: LearningPathUseCases(
        getLearningPath: sl(),
        watchChanges: sl(),
      ),
      placement: PlacementUseCases(runTest: sl(), answerQuestion: sl()),
      domains: sl(),
      clock: sl(),
    ),
    rewardPages: RewardPages(
      useCases: RewardUseCases(
        getStreak: sl(),
        getDailyGoal: sl(),
        getSessionRewards: sl(),
        getBadges: sl(),
        watchChanges: sl(),
      ),
      domains: sl(),
      feedback: sl(),
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
      feedback: sl(),
      readAloud: QuizReadAloudUseCases(
        getMode: sl(),
        read: sl(),
        stop: sl(),
      ),
    ),
  );
}

/// The pages of the shop, with their use cases.
ShopPages _createShopPages() {
  return ShopPages(
    useCases: ShopUseCases(
      getShop: sl(),
      buy: sl(),
      use: sl(),
      watchChanges: sl(),
      getActiveTheme: sl(),
      watchThemeChanges: sl(),
    ),
  );
}

/// The pages of the profile feature, with their use cases.
ProfilePages _createProfilePages() {
  return ProfilePages(
    getProfiles: sl(),
    getProfile: sl(),
    createProfile: sl(),
    updateProfile: sl(),
    selectProfile: sl(),
    settingsUseCases: SettingsUseCases(
      getProfile: sl(),
      getSettings: sl(),
      updateSettings: sl(),
      resetProgress: sl(),
      deleteProfile: sl(),
    ),
    backupUseCases: BackupUseCases(
      exportProfile: sl(),
      pickBackup: sl(),
      importBackup: sl(),
    ),
    tabUseCases: ProfileTabUseCases(
      getProfile: sl(),
      watchChanges: sl(),
      clearActiveProfile: sl(),
      getStats: sl(),
      watchProgress: sl(),
    ),
  );
}

/// Root widget: router, theme and localization of the app.
class KidMatixApp extends StatelessWidget {
  /// Creates the app around [router].
  const KidMatixApp({
    required this.router,
    this.scope,
    this.locale,
    super.key,
  });

  /// Router built at the composition root.
  final GoRouter router;

  /// Language chosen in the settings, or `null` to follow the phone.
  final Locale? locale;

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
      locale: locale,
      localeListResolutionCallback: LanguagePages.resolveLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (BuildContext context, Widget? child) {
        final Widget screen = child ?? const SizedBox.shrink();
        return AppWidthLimit(child: scope?.call(screen) ?? screen);
      },
    );
  }
}

/// Gives every screen the settings, the mascot and the theme of the
/// active player.
///
/// When the player leaves, the scope keeps that player's Cubits, with the
/// first-stage mascot and the phone's animations, until another player
/// is chosen. The widgets above the router keep their shape, so the
/// player's screens still find their Cubits while the router closes them;
/// dropping the Cubits in that frame breaks the build of those screens.
class PlayerScope extends StatefulWidget {
  /// Creates the scope of the player of [session] around [child].
  const PlayerScope({
    required this.session,
    required this.profilePages,
    required this.mascotPages,
    required this.child,
    this.shopPages,
    super.key,
  });

  /// Session telling who is playing.
  final ProfileSessionService session;

  /// Builds the settings scope.
  final ProfilePages profilePages;

  /// Builds the mascot scope.
  final MascotPages mascotPages;

  /// Builds the theme scope, or `null` to keep the lavender theme.
  final ShopPages? shopPages;

  /// The app.
  final Widget child;

  @override
  State<PlayerScope> createState() => _PlayerScopeState();
}

class _PlayerScopeState extends State<PlayerScope> {
  String? _profileId;

  @override
  void initState() {
    super.initState();
    _profileId = widget.session.activeProfileId;
    widget.session.addListener(_followSession);
  }

  @override
  void didUpdateWidget(PlayerScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session == widget.session) return;
    oldWidget.session.removeListener(_followSession);
    widget.session.addListener(_followSession);
    _profileId = widget.session.activeProfileId ?? _profileId;
  }

  @override
  void dispose() {
    widget.session.removeListener(_followSession);
    super.dispose();
  }

  void _followSession() {
    setState(() => _profileId = widget.session.activeProfileId ?? _profileId);
  }

  @override
  Widget build(BuildContext context) {
    final String? profileId = _profileId;
    if (profileId == null) return widget.child;
    final bool isPlayerActive = widget.session.activeProfileId != null;
    final Widget scoped = widget.profilePages.buildSettingsScope(
      profileId: profileId,
      isPlayerActive: isPlayerActive,
      child: widget.mascotPages.buildScope(
        profileId: profileId,
        isPlayerActive: isPlayerActive,
        child: widget.child,
      ),
    );
    return widget.shopPages?.buildThemeScope(
          profileId: profileId,
          isPlayerActive: isPlayerActive,
          child: scoped,
        ) ??
        scoped;
  }
}
