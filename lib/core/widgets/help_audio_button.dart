import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/entities/help_audio.dart';
import 'package:kid_matix/core/entities/word_audio_kind.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/services/speech_reading.dart';
import 'package:kid_matix/core/services/word_audio_service.dart';
import 'package:kid_matix/core/widgets/word_audio_scope.dart';

/// "Écouter en wolof": plays the recording of a math word in the help
/// language of the player, and stops it on a second touch.
///
/// It shows only when the player chose a help language and the pack has the
/// recording [kind] of [wordKey]: a missing file, a player who chose no
/// help, or no pack at all, and the widget is simply not there. Leaving the
/// screen stops the sound.
class HelpAudioButton extends StatefulWidget {
  /// Creates the button of the recording [kind] of the word [wordKey].
  const HelpAudioButton({
    required this.wordKey,
    this.kind = WordAudioKind.explanation,
    this.isCompact = false,
    super.key,
  });

  /// Key of the math word, such as `il_reste`.
  final String wordKey;

  /// The explanation, or the example of the word.
  final WordAudioKind kind;

  /// Whether the button is a speaker alone, for a line of a list; its
  /// label is then its tooltip.
  final bool isCompact;

  @override
  State<HelpAudioButton> createState() => _HelpAudioButtonState();
}

class _HelpAudioButtonState extends State<HelpAudioButton> {
  WordAudioService? _audio;
  SpeechReading? _reading;
  bool _isPlaying = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _audio = WordAudioScope.maybeOf(context);
  }

  @override
  void didUpdateWidget(HelpAudioButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.wordKey != widget.wordKey || oldWidget.kind != widget.kind) {
      _stopOwnSound();
    }
  }

  @override
  void dispose() {
    _stopOwnSound();
    super.dispose();
  }

  void _stopOwnSound() {
    if (_isPlaying) unawaited(_audio?.stop(reading: _reading));
    _isPlaying = false;
  }

  Future<void> _toggle(String language) async {
    final WordAudioService? audio = _audio;
    if (audio == null) return;
    if (_isPlaying) {
      setState(() => _isPlaying = false);
      return audio.stop(reading: _reading);
    }
    final SpeechReading reading = audio.play(
      languageCode: language,
      wordKey: widget.wordKey,
      kind: widget.kind,
    );
    _reading = reading;
    setState(() => _isPlaying = true);
    await reading.done;
    if (mounted && _reading == reading) setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    final WordAudioService? audio = _audio;
    final String language = HelpAudioLanguageScope.of(context);
    if (audio == null ||
        language == HelpAudio.none ||
        !audio.hasAudio(
          languageCode: language,
          wordKey: widget.wordKey,
          kind: widget.kind,
        )) {
      return const SizedBox.shrink();
    }
    final String name = context.l10n.helpAudioLanguageName(language);
    final String label = widget.kind == WordAudioKind.example
        ? context.l10n.helpAudioListenExample(name)
        : context.l10n.helpAudioListen(name);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: () => unawaited(_toggle(language)),
      child: widget.isCompact
          ? IconButton(
              onPressed: () => unawaited(_toggle(language)),
              tooltip: toBeginningOfSentenceCase(label),
              icon: Icon(
                _isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
              ),
              style: IconButton.styleFrom(
                foregroundColor: context.palette.primaryText,
                minimumSize: const Size.square(AppSizes.minTouchTarget),
              ),
            )
          : OutlinedButton.icon(
              onPressed: () => unawaited(_toggle(language)),
              icon: Icon(
                _isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
              ),
              label: Text(
                toBeginningOfSentenceCase(label),
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, AppSizes.minTouchTarget),
                foregroundColor: context.palette.primaryText,
                side: BorderSide(color: context.palette.border, width: 2),
              ),
            ),
    );
  }
}
