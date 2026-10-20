import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/features/classroom/data/models/class_answer_local_model.dart';
import 'package:kid_matix/features/classroom/data/models/class_session_local_model.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_answer.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';

part 'class_session_file_model.g.dart';

/// A session in a class file: its row, with the column names of the
/// database, and its answers as compact rows `[position, itemKey,
/// isCorrect, isRetry]` (booleans as 0 or 1), since a class sends
/// thousands of them.
@JsonSerializable(explicitToJson: true)
final class ClassSessionFileModel {
  /// Creates the entry.
  const ClassSessionFileModel({required this.session, required this.answers});

  /// Builds the entry of [session], written at [exportedAt].
  factory ClassSessionFileModel.fromEntity(
    PracticeSession session, {
    required DateTime exportedAt,
  }) {
    return ClassSessionFileModel(
      session: ClassSessionLocalModel.fromEntity(
        session,
        updatedAt: exportedAt,
      ),
      answers: <List<Object>>[
        for (final PracticeAnswer answer in session.answers)
          <Object>[
            answer.position,
            answer.itemKey,
            if (answer.isCorrect) 1 else 0,
            if (answer.isRetry) 1 else 0,
          ],
      ],
    );
  }

  /// Reads an entry of a class file.
  factory ClassSessionFileModel.fromJson(Map<String, Object?> json) =>
      _$ClassSessionFileModelFromJson(json);

  static const int _rowLength = 4;

  /// The session row.
  final ClassSessionLocalModel session;

  /// Its answers, one compact row each.
  final List<List<Object>> answers;

  /// Returns the content written in the file.
  Map<String, Object?> toJson() => _$ClassSessionFileModelToJson(this);

  /// Returns the session with its answers.
  ///
  /// Throws a [FormatException] on a malformed answer row.
  PracticeSession toEntity() {
    return session
        .toEntity(const <ClassAnswerLocalModel>[])
        .copyWith(
          answers: answers.map(_answerOf).toList(),
        );
  }

  static PracticeAnswer _answerOf(List<Object> row) {
    if (row.length != _rowLength) {
      throw const FormatException('Malformed answer row.');
    }
    final (Object position, Object itemKey, Object isCorrect, Object isRetry) =
        (row[0], row[1], row[2], row[3]);
    if (position is! int ||
        itemKey is! String ||
        isCorrect is! int ||
        isRetry is! int) {
      throw const FormatException('Malformed answer row.');
    }
    return PracticeAnswer(
      position: position,
      itemKey: itemKey,
      isCorrect: isCorrect != 0,
      isRetry: isRetry != 0,
    );
  }
}
