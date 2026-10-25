import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/classroom/data/datasources/classroom_file_codec.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_overview.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_merge_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_rules.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_transfer.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/usecases/add_pupils_params.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_params.dart';
import 'package:kid_matix/features/classroom/domain/usecases/give_assignment_params.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/data_state_test_extension.dart';
import 'helpers/classroom_device.dart';

SavedQuizSession _session(String id, String profileId, List<bool> results) {
  return SavedQuizSession(
    id: id,
    profileId: profileId,
    domainId: 'multiplication',
    mode: QuizMode.path,
    isCompleted: true,
    questionCount: results.length,
    correctCount: results.where((bool isRight) => isRight).length,
    endedAt: DateTime(2026, 10, 21, 10),
    duration: const Duration(minutes: 3),
    answers: <SavedAnswer>[
      for (int index = 0; index < results.length; index++)
        SavedAnswer(
          position: index + 1,
          itemKey: 'mul:7x8',
          isCorrect: results[index],
        ),
    ],
  );
}

void main() {
  late ClassroomDevice teacher;
  late ClassroomDevice pupils;
  late ClassroomEntity classroom;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    teacher = await ClassroomDevice.open('teacher');
    pupils = await ClassroomDevice.open('pupils');
    classroom = (await teacher.createClassroom(
      params: CreateClassroomParams(
        name: 'CE2 A',
        nicknames: ClassroomRules.numberNicknames(count: 40),
      ),
    )).requireData;
    await teacher.giveAssignment(
      params: GiveAssignmentParams(
        classroomId: classroom.id,
        domainId: 'multiplication',
        unitKey: 'mul:7',
      ),
    );
  });

  tearDown(() async {
    await teacher.close();
    await pupils.close();
  });

  /// Sends the class from [from] and receives it on [to].
  Future<ClassroomMergeReport> carry(
    ClassroomDevice from,
    ClassroomDevice to,
  ) async {
    await from.exportClassroom(
      params: (classroomId: classroom.id, isFull: true),
    );
    to.files.fileToPick = from.files.sharedContent;
    return (await to.importClassroom()).requireData!;
  }

  /// Sends a delta file from [from] to [to]; with [isNewFile] false,
  /// [to] receives the last file again.
  Future<ClassroomMergeReport> carryDelta(
    ClassroomDevice from,
    ClassroomDevice to, {
    bool isNewFile = true,
  }) async {
    if (isNewFile) {
      await from.exportClassroom(
        params: (classroomId: classroom.id, isFull: false),
      );
    }
    to.files.fileToPick = from.files.sharedContent;
    return (await to.importClassroom()).requireData!;
  }

  group('Class files', () {
    test(
      'give a new tablet the class, its 40 pupils and its homework',
      () async {
        // Act
        final ClassroomMergeReport actual = await carry(teacher, pupils);
        // Assert
        final ClassroomRoster actualRoster = (await pupils.getRoster(
          params: classroom.id,
        )).requireData;
        final ClassroomRoster expectedRoster = (await teacher.getRoster(
          params: classroom.id,
        )).requireData;
        expect(actual.addedPupilCount, 40);
        expect(actualRoster.pupils, expectedRoster.pupils);
        expect(
          (await pupils.getOverview(params: classroom.id))
              .requireData
              .assignment
              ?.unitKey,
          'mul:7',
        );
        expect(
          teacher.files.sharedName,
          'KidMatix-Classe-CE2-A-2026-10-20.kidmatix',
        );
      },
    );

    test(
      'bring the results back and merge a file received twice once',
      () async {
        // Arrange
        await carry(teacher, pupils);
        final ClassroomRoster roster = (await pupils.getRoster(
          params: classroom.id,
        )).requireData;
        await pupils.play(
          _session('s1', roster.pupils[0].id, <bool>[false, false]),
        );
        await pupils.play(
          _session('s2', roster.pupils[1].id, <bool>[false, true, false]),
        );
        // Act
        final ClassroomMergeReport actualFirst = await carry(pupils, teacher);
        final ClassroomMergeReport actualSecond = await carry(pupils, teacher);
        // Assert
        final ClassOverview actual = (await teacher.getOverview(
          params: classroom.id,
        )).requireData;
        expect(actualFirst.addedSessionCount, 2);
        expect(actualFirst.addedPupilCount, 0);
        expect(actualSecond.addedSessionCount, 0);
        expect(actualSecond.addedPupilCount, 0);
        expect(
          (await teacher.journal.getSessions(classroomId: classroom.id))
              .requireData,
          hasLength(2),
        );
        expect(actual.dashboard.struggles.single.itemKey, 'mul:7x8');
        expect(actual.dashboard.struggles.single.pupilCount, 2);
        expect(actual.challenge.correctCount, 1);
      },
    );

    test('keep the newer class goal on both sides', () async {
      // Arrange
      await carry(teacher, pupils);
      teacher.clock.current = DateTime(2026, 10, 22);
      await teacher.classrooms.updateClassroom(
        classroom: classroom.copyWith(
          weeklyGoal: 2000,
          updatedAt: DateTime(2026, 10, 22),
        ),
      );
      // Act
      await carry(pupils, teacher);
      await carry(teacher, pupils);
      // Assert
      expect(
        (await pupils.classrooms.getClassroom(classroomId: classroom.id))
            .requireData
            .weeklyGoal,
        2000,
      );
      expect(
        (await teacher.classrooms.getClassroom(classroomId: classroom.id))
            .requireData
            .weeklyGoal,
        2000,
      );
    });

    test('add nothing when the picker is cancelled', () async {
      // Arrange
      pupils.files.fileToPick = null;
      // Act
      final ClassroomMergeReport? actual =
          (await pupils.importClassroom()).requireData;
      // Assert
      expect(actual, isNull);
    });
  });

  group('Delta files and conflicts', () {
    Future<List<String>> deltaIds(ClassroomDevice from) async {
      await from.exportClassroom(
        params: (classroomId: classroom.id, isFull: false),
      );
      return const ClassroomFileCodec()
          .decode(from.files.sharedContent!)
          .sessions
          .map((PracticeSession session) => session.id)
          .toList();
    }

    Future<ClassroomRoster> readyPupils() async {
      await carry(teacher, pupils);
      return (await pupils.getRoster(params: classroom.id)).requireData;
    }

    test('resend the last 14 days, not the sessions sent before', () async {
      // Arrange
      final ClassroomRoster roster = await readyPupils();
      await pupils.play(
        _session('old', roster.pupils[0].id, <bool>[true]).copyWithEnd(
          DateTime(2026, 9, 1, 10),
        ),
      );
      await pupils.play(_session('recent', roster.pupils[0].id, <bool>[true]));
      pupils.clock.current = DateTime(2026, 10, 21, 11);
      final List<String> actualFirst = await deltaIds(pupils);
      await pupils.play(_session('new', roster.pupils[1].id, <bool>[true]));
      // Act
      final List<String> actualSecond = await deltaIds(pupils);
      await pupils.exportClassroom(
        params: (classroomId: classroom.id, isFull: true),
      );
      final List<String> actualFull = const ClassroomFileCodec()
          .decode(pupils.files.sharedContent!)
          .sessions
          .map((PracticeSession session) => session.id)
          .toList();
      // Assert
      expect(actualFirst, unorderedEquals(<String>['old', 'recent']));
      expect(actualSecond, unorderedEquals(<String>['recent', 'new']));
      expect(actualFull, unorderedEquals(<String>['old', 'recent', 'new']));
    });

    test('keep the mark when the share is cancelled', () async {
      // Arrange
      final ClassroomRoster roster = await readyPupils();
      await pupils.play(
        _session('old', roster.pupils[0].id, <bool>[true]).copyWithEnd(
          DateTime(2026, 9, 1, 10),
        ),
      );
      pupils.files.isSharing = false;
      await pupils.exportClassroom(
        params: (classroomId: classroom.id, isFull: false),
      );
      pupils.files.isSharing = true;
      // Act
      final List<String> actual = await deltaIds(pupils);
      // Assert
      expect(actual, <String>['old']);
    });

    test('merge the same delta twice once, and serve two receivers', () async {
      // Arrange
      final ClassroomRoster roster = await readyPupils();
      final ClassroomDevice other = await ClassroomDevice.open('other');
      await pupils.play(_session('s1', roster.pupils[0].id, <bool>[true]));
      final ClassroomMergeReport actualFirst = await carryDelta(
        pupils,
        teacher,
      );
      final ClassroomMergeReport actualTwice = await carryDelta(
        pupils,
        teacher,
        isNewFile: false,
      );
      await pupils.play(_session('s2', roster.pupils[1].id, <bool>[true]));
      // Act
      await carryDelta(pupils, other);
      // Assert
      expect(actualFirst.addedSessionCount, 1);
      expect(actualTwice.addedSessionCount, 0);
      expect(
        (await other.journal.getSessions(classroomId: classroom.id)).requireData
            .map((PracticeSession session) => session.id),
        <String>['s1', 's2'],
      );
      await other.close();
    });

    test('rename a new pupil whose nickname is taken in the class', () async {
      // Arrange
      await carry(teacher, pupils);
      await pupils.addPupils(
        params: AddPupilsParams(
          classroomId: classroom.id,
          nicknames: const <String>['Moussa'],
        ),
      );
      await teacher.addPupils(
        params: AddPupilsParams(
          classroomId: classroom.id,
          nicknames: const <String>['Moussa'],
        ),
      );
      // Act
      final ClassroomMergeReport actual = await carry(teacher, pupils);
      final ClassroomMergeReport actualAgain = await carry(teacher, pupils);
      // Assert
      final ClassroomRoster actualRoster = (await pupils.getRoster(
        params: classroom.id,
      )).requireData;
      expect(actual.addedPupilCount, 1);
      expect(actual.renamedNicknames, <String>['Moussa 2']);
      expect(actualAgain.addedPupilCount, 0);
      expect(
        actualRoster.pupils.map((pupil) => pupil.nickname),
        containsAll(<String>['Moussa', 'Moussa 2']),
      );
    });

    test('refuse a file that would take the class beyond 60', () async {
      // Arrange
      await carry(teacher, pupils);
      await pupils.addPupils(
        params: AddPupilsParams(
          classroomId: classroom.id,
          nicknames: ClassroomRules.numberNicknames(
            count: 20,
            existingCount: 40,
          ),
        ),
      );
      await teacher.addPupils(
        params: AddPupilsParams(
          classroomId: classroom.id,
          nicknames: const <String>['Awa'],
        ),
      );
      await teacher.exportClassroom(
        params: (classroomId: classroom.id, isFull: true),
      );
      pupils.files.fileToPick = teacher.files.sharedContent;
      // Act
      final AppErrorCode? actual =
          (await pupils.importClassroom()).exceptionOrNull?.code;
      // Assert
      expect(actual, AppErrorCode.limitReached);
    });
  });

  group('ClassroomFileCodec', () {
    const ClassroomFileCodec codec = ClassroomFileCodec();

    test('reads back what it writes', () async {
      // Arrange
      await teacher.exportClassroom(
        params: (classroomId: classroom.id, isFull: true),
      );
      final ClassroomTransfer input = codec.decode(
        teacher.files.sharedContent!,
      );
      // Act
      final ClassroomTransfer actual = codec.decode(
        codec.encode(
          input,
          exportedAt: DateTime.utc(2026, 10, 21),
          appVersion: '2.0.0',
        ),
      );
      // Assert
      expect(actual, input);
      expect(actual.pupils, hasLength(40));
    });

    test('refuses damaged files, other files and newer versions', () async {
      // Arrange
      await teacher.exportClassroom(
        params: (classroomId: classroom.id, isFull: true),
      );
      final Map<String, Object?> input =
          jsonDecode(teacher.files.sharedContent!) as Map<String, Object?>;
      AppErrorCode? codeOf(String text) {
        try {
          codec.decode(text);
          return null;
        } on Exception catch (error) {
          return (error as dynamic).code as AppErrorCode;
        }
      }

      // Act
      final AppErrorCode? actualJunk = codeOf('not json');
      final AppErrorCode? actualBackup = codeOf(
        jsonEncode(<String, Object?>{...input, 'format': 'kidmatix-profile'}),
      );
      final AppErrorCode? actualNewer = codeOf(
        jsonEncode(<String, Object?>{...input, 'version': 3}),
      );
      final Map<String, Object?> inputClassroom =
          input['classroom']! as Map<String, Object?>;
      final AppErrorCode? actualBadDate = codeOf(
        jsonEncode(<String, Object?>{
          ...input,
          'classroom': <String, Object?>{
            ...inputClassroom,
            'created_at': 9007199254740991,
          },
        }),
      );
      final AppErrorCode? actualMissing = codeOf(
        jsonEncode(<String, Object?>{...input, 'classroom': null}),
      );
      // Assert
      expect(actualJunk, AppErrorCode.invalidFile);
      expect(actualBackup, AppErrorCode.invalidFile);
      expect(actualNewer, AppErrorCode.unsupportedVersion);
      expect(actualMissing, AppErrorCode.invalidFile);
      expect(actualBadDate, AppErrorCode.invalidFile);
    });

    test('refuses a file whose sessions point to an unknown pupil', () async {
      // Arrange
      final ClassroomRoster roster = (await teacher.getRoster(
        params: classroom.id,
      )).requireData;
      await teacher.play(_session('s1', roster.pupils.first.id, <bool>[true]));
      await teacher.exportClassroom(
        params: (classroomId: classroom.id, isFull: true),
      );
      final Map<String, Object?> input =
          jsonDecode(teacher.files.sharedContent!) as Map<String, Object?>;
      pupils.files.fileToPick = jsonEncode(<String, Object?>{
        ...input,
        'pupils': <Object?>[],
      });
      // Act
      final AppErrorCode? actual =
          (await pupils.importClassroom()).exceptionOrNull?.code;
      // Assert
      expect(actual, AppErrorCode.invalidFile);
      expect((await pupils.getClassrooms()).requireData, isEmpty);
    });
  });
}

extension on SavedQuizSession {
  SavedQuizSession copyWithEnd(DateTime endedAt) {
    return SavedQuizSession(
      id: id,
      profileId: profileId,
      domainId: domainId,
      mode: mode,
      isCompleted: isCompleted,
      questionCount: questionCount,
      correctCount: correctCount,
      endedAt: endedAt,
      duration: duration,
      answers: answers,
    );
  }
}
