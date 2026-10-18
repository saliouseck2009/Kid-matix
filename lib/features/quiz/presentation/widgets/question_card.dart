import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/core/widgets/speech_bubble.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';

/// White card of the question: a label, the operation and the mascot.
///
/// A question that asks for the operation shows its label as words that
/// lead to the result, such as "Quelle multiplication donne", and the
/// result in a big yellow box.
class QuestionCard extends StatelessWidget {
  /// Creates the card of [prompt] under [label].
  const QuestionCard({
    required this.label,
    required this.prompt,
    this.blankText,
    this.blankColor,
    this.mascotMood = MascotMood.neutral,
    this.mascotMessage,
    this.resultSemanticLabel,
    super.key,
  });

  static const double _radius = 28;
  static const double _mascotSize = 72;
  static const double _promptFontSize = 68;

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

  /// What a screen reader says for a question that asks for the
  /// operation; `null` for an operation to complete. When set, only the
  /// result side of [prompt], after the equals sign, is shown.
  final String? resultSemanticLabel;

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
              padding: const EdgeInsets.all(AppSizes.space16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: switch (resultSemanticLabel) {
                  final String semanticLabel => <Widget>[
                    _ResultPrompt(
                      label: label,
                      prompt: prompt,
                      semanticLabel: semanticLabel,
                    ),
                  ],
                  null => <Widget>[
                    _QuestionLabel(label: label),
                    const SizedBox(height: AppSizes.space8),
                    _PromptText(
                      prompt: prompt,
                      blankText: blankText,
                      blankColor: blankColor,
                      fontSize: _promptFontSize,
                    ),
                  ],
                },
              ),
            ),
          ),
        ],
      ),
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

class _PromptText extends StatelessWidget {
  const _PromptText({
    required this.prompt,
    required this.blankText,
    required this.blankColor,
    required this.fontSize,
  });

  final List<PromptToken> prompt;
  final String? blankText;
  final Color? blankColor;
  final double fontSize;

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
    required this.semanticLabel,
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
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final List<PromptToken> result = prompt
        .skipWhile((PromptToken token) => token is! EqualsToken)
        .skip(1)
        .toList();
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Column(
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
      ),
    );
  }
}
