import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/router/app_shell.dart';
import 'package:kid_matix/core/router/challenge_code_routes.dart';
import 'package:kid_matix/core/router/classroom_routes.dart';
import 'package:kid_matix/core/router/play_routes.dart';
import 'package:kid_matix/core/router/profile_session_redirect.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';
import 'package:kid_matix/core/services/teacher_session_service.dart';
import 'package:kid_matix/features/challenge/presentation/challenge_pages.dart';
import 'package:kid_matix/features/challenge/presentation/code_challenge_pages.dart';
import 'package:kid_matix/features/challenge/presentation/duel_pages.dart';
import 'package:kid_matix/features/classroom/presentation/classroom_pages.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/presentation/learning_path_pages.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/placement_slots.dart';
import 'package:kid_matix/features/mascot/presentation/mascot_pages.dart';
import 'package:kid_matix/features/mastery/presentation/mastery_pages.dart';
import 'package:kid_matix/features/profile/presentation/profile_pages.dart';
import 'package:kid_matix/features/quiz/presentation/quiz_pages.dart';
import 'package:kid_matix/features/reward/presentation/leaderboard_pages.dart';
import 'package:kid_matix/features/reward/presentation/reward_pages.dart';
import 'package:kid_matix/features/setting/presentation/language_pages.dart';
import 'package:kid_matix/features/setting/presentation/reminder_pages.dart';
import 'package:kid_matix/features/shop/presentation/shop_pages.dart';

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
  required DuelPages duelPages,
  required CodeChallengePages codePages,
  required LeaderboardPages leaderboardPages,
  ReminderPages? reminderPages,
  ShopPages? shopPages,
  LanguagePages? languagePages,
  ClassroomPages? classroomPages,
  TeacherSessionService? teacherSession,
}) {
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  final _MonstersScreen monsters = _MonstersScreen(
    session: session,
    masteryPages: masteryPages,
    challengePages: challengePages,
  );
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.learningPath,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: Listenable.merge(<Listenable?>[
      session,
      teacherSession,
    ]),
    redirect: (BuildContext context, GoRouterState state) {
      final String location = state.matchedLocation;
      return redirectForProfileSession(session: session, location: location) ??
          _redirectForTeacher(teacherSession, location);
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.whoIsPlaying,
        builder: (BuildContext context, GoRouterState state) {
          return profilePages.buildWhoIsPlayingPage(
            footerOf: (String profileId) =>
                rewardPages.buildStreakPill(profileId: profileId),
            header: classroomPages?.buildClassroomShelf(
              onOpen: (String classroomId) =>
                  context.go(AppRoutes.pupilPickerOf(classroomId)),
            ),
            footer: classroomPages?.buildTeacherEntry(
              onOpen: () => context.go(AppRoutes.teacherArea),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profileCreation,
        builder: (BuildContext context, GoRouterState state) {
          return profilePages.buildProfileCreationPage(
            canGoBack: session.hasProfiles,
            footer: classroomPages?.buildTeacherEntry(
              onOpen: () => context.go(AppRoutes.teacherArea),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.placementTest,
        builder: (BuildContext context, GoRouterState state) {
          final String? profileId = session.activeProfileId;
          if (profileId == null) return const SizedBox.shrink();
          return pathPages.buildPlacementTestPage(
            profileId: profileId,
            slots: PlacementSlots(
              keypad: quizPages.buildKeypad,
              questionCard: quizPages.buildQuestionCard,
            ),
            onDone: () => context.go(AppRoutes.learningPath),
          );
        },
      ),
      if (classroomPages != null)
        ...createClassroomRoutes(pages: classroomPages),
      ...createPlayRoutes(
        session: session,
        pathPages: pathPages,
        quizPages: quizPages,
        rewardPages: rewardPages,
        challengePages: challengePages,
        codePages: codePages,
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
                    banner: classroomPages?.buildHomeBanner(
                      profileId: profileId,
                      onOpenUnit: (String unitKey) =>
                          context.go(AppRoutes.tableDetailOf(unitKey)),
                    ),
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
            build: (_, String profileId, ValueChanged<String> onPlay) =>
                challengePages.buildTrainingPage(
                  profileId: profileId,
                  onLaunch: onPlay,
                ),
          ),
          _createChallengeBranch(
            session: session,
            path: AppRoutes.challenges,
            build:
                (
                  BuildContext context,
                  String profileId,
                  ValueChanged<String> onPlay,
                ) => challengePages.buildChallengesPage(
                  profileId: profileId,
                  onPlay: onPlay,
                  onOpenMonsters: () => context.go(AppRoutes.challengeMonsters),
                  onOpenDuel: () => context.go(AppRoutes.duel),
                  onOpenCode: () => context.go(AppRoutes.challengeCodeEntry),
                ),
            routes: <RouteBase>[
              _createMonstersRoute(
                path: AppRoutes.challengeMonsters,
                monsters: monsters,
                rootNavigatorKey: rootNavigatorKey,
              ),
              GoRoute(
                path: _lastSegment(AppRoutes.duel),
                parentNavigatorKey: rootNavigatorKey,
                builder: (BuildContext context, GoRouterState state) {
                  return duelPages.buildDuelPage(
                    activeProfileId: session.activeProfileId,
                    avatarOf: (PlayerIdentity player, double size) =>
                        profilePages.buildAvatar(player: player, size: size),
                    onClose: () => context.go(AppRoutes.challenges),
                  );
                },
              ),
              createChallengeCodeRoute(
                codePages: codePages,
                rootNavigatorKey: rootNavigatorKey,
              ),
            ],
          ),
          _createProfileBranch(
            session: session,
            profilePages: profilePages,
            mascotPages: mascotPages,
            sectionsOf: (BuildContext context, String profileId) => <Widget>[
              ?shopPages?.buildEntryCard(
                profileId: profileId,
                onOpen: () => context.go(AppRoutes.shop),
              ),
              pathPages.buildDomainSection(
                profileId: profileId,
                builder: (String domainId) => <Widget>[
                  masteryPages.buildGridCard(
                    profileId: profileId,
                    domainId: domainId,
                  ),
                  pathPages.buildMonstersCard(
                    profileId: profileId,
                    domainId: domainId,
                    onOpenLittle:
                        domainId == MasteryPages.littleMonstersDomainId
                        ? () => context.go(AppRoutes.profileMonsters)
                        : null,
                  ),
                ],
              ),
              pathPages.buildPlacementCard(
                profileId: profileId,
                onRetake: () => context.go(AppRoutes.placementTest),
              ),
              rewardPages.buildBadgesCard(profileId: profileId),
              profilePages.buildForFreePlayer(
                profileId: profileId,
                child: leaderboardPages.buildEntryCard(
                  onOpen: () => context.go(AppRoutes.leaderboard),
                ),
              ),
            ],
            settingsGameRows: <Widget>[
              leaderboardPages.buildVisibilitySwitch(),
            ],
            settingsReminderRows: <Widget>[
              ?reminderPages?.buildSettingsRows(),
            ],
            settingsLanguageRows: <Widget>[
              ?languagePages?.buildSettingsRows(),
            ],
            routes: <RouteBase>[
              _createMonstersRoute(
                path: AppRoutes.profileMonsters,
                monsters: monsters,
                rootNavigatorKey: rootNavigatorKey,
              ),
              GoRoute(
                path: _lastSegment(AppRoutes.leaderboard),
                parentNavigatorKey: rootNavigatorKey,
                builder: (BuildContext context, GoRouterState state) {
                  final String? profileId = session.activeProfileId;
                  if (profileId == null) return const SizedBox.shrink();
                  return leaderboardPages.buildLeaderboardPage(
                    profileId: profileId,
                    avatarOf: (PlayerIdentity player, double size) =>
                        profilePages.buildAvatar(player: player, size: size),
                    onBack: () => context.go(AppRoutes.profile),
                  );
                },
              ),
              if (shopPages != null)
                GoRoute(
                  path: _lastSegment(AppRoutes.shop),
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (BuildContext context, GoRouterState state) {
                    final String? profileId = session.activeProfileId;
                    if (profileId == null) return const SizedBox.shrink();
                    return shopPages.buildShopPage(
                      profileId: profileId,
                      avatarOf: (PlayerIdentity player, double size) =>
                          profilePages.buildAvatar(player: player, size: size),
                      onBack: () => context.go(AppRoutes.profile),
                    );
                  },
                ),
            ],
            rootNavigatorKey: rootNavigatorKey,
          ),
        ],
      ),
    ],
  );
}

/// The redirect of the teacher area, when the app has one.
String? _redirectForTeacher(TeacherSessionService? teacher, String location) {
  if (teacher == null) return null;
  return redirectForTeacherArea(teacher: teacher, location: location);
}

/// Profile tab, with the edition of the player opened over the tab bar.
StatefulShellBranch _createProfileBranch({
  required ProfileSessionService session,
  required ProfilePages profilePages,
  required MascotPages mascotPages,
  required List<Widget> Function(BuildContext context, String profileId)
  sectionsOf,
  required List<RouteBase> routes,
  required GlobalKey<NavigatorState> rootNavigatorKey,
  List<Widget> settingsGameRows = const <Widget>[],
  List<Widget> settingsReminderRows = const <Widget>[],
  List<Widget> settingsLanguageRows = const <Widget>[],
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
            sections: sectionsOf(context, profileId),
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
                gameRows: settingsGameRows,
                reminderRows: settingsReminderRows,
                languageRows: settingsLanguageRows,
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
          ...routes,
        ],
      ),
    ],
  );
}

