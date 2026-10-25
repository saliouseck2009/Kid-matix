import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/bar_model_slot.dart';

/// Builds the place of [role] of a bar model.
typedef BarSlotBuilder = Widget Function(BarRole role);

/// A bar over two bars whose lengths follow their numbers: a whole over
/// its two parts, or the longer bar over the shorter one and the gap.
///
/// A part never gets less than a third of the top bar, so a tiny number
/// still leaves a place wide enough to touch.
class PartWholeModel extends StatelessWidget {
  /// Creates the layout of [top] over [bottom] of [picture].
  const PartWholeModel({
    required this.picture,
    required this.top,
    required this.bottom,
    required this.slotOf,
    super.key,
  });

  /// Divisor of the top number that gives the smallest share of a part.
  static const int minShareDivisor = 3;

  /// The model.
  final BarModelPicture picture;

  /// The role of the top bar.
  final BarRole top;

  /// The roles of the two bars under it.
  final List<BarRole> bottom;

  /// Builds a place.
  final BarSlotBuilder slotOf;

  @override
  Widget build(BuildContext context) {
    final int smallest =
        (picture.values[top]! + minShareDivisor - 1) ~/ minShareDivisor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space8,
      children: <Widget>[
        slotOf(top),
        Row(
          spacing: AppSizes.space8,
          children: <Widget>[
            for (final BarRole role in bottom)
              Expanded(
                flex: math.max(picture.values[role]!, smallest),
                child: slotOf(role),
              ),
          ],
        ),
      ],
    );
  }
}

/// The total over the equal groups, then how many and how big.
///
/// Every group is drawn, up to [mostBars]; when the number of groups is the
/// answer and still hidden, [hiddenBars] plain bars stand for them.
class GroupsModel extends StatelessWidget {
  /// Creates the layout of the groups of [picture].
  const GroupsModel({
    required this.picture,
    required this.showsAnswer,
    required this.slotOf,
    super.key,
  });

  /// The most groups a story draws (the table goes up to 10).
  static const int mostBars = 10;

  /// Bars drawn while the number of groups is hidden.
  static const int hiddenBars = 3;

  /// The model.
  final BarModelPicture picture;

  /// Whether the answer is written.
  final bool showsAnswer;

  /// Builds a place.
  final BarSlotBuilder slotOf;

  @override
  Widget build(BuildContext context) {
    final bool hidesCount = picture.unknown == BarRole.groups && !showsAnswer;
    final int count = hidesCount
        ? hiddenBars
        : picture.values[BarRole.groups]!.clamp(1, mostBars);
    final bool hidesEach = picture.unknown == BarRole.each && !showsAnswer;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space8,
      children: <Widget>[
        slotOf(BarRole.total),
        Row(
          spacing: AppSizes.space4,
          children: <Widget>[
            for (int index = 0; index < count; index++)
              Expanded(
                child: GroupBar(
                  text: hidesCount
                      ? ''
                      : hidesEach
                      ? '?'
                      : '${picture.values[BarRole.each]}',
                ),
              ),
          ],
        ),
        Row(
          spacing: AppSizes.space8,
          children: <Widget>[
            Expanded(child: slotOf(BarRole.groups)),
            Expanded(child: slotOf(BarRole.each)),
          ],
        ),
      ],
    );
  }
}

/// One of the equal groups of the model: a bar with the size of a group.
class GroupBar extends StatelessWidget {
  /// Creates a bar showing [text].
  const GroupBar({required this.text, super.key});

  /// The size of a group, "?" or nothing.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: BarModelSlot.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.palette.tint,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}

/// The bigger bar and the smaller one, which it holds several times.
class RatioModel extends StatelessWidget {
  /// Creates the layout of the two bars of [picture].
  const RatioModel({required this.picture, required this.slotOf, super.key});

  /// The most times drawn.
  static const int mostTimes = 6;

  /// The model.
  final BarModelPicture picture;

  /// Builds a place.
  final BarSlotBuilder slotOf;

  @override
  Widget build(BuildContext context) {
    final int times = picture.values[BarRole.times]!.clamp(2, mostTimes);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space8,
      children: <Widget>[
        slotOf(BarRole.big),
        Row(
          spacing: AppSizes.space8,
          children: <Widget>[
            Expanded(child: slotOf(BarRole.small)),
            Expanded(flex: times - 1, child: const SizedBox()),
          ],
        ),
        slotOf(BarRole.times),
      ],
    );
  }
}
