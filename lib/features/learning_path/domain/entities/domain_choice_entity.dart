import 'package:meta/meta.dart';

/// The learning domains a player can choose between, and the one chosen.
@immutable
final class DomainChoiceEntity {
  /// Creates the choice of [selectedId] among [domainIds].
  DomainChoiceEntity({
    required List<String> domainIds,
    required this.selectedId,
  }) : assert(domainIds.contains(selectedId), 'a known domain is chosen'),
       domainIds = List<String>.unmodifiable(domainIds);

  /// Every domain of the app, in registration order.
  final List<String> domainIds;

  /// Domain shown on the map and in the Profile.
  final String selectedId;

  /// Whether there is a choice to offer: two domains or more.
  bool get hasChoice => domainIds.length > 1;

  /// The same domains with [domainId] chosen.
  DomainChoiceEntity copyWith({String? selectedId}) {
    return DomainChoiceEntity(
      domainIds: domainIds,
      selectedId: selectedId ?? this.selectedId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DomainChoiceEntity || other.selectedId != selectedId) {
      return false;
    }
    if (other.domainIds.length != domainIds.length) return false;
    for (int index = 0; index < domainIds.length; index++) {
      if (other.domainIds[index] != domainIds[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(domainIds), selectedId);

  @override
  String toString() => 'DomainChoiceEntity($selectedId of $domainIds)';
}
