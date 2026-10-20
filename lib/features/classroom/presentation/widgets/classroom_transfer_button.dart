import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_merge_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_rules.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_transfer_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_transfer_state.dart';

/// « Envoyer la classe et ses résultats » when [classroomId] is given,
/// « Recevoir une classe ou des résultats » otherwise; the outcome shows
/// in a snack bar. No mockup: built with the design system (F29-11).
class ClassroomTransferButton extends StatelessWidget {
  /// Creates the button; the Cubit comes from the slot.
  const ClassroomTransferButton({this.classroomId, super.key});

  /// Class to send, or `null` to receive a file.
  final String? classroomId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClassroomTransferCubit, ClassroomTransferState>(
      listener: _showOutcome,
      builder: (BuildContext context, ClassroomTransferState state) {
        final ClassroomTransferCubit cubit = context
            .read<ClassroomTransferCubit>();
        final String? id = classroomId;
        return DepthButton(
          label: id == null
              ? context.l10n.classroomImport
              : context.l10n.classroomExport,
          icon: id == null ? Icons.download_rounded : Icons.ios_share_rounded,
          variant: DepthButtonVariant.secondary,
          onPressed: state is ClassroomTransferBusy
              ? null
              : () => id == null ? cubit.receive() : _export(context, id),
        );
      },
    );
  }

  // The results since the last file, or all of them again.
  Future<void> _export(BuildContext context, String id) async {
    final ClassroomTransferCubit cubit = context.read<ClassroomTransferCubit>();
    final bool? isFull = await showModalBottomSheet<bool>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.update_rounded),
              title: Text(context.l10n.classroomExportNew),
              onTap: () => Navigator.of(context).pop(false),
            ),
            ListTile(
              leading: const Icon(Icons.all_inclusive_rounded),
              title: Text(context.l10n.classroomExportFull),
              onTap: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
    if (isFull == null) return;
    await cubit.export(id, isFull: isFull);
  }

  void _showOutcome(BuildContext context, ClassroomTransferState state) {
    final String? message = switch (state) {
      ClassroomTransferShared() => context.l10n.classroomExportDone,
      ClassroomTransferMerged(:final ClassroomMergeReport report) =>
        _mergeMessage(context, report),
      ClassroomTransferFailed(:final AppErrorCode errorCode) =>
        switch (errorCode) {
          AppErrorCode.invalidFile => context.l10n.classroomImportInvalid,
          AppErrorCode.fileTooBig => context.l10n.classroomImportTooBig,
          AppErrorCode.limitReached => context.l10n.classroomErrorTooMany(
            ClassroomRules.maxPupils,
          ),
          AppErrorCode.unsupportedVersion =>
            context.l10n.classroomImportVersion,
          AppErrorCode.conflict => context.l10n.classroomErrorTaken,
          _ => context.l10n.classroomErrorGeneric,
        },
      ClassroomTransferIdle() || ClassroomTransferBusy() => null,
    };
    if (message == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static String _mergeMessage(
    BuildContext context,
    ClassroomMergeReport report,
  ) {
    final String done = context.l10n.classroomImportDone(
      report.classroomName,
      report.addedPupilCount,
      report.addedSessionCount,
    );
    if (report.renamedNicknames.isEmpty) return done;
    return context.l10n.classroomImportRenamed(
      done,
      report.renamedNicknames.join(', '),
    );
  }
}
