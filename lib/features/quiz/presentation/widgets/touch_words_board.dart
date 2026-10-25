import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/sentence_part.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/touchable_sentence.dart';

/// A "Tap to understand" question: a sentence whose math words are colored.
/// Touching one says it in French, then plays its recorded explanation in
/// the help language of the player when there is one, and shows its
/// drawing; the example of the word plays on request.
///
/// The child has understood once the word asked has been touched: then the
/// button gives [onUnderstood] the answer. Nothing here is a trick: a touch
/// on another colored word only explains that word.
class TouchWordsBoard extends StatefulWidget {
  /// Creates the board of [sentence], asking for the word [targetKey].
  const TouchWordsBoard({
    required this.sentence,
    required this.targetKey,
    required this.targetAnswer,
    required this.onUnderstood,
    required this.languageCode,
    this.listenButton,
    super.key,
  });

  /// Language of the words, such as `fr`, which the voice speaks.
  final String languageCode;

  /// The sentence, piece by piece.
  final List<SentencePart> sentence;

  /// Key of the word the question is about.
  final String targetKey;

  /// The answer given when the word asked has been touched.
  final Answer targetAnswer;

  /// Called with [targetAnswer]; `null` once the answer is judged, which
  /// disables the button.
  final ValueChanged<Answer>? onUnderstood;

  /// The listen button that reads the sentence, or `null` when no voice
  /// can read it.
  final Widget? listenButton;

  @override
  State<TouchWordsBoard> createState() => _TouchWordsBoardState();
}

class _TouchWordsBoardState extends State<TouchWordsBoard> {
  static const double _radius = 28;

  final Set<String> _touched = <String>{};

  bool get _hasUnderstood => _touched.contains(widget.targetKey);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space16,
      children: <Widget>[
        Row(
          spacing: AppSizes.space8,
          children: <Widget>[
            Expanded(
              child: Text(
                context.l10n.quizWordTouchLabel,
                style: textTheme.headlineSmall,
              ),
            ),
            ?widget.listenButton,
          ],
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(_radius),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.space16),
              child: TouchableSentence(
                sentence: widget.sentence,
                languageCode: widget.languageCode,
                onTouched: (String wordKey) =>
                    setState(() => _touched.add(wordKey)),
              ),
            ),
          ),
        ),
        if (!_hasUnderstood && widget.onUnderstood != null)
          Text(
            context.l10n.quizWordTouchFirst,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: context.palette.mutedText,
            ),
          ),
        DepthButton(
          label: context.l10n.quizWordUnderstood,
          onPressed: _hasUnderstood && widget.onUnderstood != null
              ? () => widget.onUnderstood!(widget.targetAnswer)
              : null,
        ),
      ],
    );
  }
}
