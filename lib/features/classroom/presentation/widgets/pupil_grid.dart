import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/pupil_avatar_builder.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/pupil_tile.dart';

/// The pupils of a class as a sliver grid of tiles, built lazily for a
/// class of up to 60, or [emptyText] when there is none to show.
class PupilGrid extends StatelessWidget {
  /// Creates the grid of [pupils].
  const PupilGrid({
    required this.pupils,
    required this.avatarOf,
    required this.emptyText,
    required this.onTap,
    super.key,
  });

  static const double _tileWidth = 120;
  static const double _tileHeight = 128;

  /// Pupils shown, in order.
  final List<PupilEntity> pupils;

  /// Draws the avatars.
  final PupilAvatarBuilder avatarOf;

  /// Text shown when [pupils] is empty.
  final String emptyText;

  /// Called with the identifier of the pupil tapped.
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    const EdgeInsets padding = EdgeInsets.fromLTRB(
      AppSizes.space24,
      0,
      AppSizes.space24,
      AppSizes.space24,
    );
    if (pupils.isEmpty) {
      return SliverPadding(
        padding: padding,
        sliver: SliverToBoxAdapter(
          child: Text(emptyText, textAlign: TextAlign.center),
        ),
      );
    }
    final double textScale = MediaQuery.textScalerOf(context).scale(1);
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: _tileWidth,
          mainAxisSpacing: AppSizes.space12,
          crossAxisSpacing: AppSizes.space12,
          // Taller tiles for a bigger system text, so names never clip.
          mainAxisExtent: _tileHeight * (textScale < 1 ? 1 : textScale),
        ),
        itemCount: pupils.length,
        itemBuilder: (BuildContext context, int index) {
          final PupilEntity pupil = pupils[index];
          return PupilTile(
            key: ValueKey<String>(pupil.id),
            pupil: pupil,
            avatarOf: avatarOf,
            onTap: () => onTap(pupil.id),
          );
        },
      ),
    );
  }
}
