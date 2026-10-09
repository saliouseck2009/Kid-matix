import 'package:flutter/widgets.dart';

/// One entry of the bottom tab bar.
@immutable
final class AppTabItem {
  /// Creates an entry shown as [icon] above [label].
  const AppTabItem({required this.icon, required this.label});

  /// Icon of the tab.
  final IconData icon;

  /// Localized name of the tab.
  final String label;
}
