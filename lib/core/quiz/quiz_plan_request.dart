import 'package:meta/meta.dart';

/// The questions a quiz needs, before the mastery engine chooses them.
@immutable
final class QuizPlanRequest {
  /// Creates the request.
  QuizPlanRequest({
    required this.profileId,
    required this.domainId,
    required List<String> itemKeys,
    required List<String> questionTypeIds,
    required this.questionCount,
  }) : itemKeys = List<String>.unmodifiable(itemKeys),
       questionTypeIds = List<String>.unmodifiable(questionTypeIds);

  /// Player of the quiz.
  final String profileId;

  /// Learning domain of the items.
  final String domainId;

  /// Items to draw from.
  final List<String> itemKeys;

  /// Question types allowed in the quiz.
  final List<String> questionTypeIds;

  /// Questions to plan.
  final int questionCount;
}
