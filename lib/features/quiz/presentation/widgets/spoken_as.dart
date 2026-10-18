import 'package:flutter/widgets.dart';

/// Makes a screen reader read [child] as the one [sentence], the same
/// sentence the voice of the quiz says, and nothing else of it.
///
/// Without a [sentence] it leaves [child] to say what it shows.
class SpokenAs extends StatelessWidget {
  /// Creates the wrapper.
  const SpokenAs({required this.sentence, required this.child, super.key});

  /// What a screen reader says, or `null` to leave [child] as it is.
  final String? sentence;

  /// The part of the question the [sentence] stands for.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final String? label = sentence;
    if (label == null) return child;
    return Semantics(label: label, excludeSemantics: true, child: child);
  }
}
