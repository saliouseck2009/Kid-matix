import 'package:meta/meta.dart';

/// The progress of one player in one learning domain.
@immutable
final class MasteryScope {
  /// Creates the scope.
  const MasteryScope({required this.profileId, required this.domainId});

  /// Player.
  final String profileId;

  /// Learning domain, such as `multiplication`.
  final String domainId;
}
