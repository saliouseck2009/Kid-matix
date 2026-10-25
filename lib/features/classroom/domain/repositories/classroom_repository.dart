import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';

/// The classes of the device.
///
/// Every method returns a [DataState]: failures arrive as a `DataFailed`
/// carrying a typed `AppException`, never as a thrown exception.
abstract interface class ClassroomRepository {
  /// Returns every class of the device, oldest first.
  Future<DataState<List<ClassroomEntity>>> getClassrooms();

  /// Returns the class [classroomId].
  ///
  /// Fails with a `NotFoundException` when there is none.
  Future<DataState<ClassroomEntity>> getClassroom({
    required String classroomId,
  });

  /// Stores the new [classroom].
  Future<DataState<void>> createClassroom({required ClassroomEntity classroom});

  /// Saves the changes made to an existing [classroom].
  ///
  /// Fails with a `NotFoundException` when it does not exist.
  Future<DataState<void>> updateClassroom({required ClassroomEntity classroom});

  /// Stores [classroom] received in a class file: added when the device
  /// does not have it, its name and goal replaced when the file's change
  /// is newer, left alone otherwise.
  Future<DataState<void>> mergeClassroom({required ClassroomEntity classroom});

  /// Deletes the class [classroomId] when it holds no pupil, such as a
  /// class whose pupils could not be written at its creation.
  Future<DataState<void>> deleteEmptyClassroom({required String classroomId});

  /// Emits an event after each change to the classes.
  Stream<void> watchChanges();
}
