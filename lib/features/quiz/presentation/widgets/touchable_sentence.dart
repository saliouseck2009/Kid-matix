import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/entities/help_audio.dart';
import 'package:kid_matix/core/entities/word_audio_kind.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/sentence_part.dart';
import 'package:kid_matix/core/services/speech_reading.dart';
import 'package:kid_matix/core/services/speech_service.dart';
import 'package:kid_matix/core/services/word_audio_service.dart';
import 'package:kid_matix/core/widgets/help_audio_button.dart';
import 'package:kid_matix/core/widgets/read_aloud_scope.dart';
import 'package:kid_matix/core/widgets/word_audio_scope.dart';
import 'package:kid_matix/core/widgets/word_picture/word_picture_view.dart';

/// A sentence whose math words are colored buttons. Touching one says it
/// in French, then plays its recorded explanation in the help language of
/// the player when there is one, and shows its drawing under the sentence;
/// the example of the word plays on request.
///
/// Shared by the « Touche pour comprendre » board and by the statements of
/// the word problems. Nothing here is a trick: a touch only explains a
/// word.
class TouchableSentence extends StatefulWidget {
  /// Creates the sentence of [sentence], spoken in [languageCode].
  const TouchableSentence({
    required this.sentence,
    required this.languageCode,
    this.onTouched,
    this.style,
    super.key,
  });

  /// Language of the words, such as `fr`, which the voice speaks.
  final String languageCode;

  /// The sentence, piece by piece.
  final List<SentencePart> sentence;

  /// Called with the key of the word each time one is touched.
  final ValueChanged<String>? onTouched;

  /// Style of the sentence; the headline style by default.
  final TextStyle? style;

  @override
  State<TouchableSentence> createState() => _TouchableSentenceState();
}

class _TouchableSentenceState extends State<TouchableSentence> {
  static const double _pictureWidth = 220;

  SentencePart? _shown;
  SpeechService? _speech;
  WordAudioService? _audio;
  bool _hasVoice = false;
  SpeechReading? _speechReading;
  SpeechReading? _audioReading;
  // Identifies the newest touch: an older one stops where it is.
  int _touchCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _audio = WordAudioScope.maybeOf(context);
    final SpeechService? speech = ReadAloudScope.maybeOf(context);
    if (speech == _speech) return;
    _speech = speech;
    unawaited(_findVoice(speech));
  }

  @override
  void dispose() {
    _touchCount++;
    unawaited(_speech?.stop(reading: _speechReading));
    unawaited(_audio?.stop(reading: _audioReading));
    super.dispose();
  }

  Future<void> _findVoice(SpeechService? speech) async {
    final bool hasVoice =
        speech != null &&
        await speech.isAvailable(languageCode: widget.languageCode);
    if (mounted && speech == _speech) _hasVoice = hasVoice;
  }

  Future<void> _touch(SentencePart part, String helpLanguage) async {
    final String? wordKey = part.wordKey;
    if (wordKey == null) return;
    final int touch = ++_touchCount;
    setState(() => _shown = part);
    widget.onTouched?.call(wordKey);
    final SpeechService? speech = _speech;
    final WordAudioService? audio = _audio;
    await speech?.stop(reading: _speechReading);
    await audio?.stop(reading: _audioReading);
    if (speech != null && _hasVoice) {
      final SpeechReading reading = speech.speak(
        text: part.text,
        languageCode: widget.languageCode,
      );
      _speechReading = reading;
      await reading.done;
    }
    if (!mounted || touch != _touchCount) return;
    if (audio != null &&
        helpLanguage != HelpAudio.none &&
        audio.hasAudio(languageCode: helpLanguage, wordKey: wordKey)) {
      _audioReading = audio.play(
        languageCode: helpLanguage,
        wordKey: wordKey,
        kind: WordAudioKind.explanation,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? style =
        widget.style ?? Theme.of(context).textTheme.headlineSmall;
    final String helpLanguage = HelpAudioLanguageScope.resolve(
      context,
      _audio,
    );
    final SentencePart? shown = _shown;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space16,
      children: <Widget>[
        Text.rich(
          TextSpan(
            style: style,
            children: <InlineSpan>[
              for (final SentencePart part in widget.sentence)
                if (part.wordKey == null)
                  TextSpan(text: part.text)
                else
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: _WordChip(
                      text: part.text,
                      isSelected: shown == part,
                      style: style,
                      onTap: () => unawaited(_touch(part, helpLanguage)),
                    ),
                  ),
            ],
          ),
        ),
        if (shown?.wordKey case final String wordKey)
          _ShownWord(
            wordKey: wordKey,
            text: shown!.text,
            width: _pictureWidth,
          ),
      ],
    );
  }
}

/// A colored word of the sentence, a button.
class _WordChip extends StatelessWidget {
  const _WordChip({
    required this.text,
    required this.isSelected,
    required this.onTap,
    required this.style,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: isSelected,
      label: text,
      excludeSemantics: true,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.space4),
        child: Material(
          color: isSelected ? colors.primary : context.palette.tint,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSizes.minTouchTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.space8,
                  vertical: AppSizes.space4,
                ),
                child: Text(
                  text,
                  style: style?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? colors.onPrimary
                        : context.palette.primaryText,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The drawing of the word just touched, with its word and its recorded
/// help.
class _ShownWord extends StatelessWidget {
  const _ShownWord({
    required this.wordKey,
    required this.text,
    required this.width,
  });

  final String wordKey;
  final String text;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSizes.space8,
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width),
          child: WordPictureView(wordKey: wordKey, label: text),
        ),
        Text(text, style: Theme.of(context).textTheme.titleLarge),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSizes.space8,
          children: <Widget>[
            HelpAudioButton(wordKey: wordKey),
            HelpAudioButton(wordKey: wordKey, kind: WordAudioKind.example),
          ],
        ),
      ],
    );
  }
}
