import 'package:meta/meta.dart';

/// Which player and which language the reading aloud of a quiz is for.
@immutable
final class ReadAloudModeParams {
  /// Creates the parameters.
  const ReadAloudModeParams({
    required this.profileId,
    required this.languageCode,
  });

  /// Player of the quiz.
  final String profileId;

  /// Language of the interface, such as `fr`.
  final String languageCode;
}
