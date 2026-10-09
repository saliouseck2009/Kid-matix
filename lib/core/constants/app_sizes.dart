/// Spacing, radius and control sizes shared by the whole design system.
abstract final class AppSizes {
  /// Smallest gap, used between an icon and its label.
  static const double space4 = 4;

  /// Gap between tightly related elements.
  static const double space8 = 8;

  /// Gap between elements of the same group.
  static const double space12 = 12;

  /// Default inner padding of cards and controls.
  static const double space16 = 16;

  /// Screen side gutter and gap between sections.
  static const double space24 = 24;

  /// Corner radius of small controls such as segmented buttons.
  static const double radiusSmall = 14;

  /// Corner radius of buttons.
  static const double radiusMedium = 18;

  /// Corner radius of cards.
  static const double radiusLarge = 24;

  /// Corner radius that turns any box into a pill.
  static const double radiusPill = 999;

  /// Smallest tappable size allowed by the accessibility rules.
  static const double minTouchTarget = 48;

  /// Total height of a depth button, raised edge included.
  static const double buttonHeight = 58;

  /// Height of the raised edge under a depth button.
  static const double buttonDepth = 6;

  /// Width of outlines and separators.
  static const double borderWidth = 2;

  /// Height of a progress bar.
  static const double progressBarHeight = 14;

  /// Smallest height of a tab bar entry.
  static const double tabBarItemHeight = 56;

  /// Size of a tab bar icon.
  static const double tabBarIconSize = 26;
}
