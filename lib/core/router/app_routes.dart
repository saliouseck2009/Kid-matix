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

  /// Settings of the active player, opened from the [profile] tab.
  static const String settings = '/profile/settings';

  /// Mascot screen, opened from the [profile] tab.
  static const String mascot = '/profile/mascot';

  /// Weekly leaderboard of the phone, opened from the [profile] tab.
  static const String leaderboard = '/profile/leaderboard';

  /// The shop of avatars and themes, opened from the [profile] tab.
  static const String shop = '/profile/shop';

  /// « Mes monstres », opened from the [challenges] tab.
  static const String challengeMonsters = '/challenges/monsters';

  /// The duel on one phone, opened from the [challenges] tab, full
  /// screen.
  static const String duel = '/challenges/duel';

  /// « J'ai un code »: the entry of a challenge code, opened from the
  /// [challenges] tab, full screen.
  static const String challengeCodeEntry = '/challenges/code';

  /// « Défier un ami »: the challenge code given as path parameter, then
  /// the entry of a code, full screen.
  static const String challengeCode = '/challenges/code/:$codeParameter';

  /// « Mes monstres », opened from the [profile] tab.
  static const String profileMonsters = '/profile/monsters';

  /// The placement test offered to a player just created, full screen.
  static const String placementTest = '/placement';

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

  /// Name of the code parameter of [challengeCode].
  static const String codeParameter = 'code';

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

  /// Path of « Défier un ami » showing the challenge [code].
  static String challengeCodeOf(String code) {
    return '$challengeCodeEntry/${Uri.encodeComponent(code)}';
  }

  /// Path of the results of [sessionId].
  static String quizResultsOf(String sessionId) {
    return '/results/${Uri.encodeComponent(sessionId)}';
  }

  /// Creation of a new player, opened from [whoIsPlaying].
  static const String profileCreation = '/players/new';

  /// The door of the teacher area: the 4-digit code, opened discreetly
  /// from [whoIsPlaying].
  static const String teacherArea = '/players/teacher';

  /// « Mes classes », the home of the teacher area.
  static const String teacherClassrooms = '/players/teacher/classes';

  /// Creation of a class with its pupils, in the teacher area.
  static const String classroomCreation = '/players/teacher/classes/new';

  /// « Rapport d'école ou de programme »: every class of the device.
  static const String programReport = '/players/teacher/classes/report';

  /// « Enregistrer les explications »: the teacher's own recordings.
  static const String teacherRecordings = '/players/teacher/classes/audio';

  /// « Recevoir par QR code »: the camera reads the results of a tablet.
  static const String resultsQrScan = '/players/teacher/classes/scan';

  /// Page of the class given as path parameter, in the teacher area.
  static const String teacherClassroom =
      '/players/teacher/classes/:$classroomIdParameter';

  /// « Ajouter des élèves » to the class given as path parameter.
  static const String classroomPupilsAddition =
      '/players/teacher/classes/:$classroomIdParameter/pupils';

  /// « Donner un devoir » to the class given as path parameter.
  static const String classroomAssignment =
      '/players/teacher/classes/:$classroomIdParameter/assignment';

  /// « Évaluations et rapports » of the class given as path parameter.
  static const String classroomAssessments =
      '/players/teacher/classes/:$classroomIdParameter/assessments';

  /// « Envoyer par QR code »: the new results of the class given as path
  /// parameter.
  static const String resultsQr =
      '/players/teacher/classes/:$classroomIdParameter/qr';

  /// The assessment given as path parameter, taken by the active pupil:
  /// the placement test, then the word check.
  static const String classAssessment = '/assessment/:$assessmentIdParameter';

  /// Name of the assessment parameter of [classAssessment].
  static const String assessmentIdParameter = 'assessmentId';

  /// « Qui es-tu ? »: a pupil finds their name in the class given as path
  /// parameter, opened from [whoIsPlaying].
  static const String pupilPicker = '/players/class/:$classroomIdParameter';

  /// Name of the class parameter of [teacherClassroom] and [pupilPicker].
  static const String classroomIdParameter = 'classroomId';

  /// Path of the page of the class [classroomId] in the teacher area.
  static String teacherClassroomOf(String classroomId) {
    return '$teacherClassrooms/${Uri.encodeComponent(classroomId)}';
  }

  /// Path of « Ajouter des élèves » to the class [classroomId].
  static String classroomPupilsAdditionOf(String classroomId) {
    return '${teacherClassroomOf(classroomId)}/pupils';
  }

  /// Path of « Donner un devoir » to the class [classroomId].
  static String classroomAssignmentOf(String classroomId) {
    return '${teacherClassroomOf(classroomId)}/assignment';
  }

  /// Path of « Évaluations et rapports » of the class [classroomId].
  static String classroomAssessmentsOf(String classroomId) {
    return '${teacherClassroomOf(classroomId)}/assessments';
  }

  /// Path of « Envoyer par QR code » of the class [classroomId].
  static String resultsQrOf(String classroomId) {
    return '${teacherClassroomOf(classroomId)}/qr';
  }

  /// Path of the assessment [assessmentId], taken by the active pupil.
  static String classAssessmentOf(String assessmentId) {
    return '/assessment/${Uri.encodeComponent(assessmentId)}';
  }

  /// Path of « Qui es-tu ? » in the class [classroomId].
  static String pupilPickerOf(String classroomId) {
    return '/players/class/${Uri.encodeComponent(classroomId)}';
  }

  /// Whether [location] is in the teacher area, its door included.
  static bool isTeacherArea(String location) {
    return location == teacherArea || location.startsWith('$teacherArea/');
  }

  /// Whether [location] is « Qui es-tu ? » of a class.
  static bool isPupilPicker(String location) {
    return location.startsWith('/players/class/');
  }
}
