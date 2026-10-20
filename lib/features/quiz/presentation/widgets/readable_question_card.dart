import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/services/speech_reading.dart';
import 'package:kid_matix/core/widgets/listen_button.dart';
import 'package:kid_matix/features/quiz/domain/entities/read_aloud_mode.dart';
import 'package:kid_matix/features/quiz/domain/usecases/read_aloud_mode_params.dart';
import 'package:kid_matix/features/quiz/domain/usecases/read_aloud_params.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_read_aloud_use_cases.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/question_card.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_labels.dart';

/// The question card of a screen outside the quiz that reads its question
/// aloud, such as the placement test: the same card and the same sentence
/// as in a quiz, with the « Écouter » button.
///
/// Like in a quiz, the button shows only when a voice exists for the
/// language, and every new question reads itself when the player turned
/// "Lire les questions à voix haute" on. No timer waits for the voice.
/// Without [readAloud] the card is silent and shows no button.
class ReadableQuestionCard extends StatefulWidget {
  /// Creates the card of [question], asked to [profileId] in [domainId];
  /// [typedDigits] stand in place of its blank.
  const ReadableQuestionCard({
    required this.profileId,
    required this.question,
    required this.domainId,
    required this.domains,
    this.readAloud,
    this.typedDigits,
    super.key,
  });

  /// Player the question is asked to; their setting says whether the
  /// questions read themselves.
  final String profileId;

  /// Question asked.
  final Question question;

  /// Learning domain of the question.
  final String domainId;

  /// Registered learning domains.
  final DomainRegistry domains;

  /// The reading aloud use cases, or `null` for a silent card.
  final QuizReadAloudUseCases? readAloud;

  /// Digits typed in place of the blank, if any.
  final String? typedDigits;

  @override
  State<ReadableQuestionCard> createState() => _ReadableQuestionCardState();
}

class _ReadableQuestionCardState extends State<ReadableQuestionCard> {
  ReadAloudMode _mode = ReadAloudMode.unavailable;
  String? _languageCode;
  SpeechReading? _reading;
  bool _isSpeaking = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String languageCode = Localizations.localeOf(context).languageCode;
    if (languageCode == _languageCode) return;
    _languageCode = languageCode;
    unawaited(_loadMode(languageCode));
  }

  @override
  void didUpdateWidget(ReadableQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question == widget.question) return;
    _silence();
    if (_mode == ReadAloudMode.automatic) _speak();
  }

  @override
  void dispose() {
    _silence();
    super.dispose();
  }

  Future<void> _loadMode(String languageCode) async {
    final QuizReadAloudUseCases? cases = widget.readAloud;
    if (cases == null) return;
    final ReadAloudMode mode = await cases.getMode(
      params: ReadAloudModeParams(
        profileId: widget.profileId,
        languageCode: languageCode,
      ),
    );
    if (!mounted || languageCode != _languageCode) return;
    setState(() => _mode = mode);
    if (mode == ReadAloudMode.automatic) _speak();
  }

  QuizLabels get _labels =>
      QuizLabels(domains: widget.domains, l10n: context.l10n);

  void _speak() {
    final QuizReadAloudUseCases? cases = widget.readAloud;
    final String? languageCode = _languageCode;
    if (cases == null || languageCode == null) return;
    final SpeechReading reading = cases.read(
      params: ReadAloudParams(
        text: _labels.speakQuestion(widget.question, widget.domainId),
        languageCode:
            widget.domains.find(widget.domainId)?.contentLanguageCode ??
            languageCode,
      ),
    );
    _reading = reading;
    setState(() => _isSpeaking = true);
    unawaited(
      reading.done.whenComplete(() {
        if (mounted && identical(_reading, reading)) {
          setState(() => _isSpeaking = false);
        }
      }),
    );
  }

  void _toggle() {
    if (_isSpeaking) {
      _silence();
      setState(() {});
    } else {
      _speak();
    }
  }

  void _silence() {
    final SpeechReading? reading = _reading;
    _reading = null;
    _isSpeaking = false;
    if (reading != null) {
      unawaited(widget.readAloud?.stop(params: reading));
    }
  }

  @override
  Widget build(BuildContext context) {
    final QuizLabels labels = _labels;
    return QuestionCard(
      label: labels.describeQuestion(widget.question, widget.domainId),
      prompt: widget.question.prompt,
      picture: widget.question.picture,
      spokenText: labels.speakQuestion(widget.question, widget.domainId),
      blankText: widget.typedDigits,
      listenButton: _mode == ReadAloudMode.unavailable
          ? null
          : ListenButton(isSpeaking: _isSpeaking, onPressed: _toggle),
    );
  }
}
