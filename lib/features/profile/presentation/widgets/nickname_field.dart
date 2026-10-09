import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_rules.dart';

/// Labelled nickname field with its rule hint or its error.
class NicknameField extends StatelessWidget {
  /// Creates the field; [errorText] replaces the hint when not `null`.
  const NicknameField({
    required this.onChanged,
    required this.onSubmitted,
    this.initialValue,
    this.errorText,
    super.key,
  });

  static const double _inputFontSize = 20;
  static const double _radius = 16;
  static const double _gap = 6;

  /// Called with the text each time it changes.
  final ValueChanged<String> onChanged;

  /// Called when the player validates from the keyboard.
  final VoidCallback onSubmitted;

  /// Nickname already in the field when it appears.
  final String? initialValue;

  /// Error to show under the field, or `null` to show the rule hint.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? error = errorText;
    final Color hintColor = error == null
        ? context.palette.mutedText
        : Theme.of(context).colorScheme.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(context.l10n.nicknameLabel, style: textTheme.titleMedium),
        const SizedBox(height: _gap),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          onFieldSubmitted: (_) => onSubmitted(),
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          enableSuggestions: false,
          inputFormatters: <TextInputFormatter>[
            LengthLimitingTextInputFormatter(NicknameRules.maxLength),
          ],
          style: textTheme.labelLarge?.copyWith(fontSize: _inputFontSize),
          decoration: InputDecoration(
            hintText: context.l10n.nicknameHint,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            enabledBorder: _border(context.palette.strongBorder),
            focusedBorder: _border(Theme.of(context).colorScheme.primary),
          ),
        ),
        const SizedBox(height: _gap),
        Semantics(
          liveRegion: error != null,
          child: Text(
            error ??
                context.l10n.nicknameRulesHint(
                  NicknameRules.minLength,
                  NicknameRules.maxLength,
                ),
            style: textTheme.bodySmall?.copyWith(color: hintColor),
          ),
        ),
      ],
    );
  }

  static OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: BorderSide(color: color, width: AppSizes.borderWidth),
    );
  }
}
