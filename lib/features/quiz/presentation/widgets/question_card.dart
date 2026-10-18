import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/core/widgets/speech_bubble.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/spoken_as.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/math_picture_view.dart';

/// White card of the question: a label, the operation and the mascot.
///
/// A question that asks for the operation shows its label as words that
/// lead to the result, such as "Quelle multiplication donne", and the
/// result in a big yellow box. A question with a drawing, such as objects
/// to count, shows it between its label and its prompt.
class QuestionCard extends StatelessWidget {
  /// Creates the card of [prompt] under [label].
  const QuestionCard({
    required this.label,
    required this.prompt,
    this.blankText,
    this.blankColor,
    this.mascotMood = MascotMood.neutral,
    this.mascotMessage,
    this.asksOperation = false,
    this.picture,
    this.spokenText,
    this.listenButton,
    this.extra,
    this.wrapsPrompt = false,
    super.key,
  });

  static const double _radius = 28;
  static const double _mascotSize = 72;
  static const double _promptFontSize = 68;
  static const double _picturePromptFontSize = 52;

  // Whether the sentence already says the label (« Vrai ou faux ? » ends
  // the sentence of a true or false question): then the whole card is that
  // one sentence, so a screen reader does not say the label twice.
  bool get _saysLabel => spokenText?.contains(label) ?? false;

  /// Short label above the operation: the table, or "Vrai ou faux ?".
  final String label;

  /// Operation shown.
  final List<PromptToken> prompt;

  /// Digits typed in place of the blank, if any.
  final String? blankText;

  /// Color of the typed digits; the text color when `null`.
  final Color? blankColor;

  /// Face the mascot makes.
  final MascotMood mascotMood;

  /// What the mascot says, or `null`.
  final String? mascotMessage;

  /// Whether the question asks for the operation that gives a result:
  /// only the result side of [prompt], after the equals sign, is shown.
  final bool asksOperation;

  /// Drawing shown between [label] and [prompt], or `null`.
  final MathPicture? picture;

  /// The whole question as one sentence (`QuizLabels.speakQuestion`), the
  /// same one the read-aloud button says. A screen reader reads it in place
  /// of [label], [picture] and [prompt]; `null` reads the prompt token by
  /// token.
  final String? spokenText;

  /// The listen button, in the top right corner, or `null` when no voice
  /// can read the question.
  final Widget? listenButton;

  /// A widget under the prompt, such as the "Écouter en wolof" button of a
  /// word, or `null`.
  final Widget? extra;

  /// Whether the prompt is a statement that wraps on several lines in a
  /// smaller type, instead of one big line scaled down.
  final bool wrapsPrompt;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: AppSizes.space12,
            bottom: 0,
            child: MascotIllustration(size: _mascotSize, mood: mascotMood),
          ),
          if (mascotMessage case final String message)
            Positioned(
              left: AppSizes.space12,
              right: _mascotSize + AppSizes.space16,
              bottom: AppSizes.space12,
              child: Align(
                alignment: Alignment.bottomRight,
                child: SpeechBubble(text: message, color: context.palette.tint),
              ),
            ),
          Center(
            child: Padding(
              // The listen button takes the top corner: the label and the
              // operation start under it, so a large text never meets it.
              padding: EdgeInsets.fromLTRB(
                AppSizes.space16,
                listenButton == null
                    ? AppSizes.space16
                    : AppSizes.minTouchTarget + AppSizes.space8,
                AppSizes.space16,
                picture == null && !wrapsPrompt && extra == null
                    ? AppSizes.space16
                    : AppSizes.space16 + _mascotSize / 2,
              ),
              // The whole card is one sentence for a screen reader, except
              // a plain operation: its label (« Table de 5 ») stays visible
              // to it and only the prompt is replaced.
              child: SpokenAs(
                sentence: asksOperation || picture != null || _saysLabel
                    ? spokenText ??
                          (asksOperation
                              ? prompt.toSpokenText(context.l10n)
                              : null)
                    : null,
                child: switch ((asksOperation, picture)) {
                  (true, _) => _ResultPrompt(label: label, prompt: prompt),
                  (false, final MathPicture shown) => _PictureQuestion(
                    label: label,
                    picture: shown,
                    prompt: prompt,
                    blankText: blankText,
                    blankColor: blankColor,
                    fontSize: _picturePromptFontSize,
                  ),
                  (false, null) => _PlainQuestion(
                    label: label,
                    prompt: prompt,
                    blankText: blankText,
                    blankColor: blankColor,
                    fontSize: _promptFontSize,
                    wraps: wrapsPrompt,
                    spokenText: _saysLabel ? null : spokenText,
                    extra: extra,
                  ),
                },
              ),
            ),
          ),
          if (listenButton case final Widget button)
            Positioned(
              top: AppSizes.space8,
              right: AppSizes.space8,
              child: button,
            ),
        ],
      ),
    );
  }
}

