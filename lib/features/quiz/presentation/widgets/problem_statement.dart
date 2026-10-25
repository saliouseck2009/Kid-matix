import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/quiz/sentence_part.dart';
import 'package:kid_matix/core/widgets/help_audio_button.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/touchable_sentence.dart';

/// The statement of a word problem: its math words can be touched, and
/// « Écouter en wolof » plays the recorded statement when the question has
/// one and the pack holds its file (the button is simply absent otherwise).
class ProblemStatement extends StatelessWidget {
  /// Creates the statement made of [sentence], recorded as [recordingKey].
  const ProblemStatement({
    required this.sentence,
    required this.languageCode,
    this.recordingKey,
    this.isCompact = false,
    super.key,
  });

  /// The statement, piece by piece.
  final List<SentencePart> sentence;

  /// Language of the statement, which the voice speaks.
  final String languageCode;

  /// Name of the recording of the statement in the audio packs, or `null`
  /// for a statement with drawn numbers, which nobody recorded.
  final String? recordingKey;

  /// Whether the statement is written smaller, to leave room to the model
  /// under it.
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space12,
      children: <Widget>[
        TouchableSentence(
          sentence: sentence,
          languageCode: languageCode,
          style: isCompact
              ? Theme.of(context).textTheme.titleMedium
              : Theme.of(context).textTheme.titleLarge,
        ),
        if (recordingKey case final String key)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: HelpAudioButton(wordKey: key),
          ),
      ],
    );
  }
}
