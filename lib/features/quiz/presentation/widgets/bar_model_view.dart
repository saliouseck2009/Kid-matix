import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/bar_model_layouts.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/bar_model_slot.dart';

/// The bar model of a word problem: a whole over its parts, two bars and
/// their gap, equal groups, or a bar that holds another several times.
///
/// While the child works, the places that hold a number the story gives
/// are empty until filled ([placed]), and the place to find shows "?"
/// until [showsAnswer]. A tap on an empty place calls [onSlotTap].
class BarModelView extends StatelessWidget {
  /// Creates the view of [picture].
  const BarModelView({
    required this.picture,
    this.placed,
    this.showsAnswer = false,
    this.onSlotTap,
    this.wrongRole,
    this.wrongCount = 0,
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

  /// The place that just got a wrong number, or `null`.
  final BarRole? wrongRole;

  /// Mistakes made so far, so each new one shakes the place again.
  final int wrongCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.quizBarModelLabel,
      container: true,
      child: switch (picture.shape) {
        BarModelShape.partWhole => PartWholeModel(
          picture: picture,
          top: BarRole.whole,
          bottom: const <BarRole>[BarRole.partA, BarRole.partB],
          slotOf: _slot,
        ),
        BarModelShape.compare => PartWholeModel(
          picture: picture,
          top: BarRole.big,
          bottom: const <BarRole>[BarRole.small, BarRole.gap],
          slotOf: _slot,
        ),
        BarModelShape.groups => GroupsModel(
          picture: picture,
          showsAnswer: showsAnswer,
          slotOf: _slot,
        ),
        BarModelShape.ratio => RatioModel(picture: picture, slotOf: _slot),
      },
    );
  }

  Widget _slot(BarRole role) {
    final bool isUnknown = role == picture.unknown;
    final bool isFilled = placed == null || placed!.containsKey(role);
    final bool isShown = isUnknown ? showsAnswer : isFilled;
    final int? number = isUnknown ? picture.values[role] : placed?[role];
    return BarModelSlot(
      key: ValueKey<String>('slot-${role.name}'),
      role: role,
      text: isShown
          ? '${number ?? picture.values[role]}'
          : (isUnknown ? '?' : ''),
      state: isUnknown
          ? (showsAnswer ? BarSlotState.answer : BarSlotState.unknown)
          : (isFilled ? BarSlotState.filled : BarSlotState.empty),
      isWrong: wrongRole == role,
      wrongCount: wrongCount,
      isDashed:
          role == BarRole.gap || (picture.isRemoval && role == BarRole.partA),
      onTap: !isUnknown && !isFilled && onSlotTap != null
          ? () => onSlotTap!(role)
          : null,
    );
  }
}
