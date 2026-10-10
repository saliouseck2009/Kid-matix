import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kid_matix/core/entities/mascot_look.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/mascot_look_scope.dart';
import 'package:kid_matix/core/widgets/mascot_painter.dart';

/// The mascot of the active player, [size] wide, making [mood].
/// Decorative.
///
/// It jumps for joy when it turns happy and nods when it encourages;
/// it stays still when the system reduces motion. Its stage and
/// accessories come from the nearest [MascotLookScope], or [look] when
/// given.
class MascotIllustration extends StatelessWidget {
  /// Creates the mascot drawing.
  const MascotIllustration({
    required this.size,
    this.mood = MascotMood.neutral,
    this.look,
    super.key,
  });

  static const Duration _reactionDuration = Duration(milliseconds: 600);
  static const double _jumpHeight = 0.12;
  static const double _nodAngle = 0.08;

  /// Width and height of the drawing.
  final double size;

  /// Face it makes.
  final MascotMood mood;

  /// Look to draw instead of the one of the scope, or `null`.
  final MascotLook? look;

  @override
  Widget build(BuildContext context) {
    final MascotLook shown = look ?? MascotLookScope.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Widget drawing = CustomPaint(
      size: Size.square(size),
      painter: MascotPainter(
        colors: (
          body: scheme.secondary,
          feet: context.palette.secondaryDepth,
          eye: scheme.onPrimary,
          ink: scheme.onSecondary,
          badge: scheme.primary,
          cheek: context.feedbackPalette.wrongTint,
        ),
        stage: shown.stage,
        mood: mood,
        accessories: shown.accessories,
      ),
    );
    if (mood == MascotMood.neutral || MediaQuery.disableAnimationsOf(context)) {
      return ExcludeSemantics(child: drawing);
    }
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        key: ValueKey<MascotMood>(mood),
        tween: Tween<double>(begin: 0, end: 1),
        duration: _reactionDuration,
        child: drawing,
        builder: (BuildContext context, double t, Widget? child) {
          final double wave = sin(t * pi);
          return mood == MascotMood.happy
              ? Transform.translate(
                  offset: Offset(0, -wave * size * _jumpHeight),
                  child: child,
                )
              : Transform.rotate(angle: wave * _nodAngle, child: child);
        },
      ),
    );
  }
}
