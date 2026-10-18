import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// Round "Écouter" button: a speaker that reads a text aloud, and a stop
/// sign while the voice is reading.
///
/// Its tooltip is what a screen reader announces. A screen shows it only
/// when a voice exists, so there is no state for "no voice" here.
class ListenButton extends StatelessWidget {
  /// Creates the button; [onPressed] reads or stops, [isSpeaking] says
  /// which one it does.
  const ListenButton({
    required this.onPressed,
    this.isSpeaking = false,
    super.key,
  });

  /// Called when the player taps the button; `null` disables it.
  final VoidCallback? onPressed;

  /// Whether the voice is reading: the button then stops it.
  final bool isSpeaking;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: isSpeaking
          ? context.l10n.commonListenStop
          : context.l10n.commonListen,
      icon: Icon(isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded),
      style: IconButton.styleFrom(
        backgroundColor: context.palette.tint,
        foregroundColor: context.palette.primaryText,
        minimumSize: const Size.square(AppSizes.minTouchTarget),
      ),
    );
  }
}
