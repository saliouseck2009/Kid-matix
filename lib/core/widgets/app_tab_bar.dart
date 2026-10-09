import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/theme/app_palette.dart';
import 'package:kid_matix/core/widgets/app_tab_item.dart';

/// Bottom navigation bar of the app, one button per main tab.
class AppTabBar extends StatelessWidget {
  /// Creates a tab bar that highlights the entry at [currentIndex].
  const AppTabBar({
    required this.items,
    required this.currentIndex,
    required this.onTabSelected,
    required this.semanticLabel,
    super.key,
  });

  /// Entries, in display order.
  final List<AppTabItem> items;

  /// Index of the selected entry.
  final int currentIndex;

  /// Called with the index of the entry the player tapped.
  final ValueChanged<int> onTabSelected;

  /// Name of the bar announced by screen readers.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.space8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: palette.tint,
              width: AppSizes.borderWidth,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: _AppTabBarRow(
            items: items,
            currentIndex: currentIndex,
            onTabSelected: onTabSelected,
          ),
        ),
      ),
    );
  }
}

class _AppTabBarRow extends StatelessWidget {
  const _AppTabBarRow({
    required this.items,
    required this.currentIndex,
    required this.onTabSelected,
  });

  final List<AppTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int index = 0; index < items.length; index++)
          Expanded(
            child: _AppTabBarButton(
              item: items[index],
              isSelected: index == currentIndex,
              onPressed: () => onTabSelected(index),
            ),
          ),
      ],
    );
  }
}

class _AppTabBarButton extends StatelessWidget {
  const _AppTabBarButton({
    required this.item,
    required this.isSelected,
    required this.onPressed,
  });

  final AppTabItem item;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final BorderRadius radius = BorderRadius.circular(AppSizes.radiusSmall);
    final Color color = isSelected ? palette.primaryText : palette.mutedText;
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? palette.tint : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: _AppTabBarLabel(item: item, color: color),
        ),
      ),
    );
  }
}

class _AppTabBarLabel extends StatelessWidget {
  const _AppTabBarLabel({required this.item, required this.color});

  final AppTabItem item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextStyle? labelStyle = Theme.of(context).textTheme.labelMedium;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.tabBarItemHeight),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(item.icon, size: AppSizes.tabBarIconSize, color: color),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: labelStyle?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
