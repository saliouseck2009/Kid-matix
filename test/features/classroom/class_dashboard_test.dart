import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_overview.dart';
import 'package:kid_matix/features/classroom/domain/services/assigned_units_service_impl.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_rules.dart';
import 'package:kid_matix/features/classroom/domain/entities/item_struggle.dart';
import 'package:kid_matix/features/classroom/domain/entities/level_group.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_class_view.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_progress.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_params.dart';
import 'package:kid_matix/features/classroom/domain/usecases/give_assignment_params.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/data_state_test_extension.dart';
import 'helpers/classroom_device.dart';

const String _additionsTo20 = 'addsub:add20';

int _sessionCount = 0;

/// A quiz session of [profileId]: [answers] is the list of item keys,
/// each followed by `!` when missed.
SavedQuizSession _session(
  String profileId,
  List<String> answers, {
  required DateTime endedAt,
  String domainId = 'addition',
  bool isCompleted = true,
}) {
  final List<SavedAnswer> saved = <SavedAnswer>[
    for (int index = 0; index < answers.length; index++)
      SavedAnswer(
        position: index + 1,
        itemKey: answers[index].replaceAll('!', ''),
        isCorrect: !answers[index].endsWith('!'),
      ),
  ];
  return SavedQuizSession(
    id: 'session-${++_sessionCount}',
    profileId: profileId,
    domainId: domainId,
    mode: QuizMode.path,
    isCompleted: isCompleted,
    questionCount: saved.length,
    correctCount: saved.where((SavedAnswer a) => a.isCorrect).length,
    endedAt: endedAt,
    duration: const Duration(minutes: 5),
    answers: saved,
  );
}

