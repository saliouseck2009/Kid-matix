import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_entity.dart';
import 'package:kid_matix/features/mascot/domain/services/mascot_rules.dart';
import 'package:kid_matix/features/mascot/presentation/bloc/mascot_cubit.dart';
import 'package:kid_matix/features/mascot/presentation/bloc/mascot_state.dart';
import 'package:kid_matix/features/mascot/presentation/widgets/mascot_look_of.dart';

/// Card of the Profile tab: the mascot, its stage and the next one, and a
/// bar of 5 segments. It opens the mascot screen.
class MascotProfileCard extends StatelessWidget {
  /// Creates the card.
  const MascotProfileCard({required this.onOpen, super.key});

  static const double _mascotSize = 72;
  static const double _radius = 24;
  static const double _segmentHeight = 8;

  /// Opens the mascot screen.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final MascotEntity? mascot = switch (context.watch<MascotCubit>().state) {
      MascotLoaded(:final mascot) => mascot,
      _ => null,
    };
    if (mascot == null) return const SizedBox.shrink();
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int? next = mascot.nextStageLevel;
    final int total = MascotRules.lastStage;
    return Semantics(
      button: true,
      label: context.l10n.mascotOpenTooltip,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_radius),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(_radius),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.space16),
            child: Row(
              spacing: AppSizes.space16,
              children: <Widget>[
                MascotIllustration(size: _mascotSize, look: lookOf(mascot)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: <Widget>[
                      Text(
                        context.l10n.mascotCardTitle,
                        style: textTheme.titleMedium,
                      ),
                      Text(
                        next == null
                            ? context.l10n.mascotCardLastStage(
                                mascot.stage,
                                total,
                              )
                            : context.l10n.mascotCardStage(
                                mascot.stage,
                                total,
                                next,
                              ),
                        style: textTheme.bodySmall?.copyWith(
                          color: context.palette.mutedText,
                        ),
                      ),
                      ExcludeSemantics(
                        child: Row(
                          spacing: 6,
                          children: <Widget>[
                            for (int stage = 1; stage <= total; stage++)
                              Expanded(
                                child: Container(
                                  height: _segmentHeight,
                                  decoration: BoxDecoration(
                                    color: stage <= mascot.stage
                                        ? Theme.of(context).colorScheme.primary
                                        : context.palette.tint,
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusPill,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
