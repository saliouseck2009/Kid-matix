import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/core/widgets/app_pill.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';

/// The nicknames of the pupils of a class, on its page in the teacher
/// area.
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
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSizes.space12,
        children: <Widget>[
          Text(context.l10n.classroomPupilsTitle, style: textTheme.titleLarge),
          if (pupils.isEmpty)
            Text(context.l10n.classroomPickerEmpty)
          else
            Wrap(
              spacing: AppSizes.space8,
              runSpacing: AppSizes.space8,
              children: <Widget>[
                for (final PupilEntity pupil in pupils)
                  AppPill(
                    key: ValueKey<String>(pupil.id),
                    label: pupil.nickname,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
