import 'package:meta/meta.dart';

/// What the teacher types to create a class.
@immutable
final class CreateClassroomParams {
  /// Creates the parameters.
  const CreateClassroomParams({required this.name, required this.nicknames});

  /// Name of the class, as typed.
  final String name;

  /// Nicknames or numbers of its pupils, in order.
  final List<String> nicknames;
}
