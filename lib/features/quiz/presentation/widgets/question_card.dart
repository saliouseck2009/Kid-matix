import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';

/// White card of the question: a label, the operation and the mascot.
class QuestionCard extends StatelessWidget {
  /// Creates the card of [prompt] under [label].
  const QuestionCard({
    required this.label,
    required this.prompt,
    this.blankText,
    this.blankColor,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned(
            right: AppSizes.space12,
            bottom: 0,
            child: MascotIllustration(size: _mascotSize),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.space16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _QuestionLabel(label: label),
                  const SizedBox(height: AppSizes.space8),
                  _PromptText(
                    prompt: prompt,
                    blankText: blankText,
                    blankColor: blankColor,
                    fontSize: _promptFontSize,
                  ),
                ],
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
