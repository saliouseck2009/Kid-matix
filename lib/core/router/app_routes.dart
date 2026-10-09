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

  /// Edition of the active player, opened from the [profile] tab.
  static const String profileEdit = '/profile/edit';

  /// "Qui joue ?": the player selection, shown while nobody is playing.
  static const String whoIsPlaying = '/players';

  /// Full-screen quiz on the unit given as path parameter.
  static const String quiz = '/quiz/:$unitKeyParameter';

  /// Results of the session given as path parameter.
  static const String quizResults = '/results/:$sessionIdParameter';

  /// Name of the unit parameter of [quiz].
  static const String unitKeyParameter = 'unitKey';

  /// Name of the session parameter of [quizResults].
  static const String sessionIdParameter = 'sessionId';

  /// Path of the quiz on [unitKey], such as `mul:5`.
  static String quizOf(String unitKey) {
    return '/quiz/${Uri.encodeComponent(unitKey)}';
  }

  /// Path of the results of [sessionId].
  static String quizResultsOf(String sessionId) {
    return '/results/${Uri.encodeComponent(sessionId)}';
  }

  /// Creation of a new player, opened from [whoIsPlaying].
  static const String profileCreation = '/players/new';
}
