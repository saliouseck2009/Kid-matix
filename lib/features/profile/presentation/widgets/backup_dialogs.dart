import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_error.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_rules.dart';
import 'package:kid_matix/features/profile/presentation/widgets/nickname_error_message.dart';
import 'package:kid_matix/features/profile/presentation/widgets/nickname_field.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_error_message.dart';

/// How the player settles a backup whose nickname is already used.
enum BackupConflictAnswer {
  /// The player of the phone is replaced by the file.
  replace,

  /// The imported player gets another nickname.
  rename,
}

/// Asks what to do with a backup of [nickname], already a player of the
/// phone; resolves to `null` when the import is given up.
Future<BackupConflictAnswer?> askBackupConflict(
  BuildContext context, {
  required String nickname,
  required int level,
}) {
  return showDialog<BackupConflictAnswer>(
    context: context,
    builder: (BuildContext context) =>
        BackupConflictDialog(nickname: nickname, level: level),
  );
}

/// Asks the nickname of the imported player, starting from [nickname]
/// and showing why it was refused when [errorCode] is given; resolves to
/// `null` when the import is given up.
Future<String?> askBackupNickname(
  BuildContext context, {
  required String nickname,
  AppErrorCode? errorCode,
}) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) =>
        BackupRenameDialog(nickname: nickname, errorCode: errorCode),
  );
}

/// The nickname of a backup is already used: replace the player of the
/// phone, or import under another nickname.
class BackupConflictDialog extends StatelessWidget {
  /// Creates the dialog for the backup of [nickname] at [level].
  const BackupConflictDialog({
    required this.nickname,
    required this.level,
    super.key,
  });

  /// Nickname of the file and of the player of the phone.
  final String nickname;

  /// Level of the player in the file.
  final int level;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.backupConflictTitle(nickname)),
      content: Text(context.l10n.backupConflictMessage(nickname, level)),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.commonCancel),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(BackupConflictAnswer.rename),
          child: Text(context.l10n.backupConflictRename),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(BackupConflictAnswer.replace),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(context.l10n.backupConflictReplace),
        ),
      ],
    );
  }
}

/// Asks another nickname for an imported player, with the same rules as
/// the creation of a player.
class BackupRenameDialog extends StatefulWidget {
  /// Creates the dialog starting from [nickname].
  const BackupRenameDialog({required this.nickname, this.errorCode, super.key});

  /// Nickname in the field when it opens.
  final String nickname;

  /// Why [nickname] was refused, or `null`.
  final AppErrorCode? errorCode;

  @override
  State<BackupRenameDialog> createState() => _BackupRenameDialogState();
}

class _BackupRenameDialogState extends State<BackupRenameDialog> {
  late String _nickname = widget.nickname;
  late AppErrorCode? _refusal = widget.errorCode;

  bool get _isValid => NicknameRules.validate(_nickname) == null;

  void _onChanged(String nickname) {
    setState(() {
      _nickname = nickname;
      _refusal = null;
    });
  }

  void _submit() {
    if (_isValid) Navigator.of(context).pop(_nickname);
  }

  String? _errorText() {
    final NicknameError? error = NicknameRules.validate(_nickname);
    if (_nickname.trim().isNotEmpty && error != null) {
      return error.toMessage(context.l10n);
    }
    return _refusal?.toProfileMessage(context.l10n);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.backupRenameTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(context.l10n.backupRenameMessage),
            const SizedBox(height: AppSizes.space16),
            NicknameField(
              initialValue: widget.nickname,
              onChanged: _onChanged,
              onSubmitted: _submit,
              errorText: _errorText(),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.commonCancel),
        ),
        TextButton(
          onPressed: _isValid ? _submit : null,
          child: Text(context.l10n.backupRenameConfirm),
        ),
      ],
    );
  }
}
