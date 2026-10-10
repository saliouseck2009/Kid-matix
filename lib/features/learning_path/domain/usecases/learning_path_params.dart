import 'package:meta/meta.dart';

/// The learning path of one player in one domain.
@immutable
final class LearningPathParams {
  /// Creates the parameters.
  const LearningPathParams({required this.profileId, required this.domainId});

  /// Player.
  final String profileId;

  /// Learning domain, such as `multiplication`.
  final String domainId;
}
