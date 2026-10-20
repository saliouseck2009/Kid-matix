import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/entities/pupil_draft.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_rules.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_summary.dart';
import 'package:kid_matix/features/classroom/domain/usecases/add_pupils_params.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_params.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_limits.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/classroom_device.dart';

Future<ClassroomEntity> _createClassroom(
  ClassroomDevice device,
  String name,
  List<String> nicknames,
) async {
  return (await device.createClassroom(
    params: CreateClassroomParams(name: name, nicknames: nicknames),
  )).requireData;
}

void main() {
  late ClassroomDevice device;

  setUpAll(sqfliteFfiInit);

  setUp(() async => device = await ClassroomDevice.open('tablet'));

  tearDown(() => device.close());

  group('A class of 40 pupils', () {
    test('is created in one go, in the order of its list', () async {
      // Arrange
      final List<String> inputNumbers = ClassroomRules.numberNicknames(
        count: 40,
      );
      // Act
      final ClassroomEntity actualClassroom = await _createClassroom(
        device,
        ' CE1 B ',
        inputNumbers,
      );
      // Assert
      final ClassroomRoster actualRoster = (await device.getRoster(
        params: actualClassroom.id,
      )).requireData;
      expect(actualClassroom.name, 'CE1 B');
      expect(actualClassroom.weeklyGoal, ClassroomRules.defaultWeeklyGoal);
      expect(actualRoster.pupils, hasLength(40));
      expect(actualRoster.pupils.first.nickname, '01');
      expect(actualRoster.pupils.last.nickname, '40');
      expect(
        actualRoster.pupils.map((pupil) => pupil.player.avatarKey).toSet(),
        hasLength(12),
      );
    });

    test('does not count towards the limit of free players', () async {
      // Arrange
      await _createClassroom(
        device,
        'CE1',
        ClassroomRules.numberNicknames(count: 40),
      );
      // Act
      final int actualFree =
          (await device.profiles.countFreeProfiles()).requireData;
      final int actualAll = (await device.profiles.countProfiles()).requireData;
      // Assert
      expect(actualFree, 0);
      expect(actualAll, 40);
    });

    test('lets the phone still hold its 10 free players', () async {
      // Arrange
      await _createClassroom(
        device,
        'CE1',
        ClassroomRules.numberNicknames(count: 40),
      );
      // Act
      for (int index = 0; index < ProfileLimits.maxProfiles; index++) {
        await device.profiles.createProfile(
          profile: ProfileEntity.newPlayer(
            id: 'free-$index',
            nickname: 'Joueur $index',
            avatar: ProfileAvatar.avatar1,
            color: ProfileColor.violet,
            createdAt: DateTime(2026),
          ),
        );
      }
      // Assert
      expect(
        (await device.profiles.countFreeProfiles()).requireData,
        ProfileLimits.maxProfiles,
      );
    });

    test('is listed with its number of pupils', () async {
      // Arrange
      await _createClassroom(
        device,
        'CE1',
        ClassroomRules.numberNicknames(count: 40),
      );
      await _createClassroom(device, 'CE2', <String>['Awa', 'Moussa']);
      // Act
      final List<ClassroomSummary> actualList =
          (await device.getClassrooms()).requireData;
      // Assert
      expect(
        actualList.map((ClassroomSummary summary) => summary.pupilCount),
        <int>[40, 2],
      );
    });
  });

  group('Pupils', () {
    test('share a nickname across two classes and a free player', () async {
      // Arrange
      await device.profiles.createProfile(
        profile: ProfileEntity.newPlayer(
          id: 'free',
          nickname: 'Awa',
          avatar: ProfileAvatar.avatar1,
          color: ProfileColor.violet,
          createdAt: DateTime(2026),
        ),
      );
      // Act
      await _createClassroom(device, 'CE1', <String>['Awa']);
      await _createClassroom(device, 'CE2', <String>['Awa']);
      // Assert
      expect((await device.profiles.countProfiles()).requireData, 3);
    });

    test('refuses a nickname already in the class', () async {
      // Arrange
      final ClassroomEntity inputClassroom = await _createClassroom(
        device,
        'CE1',
        <String>['Awa'],
      );
      // Act
      final DataState<int> actualAdded = await device.addPupils(
        params: AddPupilsParams(
          classroomId: inputClassroom.id,
          nicknames: <String>['awa'],
        ),
      );
      // Assert
      expect(actualAdded.exceptionOrNull?.code, AppErrorCode.conflict);
    });

    test('refuses a class beyond 60 pupils', () async {
      // Arrange
      final ClassroomEntity inputClassroom = await _createClassroom(
        device,
        'CE1',
        ClassroomRules.numberNicknames(count: 59),
      );
      // Act
      final DataState<int> actualAdded = await device.addPupils(
        params: AddPupilsParams(
          classroomId: inputClassroom.id,
          nicknames: ClassroomRules.numberNicknames(
            count: 2,
            existingCount: 59,
          ),
        ),
      );
      // Assert
      expect(actualAdded.exceptionOrNull?.code, AppErrorCode.limitReached);
    });

    test('refuses unusable nicknames and writes nothing', () async {
      // Act
      final DataState<ClassroomEntity> actualCreated = await device
          .createClassroom(
            params: const CreateClassroomParams(
              name: 'CE1',
              nicknames: <String>['Awa', 'A', 'AWA'],
            ),
          );
      // Assert
      expect(actualCreated.exceptionOrNull?.code, AppErrorCode.validation);
      expect(
        device.roster.findUnusableNicknames(<String>['Awa', 'A', 'AWA']),
        <String>[
          'A',
          'AWA',
        ],
      );
      expect((await device.getClassrooms()).requireData, isEmpty);
    });

    test('added twice with the same identifiers are kept once', () async {
      // Arrange
      final ClassroomEntity inputClassroom = await _createClassroom(
        device,
        'CE1',
        <String>['Awa'],
      );
      final PlayerIdentity inputPupil = (await device.roster.readPupils(
        classroomId: inputClassroom.id,
      )).requireData.single;
      // Act
      final int actualAdded = (await device.roster.addPupils(
        classroomId: inputClassroom.id,
        pupils: <PupilDraft>[
          PupilDraft(id: inputPupil.id, nickname: inputPupil.nickname),
        ],
      )).requireData;
      // Assert
      expect(actualAdded, 0);
    });

    test('refuses through the roster too a class beyond 60', () async {
      // Arrange
      final ClassroomEntity inputClassroom = await _createClassroom(
        device,
        'CE1',
        ClassroomRules.numberNicknames(count: 60),
      );
      // Act
      final DataState<int> actual = await device.roster.addPupils(
        classroomId: inputClassroom.id,
        pupils: const <PupilDraft>[PupilDraft(id: 'extra', nickname: 'Awa')],
      );
      // Assert
      expect(actual.exceptionOrNull?.code, AppErrorCode.limitReached);
    });

    test('are removed by the teacher with their profile', () async {
      // Arrange
      final ClassroomEntity inputClassroom = await _createClassroom(
        device,
        'CE1',
        <String>['Awa', 'Moussa'],
      );
      final ClassroomRoster inputRoster = (await device.getRoster(
        params: inputClassroom.id,
      )).requireData;
      // Act
      await device.roster.removePupil(profileId: inputRoster.pupils.first.id);
      // Assert
      final ClassroomRoster actual = (await device.getRoster(
        params: inputClassroom.id,
      )).requireData;
      expect(actual.pupils.map((pupil) => pupil.nickname), <String>['Moussa']);
      expect((await device.profiles.countProfiles()).requireData, 1);
    });

    test('never reset or remove a free player', () async {
      // Arrange
      await device.profiles.createProfile(
        profile: ProfileEntity.newPlayer(
          id: 'free',
          nickname: 'Libre',
          avatar: ProfileAvatar.avatar1,
          color: ProfileColor.violet,
          createdAt: DateTime(2026),
        ),
      );
      // Act
      final AppErrorCode? actualRemove = (await device.roster.removePupil(
        profileId: 'free',
      )).exceptionOrNull?.code;
      final AppErrorCode? actualReset = (await device.roster.resetPupil(
        profileId: 'free',
      )).exceptionOrNull?.code;
      // Assert
      expect(actualRemove, AppErrorCode.validation);
      expect(actualReset, AppErrorCode.validation);
      expect((await device.profiles.countProfiles()).requireData, 1);
    });
  });
}
