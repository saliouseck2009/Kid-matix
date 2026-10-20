import 'package:kid_matix/features/classroom/domain/usecases/add_pupils_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/find_unusable_nicknames_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classroom_roster_use_case.dart';
import 'package:meta/meta.dart';

/// The use cases of the form of a class.
@immutable
final class ClassroomFormUseCases {
  /// Groups the use cases.
  const ClassroomFormUseCases({
    required this.create,
    required this.addPupils,
    required this.findUnusable,
    required this.getRoster,
  });

  /// Creates a class with its pupils.
  final CreateClassroomUseCase create;

  /// Adds pupils to a class.
  final AddPupilsUseCase addPupils;

  /// Finds the nicknames that cannot be used.
  final FindUnusableNicknamesUseCase findUnusable;

  /// Reads a class and its pupils.
  final GetClassroomRosterUseCase getRoster;
}
