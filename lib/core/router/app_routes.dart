/// Every route path of the app.
abstract final class AppRoutes {
  /// Learning path tab, the home of the app.
  static const String learningPath = '/';

  /// Free training tab.
  static const String training = '/training';

  /// Challenges tab.
  static const String challenges = '/challenges';

  /// Profile tab.
  static const String profile = '/profile';

  /// "Qui joue ?": the player selection, shown while nobody is playing.
  static const String whoIsPlaying = '/players';

  /// Creation of a new player, opened from [whoIsPlaying].
  static const String profileCreation = '/players/new';
}
