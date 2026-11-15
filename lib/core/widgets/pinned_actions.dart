import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';

/// A screen whose buttons stay in sight: [child] scrolls when it is taller
/// than the room left, [actions] stay under it, at the bottom.
///
/// Every screen that ends on a choice (results, end of a duel) uses it, so
/// a child never scrolls to find what to do next.
class PinnedActions extends StatelessWidget {
  /// Creates the layout.
  const PinnedActions({required this.child, required this.actions, super.key});

  static const EdgeInsets _contentPadding = EdgeInsets.fromLTRB(
    AppSizes.space24,
    AppSizes.space24,
    AppSizes.space24,
    AppSizes.space12,
  );
  static const EdgeInsets _actionsPadding = EdgeInsets.fromLTRB(
    AppSizes.space24,
    AppSizes.space12,
    AppSizes.space24,
    AppSizes.space24,
  );

  /// What the screen shows, scrolled when it does not fit.
  final Widget child;

  /// The buttons, such as an [ActionRows].
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(padding: _contentPadding, child: child),
        ),
        Padding(padding: _actionsPadding, child: actions),
      ],
    );
  }
}

/// The buttons of a screen on two rows at most: [primary] on the whole
/// width, then the [secondary] ones side by side.
class ActionRows extends StatelessWidget {
  /// Creates the rows; [secondary] holds two buttons at most.
  const ActionRows({
    required this.primary,
    this.secondary = const <Widget>[],
    super.key,
  }) : assert(secondary.length <= 2, 'Two secondary buttons at most');

  /// The main button.
  final Widget primary;

  /// The other buttons, with short labels: each gets half of the width.
  final List<Widget> secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSizes.space12,
      children: <Widget>[
        primary,
        if (secondary.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSizes.space12,
            children: <Widget>[
              for (final Widget button in secondary) Expanded(child: button),
            ],
          ),
      ],
    );
  }
}
