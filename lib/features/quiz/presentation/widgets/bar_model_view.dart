import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/theme/app_feedback_palette.dart';

/// The bar model of a word problem: a whole over its parts, two bars and
/// their gap, equal groups, or a bar that holds another several times.
///
/// While the child works, the places that hold a number the story gives
/// are empty until filled ([filled]), and the place to find shows "?"
/// until [showsAnswer]. A tap on an empty place calls [onSlotTap].
class BarModelView extends StatelessWidget {
  /// Creates the view of [picture].
  const BarModelView({
    required this.picture,
    this.placed,
    this.showsAnswer = false,
    this.onSlotTap,
    this.wrongRole,
    super.key,
  });

  /// The model to draw.
  final BarModelPicture picture;

  /// The number written in each known place the child has filled; `null`
  /// writes them all as the story gives them.
  final Map<BarRole, int>? placed;

  /// Whether the place to find shows its number instead of "?".
  final bool showsAnswer;

  /// Called with the role of an empty place the child touches; `null` makes
  /// the places plain drawings.
  final ValueChanged<BarRole>? onSlotTap;

  /// A place to shake with the color of a mistake, or `null`.
  final BarRole? wrongRole;

  static const double _barHeight = 64;
  static const int _mostGroupBars = 6;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.quizBarModelLabel,
      container: true,
      child: switch (picture.shape) {
        BarModelShape.partWhole => _stacked(
          context,
          top: BarRole.whole,
          bottom: <BarRole>[BarRole.partA, BarRole.partB],
        ),
        BarModelShape.compare => _stacked(
          context,
          top: BarRole.big,
          bottom: <BarRole>[BarRole.small, BarRole.gap],
        ),
        BarModelShape.groups => _groups(context),
        BarModelShape.ratio => _ratio(context),
      },
    );
  }

  /// A bar over two bars whose lengths follow their numbers.
  Widget _stacked(
    BuildContext context, {
    required BarRole top,
    required List<BarRole> bottom,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space8,
      children: <Widget>[
        _slot(context, top),
        Row(
          spacing: AppSizes.space8,
          children: <Widget>[
            for (final BarRole role in bottom)
              Expanded(
                flex: picture.values[role]!.clamp(1, 1000),
                child: _slot(context, role),
              ),
          ],
        ),
      ],
    );
  }

  /// The total over the equal groups, then how many and how big.
  Widget _groups(BuildContext context) {
    final bool hidesCount = picture.unknown == BarRole.groups && !showsAnswer;
    final int count = hidesCount
        ? 3
        : picture.values[BarRole.groups]!.clamp(1, _mostGroupBars);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space8,
      children: <Widget>[
        _slot(context, BarRole.total),
        Row(
          spacing: AppSizes.space4,
          children: <Widget>[
            for (int index = 0; index < count; index++)
              Expanded(child: _plainBar(context, hidesCount: hidesCount)),
          ],
        ),
        Row(
          spacing: AppSizes.space8,
          children: <Widget>[
            Expanded(child: _slot(context, BarRole.groups)),
            Expanded(child: _slot(context, BarRole.each)),
          ],
        ),
      ],
    );
  }

  /// The bigger bar cut in equal parts, the smaller bar one of them.
  Widget _ratio(BuildContext context) {
    final int times = picture.values[BarRole.times]!.clamp(1, 6);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space8,
      children: <Widget>[
        _slot(context, BarRole.big),
        Row(
          spacing: AppSizes.space8,
          children: <Widget>[
            Expanded(child: _slot(context, BarRole.small)),
            Expanded(
              flex: times - 1 < 1 ? 1 : times - 1,
              child: const SizedBox(),
            ),
          ],
        ),
        _slot(context, BarRole.times),
      ],
    );
  }

  Widget _plainBar(BuildContext context, {required bool hidesCount}) {
    final bool isEachKnown = picture.unknown != BarRole.each || showsAnswer;
    return Container(
      height: _barHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.palette.tint,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Text(
        hidesCount
            ? ''
            : (isEachKnown ? '${picture.values[BarRole.each]}' : '?'),
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _slot(BuildContext context, BarRole role) {
    final bool isUnknown = role == picture.unknown;
    final bool isFilled = placed == null || placed!.containsKey(role);
    final bool isShown = isUnknown ? showsAnswer : isFilled;
    final int? number = isUnknown ? picture.values[role] : placed?[role];
    return _BarSlot(
      key: ValueKey<String>('slot-${role.name}'),
      role: role,
      text: isShown
          ? '${number ?? picture.values[role]}'
          : (isUnknown ? '?' : ''),
      state: isUnknown
          ? (showsAnswer ? _SlotState.answer : _SlotState.unknown)
          : (isFilled ? _SlotState.filled : _SlotState.empty),
      isWrong: wrongRole == role,
      isDashed:
          role == BarRole.gap || (picture.isRemoval && role == BarRole.partA),
      height: _barHeight,
      onTap: !isUnknown && !isFilled && onSlotTap != null
          ? () => onSlotTap!(role)
          : null,
    );
  }
}

enum _SlotState { empty, filled, unknown, answer }

/// One place of the model: its name small, its number big.
class _BarSlot extends StatelessWidget {
  const _BarSlot({
    super.key,
    required this.role,
    required this.text,
    required this.state,
    required this.isWrong,
    required this.isDashed,
    required this.height,
    required this.onTap,
  });

  final BarRole role;
  final String text;
  final _SlotState state;
  final bool isWrong;
  final bool isDashed;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppFeedbackPalette feedback = context.feedbackPalette;
    final String name = context.l10n.quizBarRoleName(role.name);
    final (Color, Color) faces = switch (state) {
      _SlotState.empty => (colors.surface, context.palette.primaryText),
      _SlotState.filled => (context.palette.tint, context.palette.primaryText),
      _SlotState.unknown => (colors.secondary, colors.onSecondary),
      _SlotState.answer => (feedback.right, colors.onPrimary),
    };
    final Color border = isWrong
        ? feedback.wrong
        : state == _SlotState.empty
        ? context.palette.border
        : Colors.transparent;
    final String spoken = switch (state) {
      _SlotState.empty => context.l10n.quizBarSlotEmpty(name),
      _SlotState.unknown => context.l10n.quizBarSlotUnknown(name),
      _ => context.l10n.quizBarSlotValue(name, text),
    };
    return Semantics(
      button: onTap != null,
      label: spoken,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: faces.$1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          side: BorderSide(
            color: isDashed && border == Colors.transparent
                ? context.palette.border
                : border,
            width: AppSizes.borderWidth,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.space8,
                vertical: AppSizes.space4,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: faces.$2,
                    ),
                  ),
                  Text(
                    text.isEmpty ? ' ' : text,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: faces.$2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
