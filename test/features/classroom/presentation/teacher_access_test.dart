import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/classroom/data/repositories/teacher_code_repository_impl.dart';
import 'package:kid_matix/features/classroom/domain/usecases/choose_teacher_code_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/close_teacher_area_use_case.dart';
import 'package:kid_matix/features/classroom/domain/services/teacher_code_attempts.dart';
import 'package:kid_matix/features/classroom/domain/usecases/forget_teacher_code_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_teacher_access_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/open_teacher_area_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/teacher_access_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/teacher_access_state.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/teacher_access_use_cases.dart';
import 'package:kid_matix/features/classroom/presentation/session/teacher_session_service_impl.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/fake_profile_session_service.dart';
import '../../../helpers/in_memory_local_storage.dart';
import '../helpers/classroom_device.dart';

void main() {
  late FakeProfileSessionService players;
  late TeacherSessionServiceImpl session;
  late InMemoryLocalStorage storage;
  late TeacherAccessUseCases useCases;
  late MovableClock clock;

  setUp(() {
    players = FakeProfileSessionService();
    session = TeacherSessionServiceImpl(session: players);
    storage = InMemoryLocalStorage();
    clock = MovableClock(DateTime(2026, 10, 20, 9));
    final TeacherCodeAttempts attempts = TeacherCodeAttempts();
    final TeacherCodeRepositoryImpl codes = TeacherCodeRepositoryImpl(
      storage: storage,
    );
    useCases = TeacherAccessUseCases(
      getAccess: GetTeacherAccessUseCase(codes: codes, session: session),
      chooseCode: ChooseTeacherCodeUseCase(codes: codes, session: session),
      openArea: OpenTeacherAreaUseCase(
        codes: codes,
        lock: session,
        attempts: attempts,
        clock: clock,
      ),
      closeArea: CloseTeacherAreaUseCase(session: session),
      forgetCode: ForgetTeacherCodeUseCase(codes: codes, attempts: attempts),
    );
  });

  tearDown(() => session.dispose());

  TeacherAccessReady readyOf(TeacherAccessCubit cubit) {
    return cubit.state as TeacherAccessReady;
  }

  group('Teacher code', () {
    test('is chosen at the first visit, typed twice, and opens', () async {
      // Arrange
      final TeacherAccessCubit cubit = TeacherAccessCubit(useCases: useCases);
      await cubit.load();
      // Act
      await cubit.submit('2468');
      final TeacherCodeStep actualSecondStep = readyOf(cubit).step;
      await cubit.submit('2468');
      // Assert
      expect(actualSecondStep, TeacherCodeStep.confirm);
      expect(session.isUnlocked, isTrue);
      expect(
        await storage.readString(key: TeacherCodeRepositoryImpl.codeKey),
        '2468',
      );
      await cubit.close();
    });

    test('starts again when the two codes differ', () async {
      // Arrange
      final TeacherAccessCubit cubit = TeacherAccessCubit(useCases: useCases);
      await cubit.load();
      // Act
      await cubit.submit('2468');
      await cubit.submit('1357');
      // Assert
      expect(readyOf(cubit).step, TeacherCodeStep.choose);
      expect(readyOf(cubit).error, TeacherCodeError.mismatch);
      expect(session.isUnlocked, isFalse);
      await cubit.close();
    });

    test('refuses a code that is not 4 digits', () async {
      // Arrange
      final TeacherAccessCubit cubit = TeacherAccessCubit(useCases: useCases);
      await cubit.load();
      // Act
      await cubit.submit('12');
      // Assert
      expect(readyOf(cubit).error, TeacherCodeError.invalid);
      await cubit.close();
    });

    test('opens the area only with the right code', () async {
      // Arrange
      await storage.writeString(
        key: TeacherCodeRepositoryImpl.codeKey,
        value: '2468',
      );
      final TeacherAccessCubit cubit = TeacherAccessCubit(useCases: useCases);
      await cubit.load();
      // Act
      await cubit.submit('0000');
      final TeacherCodeError? actualError = readyOf(cubit).error;
      final bool actualAfterWrong = session.isUnlocked;
      await cubit.submit('2468');
      // Assert
      expect(readyOf(cubit).step, TeacherCodeStep.enter);
      expect(actualError, TeacherCodeError.wrong);
      expect(actualAfterWrong, isFalse);
      expect(session.isUnlocked, isTrue);
      await cubit.close();
    });

    test('cannot be chosen again once it exists', () async {
      // Arrange
      await storage.writeString(
        key: TeacherCodeRepositoryImpl.codeKey,
        value: '2468',
      );
      // Act
      final bool actualFailed =
          (await useCases.chooseCode(
            params: '1111',
          )).exceptionOrNull !=
          null;
      // Assert
      expect(actualFailed, isTrue);
      expect(
        await storage.readString(key: TeacherCodeRepositoryImpl.codeKey),
        '2468',
      );
    });
  });

  group('Wrong codes', () {
    test('close the door 30 seconds after the fifth one', () async {
      // Arrange
      await storage.writeString(
        key: TeacherCodeRepositoryImpl.codeKey,
        value: '2468',
      );
      final TeacherAccessCubit cubit = TeacherAccessCubit(useCases: useCases);
      await cubit.load();
      // Act
      for (int index = 0; index < 4; index++) {
        await cubit.submit('0000');
      }
      final TeacherCodeError? actualFourth = readyOf(cubit).error;
      await cubit.submit('0000');
      final TeacherCodeError? actualFifth = readyOf(cubit).error;
      await cubit.submit('2468');
      final bool actualWhileLocked = session.isUnlocked;
      clock.current = clock.current.add(const Duration(seconds: 30));
      await cubit.submit('2468');
      // Assert
      expect(actualFourth, TeacherCodeError.wrong);
      expect(actualFifth, TeacherCodeError.locked);
      expect(actualWhileLocked, isFalse);
      expect(session.isUnlocked, isTrue);
      await cubit.close();
    });

    test('a forgotten code is chosen again, the classes kept', () async {
      // Arrange
      await storage.writeString(
        key: TeacherCodeRepositoryImpl.codeKey,
        value: '2468',
      );
      await storage.writeString(key: 'other', value: 'kept');
      final TeacherAccessCubit cubit = TeacherAccessCubit(useCases: useCases);
      await cubit.load();
      // Act
      await cubit.forgetCode();
      await cubit.submit('1357');
      await cubit.submit('1357');
      // Assert
      expect(session.isUnlocked, isTrue);
      expect(
        await storage.readString(key: TeacherCodeRepositoryImpl.codeKey),
        '1357',
      );
      expect(await storage.readString(key: 'other'), 'kept');
      await cubit.close();
    });
  });

  group('Teacher area', () {
    test('closes when a player starts playing', () {
      // Arrange
      session.unlock();
      // Act
      players.update(hasProfiles: true, activeProfileId: 'pupil-1');
      // Assert
      expect(session.isUnlocked, isFalse);
    });

    test('closes when the teacher leaves it', () async {
      // Arrange
      session.unlock();
      // Act
      await useCases.closeArea();
      // Assert
      expect(session.isUnlocked, isFalse);
    });
  });
}
