// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kid Matix';

  @override
  String get mainNavigationLabel => 'Main navigation';

  @override
  String get tabLearningPath => 'Path';

  @override
  String get tabTraining => 'Practice';

  @override
  String get tabChallenges => 'Challenges';

  @override
  String get tabProfile => 'Profile';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonBack => 'Back';

  @override
  String get multiplicationDomainName => 'Multiplication';

  @override
  String get numbersDomainName => 'Numbers';

  @override
  String get divisionDomainName => 'Division';

  @override
  String get additionDomainName => '+ and −';

  @override
  String get additionDomainSpokenName => 'Additions and subtractions';

  @override
  String get mathWordsDomainName => 'Math words';

  @override
  String get errorStorage => 'Oops, we couldn\'t read or save your data.';

  @override
  String get errorNotFound => 'This player doesn\'t exist anymore.';

  @override
  String get errorUnknown => 'Oops, something went wrong.';

  @override
  String get whoIsPlayingTitle => 'Who\'s playing?';

  @override
  String get whoIsPlayingSubtitle => 'Pick your player to start.';

  @override
  String profileLevel(int level) {
    return 'Level $level';
  }

  @override
  String get newPlayerButton => 'New player';

  @override
  String profileLimitHint(int maxProfiles) {
    String _temp0 = intl.Intl.pluralLogic(
      maxProfiles,
      locale: localeName,
      other: 'Up to $maxProfiles players on this phone.',
      one: 'Up to $maxProfiles player on this phone.',
    );
    return '$_temp0';
  }

  @override
  String profileLimitReached(int maxProfiles) {
    String _temp0 = intl.Intl.pluralLogic(
      maxProfiles,
      locale: localeName,
      other: 'There are already $maxProfiles players on this phone.',
      one: 'There is already $maxProfiles player on this phone.',
    );
    return '$_temp0';
  }

  @override
  String get classroomTeacherArea => 'Teacher area';

  @override
  String get classroomCodeChooseHint =>
      'Choose a 4-digit code. It locks the teacher area: don\'t give it to your pupils.';

  @override
  String get classroomCodeConfirmHint => 'Type the same code a second time.';

  @override
  String get classroomCodeEnterHint => 'Type your 4-digit code.';

  @override
  String get classroomCodeLabel => 'Code';

  @override
  String get classroomCodeOpen => 'Open';

  @override
  String get classroomCodeNext => 'Continue';

  @override
  String get classroomCodeWrong => 'That\'s not the right code.';

  @override
  String get classroomCodeMismatch =>
      'The two codes are different. Start again.';

  @override
  String get classroomCodeInvalid => 'The code has 4 digits.';

  @override
  String get classroomLeaveArea => 'Leave the teacher area';

  @override
  String get classroomListTitle => 'My classes';

  @override
  String get classroomListEmpty =>
      'No class yet. Create a class and add all its pupils at once.';

  @override
  String get classroomNew => 'New class';

  @override
  String classroomPupilCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pupils',
      one: '1 pupil',
      zero: 'No pupils',
    );
    return '$_temp0';
  }

  @override
  String get classroomNameLabel => 'Class name';

  @override
  String get classroomNameHint => 'For example Year 2 B';

  @override
  String get classroomNamePrivacyHint =>
      'The class name also appears in anonymous reports: do not put a person\'s name in it.';

  @override
  String get classroomPupilsTitle => 'Pupils';

  @override
  String get classroomPupilsByList => 'Nicknames';

  @override
  String get classroomPupilsByNumber => 'Numbers';

  @override
  String get classroomPupilsListLabel => 'One nickname per line';

  @override
  String get classroomPupilsPrivacyHint =>
      'Use nicknames or numbers rather than the children\'s real names.';

  @override
  String get classroomPupilsCountLabel => 'Number of pupils';

  @override
  String classroomPupilsPreview(int count, String first, String last) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pupils to add: $first to $last',
      one: '1 pupil to add: $first',
      zero: 'No pupil to add',
    );
    return '$_temp0';
  }

  @override
  String classroomPupilsUnusable(String nicknames) {
    return 'These nicknames don\'t work: $nicknames. A nickname has 2 to 12 letters or digits, and each one appears only once.';
  }

  @override
  String get classroomCreate => 'Create the class';

  @override
  String get classroomErrorName =>
      'Give the class a name (24 characters at most).';

  @override
  String get classroomErrorNoPupil => 'Add at least one pupil.';

  @override
  String classroomErrorTooMany(int max) {
    return 'A class has at most $max pupils.';
  }

  @override
  String get classroomErrorTaken =>
      'One of these nicknames is already in the class.';

  @override
  String get classroomErrorGeneric => 'Oops, that didn\'t work. Try again.';

  @override
  String get classroomAddPupils => 'Add pupils';

  @override
  String get classroomShelfTitle => 'Classes';

  @override
  String get classroomPickerTitle => 'Who are you?';

  @override
  String get classroomPickerSearch => 'Find your name';

  @override
  String get classroomPickerNoMatch => 'Nobody in the class has that name.';

  @override
  String get classroomPickerEmpty => 'This class has no pupils yet.';

  @override
  String get classroomCodeForgotten => 'Forgot the code?';

  @override
  String classroomCodeChanged(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Code changed on $dateString';
  }

  @override
  String classroomCodeLocked(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Too many tries. Wait $seconds seconds before trying again.',
      one: 'Too many tries. Wait 1 second before trying again.',
    );
    return '$_temp0';
  }

  @override
  String get classroomOneTabletHint =>
      'Each pupil always plays on the same tablet: their progress does not move from one tablet to another.';

  @override
  String classroomPupilManage(String nickname) {
    return 'Manage $nickname';
  }

  @override
  String get classroomPupilReset => 'Reset their progress';

  @override
  String get classroomPupilResetMessage =>
      'Their stars, crowns, badges, XP and records will be erased. Their class results stay.';

  @override
  String get classroomPupilRemove => 'Remove from the class';

  @override
  String get classroomPupilRemoveMessage =>
      'This pupil and all their progress will be erased from this tablet, their class results too.';

  @override
  String classroomPupilResetDone(String nickname) {
    return '$nickname\'s progress is reset.';
  }

  @override
  String classroomPupilRemoved(String nickname) {
    return '$nickname is removed from the class.';
  }

  @override
  String get classroomAssignmentTitle => 'Class homework';

  @override
  String get classroomAssignmentNone =>
      'No homework yet. Choose a unit for the whole class to work on.';

  @override
  String get classroomAssignmentGive => 'Give homework';

  @override
  String get classroomAssignmentPickHint =>
      'Choose the unit the whole class will work on.';

  @override
  String classroomAssignmentDue(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMMEEEEd(
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return 'Due $dateString';
  }

  @override
  String get classroomAssignmentDueNone => 'No date';

  @override
  String get classroomAssignmentDueTomorrow => 'Tomorrow';

  @override
  String get classroomAssignmentDueWeek => 'In 7 days';

  @override
  String classroomAssignmentStarted(int started, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      started,
      locale: localeName,
      other: '$started pupils out of $total have started it.',
      one: '1 pupil out of $total has started it.',
      zero: 'Nobody has started it yet.',
    );
    return '$_temp0';
  }

  @override
  String get classroomAssignmentPlay => 'Let\'s go';

  @override
  String classroomAssignmentLearned(int percent) {
    return '$percent% learned';
  }

  @override
  String get classroomChallengeTitle => 'Class challenge';

  @override
  String classroomChallengeProgress(int count, int goal) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count right answers out of $goal this week',
      one: '1 right answer out of $goal this week',
    );
    return '$_temp0';
  }

  @override
  String get classroomChallengeReached => 'Well done, class, goal reached!';

  @override
  String get classroomChallengeGoal => 'Goal of the week';

  @override
  String get classroomStrugglesTitle => 'Who is stuck, and on what?';

  @override
  String classroomStruggleLine(int count, String item) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pupils get $item wrong',
      one: '1 pupil gets $item wrong',
    );
    return '$_temp0';
  }

  @override
  String get classroomStrugglesNone => 'Nobody is stuck for now.';

  @override
  String classroomGroupsTitle(String domain) {
    return 'Level groups · $domain';
  }

  @override
  String get classroomGroupsHint =>
      'Suggested from the placement test and the pupils\' answers.';

  @override
  String get classroomGroupsNone =>
      'The groups will show up once the pupils have played.';

  @override
  String get classroomGroupFirstSteps => 'First steps';

  @override
  String get classroomGroupOnTheWay => 'On the way';

  @override
  String get classroomGroupConfident => 'Confident';

  @override
  String get classroomGroupNotYet => 'Not assessed yet';

  @override
  String get classroomPupilNeverPlayed => 'Hasn\'t played yet';

  @override
  String classroomPupilSummary(int sessions, String time, int percent) {
    String _temp0 = intl.Intl.pluralLogic(
      sessions,
      locale: localeName,
      other: '$sessions sessions',
      one: '1 session',
    );
    return '$_temp0 · $time · $percent% right answers';
  }

  @override
  String classroomPracticeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String classroomPracticeSeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String classroomPupilLastSession(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Last session: $dateString';
  }

  @override
  String classroomPupilStuckOn(String items) {
    return 'Stuck on: $items';
  }

  @override
  String get classroomExport => 'Send the class and its results';

  @override
  String get classroomExportDone => 'The class file is ready.';

  @override
  String get classroomExportNew => 'The new results since the last file';

  @override
  String classroomExportNewSince(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'The new results since $dateString';
  }

  @override
  String get classroomExportFull => 'The whole class and all its results';

  @override
  String get classroomImportTooBig => 'This file is too big for this tablet.';

  @override
  String classroomImportRenamed(String done, String nicknames) {
    return '$done Nicknames already taken in the class, pupils renamed: $nicknames.';
  }

  @override
  String get classroomImport => 'Receive a class or results';

  @override
  String classroomImportDone(String name, int pupils, int sessions) {
    String _temp0 = intl.Intl.pluralLogic(
      pupils,
      locale: localeName,
      other: '$pupils new pupils',
      one: '1 new pupil',
      zero: 'no new pupils',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sessions,
      locale: localeName,
      other: '$sessions new sessions',
      one: '1 new session',
      zero: 'no new sessions',
    );
    return '$name: $_temp0, $_temp1.';
  }

  @override
  String get classroomImportInvalid =>
      'This file is not a Kid Matix class file, or it is damaged.';

  @override
  String get classroomImportVersion =>
      'This file comes from a newer version of Kid Matix. Update the app, then try again.';

  @override
  String get classroomAssessmentsOpen => 'Assessments and reports';

  @override
  String get classroomAssessmentsTitle => 'Assessments';

  @override
  String get classroomAssessmentsHint =>
      'Start an assessment at the beginning and at the end of a period to measure progress. Each pupil takes the level test, then 12 maths words.';

  @override
  String get classroomAssessmentsEmpty => 'No assessment yet.';

  @override
  String get classroomAssessmentNew => 'Start an assessment';

  @override
  String get classroomAssessmentLabelLabel => 'Name of the period';

  @override
  String get classroomAssessmentLabelHint => 'For example Start of the year';

  @override
  String get classroomAssessmentLabelError =>
      'Give the period a name (30 characters at most).';

  @override
  String get classroomAssessmentPresetStart => 'Start of the year';

  @override
  String get classroomAssessmentPresetMiddle => 'Middle of the year';

  @override
  String get classroomAssessmentPresetEnd => 'End of the year';

  @override
  String get classroomAssessmentStart => 'Start';

  @override
  String classroomAssessmentOpenedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Opened on $dateString';
  }

  @override
  String classroomAssessmentClosedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Closed on $dateString';
  }

  @override
  String classroomAssessmentTaken(int taken, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      taken,
      locale: localeName,
      other: '$taken pupils out of $total have taken it.',
      one: '1 pupil out of $total has taken it.',
      zero: 'No pupil out of $total has taken it.',
    );
    return '$_temp0';
  }

  @override
  String get classroomAssessmentClose => 'Close';

  @override
  String classroomAssessmentCloseTitle(String label) {
    return 'Close “$label”?';
  }

  @override
  String get classroomAssessmentCloseMessage =>
      'Pupils who have not taken it yet will no longer see it. The results already in are kept.';

  @override
  String get classroomAssessmentIsOpen => 'Open to pupils';

  @override
  String get classroomAssessmentBannerTitle => 'Class assessment';

  @override
  String get classroomAssessmentBannerText =>
      'Show what you can do: a few sums, then some maths words.';

  @override
  String get classroomAssessmentBannerStart => 'Start';

  @override
  String get classroomReportCardTitle => 'Class report';

  @override
  String get classroomReportCardHint =>
      'Compare two assessments: levels, words understood, practice time and facts learned. Share the anonymous version; keep the named one for yourself.';

  @override
  String get classroomReportNeedsAssessment =>
      'The report will appear after the first assessment.';

  @override
  String get classroomReportFrom => 'Start';

  @override
  String get classroomReportTo => 'End';

  @override
  String get classroomReportNone => 'None';

  @override
  String get classroomReportAnonymousVersion => 'Anonymous version (to share)';

  @override
  String get classroomReportNamedVersion => 'Named version (for me)';

  @override
  String get classroomReportPdf => 'Export as PDF';

  @override
  String get classroomReportCsv => 'Export as CSV';

  @override
  String get classroomReportShared => 'The report is ready.';

  @override
  String classroomReportTitle(String name) {
    return 'Report of class $name';
  }

  @override
  String classroomReportPeriods(
    String from,
    DateTime fromDate,
    String to,
    DateTime toDate,
  ) {
    final intl.DateFormat fromDateDateFormat = intl.DateFormat.yMMMMd(
      localeName,
    );
    final String fromDateString = fromDateDateFormat.format(fromDate);
    final intl.DateFormat toDateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String toDateString = toDateDateFormat.format(toDate);

    return 'From “$from” ($fromDateString) to “$to” ($toDateString)';
  }

  @override
  String classroomReportOnePeriod(String label, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '“$label” ($dateString)';
  }

  @override
  String classroomReportGenerated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Made on $dateString with Kid Matix, offline.';
  }

  @override
  String get classroomReportClassTitle => 'The class';

  @override
  String get classroomReportDomain => 'Domain';

  @override
  String get classroomReportProgressed => 'Pupils who progressed';

  @override
  String classroomReportCount(int count, int total) {
    return '$count of $total';
  }

  @override
  String classroomReportPercent(int percent) {
    return '$percent%';
  }

  @override
  String get classroomReportNoValue => '–';

  @override
  String get classroomReportWords => 'Maths words understood';

  @override
  String classroomReportPractice(int sessions, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      sessions,
      locale: localeName,
      other:
          'Practice time between the two assessments: $time in $sessions sessions.',
      one: 'Practice time between the two assessments: $time in 1 session.',
      zero: 'No session between the two assessments.',
    );
    return '$_temp0';
  }

  @override
  String classroomReportHours(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String classroomReportAcquired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count facts and words learned between the two assessments (right the last 3 times).',
      one: '1 fact or word learned between the two assessments (right the last 3 times).',
      zero: 'No fact or word learned between the two assessments.',
    );
    return '$_temp0';
  }

  @override
  String get classroomReportPupilsTitle => 'The pupils';

  @override
  String get classroomReportPupil => 'Pupil';

  @override
  String classroomReportPupilNumber(int number) {
    return 'Pupil $number';
  }

  @override
  String classroomReportColumnStart(String name) {
    return '$name start';
  }

  @override
  String classroomReportColumnEnd(String name) {
    return '$name end';
  }

  @override
  String get classroomReportWordsShort => 'Words';

  @override
  String get classroomReportPracticeShort => 'Practice';

  @override
  String get classroomReportPracticeMinutes => 'Practice (min)';

  @override
  String get classroomReportSessions => 'Sessions';

  @override
  String get classroomReportAcquiredShort => 'Learned';

  @override
  String get classroomReportFileName => 'Report';

  @override
  String get classroomReportAnonymousNote =>
      'Anonymous version: each pupil is shown by their number in the class list.';

  @override
  String get classroomReportFileAnonymous => 'anonymous';

  @override
  String get classroomProgramOpen => 'School or programme report';

  @override
  String get classroomProgramHint =>
      'For a coordinator: first receive the class files, then compare two assessments over every class of this tablet. This report is always anonymous.';

  @override
  String get classroomProgramEmpty => 'No assessment on this tablet yet.';

  @override
  String classroomProgramPeriods(String from, String to) {
    return 'From “$from” to “$to”';
  }

  @override
  String classroomProgramOnePeriod(String label) {
    return '“$label”';
  }

  @override
  String get classroomProgramNote =>
      'Anonymous report: it only holds figures per class, no pupil.';

  @override
  String get classroomProgramClass => 'Class';

  @override
  String get classroomProgramPupils => 'Pupils';

  @override
  String get classroomProgramAssessed => 'Assessed';

  @override
  String get classroomProgramTotal => 'All classes';

  @override
  String classroomProgramSecondOnly(String from, String to, String classes) {
    return 'Without a “$from” assessment, reported on “$to” only: $classes.';
  }

  @override
  String get classroomProgramFileName => 'Programme';

  @override
  String get classroomQrSend => 'Send as a QR code';

  @override
  String get classroomQrSendHint =>
      'On the teacher\'s tablet, open “Receive a QR code” and point the camera at this code.';

  @override
  String classroomQrSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new sessions',
      one: '1 new session',
      zero: 'Only assessment results',
    );
    return '$_temp0';
  }

  @override
  String get classroomQrImageLabel => 'QR code of the new results';

  @override
  String get classroomQrDone => 'It\'s received';

  @override
  String get classroomQrSent => 'These results will not be sent again.';

  @override
  String get classroomQrNothing => 'Nothing new to send since the last time.';

  @override
  String get classroomQrTooBig =>
      'Too many results for a QR code: send the class file instead.';

  @override
  String get classroomQrReceive => 'Receive a QR code';

  @override
  String get classroomQrScanHint =>
      'Point the camera at the QR code shown on the other tablet. The camera is only used to read that code.';

  @override
  String get classroomQrScanAgain => 'Read another code';

  @override
  String get classroomQrInvalid =>
      'This QR code does not come from Kid Matix, or it is damaged.';

  @override
  String get classroomQrVersion =>
      'This QR code comes from a newer version of Kid Matix. Update the app, then try again.';

  @override
  String get classroomQrUnknown =>
      'This tablet does not have the class, its pupils or its assessment yet: first receive the class file.';

  @override
  String get classroomQrCameraError =>
      'The camera is not available. Allow it in the settings, or use the class file.';

  @override
  String get classroomRecordingsOpen => 'Record the explanations';

  @override
  String get classroomRecordingsHint =>
      'Record the explanation of each word in your language. On this tablet, your voice replaces the pack\'s: pupils hear it with the language button.';

  @override
  String get classroomRecordingsNoPack => 'The app has no help language yet.';

  @override
  String get classroomRecordingsLanguage => 'Language';

  @override
  String get classroomRecordingsExplanation => 'Explanation';

  @override
  String get classroomRecordingsExample => 'Example';

  @override
  String get classroomRecordingsTeacher => 'Your voice';

  @override
  String get classroomRecordingsPack => 'Pack voice';

  @override
  String get classroomRecordingsNone => 'Not recorded yet';

  @override
  String classroomRecordingsRecord(String word) {
    return 'Record “$word”';
  }

  @override
  String classroomRecordingsListen(String word) {
    return 'Listen to “$word”';
  }

  @override
  String classroomRecordingsDelete(String word) {
    return 'Delete your voice for “$word”';
  }

  @override
  String classroomRecordingsRecording(String word) {
    return 'Recording “$word”…';
  }

  @override
  String get classroomRecordingsKeep => 'Stop and keep';

  @override
  String get classroomRecordingsCancel => 'Throw it away';

  @override
  String get classroomRecordingsDenied =>
      'Without the microphone you cannot record. Allow it in the tablet settings.';

  @override
  String get classroomRecordingsSaved => 'Recorded.';

  @override
  String get classroomRecordingsExport => 'Export my recordings';

  @override
  String get classroomRecordingsImport => 'Import a pack';

  @override
  String get classroomRecordingsExported => 'The pack is ready.';

  @override
  String classroomRecordingsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordings added.',
      one: '1 recording added.',
    );
    return '$_temp0';
  }

  @override
  String get classroomRecordingsInvalid =>
      'This file is not a Kid Matix audio pack, or it is damaged.';

  @override
  String get classroomRecordingsNothing =>
      'Record at least one word before exporting.';

  @override
  String get classroomPrintablesOpen => 'Printable sheets';

  @override
  String get classroomPrintablesHint =>
      'Exercises and word cards to print. The cards also have lines in the help language: blank until their text is written, to fill in by hand.';

  @override
  String get classroomPrintablesExercisesTitle => 'Exercise sheet';

  @override
  String get classroomPrintablesDomain => 'Domain';

  @override
  String get classroomPrintablesUnit => 'Unit';

  @override
  String get classroomPrintablesExercises => 'Print the exercises (PDF)';

  @override
  String get classroomPrintablesWordsTitle => 'Word cards';

  @override
  String get classroomPrintablesWords => 'Print the cards (PDF)';

  @override
  String get classroomPrintablesNotPrintable =>
      'This unit is played with pictures: choose another one for a sheet.';

  @override
  String get classroomPrintablesShared => 'The sheet is ready.';

  @override
  String printExercisesTitle(String unit) {
    return 'Exercises · $unit';
  }

  @override
  String get printNameLine => 'Name: ____________________   Date: ____________';

  @override
  String get printExercisesInstruction => 'Work it out and write the result.';

  @override
  String printHelpLine(String language) {
    return 'In $language:';
  }

  @override
  String printHelpExample(String language) {
    return 'Example in $language:';
  }

  @override
  String printAnswersTitle(String unit) {
    return 'Answers · $unit';
  }

  @override
  String get printWordsTitle => 'Maths words';

  @override
  String printWordExample(String example) {
    return 'Example: $example';
  }

  @override
  String get printExercisesFileName => 'Exercises';

  @override
  String get printWordsFileName => 'Words';

  @override
  String get profileCreationTitle => 'New player';

  @override
  String get nicknameLabel => 'Your nickname';

  @override
  String get nicknameHint => 'Type your nickname';

  @override
  String nicknameRulesHint(int minLength, int maxLength) {
    String _temp0 = intl.Intl.pluralLogic(
      maxLength,
      locale: localeName,
      other: '$minLength to $maxLength letters or digits',
      one: '$minLength to $maxLength letter or digit',
    );
    return '$_temp0';
  }

  @override
  String nicknameTooShort(int minLength) {
    String _temp0 = intl.Intl.pluralLogic(
      minLength,
      locale: localeName,
      other: 'You need at least $minLength letters or digits.',
      one: 'You need at least $minLength letter or digit.',
    );
    return '$_temp0';
  }

  @override
  String nicknameTooLong(int maxLength) {
    String _temp0 = intl.Intl.pluralLogic(
      maxLength,
      locale: localeName,
      other: 'No more than $maxLength letters or digits.',
      one: 'No more than $maxLength letter or digit.',
    );
    return '$_temp0';
  }

  @override
  String get nicknameInvalidCharacters => 'Only letters, digits and spaces.';

  @override
  String get nicknameTaken => 'This name is already taken on this phone.';

  @override
  String get avatarPickerLabel => 'Choose your avatar';

  @override
  String avatarOptionLabel(int number) {
    return 'Avatar $number';
  }

  @override
  String get colorPickerLabel => 'Your color';

  @override
  String get profileColorViolet => 'Purple';

  @override
  String get profileColorGreen => 'Green';

  @override
  String get profileColorYellow => 'Yellow';

  @override
  String get profileColorRed => 'Red';

  @override
  String get profileColorBlue => 'Blue';

  @override
  String get profileColorPink => 'Pink';

  @override
  String get profileCreationReadAloudHint =>
      'A voice reads every question. You can change this later in the settings.';

  @override
  String get createProfileButton => 'Let\'s go!';

  @override
  String get commonCancel => 'Cancel';

  @override
  String profileStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get profileStreakLabel => 'in a row';

  @override
  String profileCrownsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'crowns',
      one: 'crown',
    );
    return '$_temp0';
  }

  @override
  String profileBadgesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'badges',
      one: 'badge',
    );
    return '$_temp0';
  }

  @override
  String get masteryGridTitle => 'My tables';

  @override
  String get masteryGridTitleNumbers => 'My numbers';

  @override
  String get masteryGridTitleDivision => 'My divisions';

  @override
  String get masteryGridTitleAddition => 'My + and −';

  @override
  String get masteryGridTitleAdditionSpoken => 'My additions and subtractions';

  @override
  String get masteryGridTitleMathWords => 'My words';

  @override
  String get masteryStatusNotSeen => 'New';

  @override
  String get masteryStatusToReview => 'To review';

  @override
  String get masteryStatusInProgress => 'In progress';

  @override
  String get masteryStatusAcquired => 'Learned';

  @override
  String get masteryStatusMastered => 'Mastered';

  @override
  String masteryCellSpoken(String fact, String status) {
    return '$fact, $status';
  }

  @override
  String get rewardBadgesTitle => 'My badges';

  @override
  String rewardBadgeEarnedSpoken(String name) {
    return '$name, earned';
  }

  @override
  String rewardBadgeLockedSpoken(String name, String hint) {
    return '$name, to earn: $hint';
  }

  @override
  String get pathMonstersTitle => 'My monsters';

  @override
  String pathMonstersCount(int defeated, int total) {
    return '$defeated of $total';
  }

  @override
  String pathMonsterDefeatedSpoken(int number) {
    return 'Monster of the $number times table, defeated';
  }

  @override
  String pathMonsterHiddenSpoken(int number) {
    return 'Monster of the $number times table, not defeated yet';
  }

  @override
  String pathUnitMonsterDefeatedSpoken(String unit) {
    return 'Monster of “$unit”, defeated';
  }

  @override
  String pathUnitMonsterHiddenSpoken(String unit) {
    return 'Monster of “$unit”, not defeated yet';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSoundSection => 'Sounds';

  @override
  String get settingsSound => 'Sounds';

  @override
  String get settingsVibration => 'Vibrations';

  @override
  String get settingsGameSection => 'Game';

  @override
  String get settingsTimer => 'Timer';

  @override
  String get settingsTimerNormal => 'Normal';

  @override
  String get settingsTimerRelaxed => 'Relaxed';

  @override
  String get settingsTimerOff => 'Off';

  @override
  String get settingsDailyGoal => 'Daily goal';

  @override
  String get settingsUnlockAll => 'Unlock everything';

  @override
  String get settingsReducedMotion => 'Reduced motion';

  @override
  String get settingsReadAloud => 'Read questions aloud';

  @override
  String get settingsHelpAudio => 'Audio help';

  @override
  String get helpAudioNone => 'None';

  @override
  String helpAudioLanguageName(String code) {
    String _temp0 = intl.Intl.selectLogic(
      code,
      {
        'wo': 'Wolof',
        'other': '$code',
      },
    );
    return '$_temp0';
  }

  @override
  String helpAudioListen(String language) {
    return 'Listen in $language';
  }

  @override
  String helpAudioListenExample(String language) {
    return 'Example in $language';
  }

  @override
  String get commonClose => 'Close';

  @override
  String get commonListen => 'Listen';

  @override
  String get commonListenStop => 'Stop reading';

  @override
  String get settingsBackupSection => 'Backup';

  @override
  String get backupExport => 'Export my profile';

  @override
  String get backupImport => 'Import a profile';

  @override
  String get backupExportDone =>
      'File ready! Open it in Kid Matix on the other phone, with “Import a profile”.';

  @override
  String backupImportDone(String nickname) {
    return '$nickname\'s profile imported! Find it with “Switch player”.';
  }

  @override
  String backupImportReplaced(String nickname) {
    return '$nickname\'s progress restored!';
  }

  @override
  String backupConflictTitle(String nickname) {
    return '$nickname already exists';
  }

  @override
  String backupConflictMessage(String nickname, int level) {
    return 'This phone already has a player called $nickname. The file has $nickname at level $level.\n\nReplace erases $nickname\'s current progress on this phone. Rename keeps both players.';
  }

  @override
  String get backupConflictReplace => 'Replace';

  @override
  String get backupConflictRename => 'Rename';

  @override
  String get backupRenameTitle => 'New nickname';

  @override
  String get backupRenameMessage =>
      'Choose another nickname for the imported player.';

  @override
  String get backupRenameConfirm => 'Import';

  @override
  String get errorBackupInvalid =>
      'This file isn\'t a Kid Matix backup, or it\'s damaged.';

  @override
  String get errorBackupVersion =>
      'This backup comes from a newer version of Kid Matix. Update the app, then try again.';

  @override
  String get parentalGateTitle => 'Ask a grown-up';

  @override
  String get parentalGateMessage =>
      'This is for grown-ups only. Type this number in digits:';

  @override
  String get parentalGateAnswerLabel => 'Number in digits';

  @override
  String get parentalGateConfirm => 'Confirm';

  @override
  String get settingsReminderSection => 'Reminder';

  @override
  String get settingsReminderDaily => 'Daily reminder';

  @override
  String get settingsReminderTime => 'Reminder time';

  @override
  String get settingsReminderPermissionDenied =>
      'Notifications are blocked. Allow them in the phone settings to get the reminder.';

  @override
  String get settingsReminderError => 'Oops, the reminder couldn\'t be set.';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsLanguageSystem => 'Phone language';

  @override
  String get languageNameFrench => 'Français';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageNameSpanish => 'Español';

  @override
  String get settingsLanguageError => 'Oops, the language couldn\'t be saved.';

  @override
  String get reminderNotificationBody => 'Time for your times tables!';

  @override
  String get reminderChannelName => 'Daily reminder';

  @override
  String get reminderChannelDescription =>
      'Reminds you to play every day at the time you chose.';

  @override
  String get settingsPlayerSection => 'This player';

  @override
  String get resetProgressButton => 'Reset my progress';

  @override
  String get resetProgressConfirm => 'Reset';

  @override
  String get resetProgressDone => 'Your progress is back to zero.';

  @override
  String settingsDailyGoalXp(int xp) {
    return '$xp XP';
  }

  @override
  String resetProgressTitle(String nickname) {
    return 'Reset $nickname?';
  }

  @override
  String resetProgressMessage(String nickname) {
    return 'Their stars, crowns, badges, XP and records will be erased. Their nickname, settings and mascot\'s name stay. To confirm, type their nickname: $nickname';
  }

  @override
  String get switchPlayerButton => 'Switch player';

  @override
  String get editProfileButton => 'Edit my profile';

  @override
  String get deleteProfileButton => 'Delete this player';

  @override
  String get profileEditTitle => 'Edit my profile';

  @override
  String get saveProfileButton => 'Save';

  @override
  String deleteProfileTitle(String nickname) {
    return 'Delete $nickname?';
  }

  @override
  String deleteProfileMessage(String nickname) {
    return 'All their progress will be erased. To confirm, type their nickname: $nickname';
  }

  @override
  String get deleteProfileConfirm => 'Delete';

  @override
  String get quizQuitTooltip => 'Leave the quiz';

  @override
  String quizProgressLabel(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get quizTimeLeftLabel => 'Time left';

  @override
  String quizMultiplicationUnit(int number) {
    return '$number times table';
  }

  @override
  String get quizTrueFalseLabel => 'True or false?';

  @override
  String get quizHintMultipleChoice => 'Tap the right answer';

  @override
  String get quizHintTrueFalse => 'Is this right?';

  @override
  String get quizFindOperationMultiplication => 'Which multiplication makes';

  @override
  String quizFindOperationSpokenMultiplication(int result) {
    return 'Which multiplication makes $result?';
  }

  @override
  String get quizCountLabel => 'How many mangoes?';

  @override
  String get quizBundlesLabel => 'What number is it?';

  @override
  String get quizNumberLineLabel => 'Which number is missing?';

  @override
  String get quizCompareLabel => 'Less, equal or greater?';

  @override
  String get quizMissingNumberLabel => 'Find the hidden number';

  @override
  String quizCompareSpoken(int first, int second) {
    return 'Is $first less than, equal to or greater than $second?';
  }

  @override
  String quizBundlesSpoken(int tens, int ones) {
    String _temp0 = intl.Intl.pluralLogic(
      tens,
      locale: localeName,
      other: '$tens bundles of ten',
      one: '1 bundle of ten',
      zero: 'No bundle of ten',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ones,
      locale: localeName,
      other: '$ones sticks',
      one: '1 stick',
      zero: 'no stick',
    );
    return '$_temp0 and $_temp1: what number is it?';
  }

  @override
  String quizNumberLineSpoken(String numbers) {
    return 'Number line: $numbers. Which number is missing?';
  }

  @override
  String get quizObjectsPictureLabel => 'Mangoes to count';

  @override
  String quizObjectsPictureCounted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mangoes',
      one: '1 mango',
    );
    return '$_temp0';
  }

  @override
  String quizBundlesPictureLabel(int tens, int ones) {
    String _temp0 = intl.Intl.pluralLogic(
      tens,
      locale: localeName,
      other: '$tens bundles of ten',
      one: '1 bundle of ten',
      zero: 'No bundle of ten',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ones,
      locale: localeName,
      other: '$ones sticks',
      one: '1 stick',
      zero: 'no stick',
    );
    return '$_temp0 and $_temp1';
  }

  @override
  String quizNumberLinePictureLabel(String numbers) {
    return 'Number line: $numbers';
  }

  @override
  String get quizHintFindOperation => 'Tap the right operation';

  @override
  String get quizHintCompare => 'Tap the right sign';

  @override
  String get quizHintWordListen => 'Tap the right picture';

  @override
  String get quizHintWordOperation => 'Tap the operation';

  @override
  String get quizWordListenLabel => 'Listen and tap';

  @override
  String get quizWordTouchLabel => 'Tap to understand';

  @override
  String get quizWordOperationLabel => 'Which operation?';

  @override
  String get quizWordMatchTitle => 'Match each word with its picture';

  @override
  String get quizWordMatchHintStart => 'Tap a word, then its picture';

  @override
  String quizWordMatchHintPicture(String word) {
    return 'Tap the picture of “$word”';
  }

  @override
  String get quizWordMatchHintWord =>
      'Tap the word that goes with this picture';

  @override
  String get quizWordUnderstood => 'I understand';

  @override
  String get quizWordTouchFirst => 'Tap the colored word';

  @override
  String get quizBarModelLabel => 'Bar model of the story';

  @override
  String quizBarRoleName(String role) {
    String _temp0 = intl.Intl.selectLogic(
      role,
      {
        'whole': 'the whole',
        'partA': 'a part',
        'partB': 'the other part',
        'big': 'the biggest',
        'small': 'the smallest',
        'gap': 'the gap',
        'total': 'the total',
        'groups': 'how many groups',
        'each': 'in each group',
        'times': 'how many times',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String quizBarSlotEmpty(String name) {
    return '$name: to fill in';
  }

  @override
  String quizBarSlotUnknown(String name) {
    return '$name: to find';
  }

  @override
  String quizBarSlotValue(String name, String value) {
    return '$name: $value';
  }

  @override
  String get quizProblemSolveLabel => 'Solve the problem';

  @override
  String get quizBarModelQuestionLabel => 'Draw the model';

  @override
  String quizProblemStepCounter(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get quizProblemStepListen =>
      'Listen to the story and touch the colored words';

  @override
  String get quizProblemStepModel =>
      'Put the numbers of the story on the model';

  @override
  String get quizProblemStepOperation => 'Which operation finds the answer?';

  @override
  String get quizProblemStepCompute => 'Work out the answer';

  @override
  String get quizProblemStepCheck => 'Check your answer';

  @override
  String get quizProblemListened => 'I listened';

  @override
  String get quizProblemChecked => 'I checked';

  @override
  String get quizProblemPickNumberFirst =>
      'Touch a number, then its place on the model';

  @override
  String get quizProblemTryAgain =>
      'Not there. Read the story again and look at the model.';

  @override
  String get quizProblemRecapTitle => 'The model of the story';

  @override
  String get quizCompareLess => 'less';

  @override
  String get quizCompareEqual => 'equal';

  @override
  String get quizCompareGreater => 'greater';

  @override
  String get quizMatchPairsTitle => 'Match each operation with its answer';

  @override
  String quizMatchPairsProgress(int count, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count of $total pairs found',
      one: '1 of $total pairs found',
      zero: '0 of $total pairs found',
    );
    return '$_temp0';
  }

  @override
  String get quizMatchPairsHintStart => 'Tap an operation, then its answer';

  @override
  String quizMatchPairsHintResult(String operation) {
    return 'Now tap the answer to $operation';
  }

  @override
  String quizMatchPairsHintOperation(String result) {
    return 'Now tap the operation that makes $result';
  }

  @override
  String quizMatchPairsFound(String label) {
    return '$label, pair found';
  }

  @override
  String get quizTrue => 'True';

  @override
  String get quizFalse => 'False';

  @override
  String get quizKeypadErase => 'Erase';

  @override
  String get quizKeypadValidate => 'OK';

  @override
  String get quizFeedbackRight => 'Great job!';

  @override
  String get quizFeedbackWrong => 'Almost!';

  @override
  String get quizFeedbackTimeUp => 'Time\'s up!';

  @override
  String get quizLightning => 'Lightning!';

  @override
  String quizMirrorReminder(String fact) {
    return 'Also remember: $fact';
  }

  @override
  String quizHelpTitle(String unit) {
    return 'Help card · $unit';
  }

  @override
  String quizHelpDotGridLabel(int rows, int columns) {
    String _temp0 = intl.Intl.pluralLogic(
      rows,
      locale: localeName,
      other: '$rows rows',
      one: '1 row',
    );
    String _temp1 = intl.Intl.pluralLogic(
      columns,
      locale: localeName,
      other: '$columns dots',
      one: '1 dot',
    );
    return '$_temp0 of $_temp1';
  }

  @override
  String quizHelpDotGridSharingLabel(int total, int groups, int each) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total dots shared',
      one: '1 dot shared',
    );
    String _temp1 = intl.Intl.pluralLogic(
      groups,
      locale: localeName,
      other: '$groups groups',
      one: '1 group',
    );
    return '$_temp0 into $_temp1: $each in each group';
  }

  @override
  String get quizContinue => 'Continue';

  @override
  String get quizQuitTitle => 'Leave the quiz?';

  @override
  String get quizQuitMessage =>
      'Your answers still count toward your progress, but this game won\'t give you a reward.';

  @override
  String get quizQuitConfirm => 'Leave';

  @override
  String get quizQuitCancel => 'Keep playing';

  @override
  String get quizSpokenTimes => 'times';

  @override
  String get quizSpokenEquals => 'equals';

  @override
  String get quizSpokenBlank => 'what';

  @override
  String quizSpokenTrueFalse(String statement) {
    return '$statement. True or false?';
  }

  @override
  String get quizSpokenPlus => 'plus';

  @override
  String get quizSpokenDividedBy => 'divided by';

  @override
  String get quizSpokenMinus => 'minus';

  @override
  String get quizSpokenLessThan => 'is less than';

  @override
  String get quizSpokenGreaterThan => 'is greater than';

  @override
  String get quizSpokenEqualTo => 'is equal to';

  @override
  String get quizSpokenHiddenNumber => 'hidden number';

  @override
  String get quizModePath => 'Path';

  @override
  String get quizModeFreeTraining => 'Free Practice';

  @override
  String get quizModeTimeAttack => 'Beat the Clock';

  @override
  String get quizModeSurvival => 'Survival';

  @override
  String quizLivesSpoken(int left, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: '$left lives out of $total',
      one: '1 life out of $total',
      zero: 'No lives left',
    );
    return '$_temp0';
  }

  @override
  String get quizModeDailyReview => 'Daily Review';

  @override
  String get quizModeMonsterHunt => 'Monster Hunt';

  @override
  String get quizModeAssessment => 'Assessment';

  @override
  String quizScoreSpoken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count right answers',
      one: '1 right answer',
      zero: 'No right answers',
    );
    return '$_temp0';
  }

  @override
  String quizClockLeftSpoken(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds seconds left',
      one: '1 second left',
      zero: 'No time left',
    );
    return '$_temp0';
  }

  @override
  String get resultsTitle => 'All done!';

  @override
  String resultsSubtitle(String unit, String mode) {
    return '$unit · $mode';
  }

  @override
  String resultsCorrectCount(int correct, int total) {
    return '$correct / $total';
  }

  @override
  String resultsCorrectLabel(int correct) {
    String _temp0 = intl.Intl.pluralLogic(
      correct,
      locale: localeName,
      other: 'correct',
      one: 'correct',
    );
    return '$_temp0';
  }

  @override
  String resultsAverageTime(double seconds) {
    final intl.NumberFormat secondsNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 1,
        );
    final String secondsString = secondsNumberFormat.format(seconds);

    return '$secondsString s';
  }

  @override
  String get resultsAverageTimeLabel => 'on average';

  @override
  String get resultsToReview => 'To review';

  @override
  String get resultsNothingToReview => 'No mistakes, well done!';

  @override
  String get resultsContinue => 'Continue';

  @override
  String get resultsReplay => 'Play again';

  @override
  String get pathStageDiscovery => 'Discovery';

  @override
  String get pathStageDiscoveryHint => 'The table and its tip';

  @override
  String get pathStageTraining => 'Practice';

  @override
  String get pathStageTrainingHint => '10 mixed-up questions';

  @override
  String get pathStageWriting => 'Writing';

  @override
  String get pathStageWritingHint => 'Write the answer yourself';

  @override
  String get pathStageSpeed => 'Speed';

  @override
  String get pathStageSpeedHint => '10 seconds per question';

  @override
  String get pathStageBoss => 'Boss fight';

  @override
  String get pathStageBossHint => 'Beat the table\'s monster';

  @override
  String get pathStageReview => 'Review';

  @override
  String get pathStageReviewHint => '15 questions on the tables you\'ve seen';

  @override
  String get pathUnitStageDiscoveryHint => 'The lesson and its tip';

  @override
  String get pathUnitStageBossHint => 'Beat the lesson\'s monster';

  @override
  String get pathUnitStageReviewHint =>
      '15 questions on the lessons you\'ve seen';

  @override
  String pathStageNumbered(int number, String name) {
    return '$number · $name';
  }

  @override
  String pathCurrentStage(int number, int total, String name) {
    return 'Stage $number of $total · $name';
  }

  @override
  String get pathPlay => 'Play';

  @override
  String get pathShowTable => 'See the table';

  @override
  String get pathShowUnit => 'See the lesson';

  @override
  String pathTableStars(int stars, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      stars,
      locale: localeName,
      other: '$stars stars out of $total',
      one: '1 star out of $total',
      zero: '0 stars out of $total',
    );
    return '$_temp0';
  }

  @override
  String get pathCrownHint => 'Beat the boss to win the crown.';

  @override
  String get placementOfferTitle => 'Let\'s see where you are!';

  @override
  String get placementOfferMessage =>
      'Answer a few questions, no timer. You stop when it gets hard and your path starts in the right place.';

  @override
  String get placementOfferStart => 'Take the test';

  @override
  String get placementOfferSkip => 'Skip';

  @override
  String placementQuestionProgress(int current) {
    return 'Question $current';
  }

  @override
  String get placementUnknownAnswer => 'I don\'t know';

  @override
  String get placementQuitTooltip => 'Stop the test';

  @override
  String get placementQuitTitle => 'Stop the test?';

  @override
  String get placementQuitMessage =>
      'The units you already found stay open in your path.';

  @override
  String get placementQuitCancel => 'Keep going';

  @override
  String get placementQuitConfirm => 'Stop';

  @override
  String placementResultTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count levels passed!',
      one: '1 level passed!',
      zero: 'Your adventure begins!',
    );
    return '$_temp0';
  }

  @override
  String placementResultSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'What you already know is open in your path. You can still win the stars.',
      zero: 'No worries, you\'ll learn one step at a time.',
    );
    return '$_temp0';
  }

  @override
  String get placementSkillNumbers => 'Numbers';

  @override
  String get placementSkillAddition => 'Addition';

  @override
  String get placementSkillSubtraction => 'Subtraction';

  @override
  String get placementSkillMultiplication => 'Multiplication';

  @override
  String get placementSkillDivision => 'Division';

  @override
  String get placementSkillAcquired => 'Got it';

  @override
  String get placementSkillToDiscover => 'To discover';

  @override
  String placementSkillSemantics(String skill, String state) {
    return '$skill, $state';
  }

  @override
  String get placementResultStartLabel => 'You start with';

  @override
  String get placementResultAllDone =>
      'You know everything the test asks. Well done!';

  @override
  String get placementSeePath => 'See my path';

  @override
  String get placementCardTitle => 'My starting level';

  @override
  String get placementCardEmpty => 'You have not taken the level test yet.';

  @override
  String placementCardLatest(String date) {
    return 'Test of $date';
  }

  @override
  String placementCardLevelSemantics(String domain, String level) {
    return '$domain, $level';
  }

  @override
  String get placementCardNotChecked => 'not checked';

  @override
  String placementCardLevel(int level, int total) {
    return 'level $level of $total';
  }

  @override
  String placementCardPast(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count levels',
      one: '1 level',
      zero: 'no level',
    );
    return '$date: $_temp0';
  }

  @override
  String get placementCardRetake => 'Take the test again';

  @override
  String get pathTableBack => 'Back to the path';

  @override
  String pathTableNodeDone(String name, int stars) {
    String _temp0 = intl.Intl.pluralLogic(
      stars,
      locale: localeName,
      other: '$stars stars',
      one: '1 star',
      zero: 'no stars',
    );
    return '$name, done, $_temp0';
  }

  @override
  String pathTableNodeCurrent(String name) {
    return '$name, in progress';
  }

  @override
  String pathTableNodeOpen(String name) {
    return '$name, open';
  }

  @override
  String pathTableNodeLocked(String name) {
    return '$name, locked';
  }

  @override
  String pathReviewNodeLocked(String name) {
    return '$name, locked';
  }

  @override
  String get pathLocked => 'Locked';

  @override
  String starsLabel(int stars, int max) {
    String _temp0 = intl.Intl.pluralLogic(
      stars,
      locale: localeName,
      other: '$stars stars out of $max',
      one: '1 star out of $max',
      zero: 'No stars out of $max',
    );
    return '$_temp0';
  }

  @override
  String pathDiscoveryTitle(int number) {
    return 'Here is the $number times table';
  }

  @override
  String get pathDiscoveryProgress => 'Before the first question';

  @override
  String get pathTipTitle => 'The tip';

  @override
  String get pathDiscoveryStart => 'My turn to play';

  @override
  String pathMultiplicationTip(String table) {
    String _temp0 = intl.Intl.selectLogic(
      table,
      {
        '1': 'Multiplying by 1 changes nothing: 1 × 7 = 7.',
        '2': 'Multiplying by 2 means adding the number to itself: 2 × 6 = 6 + 6.',
        '3': 'The answers go up by 3 each time: 3, 6, 9, 12…',
        '4': 'Multiplying by 4 means doubling twice: 4 × 6 is double 12.',
        '5': 'The answers in the 5 times table always end in 0 or 5.',
        '6': '6 times an even number ends with that same digit: 6 × 4 = 24.',
        '7': 'For 7 × 8, think 5, 6, 7, 8: 56 = 7 × 8.',
        '8': 'Multiplying by 8 means doubling three times: 8 × 3 = 24.',
        '9': 'The two digits of the answer always add up to 9: 9 × 4 = 36 and 3 + 6 = 9.',
        '10': 'Multiplying by 10 means adding a 0 on the right: 10 × 7 = 70.',
        '11': 'Up to 11 × 9, you write the digit twice: 11 × 4 = 44.',
        'other': '12 times a number is 10 times plus 2 times: 12 × 3 = 30 + 6.',
      },
    );
    return '$_temp0';
  }

  @override
  String numbersUnitName(String unit) {
    String _temp0 = intl.Intl.selectLogic(
      unit,
      {
        'count10': 'Count to 10',
        'count20': 'Count to 20',
        'count100': 'Count to 100',
        'tensones': 'Tens and ones',
        'compare': 'Compare',
        'order': 'Put in order',
        'beforeafter': 'Before and after',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String numbersUnitTip(String unit) {
    String _temp0 = intl.Intl.selectLogic(
      unit,
      {
        'count10': 'Touch each mango as you count: one, two, three… The last number tells how many there are.',
        'count20': 'First count the row of 10, then keep going: 11, 12, 13…',
        'count100':
            'A bundle is 10 sticks. Count the bundles in tens: 10, 20, 30…',
        'tensones': 'The tens digit counts the bundles, the ones digit the loose sticks: 3 bundles and 4 sticks make 34.',
        'compare': 'Look at the tens first: the number with more tens is greater. If the tens are the same, look at the ones.',
        'order': 'On the line, numbers go from smallest to greatest. Find how much they go up each time.',
        'beforeafter': 'The number after is 1 more; the number before is 1 less. After 39 comes 40!',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String divisionUnitName(int number) {
    return 'Divide by $number';
  }

  @override
  String divisionUnitTip(String unit) {
    String _temp0 = intl.Intl.selectLogic(
      unit,
      {
        '1': 'Dividing by 1 changes nothing: 7 ÷ 1 = 7.',
        '2': 'Dividing by 2 means sharing into two equal parts: 12 ÷ 2 = 6, half of 12.',
        '3': 'Dividing by 3 means making 3 equal parts: 12 ÷ 3 = 4, because 3 × 4 = 12.',
        '4': 'Dividing by 4 means halving twice: 20 ÷ 4 = 5, because half of 20 is 10 and half of 10 is 5.',
        '5': 'For 35 ÷ 5, count by 5s up to 35: 5, 10, 15, 20, 25, 30, 35. That is 7 jumps, so 35 ÷ 5 = 7.',
        '6':
            'For 42 ÷ 6, look in the 6 times table: 6 × 7 = 42, so 42 ÷ 6 = 7.',
        '7': 'For 56 ÷ 7, think of 7 × 8 = 56: so 56 ÷ 7 = 8.',
        '8': 'Dividing by 8 means halving three times: for 48 ÷ 8, 48 → 24 → 12 → 6.',
        '9': 'In the 9 times table, the digits add up to 9 (36: 3 + 6 = 9). And 36 ÷ 9 = 4, because 9 × 4 = 36.',
        '10': 'Dividing by 10 means removing the 0 on the right: 70 ÷ 10 = 7.',
        '11': 'Up to 99 ÷ 11, the numbers in the 11 times table have two identical digits: 77 ÷ 11 = 7.',
        '12': 'For 36 ÷ 12, count by 12s: 12, 24, 36. That is 3 jumps, so 36 ÷ 12 = 3.',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String additionUnitName(String unit) {
    String _temp0 = intl.Intl.selectLogic(
      unit,
      {
        'add5': 'Additions up to 5',
        'sub5': 'Subtractions up to 5',
        'add7': 'Additions up to 7',
        'add9': 'Additions up to 9',
        'toten': 'Complete to 10',
        'sub7': 'Subtractions up to 7',
        'sub9': 'Subtractions up to 9',
        'subten': 'Subtractions from 10',
        'add12': 'Additions up to 12',
        'add14': 'Additions up to 14',
        'add20': 'Additions up to 20',
        'sub12': 'Subtractions up to 12',
        'sub14': 'Subtractions up to 14',
        'sub20': 'Subtractions up to 20',
        'add100': 'Additions without carrying',
        'sub100': 'Subtractions without borrowing',
        'carry': 'Additions with carrying',
        'borrow': 'Subtractions with borrowing',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String additionUnitTip(String unit) {
    String _temp0 = intl.Intl.selectLogic(
      unit,
      {
        'add5': 'To add, move along the line: 2 + 3? Start at 2 and go up 3: 3, 4, 5!',
        'sub5': 'To subtract is to take away. 5 − 2? Start at 5 and go back 2: 4, 3!',
        'add7': 'To add, start from the bigger number and count up the smaller one. 2 + 5? Start at 5 and go up 2: 6, 7!',
        'add9': 'Think of doubles: 4 + 4 = 8, so 4 + 5 = 9.',
        'toten': 'Find what is missing to reach 10. 7 needs 3, because 7 + 3 = 10. Count on your fingers if you like!',
        'sub7': 'To subtract is to take away. 7 − 3? Start at 7 and go back 3: 6, 5, 4. Or ask: 3 plus what makes 7?',
        'sub9': 'For 9 − 4, find what to add to 4 to make 9: 4 + 5 = 9, so 9 − 4 = 5.',
        'subten':
            'For 10 − 3, think of the complement: 3 + 7 = 10, so 10 − 3 = 7.',
        'add12': 'For 9 + 2, first go up to 10: 9 + 1 = 10. There is 1 left to add: 10 + 1 = 11.',
        'add14': 'For 8 + 5, first go up to 10: 8 + 2 = 10. There are 3 left to add: 10 + 3 = 13.',
        'add20': 'For 7 + 8, first go up to 10: 7 + 3 = 10. There are 5 left to add: 10 + 5 = 15.',
        'sub12': 'For 12 − 4, first take away 2 to reach 10, then 2 more: 12 − 2 = 10, then 10 − 2 = 8.',
        'sub14': 'For 13 − 6, first take away 3 to reach 10, then 3 more: 13 − 3 = 10, then 10 − 3 = 7.',
        'sub20': 'For 15 − 7, first take away 5 to reach 10, then 2 more: 15 − 5 = 10, then 10 − 2 = 8.',
        'add100': 'Add the ones, then the tens. For 23 + 14: 3 + 4 = 7 and 20 + 10 = 30, so 37.',
        'sub100': 'Subtract the ones, then the tens. For 47 − 23: 7 − 3 = 4 and 40 − 20 = 20, so 24.',
        'carry': 'When the ones make 10 or more, you carry one ten. For 27 + 15, 7 + 5 = 12: write 2 and carry 1 ten. 20 + 10 + 10 = 40, and 40 + 2 = 42.',
        'borrow': 'If you cannot take away the ones, break a ten. For 42 − 17: 42 becomes 30 and 12. 12 − 7 = 5 and 30 − 10 = 20, so 25.',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String mathWordsUnitName(String unit) {
    String _temp0 = intl.Intl.selectLogic(
      unit,
      {
        'add': 'Add',
        'remove': 'Take away',
        'compare': 'Compare',
        'group': 'Group',
        'share': 'Share',
        'ask': 'The questions',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String mathWordsUnitTip(String unit) {
    String _temp0 = intl.Intl.selectLogic(
      unit,
      {
        'add': 'When we add, we have more than before. Listen for “en plus”, “en tout”, “ensemble”: they say we put things together.',
        'remove': 'When we take away, there is less left. The words “il reste”, “vendre”, “perdre” say the amount goes down.',
        'compare': 'To compare, look at two amounts: one is bigger, the other smaller, or they are equal.',
        'group': 'Packs of the same size are equal groups. The words “dans chaque” and “par paquets de” announce them.',
        'share': 'To share is to make equal parts: everyone gets as much as the others.',
        'ask': 'These words say what we look for (“combien”, “le total”) or when it happens (“au départ”, “à la fin”).',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get problemsDomainName => 'Problems';

  @override
  String get masteryGridTitleProblems => 'My problems';

  @override
  String problemsUnitName(String operation, String level) {
    String _temp0 = intl.Intl.selectLogic(
      operation,
      {
        'add': 'Add',
        'subtract': 'Take away',
        'multiply': 'Group',
        'divide': 'Share',
        'trap': 'The traps',
        'other': '',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      level,
      {
        '1': 'with pictures',
        '2': 'short sentences',
        '3': 'full statements',
        'other': '',
      },
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String problemsUnitTip(String operation) {
    String _temp0 = intl.Intl.selectLogic(
      operation,
      {
        'add': 'When we put quantities together, we have more than before. Draw the whole and its parts.',
        'subtract': 'When we take away, less is left. Draw the whole, the part that goes and the part that stays.',
        'multiply': 'Equal groups: draw the groups, all the same size, and find the total.',
        'divide': 'Sharing into equal parts, or finding how many parts: draw the whole cut into parts.',
        'trap': 'Careful: a word in the story can fool you. Draw the model to see what really happens.',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get resultsStageTitle => 'Stage complete!';

  @override
  String pathTableNodeCrowned(String label, String crown) {
    String _temp0 = intl.Intl.selectLogic(
      crown,
      {
        'golden': 'golden crown',
        'other': 'crown',
      },
    );
    return '$label, $_temp0';
  }

  @override
  String quizBossTitleMultiplication(int number) {
    return 'Boss of the $number times table';
  }

  @override
  String quizBossTitleUnit(String unit) {
    return 'Boss · $unit';
  }

  @override
  String get quizBossLife => 'Boss life';

  @override
  String quizBossLifeValue(int left, int total) {
    return '$left / $total';
  }

  @override
  String quizBossLifeSpoken(int left, int total) {
    return 'Boss life: $left out of $total';
  }

  @override
  String quizBossHit(int damage) {
    return 'Hit!\n−$damage';
  }

  @override
  String quizBossCriticalHit(int damage) {
    return 'Critical hit!\n−$damage';
  }

  @override
  String get quizBossStrikeBack => 'Strike back!';

  @override
  String get quizBossDefeated => 'Defeated!';

  @override
  String get quizBossFled => 'It\'s running away!';

  @override
  String get resultsBossDefeated => 'Boss defeated!';

  @override
  String get resultsBossFled => 'The monster ran away';

  @override
  String rewardXpEarned(int xp) {
    return '+$xp';
  }

  @override
  String get rewardXpEarnedLabel => 'XP earned';

  @override
  String rewardXpEarnedInline(int xp) {
    return '+$xp XP';
  }

  @override
  String rewardLevel(int level) {
    return 'Level $level';
  }

  @override
  String rewardXpToNextLevel(int xp, int next) {
    return '$xp more XP to level $next';
  }

  @override
  String rewardLevelProgressSpoken(int next) {
    return 'Progress toward level $next';
  }

  @override
  String rewardNewBadgesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'New badges',
      one: 'New badge',
    );
    return '$_temp0';
  }

  @override
  String get rewardBadgeFirstStep => 'First Step';

  @override
  String get rewardBadgePerfect => 'Flawless';

  @override
  String get rewardBadgeLightning => 'Lightning';

  @override
  String get rewardBadgeSprinter => 'Sprinter';

  @override
  String get rewardBadgeSurvivor => 'Survivor';

  @override
  String get rewardBadgeRegular => 'Steady';

  @override
  String rewardBadgeTamerMultiplication(int number) {
    return 'Tamer of the $number times table';
  }

  @override
  String rewardBadgeTamerUnit(String unit) {
    return 'Tamer of “$unit”';
  }

  @override
  String get rewardBadgeAllFacts => 'All 120';

  @override
  String get rewardBadgeFirstStepHint => 'You finished your first stage.';

  @override
  String get rewardBadgePerfectHint => 'A stage without a single mistake.';

  @override
  String get rewardBadgeLightningHint => '20 lightning answers in all.';

  @override
  String get rewardBadgeSprinterHint => '20 right answers in Beat the Clock.';

  @override
  String get rewardBadgeSurvivorHint => '30 right answers in Survival.';

  @override
  String get rewardBadgeRegularHint => '7 days of play in a row.';

  @override
  String get rewardBadgeTamerHint => 'You beat the boss of this table.';

  @override
  String get rewardBadgeAllFactsHint =>
      'You\'ve mastered every multiplication.';

  @override
  String rewardLevelUpTitle(int level) {
    return 'Level $level!';
  }

  @override
  String get rewardLevelUpHint => 'You moved up a level, well done.';

  @override
  String get rewardBadgeUnlocked => 'New badge!';

  @override
  String get rewardTapToContinue => 'Tap the screen to continue';

  @override
  String rewardStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get rewardNoStreak => 'No streak';

  @override
  String rewardStreakSpoken(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days-day streak',
      one: '1-day streak',
      zero: 'No streak',
    );
    return '$_temp0';
  }

  @override
  String get rewardDailyGoalTitle => 'Daily goal';

  @override
  String rewardDailyGoalValue(int earned, int goal) {
    return '$earned / $goal XP';
  }

  @override
  String rewardDailyGoalSpoken(int earned, int goal) {
    return 'Daily goal: $earned out of $goal XP';
  }

  @override
  String pathCrownsSpoken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count crowns',
      one: '1 crown',
      zero: 'No crowns',
    );
    return '$_temp0';
  }

  @override
  String quizComboSpoken(int count) {
    return 'Combo of $count';
  }

  @override
  String quizComboMilestone(int count) {
    return 'Combo of $count!';
  }

  @override
  String mascotGoalReminder(int xp) {
    return '$xp more XP to reach your daily goal!';
  }

  @override
  String get mascotGoalReached => 'Daily goal reached, well done!';

  @override
  String get mascotEncouragement => 'No worries, you\'ll get there!';

  @override
  String mascotComboCheer(int count) {
    return 'Well done, $count in a row!';
  }

  @override
  String get mascotCardTitle => 'Your mascot is growing';

  @override
  String mascotCardStage(int stage, int total, int level) {
    return 'Stage $stage of $total · next at level $level';
  }

  @override
  String mascotCardLastStage(int stage, int total) {
    return 'Stage $stage of $total · fully grown';
  }

  @override
  String mascotGrewTitle(String name) {
    return '$name grew!';
  }

  @override
  String mascotGrewHint(int stage, int total) {
    return 'Stage $stage of $total';
  }

  @override
  String get mascotPageTitle => 'My mascot';

  @override
  String get mascotOpenTooltip => 'See my mascot';

  @override
  String get mascotNameLabel => 'Its name';

  @override
  String get mascotRename => 'Change name';

  @override
  String get mascotAccessoriesTitle => 'Accessories';

  @override
  String get mascotSlotHead => 'Head';

  @override
  String get mascotSlotEyes => 'Eyes';

  @override
  String get mascotSlotNeck => 'Neck';

  @override
  String get mascotSlotBack => 'Back';

  @override
  String get mascotAccessoryCap => 'Cap';

  @override
  String get mascotAccessoryRoundGlasses => 'Round glasses';

  @override
  String get mascotAccessoryCape => 'Cape';

  @override
  String get mascotAccessoryBowTie => 'Bow tie';

  @override
  String get mascotAccessoryScarf => 'Scarf';

  @override
  String get mascotAccessoryWizardHat => 'Wizard hat';

  @override
  String get mascotAccessorySunglasses => 'Sunglasses';

  @override
  String get mascotAccessoryBackpack => 'Backpack';

  @override
  String get mascotAccessoryHeadphones => 'Headphones';

  @override
  String get mascotAccessoryMedal => 'Medal';

  @override
  String get mascotAccessoryWings => 'Wings';

  @override
  String get mascotAccessoryKingCrown => 'King\'s crown';

  @override
  String get mascotAccessoryPartyHat => 'Party hat';

  @override
  String get mascotAccessoryLightningGoggles => 'Lightning goggles';

  @override
  String get mascotAccessoryGoldenCape => 'Golden cape';

  @override
  String mascotUnlockCrown(int rank) {
    String _temp0 = intl.Intl.pluralLogic(
      rank,
      locale: localeName,
      other: 'With $rank crowns',
      one: 'With 1 crown',
    );
    return '$_temp0';
  }

  @override
  String get mascotUnlockRegular => 'With the Steady badge';

  @override
  String get mascotUnlockLightning => 'With the Lightning badge';

  @override
  String get mascotUnlockAllFacts => 'With the All 120 badge';

  @override
  String mascotAccessoryWorn(String name) {
    return '$name, on your mascot';
  }

  @override
  String mascotAccessoryLocked(String name, String hint) {
    return '$name, locked. $hint';
  }

  @override
  String get trainingTitle => 'Practice';

  @override
  String get trainingSubtitle => 'Pick one or more tables.';

  @override
  String get trainingQuestionCountTitle => 'How many questions?';

  @override
  String get trainingTimerTitle => 'Timer';

  @override
  String get trainingWithTimer => 'With timer';

  @override
  String get trainingWithoutTimer => 'No timer';

  @override
  String get trainingNoTable => 'Pick at least one table';

  @override
  String get trainingLaunch => 'Start';

  @override
  String get challengesTitle => 'Challenges';

  @override
  String get challengeTimeAttackSubtitle =>
      '60 seconds, as many answers as you can';

  @override
  String get challengeSurvivalSubtitle => '3 lives, faster and faster';

  @override
  String get challengeSurvivalTimerNote => 'Here, the timer stays on.';

  @override
  String challengeDailyReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions picked for you',
      one: '1 question picked for you',
    );
    return '$_temp0';
  }

  @override
  String challengeDailyReviewDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count to review',
    );
    return '$_temp0';
  }

  @override
  String get challengeDailyReviewLocked => 'Play a stage of the path first';

  @override
  String get resultsNewRecord => 'New record!';

  @override
  String get resultsFirstRecord => 'Your first record';

  @override
  String trainingSummary(int tables, int questions) {
    String _temp0 = intl.Intl.pluralLogic(
      tables,
      locale: localeName,
      other: '$tables tables',
      one: '1 table',
    );
    return '$_temp0 · $questions questions';
  }

  @override
  String challengeRecord(int score) {
    return 'Best $score';
  }

  @override
  String resultsRecordBeaten(int previous) {
    return 'Previous best: $previous';
  }

  @override
  String resultsRecordScore(int score) {
    String _temp0 = intl.Intl.pluralLogic(
      score,
      locale: localeName,
      other: '$score right answers',
      one: '1 right answer',
    );
    return '$_temp0';
  }

  @override
  String challengeMonsterHuntSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count monsters to tame',
      one: '1 monster to tame',
      zero: 'No monsters for now',
    );
    return '$_temp0';
  }

  @override
  String get duelTitle => 'Duel';

  @override
  String get challengeDuelSubtitle => '2 players, 1 phone';

  @override
  String get challengeCodeCardTitle => 'I have a code';

  @override
  String get challengeCodeCardSubtitle => 'Replay a friend\'s challenge';

  @override
  String get challengeShareButton => 'Challenge a friend';

  @override
  String get challengeCodeToBeat => 'to beat';

  @override
  String get challengeCodeYours => 'Your challenge code';

  @override
  String challengeCodeSemantics(String characters) {
    return 'Challenge code: $characters';
  }

  @override
  String get challengeCodeCopy => 'Copy the code';

  @override
  String get challengeCodeCopied => 'Code copied!';

  @override
  String get challengeCodeShareHint =>
      'Give this code to a friend: same mode, same tables, and your score to beat!';

  @override
  String get challengeCodeOr => 'or';

  @override
  String get challengeCodeEntryTitle => 'Did you get a code?';

  @override
  String get challengeCodeEntryHint => 'TYPE THE CODE HERE';

  @override
  String get challengeCodePlay => 'Play this challenge';

  @override
  String get challengeCodeErrorMalformed =>
      'This code doesn\'t exist. A code has 10 letters and digits.';

  @override
  String get challengeCodeErrorAltered =>
      'A letter or a digit is wrong. Check the code with your friend.';

  @override
  String get challengeCodeErrorVersion =>
      'This challenge comes from a newer version of the app. Update the app to play it.';

  @override
  String get challengeCodeTablesAll => 'all tables';

  @override
  String challengeCodeTablesOne(int table) {
    return '$table times table';
  }

  @override
  String challengeCodeTableItem(int table) {
    return '$table';
  }

  @override
  String challengeCodeTablesMany(String first, String last) {
    return '$first and $last times tables';
  }

  @override
  String get challengeCodeCardTablesAll => 'All tables';

  @override
  String challengeCodeCardTablesOne(int table) {
    return '$table times table';
  }

  @override
  String challengeCodeCardTablesMany(String first, String last) {
    return '$first and $last times tables';
  }

  @override
  String challengeCodeSubtitle(String mode, String tables) {
    return '$mode · $tables';
  }

  @override
  String get challengeOutcomeWon => 'Challenge won!';

  @override
  String get challengeOutcomeLost => 'Not this time!';

  @override
  String get challengeOutcomeTie => 'It\'s a tie!';

  @override
  String get challengeOutcomeToBeat => 'Score to beat';

  @override
  String get challengeOutcomeYours => 'Your score';

  @override
  String challengeOutcomeCorrect(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'right answers',
      one: 'right answer',
      zero: 'right answers',
    );
    return '$_temp0';
  }

  @override
  String challengeOutcomeMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more right answers',
      one: '1 more right answer',
    );
    return '$_temp0';
  }

  @override
  String challengeOutcomeFewer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fewer right answers',
      one: '1 fewer right answer',
    );
    return '$_temp0';
  }

  @override
  String get challengeOutcomeSame => 'Same number of right answers';

  @override
  String get challengeOutcomeResend => 'Challenge back';

  @override
  String get challengeOutcomeBack => 'Back to challenges';

  @override
  String get duelPickIntro =>
      'Lay the phone flat between you. The top player reads upside down.';

  @override
  String get duelSideTop => 'Top player';

  @override
  String get duelSideBottom => 'Bottom player';

  @override
  String get duelGuest => 'Guest';

  @override
  String get duelGuestRule => 'All tables, no XP';

  @override
  String get duelPickHint => 'Pick two different players.';

  @override
  String get duelStart => 'Let\'s go!';

  @override
  String get duelPlayerTaken => 'Already picked';

  @override
  String duelScore(int score, int target) {
    return '$score / $target';
  }

  @override
  String duelScoreSpoken(String name, int score, int target) {
    String _temp0 = intl.Intl.pluralLogic(
      score,
      locale: localeName,
      other: '$score right answers',
      one: '1 right answer',
      zero: 'no right answers',
    );
    return '$name: $_temp0 out of $target';
  }

  @override
  String get duelPause => 'Pause the duel';

  @override
  String get duelPauseTitle => 'Duel paused';

  @override
  String get duelPauseMessage => 'If you stop now, nobody earns XP.';

  @override
  String get duelResume => 'Resume';

  @override
  String get duelStop => 'Stop the duel';

  @override
  String get duelBlocked => 'Oops! Wait a moment…';

  @override
  String duelAnswerRight(int answer) {
    return '$answer, right answer';
  }

  @override
  String duelAnswerWrong(int answer) {
    return '$answer, wrong answer';
  }

  @override
  String duelWinner(String name) {
    return '$name wins!';
  }

  @override
  String duelXpEarned(int xp) {
    return '+$xp XP';
  }

  @override
  String get duelGuestNoXp => 'No XP for guests';

  @override
  String get duelXpNotSaved => 'The XP couldn\'t be saved.';

  @override
  String get duelReplay => 'Play again';

  @override
  String get duelQuit => 'Leave';

  @override
  String get monstersPageTitle => 'My monsters';

  @override
  String get monstersIntro =>
      'These facts are still tricky for you. Get them right to tame their monsters.';

  @override
  String get monstersEmpty =>
      'No monsters in sight, well done! A fact you miss twice turns into a little monster to tame.';

  @override
  String get monsterToughnessVeryTough => 'Very tough';

  @override
  String get monsterToughnessTough => 'Tough';

  @override
  String get monsterToughnessAlmostTamed => 'Almost tamed';

  @override
  String monsterWildSpoken(String fact, String toughness) {
    return 'Monster $fact, $toughness';
  }

  @override
  String monsterTamedSpoken(String fact) {
    return 'Monster $fact, tamed';
  }

  @override
  String get monstersHuntButton => 'Start the hunt';

  @override
  String monstersHuntQuestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String get monstersTamedTitle => 'Tamed';

  @override
  String monstersTamedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count monsters',
      one: '1 monster',
    );
    return '$_temp0';
  }

  @override
  String get pathMonstersOpenLittle => 'See my little monsters';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get leaderboardWeekLabel => 'XP earned this week';

  @override
  String get leaderboardResetHint => 'Resets Monday';

  @override
  String get leaderboardYou => 'That\'s you';

  @override
  String leaderboardXp(int xp) {
    return '$xp XP';
  }

  @override
  String leaderboardEntrySpoken(String nickname, int rank, int xp) {
    return '$nickname, rank $rank, $xp XP';
  }

  @override
  String leaderboardEntryYouSpoken(String nickname, int rank, int xp) {
    return '$nickname, that\'s you, rank $rank, $xp XP';
  }

  @override
  String leaderboardChaseBehind(int xp, String nickname) {
    return '$xp more XP and you\'ll catch up with $nickname!';
  }

  @override
  String leaderboardChaseTied(String nickname) {
    return 'You\'re tied with $nickname!';
  }

  @override
  String get leaderboardChaseLeading => 'You\'re in the lead this week!';

  @override
  String get leaderboardChaseNotStarted =>
      'Play to earn your first XP of the week!';

  @override
  String get leaderboardEntrySubtitle => 'Who earned the most XP this week?';

  @override
  String get settingsShowLeaderboard => 'Show the leaderboard';

  @override
  String get shopTitle => 'Shop';

  @override
  String get shopEntrySubtitle => 'Avatars and themes to unlock';

  @override
  String shopCoinBalance(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coins',
      one: '1 coin',
      zero: '0 coins',
    );
    return '$_temp0';
  }

  @override
  String get shopTabAvatars => 'Avatars';

  @override
  String get shopTabThemes => 'Themes';

  @override
  String get shopWorn => 'Worn';

  @override
  String get shopActive => 'Active';

  @override
  String get shopChoose => 'Choose';

  @override
  String shopWornLabel(String name) {
    return '$name, worn';
  }

  @override
  String shopActiveLabel(String name) {
    return '$name, active';
  }

  @override
  String shopChooseLabel(String name) {
    return 'Choose $name';
  }

  @override
  String shopBuyLabel(String name, int price) {
    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: 'Buy $name for $price coins',
      one: 'Buy $name for 1 coin',
    );
    return '$_temp0';
  }

  @override
  String shopTooExpensiveLabel(String name, int price) {
    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: '$name, $price coins: you need more coins',
      one: '$name, 1 coin: you need more coins',
    );
    return '$_temp0';
  }

  @override
  String shopNotEnoughCoins(int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'You need $missing more coins. Keep playing to earn them!',
      one: 'You need 1 more coin. Keep playing to earn it!',
    );
    return '$_temp0';
  }

  @override
  String shopBuyTitle(String name) {
    return 'Buy $name?';
  }

  @override
  String shopBuyMessage(int price, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: '$price coins',
      one: '1 coin',
    );
    String _temp1 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'You\'ll have $left left.',
      one: 'You\'ll have 1 left.',
      zero: 'You\'ll have none left.',
    );
    return 'It costs $_temp0. $_temp1';
  }

  @override
  String get shopBuyConfirm => 'Buy';

  @override
  String shopPurchased(String name) {
    return 'Great, $name is yours! Tap \"Choose\" to use it.';
  }

  @override
  String shopEarnHint(int xpPerCoin, int coinsPerCrown, int coinsPerBadge) {
    return 'Earn coins by playing: 1 coin every $xpPerCoin XP, $coinsPerCrown per crown and $coinsPerBadge per badge.';
  }

  @override
  String get shopErrorNotEnoughCoins =>
      'You don\'t have enough coins for that.';

  @override
  String get shopErrorAlreadyOwned => 'You already have it!';

  @override
  String get shopAvatarFox => 'Fox';

  @override
  String get shopAvatarPanda => 'Panda';

  @override
  String get shopAvatarRobot => 'Robot';

  @override
  String get shopAvatarAlien => 'Alien';

  @override
  String get shopAvatarUnicorn => 'Unicorn';

  @override
  String get shopAvatarDragon => 'Dragon';

  @override
  String get shopAvatarNinja => 'Ninja';

  @override
  String get shopAvatarKing => 'King';

  @override
  String get shopThemeLavender => 'Lavender';

  @override
  String get shopThemeOcean => 'Ocean';

  @override
  String get shopThemeForest => 'Forest';

  @override
  String get shopThemeSunset => 'Sunset';

  @override
  String get shopThemeNight => 'Night';
}