/// Path of a sub-route, relative to its parent route.
String _lastSegment(String path) => path.split('/').last;

/// A tab of the challenge feature at [path], whose page plays a quiz by
/// its source key, with its full-screen [routes].
StatefulShellBranch _createChallengeBranch({
  required ProfileSessionService session,
  required String path,
  required Widget Function(
    BuildContext context,
    String profileId,
    ValueChanged<String> onPlay,
  )
  build,
  List<RouteBase> routes = const <RouteBase>[],
}) {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(
        path: path,
        builder: (BuildContext context, GoRouterState state) {
          final String? profileId = session.activeProfileId;
          if (profileId == null) return const SizedBox.shrink();
          return build(
            context,
            profileId,
            (String sourceKey) => context.go(AppRoutes.playOf(sourceKey)),
          );
        },
        routes: routes,
      ),
    ],
  );
}

/// « Mes monstres » at [path], over the tab bar.
GoRoute _createMonstersRoute({
  required String path,
  required _MonstersScreen monsters,
  required GlobalKey<NavigatorState> rootNavigatorKey,
}) {
  return GoRoute(
    path: _lastSegment(path),
    parentNavigatorKey: rootNavigatorKey,
    builder: (BuildContext context, GoRouterState state) {
      return monsters.build(
        context,
        isFromProfile: path == AppRoutes.profileMonsters,
      );
    },
  );
}

/// Builds « Mes monstres »: the screen belongs to the mastery feature,
/// the hunt it starts to the challenges.
final class _MonstersScreen {
  const _MonstersScreen({
    required this.session,
    required this.masteryPages,
    required this.challengePages,
  });

  final ProfileSessionService session;
  final MasteryPages masteryPages;
  final ChallengePages challengePages;

  /// The screen opened from the Profile tab when [isFromProfile], from the
  /// challenges otherwise; back and the hunt return there.
  Widget build(BuildContext context, {required bool isFromProfile}) {
    final String? profileId = session.activeProfileId;
    if (profileId == null) return const SizedBox.shrink();
    final String huntKey = challengePages.monsterHuntKeyOf(
      isFromProfile: isFromProfile,
    );
    return masteryPages.buildMonstersPage(
      profileId: profileId,
      huntQuestionCount: challengePages.monsterHuntQuestionCount,
      onBack: () => context.go(
        isFromProfile ? AppRoutes.profile : AppRoutes.challenges,
      ),
      onHunt: () => context.go(AppRoutes.playOf(huntKey)),
    );
  }
}
