import 'package:kid_matix/features/classroom/domain/entities/item_struggle.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_progress.dart';
import 'package:meta/meta.dart';

/// The dashboard of a class: each pupil, and the items the class is
/// stuck on, most pupils first.
@immutable
final class ClassDashboard {
  /// Creates the dashboard.
  const ClassDashboard({required this.pupils, required this.struggles});

  /// Every pupil, in the order of the class list.
  final List<PupilProgress> pupils;

  /// The items at least one pupil is stuck on, most pupils first.
  final List<ItemStruggle> struggles;

  /// The pupils stuck on at least one item.
  List<PupilProgress> get stuckPupils => pupils
      .where((PupilProgress pupil) => pupil.struggleItemKeys.isNotEmpty)
      .toList();

  /// Returns a copy with the given fields replaced.
  ClassDashboard copyWith({
    List<PupilProgress>? pupils,
    List<ItemStruggle>? struggles,
  }) {
    return ClassDashboard(
      pupils: pupils ?? this.pupils,
      struggles: struggles ?? this.struggles,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ClassDashboard &&
            Object.hashAll(other.pupils) == Object.hashAll(pupils) &&
            Object.hashAll(other.struggles) == Object.hashAll(struggles);
  }

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(pupils), Object.hashAll(struggles));
}
