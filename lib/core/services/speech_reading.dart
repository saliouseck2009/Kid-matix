import 'package:meta/meta.dart';

/// A reading started by `SpeechService.speak`.
///
/// It is the handle to give back to `SpeechService.stop` to stop this
/// reading and no other, and [done] tells when the voice has finished.
@immutable
final class SpeechReading {
  /// Creates the handle of a reading that ends when [done] completes.
  const SpeechReading(this.done);

  /// A reading that has nothing to say and is over already.
  static final SpeechReading none = SpeechReading(Future<void>.value());

  /// Completes when the reading ends, is stopped, or could not start; it
  /// never completes with an error.
  final Future<void> done;
}
