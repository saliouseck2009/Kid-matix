import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_answer_button.dart';

/// The app's own keypad: digits 0 to 9 and erase.
///
/// Never the phone keyboard, so the layout stays the same everywhere. It
/// has no key to validate: the number is sent once it has as many digits
/// as the answer expected.
class AnswerKeypad extends StatelessWidget {
  /// Creates the keypad.
  const AnswerKeypad({
    required this.onDigit,
    required this.onErase,
    super.key,
  });

  static const double _keyHeight = AppSizes.buttonHeight;
  static const double _gap = AppSizes.space8;
  static const List<List<int>> _digitRows = <List<int>>[
    <int>[1, 2, 3],
    <int>[4, 5, 6],
    <int>[7, 8, 9],
  ];

  /// Called with the digit tapped.
  final ValueChanged<int> onDigit;

  /// Called by the erase key.
  final VoidCallback onErase;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: _gap,
      children: <Widget>[
        for (final List<int> row in _digitRows)
          Row(
            spacing: _gap,
            children: <Widget>[
              for (final int digit in row) _DigitKey(digit, onDigit: onDigit),
            ],
          ),
        Row(
          spacing: _gap,
          children: <Widget>[
            const Expanded(child: SizedBox.shrink()),
            _DigitKey(0, onDigit: onDigit),
            Expanded(
              child: Tooltip(
                message: context.l10n.quizKeypadErase,
                excludeFromSemantics: true,
                child: QuizAnswerButton(
                  label: '',
                  icon: Icons.backspace_outlined,
                  height: _keyHeight,
                  semanticLabel: context.l10n.quizKeypadErase,
                  onTap: onErase,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DigitKey extends StatelessWidget {
  const _DigitKey(this.digit, {required this.onDigit});

  final int digit;
  final ValueChanged<int> onDigit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: QuizAnswerButton(
        label: '$digit',
        height: AnswerKeypad._keyHeight,
        onTap: () => onDigit(digit),
      ),
    );
  }
}
