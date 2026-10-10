import 'package:flutter/widgets.dart';

/// Turns the system back gesture of a full-screen page into [onBack].
///
/// Pages opened by `go` have nothing below them to pop: without this the
/// Android back button would close the app.
class BackToParent extends StatelessWidget {
  /// Creates the wrapper around [child].
  const BackToParent({required this.onBack, required this.child, super.key});

  /// Goes back to the parent page.
  final VoidCallback onBack;

  /// The page.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) onBack();
      },
      child: child,
    );
  }
}
