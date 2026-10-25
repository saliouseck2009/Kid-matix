import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_params.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/classroom_fakes.dart';

void main() {
  test('a class whose pupils cannot be written is not kept', () async {
    // Arrange
    final FakeClassroomStack stack = FakeClassroomStack();
    stack.roster.failsNextAddition = true;
    // Act
    final AppErrorCode? actual = (await stack.create(
      params: const CreateClassroomParams(
        name: 'CE1',
        nicknames: <String>['Awa', 'Moussa'],
      ),
    )).exceptionOrNull?.code;
    // Assert
    expect(actual, AppErrorCode.cache);
    expect(stack.classrooms.rows, isEmpty);
  });
}
