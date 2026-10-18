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
/// playing (the "Aide audio" setting): the code of an audio pack,
/// [HelpAudio.none], or `null` for a player who never chose, which means
/// the first pack of the index.
class HelpAudioLanguageScope extends InheritedWidget {
  /// Creates the scope around [child].
  const HelpAudioLanguageScope({
    required this.language,
    required super.child,
    super.key,
  });

  /// Code of the help language, [HelpAudio.none], or `null` for the first
  /// pack.
  final String? language;

  /// The help language of the player: the one chosen, the first pack of
  /// [audio] when they never chose, and [HelpAudio.none] when they turned
  /// it off, when no scope tells who plays, or when the app ships no pack,
  /// so nothing plays unless a player can hear it.
  static String resolve(BuildContext context, WordAudioService? audio) {
    final HelpAudioLanguageScope? scope = context
        .dependOnInheritedWidgetOfExactType<HelpAudioLanguageScope>();
    if (scope == null) return HelpAudio.none;
    return scope.language ?? audio?.defaultLanguage ?? HelpAudio.none;
  }

  @override
  bool updateShouldNotify(HelpAudioLanguageScope oldWidget) {
    return oldWidget.language != language;
  }
}
