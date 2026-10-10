import 'package:flutter/material.dart';

/// Keeps the app at the width of a large phone, centered on the ground
/// color, on a tablet: every screen was designed for a phone.
///
/// The screens below see the narrower width in their `MediaQuery`, so
/// their layouts and dialogs follow it.
class AppWidthLimit extends StatelessWidget {
  /// Creates the limit around [child].
  const AppWidthLimit({required this.child, super.key});

  /// Widest the app gets.
  static const double maxWidth = 600;

  /// The app.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    if (media.size.width <= maxWidth) return child;
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: SizedBox(
          width: maxWidth,
          child: MediaQuery(
            data: media.copyWith(size: Size(maxWidth, media.size.height)),
            child: child,
          ),
        ),
      ),
    );
  }
}
