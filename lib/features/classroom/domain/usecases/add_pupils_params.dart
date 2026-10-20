import 'package:meta/meta.dart';

/// Pupils to add to an existing class.
@immutable
final class AddPupilsParams {
  /// Creates the parameters.
  const AddPupilsParams({required this.classroomId, required this.nicknames});

  /// Class that receives them.
  final String classroomId;

  /// Nicknames or numbers of the new pupils, in order.
  final List<String> nicknames;
}
