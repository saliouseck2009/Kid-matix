import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/utils/number_words.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';

/// Shows the parental gate and resolves to `true` once an adult typed the
/// number it shows; a wrong answer or closing it resolves to `false`.
///
/// The number, drawn by [random] from [ParentalGate.minNumber] to
/// [ParentalGate.maxNumber], is written in words: a child who plays the
/// times tables cannot easily type it in digits.
Future<bool> askAnAdult(BuildContext context, {Random? random}) async {
  final Random source = random ?? Random();
  final int number =
      ParentalGate.minNumber +
      source.nextInt(ParentalGate.maxNumber - ParentalGate.minNumber + 1);
  final bool? isAdult = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => ParentalGate(number: number),
  );
  return isAdult ?? false;
}

/// "Demande à un adulte": a full screen asking to type in digits a number
/// written in words, before an action meant for parents, such as sharing
/// a backup file (Apple Kids category, guideline 1.3).
class ParentalGate extends StatefulWidget {
  /// Creates the gate asking for [number].
  const ParentalGate({required this.number, super.key});

  /// Smallest number asked.
  static const int minNumber = 1000;

  /// Largest number asked.
  static const int maxNumber = 9999;

  /// Number to type.
  final int number;

  @override
  State<ParentalGate> createState() => _ParentalGateState();
}

class _ParentalGateState extends State<ParentalGate> {
  static const double _iconSize = 56;
  static const double _wordsRadius = 18;

  final TextEditingController _answer = TextEditingController();

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(int.tryParse(_answer.text) == widget.number);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Dialog.fullscreen(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.space24),
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppIconButton(
                icon: Icons.close_rounded,
                tooltip: context.l10n.commonClose,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(height: AppSizes.space24),
            Icon(
              Icons.family_restroom_rounded,
              size: _iconSize,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSizes.space16),
            Semantics(
              header: true,
              child: Text(
                context.l10n.parentalGateTitle,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: AppSizes.space12),
            Text(
              context.l10n.parentalGateMessage,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSizes.space24),
            _NumberInWords(number: widget.number, radius: _wordsRadius),
            const SizedBox(height: AppSizes.space24),
            TextField(
              controller: _answer,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              enableSuggestions: false,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(
                  '${ParentalGate.maxNumber}'.length,
                ),
              ],
              onSubmitted: (_) => _submit(),
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall,
              decoration: InputDecoration(
                labelText: context.l10n.parentalGateAnswerLabel,
              ),
            ),
            const SizedBox(height: AppSizes.space24),
            DepthButton(
              label: context.l10n.parentalGateConfirm,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberInWords extends StatelessWidget {
  const _NumberInWords({required this.number, required this.radius});

  final int number;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        NumberWords.spell(
          number,
          languageCode: Localizations.localeOf(context).languageCode,
        ),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
