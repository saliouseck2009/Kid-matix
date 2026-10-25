import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/pupil_actions_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/pupil_actions_state.dart';

/// « Gérer Awa », in the teacher area only: reset the progress of a
/// pupil or remove them from the class, each after a confirmation.
class PupilActionsButton extends StatelessWidget {
  /// Creates the button of [pupil]; the Cubit comes from the page.
  const PupilActionsButton({required this.pupil, super.key});

  /// The pupil.
  final PupilEntity pupil;

  Future<void> _open(BuildContext context) async {
    final PupilActionsCubit cubit = context.read<PupilActionsCubit>();
    final PupilActionKind? kind = await showModalBottomSheet<PupilActionKind>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.restart_alt_rounded),
              title: Text(context.l10n.classroomPupilReset),
              onTap: () => Navigator.of(context).pop(PupilActionKind.reset),
            ),
            ListTile(
              leading: const Icon(Icons.person_remove_rounded),
              title: Text(context.l10n.classroomPupilRemove),
              onTap: () => Navigator.of(context).pop(PupilActionKind.remove),
            ),
          ],
        ),
      ),
    );
    if (kind == null || !context.mounted) return;
    if (!await _confirm(context, kind)) return;
    switch (kind) {
      case PupilActionKind.reset:
        await cubit.reset(pupil.id, pupil.nickname);
      case PupilActionKind.remove:
        await cubit.remove(pupil.id, pupil.nickname);
    }
  }

  Future<bool> _confirm(BuildContext context, PupilActionKind kind) async {
    final bool isReset = kind == PupilActionKind.reset;
    final bool? answer = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          isReset
              ? context.l10n.resetProgressTitle(pupil.nickname)
              : context.l10n.deleteProfileTitle(pupil.nickname),
        ),
        content: Text(
          isReset
              ? context.l10n.classroomPupilResetMessage
              : context.l10n.classroomPupilRemoveMessage,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              isReset
                  ? context.l10n.resetProgressConfirm
                  : context.l10n.deleteProfileConfirm,
            ),
          ),
        ],
      ),
    );
    return answer ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert_rounded),
      tooltip: context.l10n.classroomPupilManage(pupil.nickname),
      onPressed: () => _open(context),
    );
  }
}
