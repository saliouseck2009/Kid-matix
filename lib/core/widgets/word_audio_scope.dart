import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/entities/help_audio.dart';
import 'package:kid_matix/core/services/word_audio_service.dart';

/// Gives the screens below it the recorded help of the math words, so any
/// screen that presents a word can offer a `HelpAudioButton` with no
/// wiring of its own.
///
/// Placed once above the router. Without it (in a test, or before the
/// packs are wired) the buttons simply do not show.
class WordAudioScope extends InheritedWidget {
  /// Creates the scope around [child].
  const WordAudioScope({required this.audio, required super.child, super.key});

  /// The recordings.
  final WordAudioService audio;

  /// The service of the closest scope, or `null` without one. Does not
  /// listen: the packs never change while the app runs.
  static WordAudioService? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<WordAudioScope>()?.audio;
  }

  @override
  bool updateShouldNotify(WordAudioScope oldWidget) {
    return oldWidget.audio != audio;
  }
}

/// Tells the screens below it the help language of the player who is
/// playing (the "Aide audio" setting): the code of an audio pack, or
/// [HelpAudio.none].
class HelpAudioLanguageScope extends InheritedWidget {
  /// Creates the scope around [child].
  const HelpAudioLanguageScope({
    required this.language,
    required super.child,
    super.key,
  });

  /// Code of the help language, or [HelpAudio.none].
  final String language;

  /// The help language of the closest scope; [HelpAudio.none] without one,
  /// so nothing plays unless a player asked for it.
  static String of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<HelpAudioLanguageScope>()
            ?.language ??
        HelpAudio.none;
  }

  @override
  bool updateShouldNotify(HelpAudioLanguageScope oldWidget) {
    return oldWidget.language != language;
  }
}
