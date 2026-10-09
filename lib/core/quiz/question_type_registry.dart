import 'package:kid_matix/core/quiz/question_type.dart';

/// The question types of the app, declared once at startup.
final class QuestionTypeRegistry {
  final Map<String, QuestionType> _types = <String, QuestionType>{};

  /// Every registered question type, in registration order.
  List<QuestionType> get questionTypes =>
      List<QuestionType>.unmodifiable(_types.values);

  /// Declares [questionType]; registering the same identifier twice is a
  /// programming error.
  void register(QuestionType questionType) {
    if (_types.containsKey(questionType.id)) {
      throw StateError(
        'Question type ${questionType.id} is already '
        'registered.',
      );
    }
    _types[questionType.id] = questionType;
  }

  /// Returns the question type [id], or `null` when it is not registered.
  QuestionType? find(String id) => _types[id];
}
