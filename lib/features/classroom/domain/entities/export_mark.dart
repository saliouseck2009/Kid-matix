import 'package:meta/meta.dart';

/// Where the last class file of a class sent from this tablet stopped:
/// the local sequence of its last session, and when it was shared.
@immutable
final class ExportMark {
  /// Creates the mark.
  const ExportMark({required this.sequence, required this.exportedAt});

  /// Highest local sequence (`rowid`) of the sessions already sent; the
  /// next delta starts after it, whatever the clocks say.
  final int sequence;

  /// When the file was shared, shown as « depuis le … ».
  final DateTime exportedAt;

  /// Returns a copy with the given fields replaced.
  ExportMark copyWith({int? sequence, DateTime? exportedAt}) {
    return ExportMark(
      sequence: sequence ?? this.sequence,
      exportedAt: exportedAt ?? this.exportedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ExportMark &&
            other.sequence == sequence &&
            other.exportedAt == exportedAt;
  }

  @override
  int get hashCode => Object.hash(sequence, exportedAt);
}
