import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';

/// Builds the app keypad: [onValidate] is `null` while nothing is typed.
typedef PlacementKeypadBuilder = Widget Function({
  required ValueChanged<int> onDigit,
  required VoidCallback onErase,
  required VoidCallback? onValidate,
});

/// Builds the card of a question: [label] above [prompt], with
/// [typedDigits] in place of its blank.
typedef PlacementQuestionCardBuilder = Widget Function({
  required String label,
  required List<PromptToken> prompt,
  String? typedDigits,
});

/// The widgets of the quiz the placement test shows, given by the router
/// so the test looks like every quiz.
final class PlacementSlots {
  /// Creates the slots.
  const PlacementSlots({required this.keypad, required this.questionCard});

  /// The keypad under the question.
  final PlacementKeypadBuilder keypad;

  /// The card of the question.
  final PlacementQuestionCardBuilder questionCard;
}
