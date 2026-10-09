import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/usecases/nickname_checker.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/profile_fixtures.dart';

void main() {
  late MockProfileRepository mockRepository;
  late NicknameChecker checker;

  setUp(() {
    mockRepository = MockProfileRepository();
    checker = NicknameChecker(repository: mockRepository);
  });

  void stubTaken(DataState<bool> state) {
    when(
      () => mockRepository.isNicknameTaken(
        nickname: any(named: 'nickname'),
        excludedProfileId: any(named: 'excludedProfileId'),
      ),
    ).thenAnswer((_) async => state);
  }

  group('NicknameChecker', () {
    test('accepts a valid nickname nobody uses', () async {
      // Arrange
      stubTaken(const DataSuccess<bool>(false));
      // Act
      final AppException? actualProblem = await checker.findProblem(
        nickname: 'Awa',
      );
      // Assert
      expect(actualProblem, isNull);
    });
    test('rejects a nickname that breaks the rules without a lookup', () async {
      // Arrange
      const String inputNickname = 'A';
      // Act
      final AppException? actualProblem = await checker.findProblem(
        nickname: inputNickname,
      );
      // Assert
      expect(actualProblem, isA<ValidationException>());
      verifyNever(
        () => mockRepository.isNicknameTaken(
          nickname: any(named: 'nickname'),
          excludedProfileId: any(named: 'excludedProfileId'),
        ),
      );
    });
    test('reports a taken nickname as a conflict', () async {
      // Arrange
      stubTaken(const DataSuccess<bool>(true));
      // Act
      final AppException? actualProblem = await checker.findProblem(
        nickname: 'awa',
      );
      // Assert
      expect(actualProblem, isA<ConflictException>());
    });
    test('passes the excluded profile to the lookup', () async {
      // Arrange
      stubTaken(const DataSuccess<bool>(false));
      // Act
      await checker.findProblem(nickname: 'Awa', excludedProfileId: 'p-1');
      // Assert
      verify(
        () => mockRepository.isNicknameTaken(
          nickname: 'Awa',
          excludedProfileId: 'p-1',
        ),
      ).called(1);
    });
    test('forwards a storage failure', () async {
      // Arrange
      const CacheException expectedException = CacheException();
      stubTaken(const DataFailed<bool>(expectedException));
      // Act
      final AppException? actualProblem = await checker.findProblem(
        nickname: 'Awa',
      );
      // Assert
      expect(actualProblem, expectedException);
    });
  });
}
