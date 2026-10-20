import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/core/widgets/app_pill.dart';
import 'package:kid_matix/features/classroom/domain/entities/level_group.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';

/// The level groups proposed for a class in one domain, each with its
/// pupils.
class LevelGroupsCard extends StatelessWidget {
  /// Creates the card of [groups] in [domainId].
  const LevelGroupsCard({
    required this.groups,
    required this.domainId,
    super.key,
  });

  /// The groups, least advanced first.
  final List<LevelGroup> groups;

  /// Domain of the groups, or `null` before anything was played.
  final String? domainId;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? domain = domainId;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space8,
        children: <Widget>[
          Text(
            context.l10n.classroomGroupsTitle(
              domain == null ? '' : context.l10n.domainName(domain),
            ),
            style: textTheme.titleLarge,
          ),
          Text(
            context.l10n.classroomGroupsHint,
            style: textTheme.bodySmall?.copyWith(
              color: context.palette.mutedText,
            ),
          ),
          if (groups.isEmpty) Text(context.l10n.classroomGroupsNone),
          for (final LevelGroup group in groups)
            _GroupView(key: ValueKey<LevelGroupKind>(group.kind), group: group),
        ],
      ),
    );
  }
}

class _GroupView extends StatelessWidget {
  const _GroupView({required this.group, super.key});

  final LevelGroup group;

  @override
  Widget build(BuildContext context) {
    final String name = switch (group.kind) {
      LevelGroupKind.firstSteps => context.l10n.classroomGroupFirstSteps,
      LevelGroupKind.onTheWay => context.l10n.classroomGroupOnTheWay,
      LevelGroupKind.confident => context.l10n.classroomGroupConfident,
      LevelGroupKind.notYet => context.l10n.classroomGroupNotYet,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSizes.space4,
      children: <Widget>[
        Text(name, style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: AppSizes.space8,
          runSpacing: AppSizes.space8,
          children: <Widget>[
            for (final PupilEntity pupil in group.pupils)
              AppPill(key: ValueKey<String>(pupil.id), label: pupil.nickname),
          ],
        ),
      ],
    );
  }
}
