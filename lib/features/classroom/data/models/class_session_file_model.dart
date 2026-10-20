import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/features/classroom/data/models/class_answer_local_model.dart';
import 'package:kid_matix/features/classroom/data/models/class_session_local_model.dart';

part 'class_session_file_model.g.dart';

/// A session in a class file: its row and the rows of its answers, with
/// the column names of the database.
@JsonSerializable(explicitToJson: true)
final class ClassSessionFileModel {
  /// Creates the entry.
  const ClassSessionFileModel({required this.session, required this.answers});

  /// Reads an entry of a class file.
  factory ClassSessionFileModel.fromJson(Map<String, Object?> json) =>
      _$ClassSessionFileModelFromJson(json);

  /// The session row.
  final ClassSessionLocalModel session;

  /// Its answer rows.
  final List<ClassAnswerLocalModel> answers;

  /// Returns the content written in the file.
  Map<String, Object?> toJson() => _$ClassSessionFileModelToJson(this);
}
