import 'package:meta/meta.dart';

/// A text to read aloud.
@immutable
final class ReadAloudParams {
  /// Creates the parameters.
  const ReadAloudParams({required this.text, required this.languageCode});

  /// What the voice says.
  final String text;

  /// Language of the voice, such as `fr`.
  final String languageCode;
}
