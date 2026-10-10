import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/item_help.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/prompt_reading.dart';

/// Help card shown in place of the question after two mistakes on the
/// same fact: the whole unit with the fact highlighted, and its dots.
class QuizHelpCard extends StatelessWidget {
  /// Creates the card of [help], for the unit named [unitName].
  const QuizHelpCard({required this.help, required this.unitName, super.key});

  static const double _radius = 28;

  /// Facts and dots to show.
  final ItemHelp help;

  /// Name of the unit, such as "Table de 7".
  final String unitName;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DotGrid? dotGrid = help.dotGrid;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSizes.space12,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(
                context.l10n.quizHelpTitle(unitName),
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSizes.space24,
              runSpacing: AppSizes.space16,
              children: <Widget>[
                _UnitFacts(help: help),
                if (dotGrid != null) _DotGridView(grid: dotGrid),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitFacts extends StatelessWidget {
  const _UnitFacts({required this.help});

  static const EdgeInsets _linePadding = EdgeInsets.symmetric(
    horizontal: AppSizes.space8,
    vertical: 1,
  );

  final ItemHelp help;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.bodyLarge;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int index = 0; index < help.unitFacts.length; index++)
          _FactLine(
            fact: help.unitFacts[index],
            isHighlighted: index == help.itemIndex,
            style: style,
            padding: _linePadding,
          ),
      ],
    );
  }
}

class _FactLine extends StatelessWidget {
  const _FactLine({
    required this.fact,
    required this.isHighlighted,
    required this.style,
    required this.padding,
  });

  final List<PromptToken> fact;
  final bool isHighlighted;
  final TextStyle? style;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: fact.toSpokenText(context.l10n),
      selected: isHighlighted,
      excludeSemantics: true,
      child: Container(
        padding: padding,
        decoration: isHighlighted
            ? BoxDecoration(
                color: context.palette.tint,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              )
            : null,
        child: Text(
          fact.toDisplayText(),
          style: isHighlighted
              ? style?.copyWith(
                  color: context.palette.primaryText,
                  fontWeight: FontWeight.w800,
                )
              : style,
        ),
      ),
    );
  }
}

class _DotGridView extends StatelessWidget {
  const _DotGridView({required this.grid});

  static const double _dotSize = 10;
  static const double _gap = 4;

  final DotGrid grid;

  @override
  Widget build(BuildContext context) {
    final String label = context.l10n.quizHelpDotGridLabel(
      grid.rows,
      grid.columns,
    );
    final Widget dot = Container(
      width: _dotSize,
      height: _dotSize,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSizes.space8,
      children: <Widget>[
        ExcludeSemantics(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: _gap,
            children: <Widget>[
              for (int row = 0; row < grid.rows; row++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: _gap,
                  children: List<Widget>.filled(grid.columns, dot),
                ),
            ],
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: context.palette.mutedText),
        ),
      ],
    );
  }
}
