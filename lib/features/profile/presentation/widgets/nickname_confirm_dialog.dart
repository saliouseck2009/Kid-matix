import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_rules.dart';

/// Asks the child to type [nickname] again before deleting the player.
///
/// Resolves to `true` when the deletion is confirmed. The typed nickname is
/// compared ignoring case, accents and stray spaces.
Future<bool> confirmProfileDeletion(
  BuildContext context, {
  required String nickname,
}) {
  return _confirm(
    context,
    NicknameConfirmDialog(
      nickname: nickname,
      title: context.l10n.deleteProfileTitle(nickname),
      message: context.l10n.deleteProfileMessage(nickname),
      confirmLabel: context.l10n.deleteProfileConfirm,
    ),
  );
}

/// Asks the child to type [nickname] again before erasing their progress;
/// resolves to `true` when it is confirmed.
Future<bool> confirmProgressReset(
  BuildContext context, {
  required String nickname,
}) {
  return _confirm(
    context,
    NicknameConfirmDialog(
      nickname: nickname,
      title: context.l10n.resetProgressTitle(nickname),
      message: context.l10n.resetProgressMessage(nickname),
      confirmLabel: context.l10n.resetProgressConfirm,
    ),
  );
}

Future<bool> _confirm(BuildContext context, Widget dialog) async {
  final bool? isConfirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => dialog,
  );
  return isConfirmed ?? false;
}

/// Confirmation of an action that cannot be undone, such as deleting a
/// player: the child types the nickname again to enable it.
class NicknameConfirmDialog extends StatefulWidget {
  /// Creates the dialog for the player [nickname].
  const NicknameConfirmDialog({
    required this.nickname,
    required this.title,
    required this.message,
    required this.confirmLabel,
    super.key,
  });

  /// Nickname the child must type again.
  final String nickname;

  /// Question asked, such as "Supprimer Awa ?".
  final String title;

  /// What the action does and how to confirm it.
  final String message;

  /// Text of the confirm button.
  final String confirmLabel;

  @override
  State<NicknameConfirmDialog> createState() => _NicknameConfirmDialogState();
}

class _NicknameConfirmDialogState extends State<NicknameConfirmDialog> {
  bool _isMatching = false;

  void _onChanged(String typed) {
    final bool isMatching =
        NicknameRules.normalize(typed) ==
        NicknameRules.normalize(widget.nickname);
    if (isMatching != _isMatching) setState(() => _isMatching = isMatching);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(widget.message),
          const SizedBox(height: AppSizes.space16),
          TextField(
            autofocus: true,
            onChanged: _onChanged,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(hintText: widget.nickname),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.commonCancel),
        ),
        TextButton(
          onPressed: _isMatching ? () => Navigator.of(context).pop(true) : null,
          style: TextButton.styleFrom(foregroundColor: colors.error),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
