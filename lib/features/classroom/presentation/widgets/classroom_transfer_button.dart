import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_merge_report.dart';
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
              : () => id == null ? cubit.receive() : cubit.export(id),
        );
      },
    );
  }

  void _showOutcome(BuildContext context, ClassroomTransferState state) {
    final String? message = switch (state) {
      ClassroomTransferShared() => context.l10n.classroomExportDone,
      ClassroomTransferMerged(:final ClassroomMergeReport report) =>
        context.l10n.classroomImportDone(
          report.classroomName,
          report.addedPupilCount,
          report.addedSessionCount,
        ),
      ClassroomTransferFailed(:final AppErrorCode errorCode) =>
        switch (errorCode) {
          AppErrorCode.invalidFile => context.l10n.classroomImportInvalid,
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
}
