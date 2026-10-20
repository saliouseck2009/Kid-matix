import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/pupil_actions_button.dart';

/// The pupils of a class on its page in the teacher area, each with « Gérer
/// … » (reset, remove).
class ClassroomPupilsCard extends StatelessWidget {
  /// Creates the card of [pupils].
  const ClassroomPupilsCard({required this.pupils, super.key});

  /// Pupils of the class, in order.
  final List<PupilEntity> pupils;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space4,
        children: <Widget>[
          Text(context.l10n.classroomPupilsTitle, style: textTheme.titleLarge),
          if (pupils.isEmpty) Text(context.l10n.classroomPickerEmpty),
          for (final PupilEntity pupil in pupils)
            Row(
              key: ValueKey<String>(pupil.id),
              children: <Widget>[
                Expanded(
                  child: Text(pupil.nickname, style: textTheme.bodyLarge),
                ),
                PupilActionsButton(pupil: pupil),
              ],
            ),
        ],
      ),
    );
  }
}
