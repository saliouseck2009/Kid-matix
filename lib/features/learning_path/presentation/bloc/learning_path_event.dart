import 'package:meta/meta.dart';

/// What happens to the learning path screen.
@immutable
sealed class LearningPathEvent {
  const LearningPathEvent();
}

/// The screen opens: load the path and follow its changes.
final class LearningPathStarted extends LearningPathEvent {
  /// Creates the event.
  const LearningPathStarted();
}

/// The stars or the settings of the player changed.
final class LearningPathChanged extends LearningPathEvent {
  /// Creates the event.
  const LearningPathChanged();
}
