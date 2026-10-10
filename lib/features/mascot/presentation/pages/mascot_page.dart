import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/entities/accessory_slot.dart';
import 'package:kid_matix/core/entities/mascot_accessory.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_entity.dart';
import 'package:kid_matix/features/mascot/presentation/bloc/mascot_cubit.dart';
import 'package:kid_matix/features/mascot/presentation/bloc/mascot_state.dart';
import 'package:kid_matix/features/mascot/presentation/widgets/mascot_accessory_tile.dart';
import 'package:kid_matix/features/mascot/presentation/widgets/mascot_labels.dart';
import 'package:kid_matix/features/mascot/presentation/widgets/mascot_look_of.dart';
import 'package:kid_matix/features/mascot/presentation/widgets/mascot_name_field.dart';

/// The mascot screen: the mascot, its name, and its accessories by slot.
class MascotPage extends StatelessWidget {
  /// Creates the page; the mascot comes from the enclosing Cubit.
  const MascotPage({required this.onBack, super.key});

  static const double _mascotSize = 180;

  /// Goes back to the Profile tab.
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final MascotEntity? mascot = switch (context.watch<MascotCubit>().state) {
      MascotLoaded(:final mascot) => mascot,
      _ => null,
    };
    final MascotLabels labels = MascotLabels(l10n: context.l10n);
    return BackToParent(
      onBack: onBack,
      child: Scaffold(
        body: SafeArea(
          child: mascot == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(AppSizes.space24),
                  children: <Widget>[
                    Row(
                      spacing: AppSizes.space12,
                      children: <Widget>[
                        AppIconButton(
                          icon: Icons.arrow_back_rounded,
                          tooltip: context.l10n.commonBack,
                          onPressed: onBack,
                        ),
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: Text(
                              context.l10n.mascotPageTitle,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.space16),
                    Center(
                      child: MascotIllustration(
                        size: _mascotSize,
                        mood: MascotMood.happy,
                        look: lookOf(mascot),
                      ),
                    ),
                    const SizedBox(height: AppSizes.space16),
                    MascotNameField(name: mascot.name),
                    const SizedBox(height: AppSizes.space24),
                    Text(
                      context.l10n.mascotAccessoriesTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    for (final AccessorySlot slot in AccessorySlot.values)
                      _SlotSection(slot: slot, mascot: mascot, labels: labels),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SlotSection extends StatelessWidget {
  const _SlotSection({
    required this.slot,
    required this.mascot,
    required this.labels,
  });

  final AccessorySlot slot;
  final MascotEntity mascot;
  final MascotLabels labels;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSizes.space8,
        children: <Widget>[
          Text(
            labels.slotName(slot),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Wrap(
            spacing: AppSizes.space8,
            runSpacing: AppSizes.space8,
            children: <Widget>[
              for (final MascotAccessory accessory in MascotAccessory.values)
                if (accessory.slot == slot)
                  MascotAccessoryTile(
                    accessory: accessory,
                    isUnlocked: mascot.unlocked.contains(accessory),
                    isWorn: mascot.worn[slot] == accessory,
                    labels: labels,
                    onTap: () => context.read<MascotCubit>().toggleAccessory(
                      accessory,
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
