import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/parental_gate.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_preview_entity.dart';
import 'package:kid_matix/features/profile/presentation/bloc/backup_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/backup_state.dart';
import 'package:kid_matix/features/profile/presentation/widgets/backup_dialogs.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_error_message.dart';
import 'package:kid_matix/features/profile/presentation/widgets/settings_link_row.dart';
import 'package:kid_matix/features/profile/presentation/widgets/settings_parts.dart';

/// "Sauvegarde" section of the settings (mockup 13): export the player to
/// a file, import a player from a file. An adult opens both.
class BackupSettingsSection extends StatelessWidget {
  /// Creates the section; [random] draws the numbers of the parental
  /// gate, seeded in tests.
  const BackupSettingsSection({this.random, super.key});

  /// Source of the numbers of the parental gate, or `null` for a new one.
  final Random? random;

  Future<void> _export(BuildContext context) async {
    final BackupCubit cubit = context.read<BackupCubit>();
    if (await askAnAdult(context, random: random)) {
      await cubit.exportProfile();
    }
  }

  Future<void> _import(BuildContext context) async {
    final BackupCubit cubit = context.read<BackupCubit>();
    if (await askAnAdult(context, random: random)) {
      await cubit.pickBackup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BackupCubit, BackupState>(
      listener: _onState,
      buildWhen: (BackupState previous, BackupState current) =>
          (previous is BackupWorking) != (current is BackupWorking),
      builder: (BuildContext context, BackupState state) {
        final bool isWorking = state is BackupWorking;
        return SettingsSection(
          title: context.l10n.settingsBackupSection,
          rows: <Widget>[
            SettingsLinkRow(
              label: context.l10n.backupExport,
              onTap: isWorking ? null : () => _export(context),
            ),
            SettingsLinkRow(
              label: context.l10n.backupImport,
              onTap: isWorking ? null : () => _import(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onState(BuildContext context, BackupState state) async {
    switch (state) {
      case BackupConflict(:final BackupPreviewEntity preview):
        await _settleConflict(context, preview);
      case BackupRenameRefused(:final nickname, :final errorCode):
        await _askNickname(context, nickname: nickname, errorCode: errorCode);
      case BackupExported():
        _tell(context, context.l10n.backupExportDone);
      case BackupImported(:final nickname, wasReplaced: true):
        _tell(context, context.l10n.backupImportReplaced(nickname));
      case BackupImported(:final nickname):
        _tell(context, context.l10n.backupImportDone(nickname));
      case BackupFailed(:final errorCode):
        _tell(context, errorCode.toProfileMessage(context.l10n));
      case BackupIdle() || BackupWorking():
        break;
    }
  }

  Future<void> _settleConflict(
    BuildContext context,
    BackupPreviewEntity preview,
  ) async {
    final BackupCubit cubit = context.read<BackupCubit>();
    final BackupConflictAnswer? answer = await askBackupConflict(
      context,
      nickname: preview.backup.nickname,
      level: preview.backup.level,
    );
    if (!context.mounted) return;
    switch (answer) {
      case BackupConflictAnswer.replace:
        await cubit.replacePlayer();
      case BackupConflictAnswer.rename:
        await _askNickname(context, nickname: preview.backup.nickname);
      case null:
        cubit.cancel();
    }
  }

  Future<void> _askNickname(
    BuildContext context, {
    required String nickname,
    AppErrorCode? errorCode,
  }) async {
    final BackupCubit cubit = context.read<BackupCubit>();
    final String? typed = await askBackupNickname(
      context,
      nickname: nickname,
      errorCode: errorCode,
    );
    if (typed == null) {
      cubit.cancel();
    } else {
      await cubit.renamePlayer(typed);
    }
  }

  void _tell(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
