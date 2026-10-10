import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/entities/mascot_look.dart';

/// Gives the look of the active player's mascot to every mascot drawing
/// below it. Provided by the mascot feature; without it the mascot shows
/// its first stage.
class MascotLookScope extends InheritedWidget {
  /// Creates the scope of [look].
  const MascotLookScope({required this.look, required super.child, super.key});

  /// Look of the mascot.
  final MascotLook look;

  /// The look of the nearest scope, or the first stage without one.
  static MascotLook of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<MascotLookScope>()
            ?.look ??
        const MascotLook.initial();
  }

  @override
  bool updateShouldNotify(MascotLookScope oldWidget) => oldWidget.look != look;
}
