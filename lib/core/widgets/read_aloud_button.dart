import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/widgets/listen_button.dart';
import 'package:kid_matix/core/widgets/read_aloud_control.dart';

/// A [ListenButton] that reads [text] aloud, for a screen whose reading
/// does not hold any timer (a tip of the Discovery stage).
///
/// It shows nothing, and no message, when no voice is installed; see
/// [ReadAloudControl].
class ReadAloudButton extends StatelessWidget {
  /// Creates the button that reads [text].
  const ReadAloudButton({required this.text, super.key});

  /// What the voice says.
  final String text;

  @override
  Widget build(BuildContext context) {
    return ReadAloudControl(
      text: text,
      builder: (BuildContext context, ReadAloudAction? action) {
        if (action == null) return const SizedBox.shrink();
        return ListenButton(
          isSpeaking: action.isSpeaking,
          onPressed: action.toggle,
        );
      },
    );
  }
}
