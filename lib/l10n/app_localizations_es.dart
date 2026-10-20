// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Kid Matix';

  @override
  String get mainNavigationLabel => 'Navegación principal';

  @override
  String get tabLearningPath => 'Camino';

  @override
  String get tabTraining => 'Practicar';

  @override
  String get tabChallenges => 'Retos';

  @override
  String get tabProfile => 'Perfil';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonBack => 'Volver';

  @override
  String get multiplicationDomainName => 'Multiplicación';

  @override
  String get numbersDomainName => 'Números';

  @override
  String get divisionDomainName => 'División';

  @override
  String get additionDomainName => '+ y −';

  @override
  String get additionDomainSpokenName => 'Sumas y restas';

  @override
  String get mathWordsDomainName => 'Palabras de mates';

  @override
  String get errorStorage => 'Uy, no pudimos leer o guardar tus datos.';

  @override
  String get errorNotFound => 'Este jugador ya no existe.';

  @override
  String get errorUnknown => 'Uy, algo salió mal.';

  @override
  String get whoIsPlayingTitle => '¿Quién juega?';

  @override
  String get whoIsPlayingSubtitle => 'Elige tu jugador para empezar.';

  @override
  String profileLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String get newPlayerButton => 'Nuevo jugador';

  @override
  String profileLimitHint(int maxProfiles) {
    String _temp0 = intl.Intl.pluralLogic(
      maxProfiles,
      locale: localeName,
      other: 'Hasta $maxProfiles jugadores en este teléfono.',
      one: 'Hasta $maxProfiles jugador en este teléfono.',
    );
    return '$_temp0';
  }

  @override
  String profileLimitReached(int maxProfiles) {
    String _temp0 = intl.Intl.pluralLogic(
      maxProfiles,
      locale: localeName,
      other: 'Ya hay $maxProfiles jugadores en este teléfono.',
      one: 'Ya hay $maxProfiles jugador en este teléfono.',
    );
    return '$_temp0';
  }

  @override
  String get classroomTeacherArea => 'Espacio docente';

  @override
  String get classroomCodeChooseHint =>
      'Elige un código de 4 cifras. Cierra el espacio docente: no se lo des a tus alumnos.';

  @override
  String get classroomCodeConfirmHint => 'Escribe el mismo código otra vez.';

  @override
  String get classroomCodeEnterHint => 'Escribe tu código de 4 cifras.';

  @override
  String get classroomCodeLabel => 'Código';

  @override
  String get classroomCodeOpen => 'Abrir';

  @override
  String get classroomCodeNext => 'Continuar';

  @override
  String get classroomCodeWrong => 'Ese no es el código correcto.';

  @override
  String get classroomCodeMismatch =>
      'Los dos códigos son distintos. Empieza otra vez.';

  @override
  String get classroomCodeInvalid => 'El código tiene 4 cifras.';

  @override
  String get classroomLeaveArea => 'Salir del espacio docente';

  @override
  String get classroomListTitle => 'Mis clases';

  @override
  String get classroomListEmpty =>
      'Todavía no hay ninguna clase. Crea una clase y añade a todos sus alumnos de una vez.';

  @override
  String get classroomNew => 'Nueva clase';

  @override
  String classroomPupilCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alumnos',
      one: '1 alumno',
      zero: 'Ningún alumno',
    );
    return '$_temp0';
  }

  @override
  String get classroomNameLabel => 'Nombre de la clase';

  @override
  String get classroomNameHint => 'Por ejemplo 2.º B';

  @override
  String get classroomPupilsTitle => 'Alumnos';

  @override
  String get classroomPupilsByList => 'Apodos';

  @override
  String get classroomPupilsByNumber => 'Números';

  @override
  String get classroomPupilsListLabel => 'Un apodo por línea';

  @override
  String get classroomPupilsPrivacyHint =>
      'Pon apodos o números en lugar de los nombres reales de los niños.';

  @override
  String get classroomPupilsCountLabel => 'Número de alumnos';

  @override
  String classroomPupilsPreview(int count, String first, String last) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alumnos que añadir: de $first a $last',
      one: '1 alumno que añadir: $first',
      zero: 'Ningún alumno que añadir',
    );
    return '$_temp0';
  }

  @override
  String classroomPupilsUnusable(String nicknames) {
    return 'Estos apodos no sirven: $nicknames. Un apodo tiene de 2 a 12 letras o cifras, y cada uno aparece una sola vez.';
  }

  @override
  String get classroomCreate => 'Crear la clase';

  @override
  String get classroomErrorName =>
      'Ponle un nombre a la clase (24 caracteres como máximo).';

  @override
  String get classroomErrorNoPupil => 'Añade al menos un alumno.';

  @override
  String classroomErrorTooMany(int max) {
    return 'Una clase tiene como máximo $max alumnos.';
  }

  @override
  String get classroomErrorTaken => 'Uno de estos apodos ya está en la clase.';

  @override
  String get classroomErrorGeneric =>
      'Uy, no ha funcionado. Inténtalo otra vez.';

  @override
  String get classroomAddPupils => 'Añadir alumnos';

  @override
  String get classroomShelfTitle => 'Las clases';

  @override
  String get classroomPickerTitle => '¿Quién eres?';

  @override
  String get classroomPickerSearch => 'Busca tu nombre';

  @override
  String get classroomPickerNoMatch => 'Nadie en la clase se llama así.';

  @override
  String get classroomPickerEmpty => 'Esta clase todavía no tiene alumnos.';

  @override
  String get classroomCodeForgotten => '¿Olvidaste el código?';

  @override
  String classroomCodeLocked(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other:
          'Demasiados intentos. Espera $seconds segundos antes de volver a intentarlo.',
      one:
          'Demasiados intentos. Espera 1 segundo antes de volver a intentarlo.',
    );
    return '$_temp0';
  }

  @override
  String get classroomOneTabletHint =>
      'Cada alumno juega siempre en la misma tableta: su progreso no pasa de una tableta a otra.';

  @override
  String classroomPupilManage(String nickname) {
    return 'Gestionar a $nickname';
  }

  @override
  String get classroomPupilReset => 'Reiniciar su progreso';

  @override
  String get classroomPupilResetMessage =>
      'Se borrarán sus estrellas, coronas, insignias, XP y récords. Sus resultados de clase se quedan.';

  @override
  String get classroomPupilRemove => 'Quitar de la clase';

  @override
  String get classroomPupilRemoveMessage =>
      'Este alumno y todo su progreso se borrarán de esta tableta, también sus resultados de clase.';

  @override
  String classroomPupilResetDone(String nickname) {
    return 'El progreso de $nickname se ha reiniciado.';
  }

  @override
  String classroomPupilRemoved(String nickname) {
    return '$nickname ya no está en la clase.';
  }

  @override
  String get classroomAssignmentTitle => 'La tarea de la clase';

  @override
  String get classroomAssignmentNone =>
      'Todavía no hay tarea. Elige una unidad para que toda la clase la trabaje.';

  @override
  String get classroomAssignmentGive => 'Poner una tarea';

  @override
  String get classroomAssignmentPickHint =>
      'Elige la unidad que va a trabajar toda la clase.';

  @override
  String classroomAssignmentDue(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMMEEEEd(
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return 'Para el $dateString';
  }

  @override
  String get classroomAssignmentDueNone => 'Sin fecha';

  @override
  String get classroomAssignmentDueTomorrow => 'Para mañana';

  @override
  String get classroomAssignmentDueWeek => 'En 7 días';

  @override
  String classroomAssignmentStarted(int started, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      started,
      locale: localeName,
      other: '$started alumnos de $total la han empezado.',
      one: '1 alumno de $total la ha empezado.',
      zero: 'Nadie la ha empezado todavía.',
    );
    return '$_temp0';
  }

  @override
  String get classroomAssignmentPlay => '¡Vamos!';

  @override
  String classroomAssignmentLearned(int percent) {
    return '$percent % aprendido';
  }

  @override
  String get classroomChallengeTitle => 'Reto de la clase';

  @override
  String classroomChallengeProgress(int count, int goal) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respuestas correctas de $goal esta semana',
      one: '1 respuesta correcta de $goal esta semana',
    );
    return '$_temp0';
  }

  @override
  String get classroomChallengeReached => '¡Bravo, clase, objetivo cumplido!';

  @override
  String get classroomChallengeGoal => 'Objetivo de la semana';

  @override
  String get classroomStrugglesTitle => '¿Quién se atasca, y en qué?';

  @override
  String classroomStruggleLine(int count, String item) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alumnos se equivocan en $item',
      one: '1 alumno se equivoca en $item',
    );
    return '$_temp0';
  }

  @override
  String get classroomStrugglesNone => 'Nadie se atasca por ahora.';

  @override
  String classroomGroupsTitle(String domain) {
    return 'Grupos de nivel · $domain';
  }

  @override
  String get classroomGroupsHint =>
      'Propuestos a partir de la prueba de nivel y de las respuestas de los alumnos.';

  @override
  String get classroomGroupsNone =>
      'Los grupos aparecerán cuando los alumnos hayan jugado.';

  @override
  String get classroomGroupFirstSteps => 'Primeros pasos';

  @override
  String get classroomGroupOnTheWay => 'En camino';

  @override
  String get classroomGroupConfident => 'Con soltura';

  @override
  String get classroomGroupNotYet => 'Aún sin evaluar';

  @override
  String get classroomPupilNeverPlayed => 'Aún no ha jugado';

  @override
  String classroomPupilSummary(int sessions, String time, int percent) {
    String _temp0 = intl.Intl.pluralLogic(
      sessions,
      locale: localeName,
      other: '$sessions sesiones',
      one: '1 sesión',
    );
    return '$_temp0 · $time · $percent % de respuestas correctas';
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

    return 'Última sesión: $dateString';
  }

  @override
  String classroomPupilStuckOn(String items) {
    return 'Se atasca en: $items';
  }

  @override
  String get classroomExport => 'Enviar la clase y sus resultados';

  @override
  String get classroomExportDone => 'El archivo de la clase está listo.';

  @override
  String get classroomExportNew =>
      'Los resultados nuevos desde el último envío';

  @override
  String get classroomExportFull => 'Toda la clase y todos sus resultados';

  @override
  String get classroomImportTooBig =>
      'Este archivo es demasiado grande para esta tableta.';

  @override
  String classroomImportRenamed(String done, String nicknames) {
    return '$done Apodos ya usados en la clase, alumnos renombrados: $nicknames.';
  }

  @override
  String get classroomImport => 'Recibir una clase o resultados';

  @override
  String classroomImportDone(String name, int pupils, int sessions) {
    String _temp0 = intl.Intl.pluralLogic(
      pupils,
      locale: localeName,
      other: '$pupils alumnos nuevos',
      one: '1 alumno nuevo',
      zero: 'ningún alumno nuevo',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sessions,
      locale: localeName,
      other: '$sessions sesiones nuevas',
      one: '1 sesión nueva',
      zero: 'ninguna sesión nueva',
    );
    return '$name: $_temp0, $_temp1.';
  }

  @override
  String get classroomImportInvalid =>
      'Este archivo no es un archivo de clase de Kid Matix, o está dañado.';

  @override
  String get classroomImportVersion =>
      'Este archivo viene de una versión más reciente de Kid Matix. Actualiza la app y vuelve a intentarlo.';

  @override
  String get profileCreationTitle => 'Nuevo jugador';

  @override
  String get nicknameLabel => 'Tu apodo';

  @override
  String get nicknameHint => 'Escribe tu apodo';

  @override
  String nicknameRulesHint(int minLength, int maxLength) {
    String _temp0 = intl.Intl.pluralLogic(
      maxLength,
      locale: localeName,
      other: 'De $minLength a $maxLength letras o números',
      one: 'De $minLength a $maxLength letra o número',
    );
    return '$_temp0';
  }

  @override
  String nicknameTooShort(int minLength) {
    String _temp0 = intl.Intl.pluralLogic(
      minLength,
      locale: localeName,
      other: 'Hacen falta al menos $minLength letras o números.',
      one: 'Hace falta al menos $minLength letra o número.',
    );
    return '$_temp0';
  }

  @override
  String nicknameTooLong(int maxLength) {
    String _temp0 = intl.Intl.pluralLogic(
      maxLength,
      locale: localeName,
      other: 'No más de $maxLength letras o números.',
      one: 'No más de $maxLength letra o número.',
    );
    return '$_temp0';
  }

  @override
  String get nicknameInvalidCharacters => 'Solo letras, números y espacios.';

  @override
  String get nicknameTaken => 'Este nombre ya está en uso en este teléfono.';

  @override
  String get avatarPickerLabel => 'Elige tu avatar';

  @override
  String avatarOptionLabel(int number) {
    return 'Avatar $number';
  }

  @override
  String get colorPickerLabel => 'Tu color';

  @override
  String get profileColorViolet => 'Violeta';

  @override
  String get profileColorGreen => 'Verde';

  @override
  String get profileColorYellow => 'Amarillo';

  @override
  String get profileColorRed => 'Rojo';

  @override
  String get profileColorBlue => 'Azul';

  @override
  String get profileColorPink => 'Rosa';

  @override
  String get profileCreationReadAloudHint =>
      'Una voz lee cada pregunta. Podrás cambiarlo después en los ajustes.';

  @override
  String get createProfileButton => '¡Vamos!';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String profileStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get profileStreakLabel => 'de racha';

  @override
  String profileCrownsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'coronas',
      one: 'corona',
    );
    return '$_temp0';
  }

  @override
  String profileBadgesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'insignias',
      one: 'insignia',
    );
    return '$_temp0';
  }

  @override
  String get masteryGridTitle => 'Mis tablas';

  @override
  String get masteryGridTitleNumbers => 'Mis números';

  @override
  String get masteryGridTitleDivision => 'Mis divisiones';

  @override
  String get masteryGridTitleAddition => 'Mis + y −';

  @override
  String get masteryGridTitleAdditionSpoken => 'Mis sumas y restas';

  @override
  String get masteryGridTitleMathWords => 'Mis palabras';

  @override
  String get masteryStatusNotSeen => 'Nuevo';

  @override
  String get masteryStatusToReview => 'Por repasar';

  @override
  String get masteryStatusInProgress => 'En progreso';

  @override
  String get masteryStatusAcquired => 'Aprendido';

  @override
  String get masteryStatusMastered => 'Dominado';

  @override
  String masteryCellSpoken(String fact, String status) {
    return '$fact, $status';
  }

  @override
  String get rewardBadgesTitle => 'Mis insignias';

  @override
  String rewardBadgeEarnedSpoken(String name) {
    return '$name, conseguida';
  }

  @override
  String rewardBadgeLockedSpoken(String name, String hint) {
    return '$name, por conseguir: $hint';
  }

  @override
  String get pathMonstersTitle => 'Mis monstruos';

  @override
  String pathMonstersCount(int defeated, int total) {
    return '$defeated de $total';
  }

  @override
  String pathMonsterDefeatedSpoken(int number) {
    return 'Monstruo de la tabla del $number, vencido';
  }

  @override
  String pathMonsterHiddenSpoken(int number) {
    return 'Monstruo de la tabla del $number, todavía sin vencer';
  }

  @override
  String pathUnitMonsterDefeatedSpoken(String unit) {
    return 'Monstruo de «$unit», vencido';
  }

  @override
  String pathUnitMonsterHiddenSpoken(String unit) {
    return 'Monstruo de «$unit», todavía sin vencer';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSoundSection => 'Sonidos';

  @override
  String get settingsSound => 'Sonidos';

  @override
  String get settingsVibration => 'Vibraciones';

  @override
  String get settingsGameSection => 'Juego';

  @override
  String get settingsTimer => 'Cronómetro';

  @override
  String get settingsTimerNormal => 'Normal';

  @override
  String get settingsTimerRelaxed => 'Relajado';

  @override
  String get settingsTimerOff => 'Apagado';

  @override
  String get settingsDailyGoal => 'Meta del día';

  @override
  String get settingsUnlockAll => 'Desbloquear todo';

  @override
  String get settingsReducedMotion => 'Animaciones reducidas';

  @override
  String get settingsReadAloud => 'Leer las preguntas en voz alta';

  @override
  String get settingsHelpAudio => 'Ayuda de audio';

  @override
  String get helpAudioNone => 'Ninguna';

  @override
  String helpAudioLanguageName(String code) {
    String _temp0 = intl.Intl.selectLogic(
      code,
      {
        'wo': 'wolof',
        'other': '$code',
      },
    );
    return '$_temp0';
  }

  @override
  String helpAudioListen(String language) {
    return 'Escuchar en $language';
  }

  @override
  String helpAudioListenExample(String language) {
    return 'Ejemplo en $language';
  }

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonListen => 'Escuchar';

  @override
  String get commonListenStop => 'Detener la lectura';

  @override
  String get settingsBackupSection => 'Copia de seguridad';

  @override
  String get backupExport => 'Exportar mi perfil';

  @override
  String get backupImport => 'Importar un perfil';

  @override
  String get backupExportDone =>
      '¡Archivo listo! Ábrelo en Kid Matix en el otro teléfono, con «Importar un perfil».';

  @override
  String backupImportDone(String nickname) {
    return '¡Perfil de $nickname importado! Encuéntralo con «Cambiar de jugador».';
  }

  @override
  String backupImportReplaced(String nickname) {
    return '¡Progreso de $nickname restaurado!';
  }

  @override
  String backupConflictTitle(String nickname) {
    return '$nickname ya existe';
  }

  @override
  String backupConflictMessage(String nickname, int level) {
    return 'Este teléfono ya tiene un jugador $nickname. El archivo contiene a $nickname en el nivel $level.\n\nReemplazar borra el progreso actual de $nickname en este teléfono. Renombrar conserva a los dos jugadores.';
  }

  @override
  String get backupConflictReplace => 'Reemplazar';

  @override
  String get backupConflictRename => 'Renombrar';

  @override
  String get backupRenameTitle => 'Nuevo apodo';

  @override
  String get backupRenameMessage =>
      'Elige otro apodo para el jugador importado.';

  @override
  String get backupRenameConfirm => 'Importar';

  @override
  String get errorBackupInvalid =>
      'Este archivo no es una copia de seguridad de Kid Matix, o está dañado.';

  @override
  String get errorBackupVersion =>
      'Esta copia de seguridad viene de una versión más nueva de Kid Matix. Actualiza la app y vuelve a intentarlo.';

  @override
  String get parentalGateTitle => 'Pide ayuda a un adulto';

  @override
  String get parentalGateMessage =>
      'Esta acción es solo para adultos. Escribe este número en cifras:';

  @override
  String get parentalGateAnswerLabel => 'Número en cifras';

  @override
  String get parentalGateConfirm => 'Confirmar';

  @override
  String get settingsReminderSection => 'Recordatorio';

  @override
  String get settingsReminderDaily => 'Recordatorio diario';

  @override
  String get settingsReminderTime => 'Hora del recordatorio';

  @override
  String get settingsReminderPermissionDenied =>
      'Las notificaciones están bloqueadas. Permítelas en los ajustes del teléfono para recibir el recordatorio.';

  @override
  String get settingsReminderError =>
      'Uy, no se pudo programar el recordatorio.';

  @override
  String get settingsLanguageSection => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Idioma del teléfono';

  @override
  String get languageNameFrench => 'Français';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageNameSpanish => 'Español';

  @override
  String get settingsLanguageError => 'Uy, no se pudo guardar el idioma.';

  @override
  String get reminderNotificationBody => '¡Es la hora de tus tablas!';

  @override
  String get reminderChannelName => 'Recordatorio diario';

  @override
  String get reminderChannelDescription =>
      'Te recuerda jugar cada día a la hora elegida.';

  @override
  String get settingsPlayerSection => 'Este jugador';

  @override
  String get resetProgressButton => 'Reiniciar mi progreso';

  @override
  String get resetProgressConfirm => 'Reiniciar';

  @override
  String get resetProgressDone => 'Tu progreso volvió a cero.';

  @override
  String settingsDailyGoalXp(int xp) {
    return '$xp XP';
  }

  @override
  String resetProgressTitle(String nickname) {
    return '¿Reiniciar a $nickname?';
  }

  @override
  String resetProgressMessage(String nickname) {
    return 'Se borrarán sus estrellas, coronas, insignias, XP y récords. Su apodo, sus ajustes y el nombre de su mascota se quedan. Para confirmar, escribe su apodo: $nickname';
  }

  @override
  String get switchPlayerButton => 'Cambiar de jugador';

  @override
  String get editProfileButton => 'Editar mi perfil';

  @override
  String get deleteProfileButton => 'Borrar este jugador';

  @override
  String get profileEditTitle => 'Editar mi perfil';

  @override
  String get saveProfileButton => 'Guardar';

  @override
  String deleteProfileTitle(String nickname) {
    return '¿Borrar a $nickname?';
  }

  @override
  String deleteProfileMessage(String nickname) {
    return 'Se borrará todo su progreso. Para confirmar, escribe su apodo: $nickname';
  }

  @override
  String get deleteProfileConfirm => 'Borrar';

  @override
  String get quizQuitTooltip => 'Salir del quiz';

  @override
  String quizProgressLabel(int current, int total) {
    return 'Pregunta $current de $total';
  }

  @override
  String get quizTimeLeftLabel => 'Tiempo restante';

  @override
  String quizMultiplicationUnit(int number) {
    return 'Tabla del $number';
  }

  @override
  String get quizTrueFalseLabel => '¿Verdadero o falso?';

  @override
  String get quizHintMultipleChoice => 'Toca la respuesta correcta';

  @override
  String get quizHintTrueFalse => '¿Está bien esta cuenta?';

  @override
  String get quizFindOperationMultiplication =>
      'Busca la multiplicación que da';

  @override
  String quizFindOperationSpokenMultiplication(int result) {
    return '¿Qué multiplicación da $result?';
  }

  @override
  String get quizCountLabel => '¿Cuántos mangos hay?';

  @override
  String get quizBundlesLabel => '¿Qué número es?';

  @override
  String get quizNumberLineLabel => '¿Qué número falta?';

  @override
  String get quizCompareLabel => '¿Menor, igual o mayor?';

  @override
  String get quizMissingNumberLabel => 'Encuentra el número escondido';

  @override
  String quizCompareSpoken(int first, int second) {
    return '¿$first es menor, igual o mayor que $second?';
  }

  @override
  String quizBundlesSpoken(int tens, int ones) {
    String _temp0 = intl.Intl.pluralLogic(
      tens,
      locale: localeName,
      other: '$tens paquetes de diez',
      one: '1 paquete de diez',
      zero: 'Ningún paquete de diez',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ones,
      locale: localeName,
      other: '$ones palitos',
      one: '1 palito',
      zero: 'ningún palito',
    );
    return '$_temp0 y $_temp1: ¿qué número es?';
  }

  @override
  String quizNumberLineSpoken(String numbers) {
    return 'Recta numérica: $numbers. ¿Qué número falta?';
  }

  @override
  String get quizObjectsPictureLabel => 'Mangos para contar';

  @override
  String quizObjectsPictureCounted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mangos',
      one: '1 mango',
    );
    return '$_temp0';
  }

  @override
  String quizBundlesPictureLabel(int tens, int ones) {
    String _temp0 = intl.Intl.pluralLogic(
      tens,
      locale: localeName,
      other: '$tens paquetes de diez',
      one: '1 paquete de diez',
      zero: 'Ningún paquete de diez',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ones,
      locale: localeName,
      other: '$ones palitos',
      one: '1 palito',
      zero: 'ningún palito',
    );
    return '$_temp0 y $_temp1';
  }

  @override
  String quizNumberLinePictureLabel(String numbers) {
    return 'Recta numérica: $numbers';
  }

  @override
  String get quizHintFindOperation => 'Toca la operación correcta';

  @override
  String get quizHintCompare => 'Toca el signo correcto';

  @override
  String get quizHintWordListen => 'Toca el dibujo correcto';

  @override
  String get quizHintWordOperation => 'Toca la operación';

  @override
  String get quizWordListenLabel => 'Escucha y toca';

  @override
  String get quizWordTouchLabel => 'Toca para entender';

  @override
  String get quizWordOperationLabel => '¿Qué operación?';

  @override
  String get quizWordMatchTitle => 'Une cada palabra con su dibujo';

  @override
  String get quizWordMatchHintStart => 'Toca una palabra y luego su dibujo';

  @override
  String quizWordMatchHintPicture(String word) {
    return 'Toca el dibujo de «$word»';
  }

  @override
  String get quizWordMatchHintWord => 'Toca la palabra que va con este dibujo';

  @override
  String get quizWordUnderstood => 'Lo entiendo';

  @override
  String get quizWordTouchFirst => 'Toca la palabra de color';

  @override
  String get quizCompareLess => 'menor';

  @override
  String get quizCompareEqual => 'igual';

  @override
  String get quizCompareGreater => 'mayor';

  @override
  String get quizMatchPairsTitle => 'Une cada operación con su resultado';

  @override
  String quizMatchPairsProgress(int count, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parejas encontradas de $total',
      one: '1 pareja encontrada de $total',
      zero: 'Ninguna pareja encontrada de $total',
    );
    return '$_temp0';
  }

  @override
  String get quizMatchPairsHintStart =>
      'Toca una operación y luego su resultado';

  @override
  String quizMatchPairsHintResult(String operation) {
    return 'Ahora toca el resultado de $operation';
  }

  @override
  String quizMatchPairsHintOperation(String result) {
    return 'Ahora toca la operación que da $result';
  }

  @override
  String quizMatchPairsFound(String label) {
    return '$label, pareja encontrada';
  }

  @override
  String get quizTrue => 'Verdadero';

  @override
  String get quizFalse => 'Falso';

  @override
  String get quizKeypadErase => 'Borrar';

  @override
  String get quizKeypadValidate => 'Aceptar';

  @override
  String get quizFeedbackRight => '¡Muy bien!';

  @override
  String get quizFeedbackWrong => '¡Casi!';

  @override
  String get quizFeedbackTimeUp => '¡Se acabó el tiempo!';

  @override
  String get quizLightning => '¡Relámpago!';

  @override
  String quizMirrorReminder(String fact) {
    return 'Recuerda también: $fact';
  }

  @override
  String quizHelpTitle(String unit) {
    return 'Ficha de ayuda · $unit';
  }

  @override
  String quizHelpDotGridLabel(int rows, int columns) {
    String _temp0 = intl.Intl.pluralLogic(
      rows,
      locale: localeName,
      other: '$rows filas',
      one: '1 fila',
    );
    String _temp1 = intl.Intl.pluralLogic(
      columns,
      locale: localeName,
      other: '$columns puntos',
      one: '1 punto',
    );
    return '$_temp0 de $_temp1';
  }

  @override
  String quizHelpDotGridSharingLabel(int total, int groups, int each) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total puntos repartidos',
      one: '1 punto repartido',
    );
    String _temp1 = intl.Intl.pluralLogic(
      groups,
      locale: localeName,
      other: '$groups grupos',
      one: '1 grupo',
    );
    return '$_temp0 en $_temp1: $each en cada grupo';
  }

  @override
  String get quizContinue => 'Continuar';

  @override
  String get quizQuitTitle => '¿Salir del quiz?';

  @override
  String get quizQuitMessage =>
      'Tus respuestas cuentan para tu progreso, pero esta partida no te dará recompensa.';

  @override
  String get quizQuitConfirm => 'Salir';

  @override
  String get quizQuitCancel => 'Seguir jugando';

  @override
  String get quizSpokenTimes => 'por';

  @override
  String get quizSpokenEquals => 'es igual a';

  @override
  String get quizSpokenBlank => 'cuánto';

  @override
  String quizSpokenTrueFalse(String statement) {
    return '$statement. ¿Verdadero o falso?';
  }

  @override
  String get quizSpokenPlus => 'más';

  @override
  String get quizSpokenDividedBy => 'dividido entre';

  @override
  String get quizSpokenMinus => 'menos';

  @override
  String get quizSpokenLessThan => 'es menor que';

  @override
  String get quizSpokenGreaterThan => 'es mayor que';

  @override
  String get quizSpokenEqualTo => 'es igual a';

  @override
  String get quizSpokenHiddenNumber => 'número escondido';

  @override
  String get quizModePath => 'Camino';

  @override
  String get quizModeFreeTraining => 'Práctica libre';

  @override
  String get quizModeTimeAttack => 'Contrarreloj';

  @override
  String get quizModeSurvival => 'Supervivencia';

  @override
  String quizLivesSpoken(int left, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: '$left vidas de $total',
      one: '1 vida de $total',
      zero: 'Sin vidas',
    );
    return '$_temp0';
  }

  @override
  String get quizModeDailyReview => 'Repaso del día';

  @override
  String get quizModeMonsterHunt => 'Caza de monstruos';

  @override
  String quizScoreSpoken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respuestas correctas',
      one: '1 respuesta correcta',
      zero: 'Ninguna respuesta correcta',
    );
    return '$_temp0';
  }

  @override
  String quizClockLeftSpoken(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Quedan $seconds segundos',
      one: 'Queda 1 segundo',
      zero: 'Se acabó el tiempo',
    );
    return '$_temp0';
  }

  @override
  String get resultsTitle => '¡Partida terminada!';

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
      other: 'acertadas',
      one: 'acertada',
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
  String get resultsAverageTimeLabel => 'de media';

  @override
  String get resultsToReview => 'Por repasar';

  @override
  String get resultsNothingToReview => '¡Ningún error, muy bien!';

  @override
  String get resultsContinue => 'Continuar';

  @override
  String get resultsReplay => 'Volver a jugar';

  @override
  String get pathStageDiscovery => 'Descubrimiento';

  @override
  String get pathStageDiscoveryHint => 'La tabla y su truco';

  @override
  String get pathStageTraining => 'Entrenamiento';

  @override
  String get pathStageTrainingHint => '10 preguntas mezcladas';

  @override
  String get pathStageWriting => 'Escritura';

  @override
  String get pathStageWritingHint => 'Escribe tú la respuesta';

  @override
  String get pathStageSpeed => 'Velocidad';

  @override
  String get pathStageSpeedHint => '10 segundos por pregunta';

  @override
  String get pathStageBoss => 'Jefe final';

  @override
  String get pathStageBossHint => 'Vence al monstruo de la tabla';

  @override
  String get pathStageReview => 'Repaso';

  @override
  String get pathStageReviewHint => '15 preguntas de las tablas ya vistas';

  @override
  String get pathUnitStageDiscoveryHint => 'La lección y su truco';

  @override
  String get pathUnitStageBossHint => 'Vence al monstruo de la lección';

  @override
  String get pathUnitStageReviewHint =>
      '15 preguntas de las lecciones ya vistas';

  @override
  String pathStageNumbered(int number, String name) {
    return '$number · $name';
  }

  @override
  String pathCurrentStage(int number, int total, String name) {
    return 'Etapa $number de $total · $name';
  }

  @override
  String get pathPlay => 'Jugar';

  @override
  String get pathShowTable => 'Ver la tabla';

  @override
  String get pathShowUnit => 'Ver la lección';

  @override
  String pathTableStars(int stars, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      stars,
      locale: localeName,
      other: '$stars estrellas de $total',
      one: '1 estrella de $total',
      zero: '0 estrellas de $total',
    );
    return '$_temp0';
  }

  @override
  String get pathCrownHint => 'Vence al jefe para ganar la corona.';

  @override
  String get placementOfferTitle => '¿Ya te sabes algunas tablas?';

  @override
  String get placementOfferMessage =>
      'Responde una pregunta por tabla, sin cronómetro. Cada tabla que te sepas se abre enseguida en tu camino.';

  @override
  String get placementOfferStart => 'Hacer la prueba';

  @override
  String get placementOfferSkip => 'Saltar';

  @override
  String placementQuestionProgress(int current, int total) {
    return 'Pregunta $current de $total';
  }

  @override
  String get placementUnknownAnswer => 'No lo sé';

  @override
  String get placementQuitTooltip => 'Dejar la prueba';

  @override
  String get placementQuitTitle => '¿Dejar la prueba?';

  @override
  String get placementQuitMessage =>
      'Las tablas que ya encontraste siguen abiertas en tu camino.';

  @override
  String get placementQuitCancel => 'Seguir con la prueba';

  @override
  String get placementQuitConfirm => 'Dejar';

  @override
  String placementResultTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¡Ya te sabes $count tablas!',
      one: '¡Ya te sabes 1 tabla!',
      zero: '¡Todo por descubrir!',
    );
    return '$_temp0';
  }

  @override
  String placementResultSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Están abiertas en tu camino. Sus estrellas están por ganar.',
      one: 'Está abierta en tu camino. Sus estrellas están por ganar.',
      zero: 'No te preocupes, las aprenderás una por una. Tu camino empieza por la tabla del 1.',
    );
    return '$_temp0';
  }

  @override
  String get placementLegendKnown => 'Ya conocida';

  @override
  String get placementLegendToDiscover => 'Por descubrir';

  @override
  String placementTableKnown(String name) {
    return '$name, ya conocida';
  }

  @override
  String placementTableToDiscover(String name) {
    return '$name, por descubrir';
  }

  @override
  String get placementSeePath => 'Ver mi camino';

  @override
  String get pathTableBack => 'Volver al camino';

  @override
  String pathTableNodeDone(String name, int stars) {
    String _temp0 = intl.Intl.pluralLogic(
      stars,
      locale: localeName,
      other: '$stars estrellas',
      one: '1 estrella',
      zero: 'ninguna estrella',
    );
    return '$name, terminada, $_temp0';
  }

  @override
  String pathTableNodeCurrent(String name) {
    return '$name, en curso';
  }

  @override
  String pathTableNodeOpen(String name) {
    return '$name, abierta';
  }

  @override
  String pathTableNodeLocked(String name) {
    return '$name, bloqueada';
  }

  @override
  String pathReviewNodeLocked(String name) {
    return '$name, bloqueado';
  }

  @override
  String get pathLocked => 'Bloqueada';

  @override
  String starsLabel(int stars, int max) {
    String _temp0 = intl.Intl.pluralLogic(
      stars,
      locale: localeName,
      other: '$stars estrellas de $max',
      one: '1 estrella de $max',
      zero: 'Ninguna estrella de $max',
    );
    return '$_temp0';
  }

  @override
  String pathDiscoveryTitle(int number) {
    return 'Esta es la tabla del $number';
  }

  @override
  String get pathDiscoveryProgress => 'Antes de la primera pregunta';

  @override
  String get pathTipTitle => 'El truco';

  @override
  String get pathDiscoveryStart => '¡Me toca jugar!';

  @override
  String pathMultiplicationTip(String table) {
    String _temp0 = intl.Intl.selectLogic(
      table,
      {
        '1': 'Multiplicar por 1 no cambia nada: 1 × 7 = 7.',
        '2': 'Multiplicar por 2 es sumar el número consigo mismo: 2 × 6 = 6 + 6.',
        '3': 'Los resultados avanzan de 3 en 3: 3, 6, 9, 12…',
        '4':
            'Multiplicar por 4 es duplicar dos veces: 4 × 6 es el doble de 12.',
        '5': 'Los resultados de la tabla del 5 siempre terminan en 0 o en 5.',
        '6': '6 por un número par termina en la misma cifra: 6 × 4 = 24.',
        '7': 'Para 7 × 8, piensa en 5, 6, 7, 8: 56 = 7 × 8.',
        '8': 'Multiplicar por 8 es duplicar tres veces: 8 × 3 = 24.',
        '9': 'Las dos cifras del resultado siempre suman 9: 9 × 4 = 36 y 3 + 6 = 9.',
        '10': 'Multiplicar por 10 es añadir un 0 a la derecha: 10 × 7 = 70.',
        '11': 'Hasta 11 × 9, se escribe la cifra dos veces: 11 × 4 = 44.',
        'other': '12 por un número es 10 veces más 2 veces: 12 × 3 = 30 + 6.',
      },
    );
    return '$_temp0';
  }

  @override
  String numbersUnitName(String unit) {
    String _temp0 = intl.Intl.selectLogic(
      unit,
      {
        'count10': 'Contar hasta 10',
        'count20': 'Contar hasta 20',
        'count100': 'Contar hasta 100',
        'tensones': 'Decenas y unidades',
        'compare': 'Comparar',
        'order': 'Ordenar',
        'beforeafter': 'Antes y después',
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
        'count10': 'Toca cada mango con el dedo mientras cuentas: uno, dos, tres… El último número dice cuántos hay.',
        'count20': 'Cuenta primero la fila de 10 y luego sigue: 11, 12, 13…',
        'count100': 'Un paquete son 10 palitos. Cuenta los paquetes de 10 en 10: 10, 20, 30…',
        'tensones': 'La cifra de las decenas cuenta los paquetes, la de las unidades los palitos sueltos: 3 paquetes y 4 palitos son 34.',
        'compare': 'Mira primero las decenas: el número que tiene más es el mayor. Si son iguales, mira las unidades.',
        'order': 'En la recta, los números van del menor al mayor. Descubre cuánto avanzan cada vez.',
        'beforeafter': 'El número siguiente es 1 más; el anterior, 1 menos. ¡Después del 39 viene el 40!',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String divisionUnitName(int number) {
    return 'Dividir entre $number';
  }

  @override
  String divisionUnitTip(String unit) {
    String _temp0 = intl.Intl.selectLogic(
      unit,
      {
        '1': 'Dividir entre 1 no cambia nada: 7 ÷ 1 = 7.',
        '2': 'Dividir entre 2 es repartir en dos partes iguales: 12 ÷ 2 = 6, la mitad de 12.',
        '3': 'Dividir entre 3 es hacer 3 partes iguales: 12 ÷ 3 = 4, porque 3 × 4 = 12.',
        '4': 'Dividir entre 4 es sacar la mitad de la mitad: 20 ÷ 4 = 5, porque la mitad de 20 es 10 y la mitad de 10 es 5.',
        '5': 'Para 35 ÷ 5, cuenta de 5 en 5 hasta 35: 5, 10, 15, 20, 25, 30, 35. Son 7 saltos, así que 35 ÷ 5 = 7.',
        '6': 'Para 42 ÷ 6, busca en la tabla del 6: 6 × 7 = 42, así que 42 ÷ 6 = 7.',
        '7': 'Para 56 ÷ 7, piensa en 7 × 8 = 56: así que 56 ÷ 7 = 8.',
        '8': 'Dividir entre 8 es sacar la mitad tres veces: para 48 ÷ 8, 48 → 24 → 12 → 6.',
        '9': 'En la tabla del 9, las cifras suman 9 (36: 3 + 6 = 9). Y 36 ÷ 9 = 4, porque 9 × 4 = 36.',
        '10': 'Dividir entre 10 es quitar el 0 de la derecha: 70 ÷ 10 = 7.',
        '11': 'Hasta 99 ÷ 11, los números de la tabla del 11 tienen dos cifras iguales: 77 ÷ 11 = 7.',
        '12': 'Para 36 ÷ 12, cuenta de 12 en 12: 12, 24, 36. Son 3 saltos, así que 36 ÷ 12 = 3.',
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
        'add5': 'Sumas hasta 5',
        'sub5': 'Restas hasta 5',
        'add7': 'Sumas hasta 7',
        'add9': 'Sumas hasta 9',
        'toten': 'Completar hasta 10',
        'sub7': 'Restas hasta 7',
        'sub9': 'Restas hasta 9',
        'subten': 'Restas desde 10',
        'add12': 'Sumas hasta 12',
        'add14': 'Sumas hasta 14',
        'add20': 'Sumas hasta 20',
        'sub12': 'Restas hasta 12',
        'sub14': 'Restas hasta 14',
        'sub20': 'Restas hasta 20',
        'add100': 'Sumas sin llevada',
        'sub100': 'Restas sin llevada',
        'carry': 'Sumas con llevada',
        'borrow': 'Restas con llevada',
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
        'add5': 'Para sumar, avanza por la recta: ¿2 + 3? Empieza en 2 y avanza 3: 3, 4, 5.',
        'sub5': 'Restar es quitar. ¿5 − 2? Empieza en 5 y retrocede 2: 4, 3.',
        'add7': 'Para sumar, empieza por el número más grande y avanza el más pequeño. ¿2 + 5? Empieza en 5 y avanza 2: 6, 7.',
        'add9': 'Piensa en los dobles: 4 + 4 = 8, así que 4 + 5 = 9.',
        'toten': 'Busca lo que falta para llegar a 10. A 7 le faltan 3, porque 7 + 3 = 10. Cuenta con los dedos si quieres.',
        'sub7': 'Restar es quitar. ¿7 − 3? Empieza en 7 y retrocede 3: 6, 5, 4. O busca: 3 más cuánto es 7.',
        'sub9': 'Para 9 − 4, busca lo que hay que sumar a 4 para llegar a 9: 4 + 5 = 9, así que 9 − 4 = 5.',
        'subten': 'Para 10 − 3, piensa en el complemento: 3 + 7 = 10, así que 10 − 3 = 7.',
        'add12': 'Para 9 + 2, ve primero hasta 10: 9 + 1 = 10. Queda 1 por sumar: 10 + 1 = 11.',
        'add14': 'Para 8 + 5, ve primero hasta 10: 8 + 2 = 10. Quedan 3 por sumar: 10 + 3 = 13.',
        'add20': 'Para 7 + 8, ve primero hasta 10: 7 + 3 = 10. Quedan 5 por sumar: 10 + 5 = 15.',
        'sub12': 'Para 12 − 4, quita primero 2 para llegar a 10 y luego 2 más: 12 − 2 = 10 y 10 − 2 = 8.',
        'sub14': 'Para 13 − 6, quita primero 3 para llegar a 10 y luego 3 más: 13 − 3 = 10 y 10 − 3 = 7.',
        'sub20': 'Para 15 − 7, quita primero 5 para llegar a 10 y luego 2 más: 15 − 5 = 10 y 10 − 2 = 8.',
        'add100': 'Suma las unidades y luego las decenas. Para 23 + 14: 3 + 4 = 7 y 20 + 10 = 30, así que 37.',
        'sub100': 'Resta las unidades y luego las decenas. Para 47 − 23: 7 − 3 = 4 y 40 − 20 = 20, así que 24.',
        'carry': 'Cuando las unidades suman 10 o más, te llevas una decena. Para 27 + 15, 7 + 5 = 12: escribes 2 y te llevas 1 decena. 20 + 10 + 10 = 40, y 40 + 2 = 42.',
        'borrow': 'Si no puedes quitar las unidades, rompe una decena. Para 42 − 17: 42 se convierte en 30 y 12. 12 − 7 = 5 y 30 − 10 = 20, así que 25.',
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
        'add': 'Añadir',
        'remove': 'Quitar',
        'compare': 'Comparar',
        'group': 'Agrupar',
        'share': 'Repartir',
        'ask': 'Las preguntas',
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
        'add': 'Cuando añadimos, tenemos más que antes. Escucha «en plus», «en tout», «ensemble»: dicen que juntamos.',
        'remove': 'Cuando quitamos, queda menos. Las palabras «il reste», «vendre», «perdre» dicen que la cantidad baja.',
        'compare': 'Para comparar, mira dos cantidades: una es más grande, la otra más pequeña, o son iguales.',
        'group': 'Los paquetes del mismo tamaño son grupos iguales. Las palabras «dans chaque» y «par paquets de» los anuncian.',
        'share': 'Repartir es hacer partes iguales: cada uno recibe tanto como los demás.',
        'ask': 'Estas palabras dicen qué buscamos («combien», «le total») o cuándo pasa («au départ», «à la fin»).',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get resultsStageTitle => '¡Etapa terminada!';

  @override
  String pathTableNodeCrowned(String label, String crown) {
    String _temp0 = intl.Intl.selectLogic(
      crown,
      {
        'golden': 'corona dorada',
        'other': 'corona',
      },
    );
    return '$label, $_temp0';
  }

  @override
  String quizBossTitleMultiplication(int number) {
    return 'Jefe de la tabla del $number';
  }

  @override
  String quizBossTitleUnit(String unit) {
    return 'Jefe · $unit';
  }

  @override
  String get quizBossLife => 'Vida del jefe';

  @override
  String quizBossLifeValue(int left, int total) {
    return '$left / $total';
  }

  @override
  String quizBossLifeSpoken(int left, int total) {
    return 'Vida del jefe: $left de $total';
  }

  @override
  String quizBossHit(int damage) {
    return '¡Golpe!\n−$damage';
  }

  @override
  String quizBossCriticalHit(int damage) {
    return '¡Golpe crítico!\n−$damage';
  }

  @override
  String get quizBossStrikeBack => '¡Contraataque!';

  @override
  String get quizBossDefeated => '¡Vencido!';

  @override
  String get quizBossFled => '¡Se escapa!';

  @override
  String get resultsBossDefeated => '¡Jefe vencido!';

  @override
  String get resultsBossFled => 'El monstruo se escapó';

  @override
  String rewardXpEarned(int xp) {
    return '+$xp';
  }

  @override
  String get rewardXpEarnedLabel => 'XP ganados';

  @override
  String rewardXpEarnedInline(int xp) {
    return '+$xp XP';
  }

  @override
  String rewardLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String rewardXpToNextLevel(int xp, int next) {
    return 'Faltan $xp XP para el nivel $next';
  }

  @override
  String rewardLevelProgressSpoken(int next) {
    return 'Progreso hacia el nivel $next';
  }

  @override
  String rewardNewBadgesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nuevas insignias',
      one: 'Nueva insignia',
    );
    return '$_temp0';
  }

  @override
  String get rewardBadgeFirstStep => 'Primer paso';

  @override
  String get rewardBadgePerfect => 'Sin fallos';

  @override
  String get rewardBadgeLightning => 'Relámpago';

  @override
  String get rewardBadgeSprinter => 'Velocista';

  @override
  String get rewardBadgeSurvivor => 'Superviviente';

  @override
  String get rewardBadgeRegular => 'Constante';

  @override
  String rewardBadgeTamerMultiplication(int number) {
    return 'Domador de la tabla del $number';
  }

  @override
  String rewardBadgeTamerUnit(String unit) {
    return 'Domador de «$unit»';
  }

  @override
  String get rewardBadgeAllFacts => 'Las 120';

  @override
  String get rewardBadgeFirstStepHint => 'Terminaste tu primera etapa.';

  @override
  String get rewardBadgePerfectHint => 'Una etapa sin ningún error.';

  @override
  String get rewardBadgeLightningHint => '20 respuestas relámpago en total.';

  @override
  String get rewardBadgeSprinterHint =>
      '20 respuestas correctas en Contrarreloj.';

  @override
  String get rewardBadgeSurvivorHint =>
      '30 respuestas correctas en Supervivencia.';

  @override
  String get rewardBadgeRegularHint => '7 días seguidos jugando.';

  @override
  String get rewardBadgeTamerHint => 'Venciste al jefe de esta tabla.';

  @override
  String get rewardBadgeAllFactsHint => 'Dominas todas las multiplicaciones.';

  @override
  String rewardLevelUpTitle(int level) {
    return '¡Nivel $level!';
  }

  @override
  String get rewardLevelUpHint => 'Subes de nivel, ¡muy bien!';

  @override
  String get rewardBadgeUnlocked => '¡Nueva insignia!';

  @override
  String get rewardTapToContinue => 'Toca la pantalla para continuar';

  @override
  String rewardStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get rewardNoStreak => 'Sin racha';

  @override
  String rewardStreakSpoken(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Racha de $days días',
      one: 'Racha de 1 día',
      zero: 'Sin racha',
    );
    return '$_temp0';
  }

  @override
  String get rewardDailyGoalTitle => 'Meta del día';

  @override
  String rewardDailyGoalValue(int earned, int goal) {
    return '$earned / $goal XP';
  }

  @override
  String rewardDailyGoalSpoken(int earned, int goal) {
    return 'Meta del día: $earned de $goal XP';
  }

  @override
  String pathCrownsSpoken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coronas',
      one: '1 corona',
      zero: 'Ninguna corona',
    );
    return '$_temp0';
  }

  @override
  String quizComboSpoken(int count) {
    return 'Combo de $count';
  }

  @override
  String quizComboMilestone(int count) {
    return '¡Combo de $count!';
  }

  @override
  String mascotGoalReminder(int xp) {
    return '¡Faltan $xp XP para tu meta del día!';
  }

  @override
  String get mascotGoalReached => '¡Meta del día cumplida, muy bien!';

  @override
  String get mascotEncouragement => 'No pasa nada, ¡tú puedes!';

  @override
  String mascotComboCheer(int count) {
    return '¡Bravo, $count seguidas!';
  }

  @override
  String get mascotCardTitle => 'Tu mascota crece';

  @override
  String mascotCardStage(int stage, int total, int level) {
    return 'Fase $stage de $total · la siguiente en el nivel $level';
  }

  @override
  String mascotCardLastStage(int stage, int total) {
    return 'Fase $stage de $total · tamaño máximo';
  }

  @override
  String mascotGrewTitle(String name) {
    return '¡$name creció!';
  }

  @override
  String mascotGrewHint(int stage, int total) {
    return 'Fase $stage de $total';
  }

  @override
  String get mascotPageTitle => 'Mi mascota';

  @override
  String get mascotOpenTooltip => 'Ver mi mascota';

  @override
  String get mascotNameLabel => 'Su nombre';

  @override
  String get mascotRename => 'Cambiar el nombre';

  @override
  String get mascotAccessoriesTitle => 'Accesorios';

  @override
  String get mascotSlotHead => 'Cabeza';

  @override
  String get mascotSlotEyes => 'Ojos';

  @override
  String get mascotSlotNeck => 'Cuello';

  @override
  String get mascotSlotBack => 'Espalda';

  @override
  String get mascotAccessoryCap => 'Gorra';

  @override
  String get mascotAccessoryRoundGlasses => 'Gafas redondas';

  @override
  String get mascotAccessoryCape => 'Capa';

  @override
  String get mascotAccessoryBowTie => 'Pajarita';

  @override
  String get mascotAccessoryScarf => 'Bufanda';

  @override
  String get mascotAccessoryWizardHat => 'Sombrero de mago';

  @override
  String get mascotAccessorySunglasses => 'Gafas de sol';

  @override
  String get mascotAccessoryBackpack => 'Mochila';

  @override
  String get mascotAccessoryHeadphones => 'Auriculares';

  @override
  String get mascotAccessoryMedal => 'Medalla';

  @override
  String get mascotAccessoryWings => 'Alas';

  @override
  String get mascotAccessoryKingCrown => 'Corona de rey';

  @override
  String get mascotAccessoryPartyHat => 'Gorro de fiesta';

  @override
  String get mascotAccessoryLightningGoggles => 'Gafas relámpago';

  @override
  String get mascotAccessoryGoldenCape => 'Capa dorada';

  @override
  String mascotUnlockCrown(int rank) {
    String _temp0 = intl.Intl.pluralLogic(
      rank,
      locale: localeName,
      other: 'Con la $rank.ª corona',
      one: 'Con la 1.ª corona',
    );
    return '$_temp0';
  }

  @override
  String get mascotUnlockRegular => 'Con la insignia Constante';

  @override
  String get mascotUnlockLightning => 'Con la insignia Relámpago';

  @override
  String get mascotUnlockAllFacts => 'Con la insignia Las 120';

  @override
  String mascotAccessoryWorn(String name) {
    return '$name, en tu mascota';
  }

  @override
  String mascotAccessoryLocked(String name, String hint) {
    return '$name, por desbloquear. $hint';
  }

  @override
  String get trainingTitle => 'Practicar';

  @override
  String get trainingSubtitle => 'Elige una o varias tablas.';

  @override
  String get trainingQuestionCountTitle => '¿Cuántas preguntas?';

  @override
  String get trainingTimerTitle => 'Cronómetro';

  @override
  String get trainingWithTimer => 'Con crono';

  @override
  String get trainingWithoutTimer => 'Sin crono';

  @override
  String get trainingNoTable => 'Elige al menos una tabla';

  @override
  String get trainingLaunch => 'Empezar';

  @override
  String get challengesTitle => 'Retos';

  @override
  String get challengeTimeAttackSubtitle =>
      '60 segundos, todas las respuestas que puedas';

  @override
  String get challengeSurvivalSubtitle => '3 vidas, cada vez más rápido';

  @override
  String get challengeSurvivalTimerNote => 'Aquí el cronómetro sigue activo.';

  @override
  String challengeDailyReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count preguntas elegidas para ti',
      one: '1 pregunta elegida para ti',
    );
    return '$_temp0';
  }

  @override
  String challengeDailyReviewDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count por repasar',
    );
    return '$_temp0';
  }

  @override
  String get challengeDailyReviewLocked => 'Primero juega una etapa del camino';

  @override
  String get resultsNewRecord => '¡Nuevo récord!';

  @override
  String get resultsFirstRecord => 'Tu primer récord';

  @override
  String trainingSummary(int tables, int questions) {
    String _temp0 = intl.Intl.pluralLogic(
      tables,
      locale: localeName,
      other: '$tables tablas',
      one: '1 tabla',
    );
    return '$_temp0 · $questions preguntas';
  }

  @override
  String challengeRecord(int score) {
    return 'Récord $score';
  }

  @override
  String resultsRecordBeaten(int previous) {
    return 'Récord anterior: $previous';
  }

  @override
  String resultsRecordScore(int score) {
    String _temp0 = intl.Intl.pluralLogic(
      score,
      locale: localeName,
      other: '$score respuestas correctas',
      one: '1 respuesta correcta',
    );
    return '$_temp0';
  }

  @override
  String challengeMonsterHuntSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count monstruos por domar',
      one: '1 monstruo por domar',
      zero: 'Ningún monstruo por ahora',
    );
    return '$_temp0';
  }

  @override
  String get duelTitle => 'Duelo';

  @override
  String get challengeDuelSubtitle => '2 jugadores, 1 teléfono';

  @override
  String get challengeCodeCardTitle => 'Tengo un código';

  @override
  String get challengeCodeCardSubtitle => 'Juega el reto de un amigo';

  @override
  String get challengeShareButton => 'Retar a un amigo';

  @override
  String get challengeCodeToBeat => 'a superar';

  @override
  String get challengeCodeYours => 'Tu código de reto';

  @override
  String challengeCodeSemantics(String characters) {
    return 'Código de reto: $characters';
  }

  @override
  String get challengeCodeCopy => 'Copiar el código';

  @override
  String get challengeCodeCopied => '¡Código copiado!';

  @override
  String get challengeCodeShareHint =>
      'Dale este código a un amigo: mismo modo, mismas tablas, ¡y tus puntos a superar!';

  @override
  String get challengeCodeOr => 'o';

  @override
  String get challengeCodeEntryTitle => '¿Te dieron un código?';

  @override
  String get challengeCodeEntryHint => 'ESCRIBE EL CÓDIGO AQUÍ';

  @override
  String get challengeCodePlay => 'Jugar este reto';

  @override
  String get challengeCodeErrorMalformed =>
      'Este código no existe. Un código tiene 10 letras y números.';

  @override
  String get challengeCodeErrorAltered =>
      'Una letra o un número no está bien. Revisa el código con tu amigo.';

  @override
  String get challengeCodeErrorVersion =>
      'Este reto viene de una versión más nueva de la app. Actualiza la app para jugarlo.';

  @override
  String get challengeCodeTablesAll => 'todas las tablas';

  @override
  String challengeCodeTablesOne(int table) {
    return 'tabla del $table';
  }

  @override
  String challengeCodeTableItem(int table) {
    return 'del $table';
  }

  @override
  String challengeCodeTablesMany(String first, String last) {
    return 'tablas $first y $last';
  }

  @override
  String get challengeCodeCardTablesAll => 'Todas las tablas';

  @override
  String challengeCodeCardTablesOne(int table) {
    return 'Tabla del $table';
  }

  @override
  String challengeCodeCardTablesMany(String first, String last) {
    return 'Tablas $first y $last';
  }

  @override
  String challengeCodeSubtitle(String mode, String tables) {
    return '$mode · $tables';
  }

  @override
  String get challengeOutcomeWon => '¡Reto ganado!';

  @override
  String get challengeOutcomeLost => '¡Esta vez no!';

  @override
  String get challengeOutcomeTie => '¡Empate!';

  @override
  String get challengeOutcomeToBeat => 'Puntos a superar';

  @override
  String get challengeOutcomeYours => 'Tus puntos';

  @override
  String challengeOutcomeCorrect(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'respuestas correctas',
      one: 'respuesta correcta',
      zero: 'respuestas correctas',
    );
    return '$_temp0';
  }

  @override
  String challengeOutcomeMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respuestas correctas más',
      one: '1 respuesta correcta más',
    );
    return '$_temp0';
  }

  @override
  String challengeOutcomeFewer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respuestas correctas menos',
      one: '1 respuesta correcta menos',
    );
    return '$_temp0';
  }

  @override
  String get challengeOutcomeSame => 'Las mismas respuestas correctas';

  @override
  String get challengeOutcomeResend => 'Devolver el reto';

  @override
  String get challengeOutcomeBack => 'Volver a los retos';

  @override
  String get duelPickIntro =>
      'Pongan el teléfono plano entre los dos. El jugador de arriba lee al revés.';

  @override
  String get duelSideTop => 'Jugador de arriba';

  @override
  String get duelSideBottom => 'Jugador de abajo';

  @override
  String get duelGuest => 'Invitado';

  @override
  String get duelGuestRule => 'Todas las tablas, sin XP';

  @override
  String get duelPickHint => 'Elijan dos jugadores distintos.';

  @override
  String get duelStart => '¡Vamos!';

  @override
  String get duelPlayerTaken => 'Ya elegido';

  @override
  String duelScore(int score, int target) {
    return '$score / $target';
  }

  @override
  String duelScoreSpoken(String name, int score, int target) {
    String _temp0 = intl.Intl.pluralLogic(
      score,
      locale: localeName,
      other: '$score respuestas correctas',
      one: '1 respuesta correcta',
      zero: 'ninguna respuesta correcta',
    );
    return '$name: $_temp0 de $target';
  }

  @override
  String get duelPause => 'Pausar el duelo';

  @override
  String get duelPauseTitle => 'Duelo en pausa';

  @override
  String get duelPauseMessage => 'Si paran ahora, nadie gana XP.';

  @override
  String get duelResume => 'Seguir';

  @override
  String get duelStop => 'Terminar el duelo';

  @override
  String get duelBlocked => '¡Uy! Espera un poco…';

  @override
  String duelAnswerRight(int answer) {
    return '$answer, respuesta correcta';
  }

  @override
  String duelAnswerWrong(int answer) {
    return '$answer, respuesta incorrecta';
  }

  @override
  String duelWinner(String name) {
    return '¡$name gana!';
  }

  @override
  String duelXpEarned(int xp) {
    return '+$xp XP';
  }

  @override
  String get duelGuestNoXp => 'Sin XP para un invitado';

  @override
  String get duelXpNotSaved => 'No se pudieron guardar los XP.';

  @override
  String get duelReplay => 'Volver a jugar';

  @override
  String get duelQuit => 'Salir';

  @override
  String get monstersPageTitle => 'Mis monstruos';

  @override
  String get monstersIntro =>
      'Estas cuentas todavía se te resisten. Acértalas para domar a sus monstruos.';

  @override
  String get monstersEmpty =>
      '¡Ningún monstruo a la vista, muy bien! Una cuenta fallada dos veces se convertirá en un pequeño monstruo por domar.';

  @override
  String get monsterToughnessVeryTough => 'Muy rebelde';

  @override
  String get monsterToughnessTough => 'Rebelde';

  @override
  String get monsterToughnessAlmostTamed => 'Casi domado';

  @override
  String monsterWildSpoken(String fact, String toughness) {
    return 'Monstruo $fact, $toughness';
  }

  @override
  String monsterTamedSpoken(String fact) {
    return 'Monstruo $fact, domado';
  }

  @override
  String get monstersHuntButton => 'Empezar la caza';

  @override
  String monstersHuntQuestions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count preguntas',
      one: '1 pregunta',
    );
    return '$_temp0';
  }

  @override
  String get monstersTamedTitle => 'Domados';

  @override
  String monstersTamedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count monstruos',
      one: '1 monstruo',
    );
    return '$_temp0';
  }

  @override
  String get pathMonstersOpenLittle => 'Ver mis monstruitos';

  @override
  String get leaderboardTitle => 'Clasificación';

  @override
  String get leaderboardWeekLabel => 'XP ganados esta semana';

  @override
  String get leaderboardResetHint => 'Vuelve a cero el lunes';

  @override
  String get leaderboardYou => 'Eres tú';

  @override
  String leaderboardXp(int xp) {
    return '$xp XP';
  }

  @override
  String leaderboardEntrySpoken(String nickname, int rank, int xp) {
    return '$nickname, puesto $rank, $xp XP';
  }

  @override
  String leaderboardEntryYouSpoken(String nickname, int rank, int xp) {
    return '$nickname, eres tú, puesto $rank, $xp XP';
  }

  @override
  String leaderboardChaseBehind(int xp, String nickname) {
    return '¡$xp XP más y alcanzas a $nickname!';
  }

  @override
  String leaderboardChaseTied(String nickname) {
    return '¡Tienes los mismos XP que $nickname!';
  }

  @override
  String get leaderboardChaseLeading => '¡Vas en cabeza esta semana!';

  @override
  String get leaderboardChaseNotStarted =>
      '¡Juega para ganar tus primeros XP de la semana!';

  @override
  String get leaderboardEntrySubtitle => '¿Quién ganó más XP esta semana?';

  @override
  String get settingsShowLeaderboard => 'Mostrar la clasificación';

  @override
  String get shopTitle => 'Tienda';

  @override
  String get shopEntrySubtitle => 'Avatares y temas para desbloquear';

  @override
  String shopCoinBalance(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count monedas',
      one: '1 moneda',
      zero: '0 monedas',
    );
    return '$_temp0';
  }

  @override
  String get shopTabAvatars => 'Avatares';

  @override
  String get shopTabThemes => 'Temas';

  @override
  String get shopWorn => 'Puesto';

  @override
  String get shopActive => 'Activo';

  @override
  String get shopChoose => 'Elegir';

  @override
  String shopWornLabel(String name) {
    return '$name, puesto';
  }

  @override
  String shopActiveLabel(String name) {
    return '$name, activo';
  }

  @override
  String shopChooseLabel(String name) {
    return 'Elegir $name';
  }

  @override
  String shopBuyLabel(String name, int price) {
    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: 'Comprar $name por $price monedas',
      one: 'Comprar $name por 1 moneda',
    );
    return '$_temp0';
  }

  @override
  String shopTooExpensiveLabel(String name, int price) {
    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: '$name, $price monedas: te faltan monedas',
      one: '$name, 1 moneda: te faltan monedas',
    );
    return '$_temp0';
  }

  @override
  String shopNotEnoughCoins(int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'Te faltan $missing monedas. ¡Sigue jugando para ganarlas!',
      one: 'Te falta 1 moneda. ¡Sigue jugando para ganarla!',
    );
    return '$_temp0';
  }

  @override
  String shopBuyTitle(String name) {
    return '¿Comprar $name?';
  }

  @override
  String shopBuyMessage(int price, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: '$price monedas',
      one: '1 moneda',
    );
    String _temp1 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'Te quedarán $left.',
      one: 'Te quedará 1.',
      zero: 'No te quedará ninguna.',
    );
    return 'Cuesta $_temp0. $_temp1';
  }

  @override
  String get shopBuyConfirm => 'Comprar';

  @override
  String shopPurchased(String name) {
    return '¡Genial, $name es tuyo! Toca «Elegir» para usarlo.';
  }

  @override
  String shopEarnHint(int xpPerCoin, int coinsPerCrown, int coinsPerBadge) {
    return 'Gana monedas jugando: 1 moneda cada $xpPerCoin XP, $coinsPerCrown por corona y $coinsPerBadge por insignia.';
  }

  @override
  String get shopErrorNotEnoughCoins =>
      'No tienes suficientes monedas para eso.';

  @override
  String get shopErrorAlreadyOwned => '¡Ya lo tienes!';

  @override
  String get shopAvatarFox => 'Zorro';

  @override
  String get shopAvatarPanda => 'Panda';

  @override
  String get shopAvatarRobot => 'Robot';

  @override
  String get shopAvatarAlien => 'Extraterrestre';

  @override
  String get shopAvatarUnicorn => 'Unicornio';

  @override
  String get shopAvatarDragon => 'Dragón';

  @override
  String get shopAvatarNinja => 'Ninja';

  @override
  String get shopAvatarKing => 'Rey';

  @override
  String get shopThemeLavender => 'Lavanda';

  @override
  String get shopThemeOcean => 'Océano';

  @override
  String get shopThemeForest => 'Bosque';

  @override
  String get shopThemeSunset => 'Atardecer';

  @override
  String get shopThemeNight => 'Noche';
}