void main() {
  late ClassroomDevice tablet;
  late ClassroomEntity classroom;
  late ClassroomRoster roster;
  late List<String> unitItems;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    tablet = await ClassroomDevice.open(
      'tablet',
      now: DateTime(2026, 10, 21, 10),
    );
    classroom = (await tablet.createClassroom(
      params: CreateClassroomParams(
        name: 'CE1 B',
        nicknames: ClassroomRules.numberNicknames(count: 30),
      ),
    )).requireData;
    roster = (await tablet.getRoster(params: classroom.id)).requireData;
    unitItems = tablet.domains
        .find('addition')!
        .findUnit(_additionsTo20)!
        .items
        .map((LearningItem item) => item.key)
        .toList();
  });

  tearDown(() => tablet.close());

  String pupil(int index) => roster.pupils[index].id;

  group('Done when: a class of 30, « Additions jusqu’à 20 », three pupils', () {
    test('shows who is stuck and on which facts', () async {
      // Arrange
      final String hardFact = unitItems[3];
      final String otherFact = unitItems[5];
      await tablet.giveAssignment(
        params: GiveAssignmentParams(
          classroomId: classroom.id,
          domainId: 'addition',
          unitKey: _additionsTo20,
        ),
      );
      final DateTime tuesday = DateTime(2026, 10, 20, 9);
      // Act: pupil 0 masters the unit's first facts, pupils 1 and 2 keep
      // missing the same fact; pupil 2 also misses another one.
      await tablet.play(
        _session(pupil(0), <String>[
          for (final String key in unitItems.take(3)) ...<String>[
            key,
            key,
            key,
          ],
        ], endedAt: tuesday),
      );
      await tablet.play(
        _session(pupil(1), <String>[
          '$hardFact!',
          hardFact,
          '$hardFact!',
        ], endedAt: tuesday),
      );
      await tablet.play(
        _session(pupil(2), <String>[
          '$hardFact!',
          '$hardFact!',
          '$otherFact!',
          '$otherFact!',
        ], endedAt: tuesday),
      );
      final ClassOverview actual = (await tablet.getOverview(
        params: classroom.id,
      )).requireData;
      // Assert
      final List<ItemStruggle> actualStruggles = actual.dashboard.struggles;
      expect(actualStruggles.first.itemKey, hardFact);
      expect(actualStruggles.first.pupilIds, <String>[pupil(1), pupil(2)]);
      expect(actualStruggles[1].itemKey, otherFact);
      expect(
        actual.dashboard.stuckPupils.map((PupilProgress p) => p.pupil.id),
        <String>[pupil(1), pupil(2)],
      );
      final PupilProgress actualFirst = actual.dashboard.pupils.first;
      expect(actualFirst.sessionCount, 1);
      expect(actualFirst.correctCount, 9);
      expect(actualFirst.practiceTime, const Duration(minutes: 5));
      expect(actualFirst.lastPlayedAt, tuesday);
      expect(actualFirst.assignmentProgress, 3 / unitItems.length);
      expect(actual.dashboard.pupils[3].hasPlayed, isFalse);
      expect(actual.challenge.correctCount, 9 + 1);
      expect(actual.assignment?.unitKey, _additionsTo20);
    });
  });

  group('Class results', () {
    test('keep the sessions of pupils only', () async {
      // Arrange
      await tablet.profiles.createProfile(
        profile: ProfileEntity.newPlayer(
          id: 'free',
          nickname: 'Libre',
          avatar: ProfileAvatar.avatar1,
          color: ProfileColor.violet,
          createdAt: DateTime(2026),
        ),
      );
      // Act
      await tablet.play(
        _session('free', <String>[unitItems.first], endedAt: DateTime(2026)),
      );
      await tablet.play(
        _session(pupil(0), <String>[unitItems.first], endedAt: DateTime(2026)),
      );
      // Assert
      final List<PracticeSession> actual = (await tablet.journal.getSessions(
        classroomId: classroom.id,
      )).requireData;
      expect(actual.single.pupilId, pupil(0));
      expect(actual.single.answers.single.itemKey, unitItems.first);
    });

    test('refuse a session whose player cannot be read', () async {
      // Act
      Future<void> actual() => tablet.play(
        _session('ghost', <String>[unitItems.first], endedAt: DateTime(2026)),
      );
      // Assert
      await expectLater(actual(), throwsA(isA<NotFoundException>()));
    });

    test('keep an abandoned session and a mixed daily review', () async {
      // Act
      await tablet.play(
        _session(
          pupil(0),
          <String>['${unitItems.first}!'],
          endedAt: DateTime(2026, 10, 20, 9),
          isCompleted: false,
        ),
      );
      await tablet.play(
        _session(
          pupil(0),
          <String>['${unitItems.first}!', 'mul:7x8'],
          endedAt: DateTime(2026, 10, 21, 9),
          domainId: 'mixed',
        ),
      );
      // Assert
      final ClassOverview actual = (await tablet.getOverview(
        params: classroom.id,
      )).requireData;
      expect(actual.dashboard.pupils.first.sessionCount, 2);
      expect(actual.dashboard.struggles.single.itemKey, unitItems.first);
      expect(actual.groupsDomainId, 'addition');
    });

    test('count the challenge from Monday only', () async {
      // Arrange
      await tablet.play(
        _session(pupil(0), <String>[
          unitItems.first,
        ], endedAt: DateTime(2026, 10, 18, 23)),
      );
      await tablet.play(
        _session(pupil(1), <String>[
          unitItems.first,
          unitItems[1],
        ], endedAt: DateTime(2026, 10, 19, 8)),
      );
      // Act
      final ClassOverview actual = (await tablet.getOverview(
        params: classroom.id,
      )).requireData;
      // Assert
      expect(actual.challenge.weekStart, DateTime(2026, 10, 19));
      expect(actual.challenge.correctCount, 2);
      expect(actual.challenge.goal, ClassroomRules.defaultWeeklyGoal);
    });

    test('give a pupil their class view on the home', () async {
      // Arrange
      await tablet.giveAssignment(
        params: GiveAssignmentParams(
          classroomId: classroom.id,
          domainId: 'addition',
          unitKey: _additionsTo20,
          dueInDays: 7,
        ),
      );
      await tablet.play(
        _session(pupil(0), <String>[
          unitItems.first,
          unitItems.first,
          unitItems.first,
        ], endedAt: DateTime(2026, 10, 21, 9)),
      );
      // Act
      final PupilClassView? actual = (await tablet.getPupilView(
        params: pupil(0),
      )).requireData;
      final PupilClassView? actualFree = (await tablet.getPupilView(
        params: 'nobody',
      )).requireData;
      // Assert
      expect(actual?.assignment?.dueAt, DateTime(2026, 10, 28));
      expect(actual?.assignmentProgress, 1 / unitItems.length);
      expect(actual?.challenge.correctCount, 3);
      expect(actualFree, isNull);
    });

    test('open the unit of the homework to the pupils only', () async {
      // Arrange
      final AssignedUnitsServiceImpl inputService = AssignedUnitsServiceImpl(
        roster: tablet.roster,
        assignments: tablet.assignments,
      );
      await tablet.giveAssignment(
        params: GiveAssignmentParams(
          classroomId: classroom.id,
          domainId: 'addition',
          unitKey: _additionsTo20,
        ),
      );
      await tablet.giveAssignment(
        params: GiveAssignmentParams(
          classroomId: classroom.id,
          domainId: 'multiplication',
          unitKey: 'mul:7',
        ),
      );
      await tablet.profiles.createProfile(
        profile: ProfileEntity.newPlayer(
          id: 'free',
          nickname: 'Libre',
          avatar: ProfileAvatar.avatar1,
          color: ProfileColor.violet,
          createdAt: DateTime(2026),
        ),
      );
      // Act
      final Set<String> actualPupil = (await inputService.readAssignedUnitKeys(
        profileId: pupil(0),
      )).requireData;
      final Set<String> actualFree = (await inputService.readAssignedUnitKeys(
        profileId: 'free',
      )).requireData;
      // Assert
      expect(actualPupil, <String>{_additionsTo20, 'mul:7'});
      expect(actualFree, isEmpty);
    });

    test('place pupils in the groups from their latest placement', () async {
      // Arrange
      Future<void> place(String profileId, DateTime at, int? level) async {
        final Database db = await tablet.database.database;
        await db.insert('placement_result', <String, Object?>{
          'profile_id': profileId,
          'taken_at': at.millisecondsSinceEpoch,
          'domain_id': 'addition',
          'level': level,
          'skill_count': 5,
          'unit_count': 4,
          'updated_at': at.millisecondsSinceEpoch,
        });
      }

      await tablet.giveAssignment(
        params: GiveAssignmentParams(
          classroomId: classroom.id,
          domainId: 'addition',
          unitKey: _additionsTo20,
        ),
      );
      await place(pupil(2), DateTime(2026, 10, 1), 1);
      await place(pupil(2), DateTime(2026, 10, 15), 4);
      await place(pupil(3), DateTime(2026, 10, 1), 5);
      await place(pupil(3), DateTime(2026, 10, 15), null);
      // Act
      final ClassOverview actual = (await tablet.getOverview(
        params: classroom.id,
      )).requireData;
      // Assert
      final LevelGroup actualConfident = actual.groups.firstWhere(
        (LevelGroup group) => group.kind == LevelGroupKind.confident,
      );
      expect(actualConfident.pupils.map((p) => p.id), <String>[pupil(2)]);
      expect(
        (await tablet.placements.readLatestLevel(
          profileId: pupil(3),
          domainId: 'addition',
        )).requireData,
        isNull,
      );
    });

    test('propose level groups in the domain of the assignment', () async {
      // Arrange
      await tablet.giveAssignment(
        params: GiveAssignmentParams(
          classroomId: classroom.id,
          domainId: 'addition',
          unitKey: _additionsTo20,
        ),
      );
      final List<String> worked = unitItems.take(3).toList();
      await tablet.play(
        _session(pupil(0), <String>[
          for (final String key in worked) ...<String>[key, key, key],
        ], endedAt: DateTime(2026, 10, 21, 9)),
      );
      await tablet.play(
        _session(pupil(1), <String>[
          worked.first,
          worked.first,
          worked.first,
          '${worked[1]}!',
        ], endedAt: DateTime(2026, 10, 21, 9)),
      );
      // Act
      final ClassOverview actual = (await tablet.getOverview(
        params: classroom.id,
      )).requireData;
      // Assert
      final Map<LevelGroupKind, int> actualSizes = <LevelGroupKind, int>{
        for (final LevelGroup group in actual.groups)
          group.kind: group.pupils.length,
      };
      expect(actual.groupsDomainId, 'addition');
      expect(actualSizes, <LevelGroupKind, int>{
        LevelGroupKind.onTheWay: 1,
        LevelGroupKind.confident: 1,
        LevelGroupKind.notYet: 28,
      });
    });
  });
}
