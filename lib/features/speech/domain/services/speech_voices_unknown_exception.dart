/// The speech engine could not say which voices it has, for instance
/// because the speech service of the phone is disconnected or did not
/// start.
///
/// It says nothing about the voices, so it is not an answer "no voice":
/// the service does not remember it and asks the engine again.
final class SpeechVoicesUnknownException implements Exception {
  /// Creates the exception.
  const SpeechVoicesUnknownException();

  @override
  String toString() =>
      'SpeechVoicesUnknownException: the speech service '
      'did not list its voices';
}
