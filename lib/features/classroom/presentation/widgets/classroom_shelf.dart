import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_summary.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classrooms_cubit.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classrooms_state.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/classroom_card.dart';

/// The classes of the device at the top of « Qui joue ? », before the
/// free players; nothing when the device has none. No mockup: built
/// with the design system (F29-11).
class ClassroomShelf extends StatelessWidget {
  /// Creates the shelf; the Cubit comes from the slot.
  const ClassroomShelf({required this.onOpenClassroom, super.key});

  /// Opens « Qui es-tu ? » in a class.
  final ValueChanged<String> onOpenClassroom;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassroomsCubit, ClassroomsState>(
      builder: (BuildContext context, ClassroomsState state) {
        if (state is! ClassroomsLoaded || state.classrooms.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSizes.space12,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(
                  context.l10n.classroomShelfTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              for (final ClassroomSummary summary in state.classrooms)
                ClassroomCard(
                  key: ValueKey<String>(summary.classroom.id),
                  summary: summary,
                  onTap: () => onOpenClassroom(summary.classroom.id),
                ),
            ],
          ),
        );
      },
    );
  }
}