/// A question with no drawing: the label, the prompt (one big line, or a
/// statement that wraps) and what goes under it. It scrolls when a large
/// text leaves it too little room, and stays centered otherwise.
class _PlainQuestion extends StatelessWidget {
  const _PlainQuestion({
    required this.label,
    required this.prompt,
    required this.blankText,
    required this.blankColor,
    required this.fontSize,
    required this.wraps,
    required this.spokenText,
    required this.extra,
  });

  final String label;
  final List<PromptToken> prompt;
  final String? blankText;
  final Color? blankColor;
  final double fontSize;
  final bool wraps;
  final String? spokenText;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _QuestionLabel(label: label),
                  const SizedBox(height: AppSizes.space8),
                  if (prompt.isNotEmpty)
                    SpokenAs(
                      sentence: spokenText,
                      child: _PromptText(
                        prompt: prompt,
                        blankText: blankText,
                        blankColor: blankColor,
                        fontSize: fontSize,
                        wraps: wraps,
                      ),
                    ),
                  if (extra case final Widget shown) ...<Widget>[
                    const SizedBox(height: AppSizes.space12),
                    shown,
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuestionLabel extends StatelessWidget {
  const _QuestionLabel({required this.label});

  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 6,
  );

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: context.palette.tint,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: context.palette.primaryText,
        ),
      ),
    );
  }
}

/// A question with a drawing: the label, the drawing, then the prompt
/// when it has one; a number line holds its own blank.
class _PictureQuestion extends StatelessWidget {
  const _PictureQuestion({
    required this.label,
    required this.picture,
    required this.prompt,
    required this.blankText,
    required this.blankColor,
    required this.fontSize,
  });

  final String label;
  final MathPicture picture;
  final List<PromptToken> prompt;
  final String? blankText;
  final Color? blankColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _QuestionLabel(label: label),
        const SizedBox(height: AppSizes.space12),
        Flexible(
          child: MathPictureView(
            picture: picture,
            blankText: prompt.isEmpty ? blankText : null,
            blankColor: blankColor,
          ),
        ),
        if (prompt.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSizes.space8),
          _PromptText(
            prompt: prompt,
            blankText: blankText,
            blankColor: blankColor,
            fontSize: fontSize,
          ),
        ],
      ],
    );
  }
}

class _PromptText extends StatelessWidget {
  const _PromptText({
    required this.prompt,
    required this.blankText,
    required this.blankColor,
    required this.fontSize,
    this.wraps = false,
  });

  final List<PromptToken> prompt;
  final String? blankText;
  final Color? blankColor;
  final double fontSize;
  final bool wraps;

  List<InlineSpan> _buildSpans() {
    final List<String> parts = prompt.toDisplayParts(blankText: blankText);
    return <InlineSpan>[
      for (int index = 0; index < parts.length; index++)
        TextSpan(
          text: index == 0 ? parts[index] : ' ${parts[index]}',
          style: prompt[index] is BlankToken && blankText != null
              ? TextStyle(color: blankColor)
              : null,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(
      context,
    ).textTheme.displaySmall?.copyWith(fontSize: fontSize);
    if (wraps) {
      return Semantics(
        label: prompt.toSpokenText(context.l10n),
        excludeSemantics: true,
        child: Text(
          prompt.toDisplayText(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }
    return Semantics(
      label: prompt.toSpokenText(context.l10n),
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text.rich(
          TextSpan(
            style: style,
            children: _buildSpans(),
          ),
          maxLines: 1,
        ),
      ),
    );
  }
}

/// "Quelle multiplication donne" above the result in a yellow box.
class _ResultPrompt extends StatelessWidget {
  const _ResultPrompt({
    required this.label,
    required this.prompt,
  });

  static const double _fontSize = 84;
  static const double _radius = 28;
  static const double _minWidth = 150;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSizes.space24,
    vertical: AppSizes.space4,
  );

  final String label;
  final List<PromptToken> prompt;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final List<PromptToken> result = prompt
        .skipWhile((PromptToken token) => token is! EqualsToken)
        .skip(1)
        .toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSizes.space8,
      children: <Widget>[
        Text(
          label,
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: context.palette.mutedText,
            fontWeight: FontWeight.w800,
          ),
        ),
        Container(
          constraints: const BoxConstraints(minWidth: _minWidth),
          padding: _padding,
          decoration: BoxDecoration(
            color: colors.secondary,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              result.toDisplayText(),
              textAlign: TextAlign.center,
              style: textTheme.displaySmall?.copyWith(
                fontSize: _fontSize,
                color: colors.onSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
