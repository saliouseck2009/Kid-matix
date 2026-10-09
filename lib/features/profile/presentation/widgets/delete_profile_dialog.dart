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
}) async {
  final bool? isConfirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => DeleteProfileDialog(nickname: nickname),
  );
  return isConfirmed ?? false;
}

/// Confirmation dialog of a player's deletion.
class DeleteProfileDialog extends StatefulWidget {
  /// Creates the dialog for the player [nickname].
  const DeleteProfileDialog({required this.nickname, super.key});

  /// Nickname the child must type again.
  final String nickname;

  @override
  State<DeleteProfileDialog> createState() => _DeleteProfileDialogState();
}

class _DeleteProfileDialogState extends State<DeleteProfileDialog> {
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
      title: Text(context.l10n.deleteProfileTitle(widget.nickname)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(context.l10n.deleteProfileMessage(widget.nickname)),
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
          child: Text(context.l10n.deleteProfileConfirm),
        ),
      ],
    );
  }
}
