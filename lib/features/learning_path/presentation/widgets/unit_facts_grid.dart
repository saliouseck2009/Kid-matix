import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';

/// Every fact of a table on a white card, in two columns: the operation on
/// the left of each line, its result on the right.
class UnitFactsGrid extends StatelessWidget {
  /// Creates the grid of [facts], each a whole fact with its result.
  const UnitFactsGrid({required this.facts, super.key});

  static const double _columnGap = AppSizes.space16;
  static const double _rowGap = 10;

  /// Facts of the table, in order.
  final List<List<PromptToken>> facts;

  @override
  Widget build(BuildContext context) {
    final int half = (facts.length + 1) ~/ 2;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: _columnGap,
        children: <Widget>[
          for (final List<List<PromptToken>> column
              in <List<List<PromptToken>>>[
                facts.take(half).toList(),
                facts.skip(half).toList(),
              ])
            Expanded(
              child: Column(
                spacing: _rowGap,
                children: <Widget>[
                  for (final List<PromptToken> fact in column)
                    _FactLine(fact: fact),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FactLine extends StatelessWidget {
  const _FactLine({required this.fact});

  final List<PromptToken> fact;

  @override
  Widget build(BuildContext context) {
    final int equals = fact.indexWhere(
      (PromptToken token) => token is EqualsToken,
    );
    final List<PromptToken> operation = equals < 0
        ? fact
        : fact.sublist(0, equals);
    final List<PromptToken> result = equals < 0
        ? const <PromptToken>[]
        : fact.sublist(equals + 1);
    final TextStyle? style = Theme.of(context).textTheme.titleLarge;
    return Semantics(
      label: fact.toSpokenText(context.l10n),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.space12,
          vertical: AppSizes.space8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(operation.toDisplayText(), style: style),
              ),
            ),
            Text(
              result.toDisplayText(),
              style: style?.copyWith(color: context.palette.primaryText),
            ),
          ],
        ),
      ),
    );
  }
}
