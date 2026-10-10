import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/star_row.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/path_labels.dart';

/// The review after a group of 3 tables: a small round node, its name and
/// its stars. It starts its quiz at once; it never locks a table.
class ReviewNode extends StatelessWidget {
  /// Creates the node of [review].
  const ReviewNode({
    required this.review,
    required this.labels,
    required this.onPlay,
    super.key,
  });

  static const double _size = 64;
  static const double _depth = 5;

  /// Review shown.
  final ReviewPathNode review;

  /// Texts of the path.
  final PathLabels labels;

  /// Starts the review.
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final bool isPlayable = review.stage.isPlayable;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String name = labels.stageName(review.stage.kind);
    return Semantics(
      button: isPlayable,
      label: isPlayable ? name : context.l10n.pathReviewNodeLocked(name),
      child: GestureDetector(
        onTap: isPlayable ? onPlay : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: <Widget>[
            ExcludeSemantics(
              child: Container(
                width: _size,
                height: _size,
                padding: const EdgeInsets.only(bottom: _depth),
                decoration: BoxDecoration(
                  color: isPlayable
                      ? context.palette.secondaryDepth
                      : context.palette.lockedDepth,
                  shape: BoxShape.circle,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isPlayable
                        ? scheme.secondary
                        : context.palette.lockedFace,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlayable
                        ? Icons.replay_rounded
                        : Icons.lock_outline_rounded,
                    color: isPlayable
                        ? scheme.onSecondary
                        : context.palette.mutedText,
                  ),
                ),
              ),
            ),
            ExcludeSemantics(
              child: Text(
                name,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: context.palette.mutedText,
                ),
              ),
            ),
            if (review.stage.stars > 0) StarRow(count: review.stage.stars),
          ],
        ),
      ),
    );
  }
}
