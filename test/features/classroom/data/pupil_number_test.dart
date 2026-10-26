import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:kid_matix/features/classroom/domain/usecases/add_pupils_params.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_params.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/classroom_device.dart';

/// F31-04: each pupil keeps the number given at enrolment, the one the
/// anonymous reports show; a number is never given again.
void main() {
  late ClassroomDevice device;

  setUpAll(sqfliteFfiInit);

  setUp(() async => device = await ClassroomDevice.open('numbers'));

  tearDown(() => device.close());

  Future<Map<String, int>> numbersOf(String classroomId) async {
    final ClassroomRoster roster = (await device.getRoster(
      params: classroomId,
    )).requireData;
    return (await device.numbers.assign(
      classroomId: classroomId,
      pupilIds: roster.pupils.map((PupilEntity p) => p.id).toList(),
    )).requireData;
  }

  test('a removed pupil\'s number is never given again', () async {
    // Arrange
    final ClassroomEntity classroom = (await device.createClassroom(
      params: const CreateClassroomParams(
        name: 'CE1',
        nicknames: <String>['Awa', 'Moussa', 'Fatou'],
      ),
    )).requireData;
    final ClassroomRoster roster = (await device.getRoster(
      params: classroom.id,
    )).requireData;
    final Map<String, int> before = await numbersOf(classroom.id);
    final PupilEntity removed = roster.pupils.firstWhere(
      (PupilEntity pupil) => before[pupil.id] == 3,
    );
    // Act
    await device.roster.removePupil(profileId: removed.id);
    await device.addPupils(
      params: AddPupilsParams(
        classroomId: classroom.id,
        nicknames: const <String>['Ibou'],
      ),
    );
    final Map<String, int> actual = await numbersOf(classroom.id);
    // Assert
    expect(before.values.toSet(), <int>{1, 2, 3});
    for (final PupilEntity pupil in roster.pupils) {
      if (pupil.id != removed.id) expect(actual[pupil.id], before[pupil.id]);
    }
    final ClassroomRoster after = (await device.getRoster(
      params: classroom.id,
    )).requireData;
    final PupilEntity newcomer = after.pupils.firstWhere(
      (PupilEntity pupil) => pupil.nickname == 'Ibou',
    );
    expect(actual[newcomer.id], 4);
  });
}
