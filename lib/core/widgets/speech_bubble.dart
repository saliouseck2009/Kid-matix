import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/read_aloud_action.dart';
import 'package:kid_matix/core/widgets/read_aloud_control.dart';

/// What the mascot says, in a white rounded bubble announced to screen
/// readers when it changes.
///
/// When a voice is installed the bubble can be tapped to hear its text:
/// a small speaker marks it, and the tap reads the message aloud.
class SpeechBubble extends StatelessWidget {
  /// Creates the bubble of [text].
  const SpeechBubble({required this.text, this.color, super.key});

  static const double _radius = 18;
  static const BorderRadius _shape = BorderRadius.only(
    topLeft: Radius.circular(_radius),
    topRight: Radius.circular(_radius),
    bottomRight: Radius.circular(_radius),
    bottomLeft: Radius.circular(AppSizes.space4),
  );

  /// What the mascot says.
  final String text;

  /// Background of the bubble; the surface color when `null`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: ReadAloudControl(
        text: text,
        builder: (BuildContext context, ReadAloudAction? action) {
          final Widget body = _BubbleBody(text: text, action: action);
          return Material(
            color: color ?? Theme.of(context).colorScheme.surface,
            borderRadius: _shape,
            child: action == null
                ? body
                : Tooltip(
                    message: action.isSpeaking
                        ? context.l10n.commonListenStop
                        : context.l10n.commonListen,
                    child: body,
                  ),
          );
        },
      ),
    );
  }
}

/// The text of a bubble, tappable with its speaker when a voice reads it.
class _BubbleBody extends StatelessWidget {
  const _BubbleBody({required this.text, required this.action});

  static const double _speakerSize = 20;

  final String text;
  final ReadAloudAction? action;

  @override
  Widget build(BuildContext context) {
    final ReadAloudAction? reading = action;
    return InkWell(
      borderRadius: SpeechBubble._shape,
      onTap: reading?.toggle,
      child: Container(
        constraints: BoxConstraints(
          minHeight: reading == null ? 0 : AppSizes.minTouchTarget,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: AppSizes.space8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSizes.space8,
          children: <Widget>[
            Flexible(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ),
            if (reading != null)
              Icon(
                reading.isSpeaking
                    ? Icons.stop_rounded
                    : Icons.volume_up_rounded,
                size: _speakerSize,
                color: context.palette.mutedText,
              ),
          ],
        ),
      ),
    );
  }
}
