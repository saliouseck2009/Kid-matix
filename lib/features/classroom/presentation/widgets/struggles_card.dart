import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/features/classroom/domain/entities/item_struggle.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/class_item_labels.dart';

/// « Qui bloque, et sur quoi ? »: the facts and words the most pupils
/// keep missing, such as « 8 élèves se trompent sur 7 × 8 = 56 ».
class StrugglesCard extends StatelessWidget {
  /// Creates the card of [struggles], most pupils first.
  const StrugglesCard({
    required this.struggles,
    required this.labels,
    super.key,
  });

  /// Lines shown at most.
  static const int maxLines = 10;

  /// The items the class is stuck on, most pupils first.
  final List<ItemStruggle> struggles;

  /// Writes the items.
  final ClassItemLabels labels;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space8,
        children: <Widget>[
          Text(
            context.l10n.classroomStrugglesTitle,
            style: textTheme.titleLarge,
          ),
          if (struggles.isEmpty) Text(context.l10n.classroomStrugglesNone),
          for (final ItemStruggle struggle in struggles.take(maxLines))
            Row(
              key: ValueKey<String>(struggle.itemKey),
              spacing: AppSizes.space8,
              children: <Widget>[
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                Expanded(
                  child: Text(
                    context.l10n.classroomStruggleLine(
                      struggle.pupilCount,
                      labels.describe(struggle.itemKey),
                    ),
                    style: textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
