import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/quiz/question.dart';

/// Builds the app keypad: [onValidate] is `null` while nothing is typed.
typedef PlacementKeypadBuilder = Widget Function({
  required ValueChanged<int> onDigit,
  required VoidCallback onErase,
  required VoidCallback? onValidate,
});

/// Builds the card of [question], asked to [profileId] in [domainId], with
/// [typedDigits] in place of its blank; it reads the question aloud like a
/// quiz does.
typedef PlacementQuestionCardBuilder = Widget Function({
  required String profileId,
  required Question question,
  required String domainId,
  String? typedDigits,
});

/// The widgets of the quiz the placement test shows, given by the router
/// so the test looks and reads like every quiz.
final class PlacementSlots {
  /// Creates the slots.
  const PlacementSlots({required this.keypad, required this.questionCard});

  /// The keypad under the question.
  final PlacementKeypadBuilder keypad;

  /// The card of the question.
  final PlacementQuestionCardBuilder questionCard;
}
