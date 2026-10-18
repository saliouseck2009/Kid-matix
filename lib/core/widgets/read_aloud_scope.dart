import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/services/speech_service.dart';

/// Gives the screens below it the voice of the phone, so a tip or a
/// message of the mascot can offer a [ReadAloudButton] without any wiring
/// of its own.
///
/// Rule of the exception: a widget may reach `SpeechService` through this
/// scope only for a reading that holds no timer (a tip, a message of the
/// mascot), where nothing waits for the end of the voice. A reading that
/// must be timed, such as a question of a quiz, goes through the Bloc and
/// its use cases like any other capability.
///
/// Placed once above the router. Without it (in a test, or before a voice
/// is wired) the buttons simply do not show.
class ReadAloudScope extends InheritedWidget {
  /// Creates the scope around [child].
  const ReadAloudScope({required this.speech, required super.child, super.key});

  /// The voice.
  final SpeechService speech;

  /// The voice of the closest scope, or `null` without one. Does not
  /// listen: the voice never changes while the app runs.
  static SpeechService? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<ReadAloudScope>()?.speech;
  }

  @override
  bool updateShouldNotify(ReadAloudScope oldWidget) {
    return oldWidget.speech != speech;
  }
}
