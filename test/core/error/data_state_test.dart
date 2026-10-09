import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';

String _describeState(DataState<int> state) {
  return switch (state) {
    DataSuccess<int>(:final int data) => 'success:$data',
    DataFailed<int>(:final AppException exception) =>
      'failed:${exception.code.name}',
  };
}

void main() {
  group('DataState', () {
    test('a success exposes its data', () {
      // Arrange
      const DataState<int> inputState = DataSuccess<int>(42);
      const String expectedDescription = 'success:42';
      // Act
      final String actualDescription = _describeState(inputState);
      // Assert
      expect(actualDescription, expectedDescription);
    });
    test('a failure exposes its typed exception', () {
      // Arrange
      const DataState<int> inputState = DataFailed<int>(CacheException());
      const String expectedDescription = 'failed:cache';
      // Act
      final String actualDescription = _describeState(inputState);
      // Assert
      expect(actualDescription, expectedDescription);
    });
  });
  group('AppException', () {
    test('each exception type carries its own stable error code', () {
      // Arrange
      const List<AppException> inputExceptions = <AppException>[
        CacheException(),
        ValidationException(),
        NotFoundException(),
        ConflictException(),
        UnknownException(),
      ];
      const List<AppErrorCode> expectedCodes = <AppErrorCode>[
        AppErrorCode.cache,
        AppErrorCode.validation,
        AppErrorCode.notFound,
        AppErrorCode.conflict,
        AppErrorCode.unknown,
      ];
      // Act
      final List<AppErrorCode> actualCodes = inputExceptions
          .map((AppException exception) => exception.code)
          .toList();
      // Assert
      expect(actualCodes, expectedCodes);
    });
  });
}
