import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/pupil_actions_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/pupil_actions_state.dart';

/// Tells in a snack bar what the last action on a pupil did.
class PupilActionsListener extends StatelessWidget {
  /// Creates the listener around [child].
  const PupilActionsListener({required this.child, super.key});

  /// The page.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PupilActionsCubit, PupilActionsState>(
      listener: (BuildContext context, PupilActionsState state) {
        final String? message = switch (state) {
          PupilActionDone(kind: PupilActionKind.reset, :final nickname) =>
            context.l10n.classroomPupilResetDone(nickname),
          PupilActionDone(kind: PupilActionKind.remove, :final nickname) =>
            context.l10n.classroomPupilRemoved(nickname),
          PupilActionFailed() => context.l10n.classroomErrorGeneric,
          PupilActionsIdle() => null,
        };
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      child: child,
    );
  }
}
