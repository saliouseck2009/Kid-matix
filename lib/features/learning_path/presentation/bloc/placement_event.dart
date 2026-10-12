import 'package:meta/meta.dart';

/// What happens during the placement test.
@immutable
sealed class PlacementEvent {
  const PlacementEvent();
}

/// The player accepted the test: build it and ask the first question.
final class PlacementStarted extends PlacementEvent {
  /// Creates the event.
  const PlacementStarted();
}

/// The player typed [digit] on the keypad.
final class PlacementDigitTyped extends PlacementEvent {
  /// Creates the event.
  const PlacementDigitTyped({required this.digit});

  /// Digit typed, from 0 to 9.
  final int digit;
}

/// The player erased the last digit typed.
final class PlacementDigitErased extends PlacementEvent {
  /// Creates the event.
  const PlacementDigitErased();
}

/// The player validated the number typed.
final class PlacementAnswerValidated extends PlacementEvent {
  /// Creates the event.
  const PlacementAnswerValidated();
}

/// The player said they do not know the answer.
final class PlacementAnswerUnknown extends PlacementEvent {
  /// Creates the event.
  const PlacementAnswerUnknown();
}
