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

  /// Mascot screen, opened from the [profile] tab.
  static const String mascot = '/profile/mascot';

  /// "Qui joue ?": the player selection, shown while nobody is playing.
  static const String whoIsPlaying = '/players';

  /// Detail of the table given as path parameter, full screen.
  static const String tableDetail = '/table/:$unitKeyParameter';

  /// The whole table and its tip, opened by "Voir la table".
  static const String tableView = '/table/:$unitKeyParameter/view';

  /// The Discovery stage of the table: the table, its tip, then "À moi de
  /// jouer".
  static const String discovery = '/table/:$unitKeyParameter/discovery';

  /// Full-screen quiz played for the source given as path parameter, such
  /// as a stage of the learning path.
  static const String play = '/play/:$sourceKeyParameter';

  /// Results of the session given as path parameter.
  static const String quizResults = '/results/:$sessionIdParameter';

  /// Name of the unit parameter of [tableDetail], [tableView] and
  /// [discovery].
  static const String unitKeyParameter = 'unitKey';

  /// Name of the source parameter of [play].
  static const String sourceKeyParameter = 'sourceKey';

  /// Name of the session parameter of [quizResults].
  static const String sessionIdParameter = 'sessionId';

  /// Path of the detail of the table [unitKey], such as `mul:5`.
  static String tableDetailOf(String unitKey) {
    return '/table/${Uri.encodeComponent(unitKey)}';
  }

  /// Path of the whole table [unitKey] and its tip.
  static String tableViewOf(String unitKey) => '${tableDetailOf(unitKey)}/view';

  /// Path of the Discovery stage of the table [unitKey].
  static String discoveryOf(String unitKey) {
    return '${tableDetailOf(unitKey)}/discovery';
  }

  /// Path of the quiz played for [sourceKey].
  static String playOf(String sourceKey) {
    return '/play/${Uri.encodeComponent(sourceKey)}';
  }

  /// Path of the results of [sessionId].
  static String quizResultsOf(String sessionId) {
    return '/results/${Uri.encodeComponent(sessionId)}';
  }

  /// Creation of a new player, opened from [whoIsPlaying].
  static const String profileCreation = '/players/new';
}
