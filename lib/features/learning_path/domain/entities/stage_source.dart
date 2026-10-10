import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:meta/meta.dart';

/// A stage of the learning path, as a quiz session remembers it.
///
/// Written as the opaque source key of the quiz, `path:mul:5:training`,
/// so the end of the session finds the stage it was played for.
@immutable
final class StageSource {
  /// Creates the source of [stage] of the unit [unitKey].
  const StageSource({required this.unitKey, required this.stage});

  /// Prefix of every learning path source key.
  static const String prefix = 'path';

  /// Separator of the parts of a source key.
  static const String separator = ':';

  /// Key of the table, such as `mul:5`, or of the review, `review:2`.
  final String unitKey;

  /// Stage of the unit.
  final StageKind stage;

  /// Reads [sourceKey]; `null` when it is not a stage of the path.
  static StageSource? tryParse(String? sourceKey) {
    if (sourceKey == null || !sourceKey.startsWith('$prefix$separator')) {
      return null;
    }
    final String rest = sourceKey.substring(prefix.length + 1);
    final int last = rest.lastIndexOf(separator);
    if (last <= 0) return null;
    final String stageName = rest.substring(last + 1);
    for (final StageKind stage in StageKind.values) {
      if (stage.name == stageName) {
        return StageSource(unitKey: rest.substring(0, last), stage: stage);
      }
    }
    return null;
  }

  /// The source key, such as `path:mul:5:training`.
  String toKey() => '$prefix$separator$unitKey$separator${stage.name}';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StageSource &&
            other.unitKey == unitKey &&
            other.stage == stage;
  }

  @override
  int get hashCode => Object.hash(unitKey, stage);

  @override
  String toString() => toKey();
}
