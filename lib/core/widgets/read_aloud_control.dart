import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/services/speech_service.dart';
import 'package:kid_matix/core/widgets/read_aloud_builder.dart';
import 'package:kid_matix/core/widgets/read_aloud_scope.dart';

/// Gives [builder] the means to read [text] aloud, for a screen whose
/// reading does not hold any timer (a tip, a message of the mascot).
///
/// The voice comes from the [ReadAloudScope] and speaks the language of the
/// interface. Without a scope or without an installed voice, [builder]
/// gets no action: the widget it draws then offers nothing, and shows no
/// message. The action starts the reading, or stops it while the voice
/// speaks; leaving the screen, or the app going to the background, stops it
/// too.
class ReadAloudControl extends StatefulWidget {
  /// Creates the control that reads [text] and draws itself with
  /// [builder].
  const ReadAloudControl({
    required this.text,
    required this.builder,
    super.key,
  });

  /// What the voice says.
  final String text;

  /// Draws the control, with its action once a voice exists.
  final ReadAloudBuilder builder;

  @override
  State<ReadAloudControl> createState() => _ReadAloudControlState();
}

class _ReadAloudControlState extends State<ReadAloudControl> {
  SpeechService? _speech;
  String? _languageCode;
  bool _hasVoice = false;
  bool _isSpeaking = false;

  // The reading of this control, to stop it and no other: another screen
  // may have started its own since.
  Future<void>? _reading;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onHide: _stopOwnReading);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final SpeechService? speech = ReadAloudScope.maybeOf(context);
    final String languageCode = Localizations.localeOf(context).languageCode;
    if (speech == _speech && languageCode == _languageCode) return;
    _speech = speech;
    _languageCode = languageCode;
    unawaited(_findVoice(speech, languageCode));
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _stopOwnReading();
    super.dispose();
  }

  void _stopOwnReading() {
    if (_isSpeaking) unawaited(_speech?.stop(reading: _reading));
  }

  Future<void> _findVoice(SpeechService? speech, String languageCode) async {
    final bool hasVoice =
        speech != null && await speech.isAvailable(languageCode: languageCode);
    if (!mounted || speech != _speech || languageCode != _languageCode) return;
    setState(() => _hasVoice = hasVoice);
  }

  Future<void> _toggle() async {
    final SpeechService? speech = _speech;
    final String? languageCode = _languageCode;
    if (speech == null || languageCode == null) return;
    if (_isSpeaking) return speech.stop(reading: _reading);
    final Future<void> reading = speech.speak(
      text: widget.text,
      languageCode: languageCode,
    );
    _reading = reading;
    setState(() => _isSpeaking = true);
    await reading;
    if (mounted) setState(() => _isSpeaking = false);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _hasVoice
          ? (isSpeaking: _isSpeaking, toggle: () => unawaited(_toggle()))
          : null,
    );
  }
}
