// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Kid Matix';

  @override
  String get mainNavigationLabel => 'Navigation principale';

  @override
  String get tabLearningPath => 'Parcours';

  @override
  String get tabTraining => 'S\'entraîner';

  @override
  String get tabChallenges => 'Défis';

  @override
  String get tabProfile => 'Profil';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonBack => 'Retour';

  @override
  String get errorStorage =>
      'Oups, on n\'a pas pu lire ou enregistrer tes données.';

  @override
  String get errorNotFound => 'Ce joueur n\'existe plus.';

  @override
  String get errorUnknown => 'Oups, quelque chose s\'est mal passé.';

  @override
  String get whoIsPlayingTitle => 'Qui joue ?';

  @override
  String get whoIsPlayingSubtitle => 'Choisis ton joueur pour commencer.';

  @override
  String profileLevel(int level) {
    return 'Niveau $level';
  }

  @override
  String get newPlayerButton => 'Nouveau joueur';

  @override
  String profileLimitHint(int maxProfiles) {
    String _temp0 = intl.Intl.pluralLogic(
      maxProfiles,
      locale: localeName,
      other: 'Jusqu\'à $maxProfiles joueurs sur ce téléphone.',
      one: 'Jusqu\'à $maxProfiles joueur sur ce téléphone.',
    );
    return '$_temp0';
  }

  @override
  String profileLimitReached(int maxProfiles) {
    String _temp0 = intl.Intl.pluralLogic(
      maxProfiles,
      locale: localeName,
      other: 'Il y a déjà $maxProfiles joueurs sur ce téléphone.',
      one: 'Il y a déjà $maxProfiles joueur sur ce téléphone.',
    );
    return '$_temp0';
  }

  @override
  String get profileCreationTitle => 'Nouveau joueur';

  @override
  String get nicknameLabel => 'Ton pseudo';

  @override
  String get nicknameHint => 'Écris ton pseudo';

  @override
  String nicknameRulesHint(int minLength, int maxLength) {
    String _temp0 = intl.Intl.pluralLogic(
      maxLength,
      locale: localeName,
      other: '$minLength à $maxLength lettres ou chiffres',
      one: '$minLength à $maxLength lettre ou chiffre',
    );
    return '$_temp0';
  }

  @override
  String nicknameTooShort(int minLength) {
    String _temp0 = intl.Intl.pluralLogic(
      minLength,
      locale: localeName,
      other: 'Il faut au moins $minLength lettres ou chiffres.',
      one: 'Il faut au moins $minLength lettre ou chiffre.',
    );
    return '$_temp0';
  }

  @override
  String nicknameTooLong(int maxLength) {
    String _temp0 = intl.Intl.pluralLogic(
      maxLength,
      locale: localeName,
      other: 'Pas plus de $maxLength lettres ou chiffres.',
      one: 'Pas plus de $maxLength lettre ou chiffre.',
    );
    return '$_temp0';
  }

  @override
  String get nicknameInvalidCharacters =>
      'Seulement des lettres, des chiffres et des espaces.';

  @override
  String get nicknameTaken => 'Ce nom est déjà pris sur ce téléphone.';

  @override
  String get avatarPickerLabel => 'Choisis ton avatar';

  @override
  String avatarOptionLabel(int number) {
    return 'Avatar $number';
  }

  @override
  String get colorPickerLabel => 'Ta couleur';

  @override
  String get profileColorViolet => 'Violet';

  @override
  String get profileColorGreen => 'Vert';

  @override
  String get profileColorYellow => 'Jaune';

  @override
  String get profileColorRed => 'Rouge';

  @override
  String get profileColorBlue => 'Bleu';

  @override
  String get profileColorPink => 'Rose';

  @override
  String get createProfileButton => 'C\'est parti !';

  @override
  String get commonCancel => 'Annuler';

  @override
  String profileStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get profileStreakLabel => 'de série';

  @override
  String profileCrownsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'couronnes',
      one: 'couronne',
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
  String get masteryGridTitle => 'Mes tables';

  @override
  String get masteryStatusNotSeen => 'Nouveau';

  @override
  String get masteryStatusToReview => 'À revoir';

  @override
  String get masteryStatusInProgress => 'En cours';

  @override
  String get masteryStatusAcquired => 'Acquis';

  @override
  String get masteryStatusMastered => 'Maîtrisé';

  @override
  String masteryCellSpoken(String fact, String status) {
    return '$fact, $status';
  }

  @override
  String get rewardBadgesTitle => 'Mes badges';

  @override
  String rewardBadgeEarnedSpoken(String name) {
    return '$name, obtenu';
  }

  @override
  String rewardBadgeLockedSpoken(String name, String hint) {
    return '$name, à obtenir : $hint';
  }

  @override
  String get pathMonstersTitle => 'Mes monstres';

  @override
  String pathMonstersCount(int defeated, int total) {
    return '$defeated sur $total';
  }

  @override
  String pathMonsterDefeatedSpoken(int number) {
    return 'Monstre de la table de $number, vaincu';
  }

  @override
  String pathMonsterHiddenSpoken(int number) {
    return 'Monstre de la table de $number, pas encore vaincu';
  }

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsSoundSection => 'Sons';

  @override
  String get settingsSound => 'Sons';

  @override
  String get settingsVibration => 'Vibrations';

  @override
  String get settingsGameSection => 'Jeu';

  @override
  String get settingsTimer => 'Chrono';

  @override
  String get settingsTimerNormal => 'Normal';

  @override
  String get settingsTimerRelaxed => 'Détendu';

  @override
  String get settingsTimerOff => 'Sans';

  @override
  String get settingsDailyGoal => 'Objectif du jour';

  @override
  String get settingsUnlockAll => 'Tout débloquer';

  @override
  String get settingsReducedMotion => 'Animations réduites';

  @override
  String get commonClose => 'Fermer';

  @override
  String get settingsBackupSection => 'Sauvegarde';

  @override
  String get backupExport => 'Exporter mon profil';

  @override
  String get backupImport => 'Importer un profil';

  @override
  String get backupExportDone =>
      'Fichier prêt ! Ouvre-le dans Kid Matix sur l\'autre téléphone, avec « Importer un profil ».';

  @override
  String backupImportDone(String nickname) {
    return 'Profil de $nickname importé ! Retrouve-le avec « Changer de joueur ».';
  }

  @override
  String backupImportReplaced(String nickname) {
    return 'Progression de $nickname restaurée !';
  }

  @override
  String backupConflictTitle(String nickname) {
    return '$nickname existe déjà';
  }

  @override
  String backupConflictMessage(String nickname, int level) {
    return 'Ce téléphone a déjà un joueur $nickname. Le fichier contient $nickname au niveau $level.\n\nRemplacer efface la progression actuelle de $nickname sur ce téléphone. Renommer garde les deux joueurs.';
  }

  @override
  String get backupConflictReplace => 'Remplacer';

  @override
  String get backupConflictRename => 'Renommer';

  @override
  String get backupRenameTitle => 'Nouveau pseudo';

  @override
  String get backupRenameMessage =>
      'Choisis un autre pseudo pour le joueur importé.';

  @override
  String get backupRenameConfirm => 'Importer';

  @override
  String get errorBackupInvalid =>
      'Ce fichier n\'est pas une sauvegarde Kid Matix, ou il est abîmé.';

  @override
  String get errorBackupVersion =>
      'Cette sauvegarde vient d\'une version plus récente de Kid Matix. Mets l\'app à jour, puis réessaie.';

  @override
  String get parentalGateTitle => 'Demande à un adulte';

  @override
  String get parentalGateMessage =>
      'Cette action est réservée aux adultes. Écris ce nombre en chiffres :';

  @override
  String get parentalGateAnswerLabel => 'Nombre en chiffres';

  @override
  String get parentalGateConfirm => 'Valider';

  @override
  String get settingsReminderSection => 'Rappel';

  @override
  String get settingsReminderDaily => 'Rappel quotidien';

  @override
  String get settingsReminderTime => 'Heure du rappel';

  @override
  String get settingsReminderPermissionDenied =>
      'Les notifications sont bloquées. Autorise-les dans les réglages du téléphone pour recevoir le rappel.';

  @override
  String get settingsReminderError => 'Oups, le rappel n\'a pas pu être réglé.';

  @override
  String get settingsLanguageSection => 'Langue';

  @override
  String get settingsLanguageSystem => 'Langue du téléphone';

  @override
  String get languageNameFrench => 'Français';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageNameSpanish => 'Español';

  @override
  String get settingsLanguageError =>
      'Oups, la langue n\'a pas pu être enregistrée.';

  @override
  String get reminderNotificationBody => 'C\'est l\'heure de tes tables !';

  @override
  String get reminderChannelName => 'Rappel quotidien';

  @override
  String get reminderChannelDescription =>
      'Te rappelle de jouer chaque jour à l\'heure choisie.';

  @override
  String get settingsPlayerSection => 'Ce joueur';

  @override
  String get resetProgressButton => 'Réinitialiser ma progression';

  @override
  String get resetProgressConfirm => 'Réinitialiser';

  @override
  String get resetProgressDone => 'Ta progression est remise à zéro.';

  @override
  String settingsDailyGoalXp(int xp) {
    return '$xp XP';
  }

  @override
  String resetProgressTitle(String nickname) {
    return 'Réinitialiser $nickname ?';
  }

  @override
  String resetProgressMessage(String nickname) {
    return 'Ses étoiles, couronnes, badges, XP et records seront effacés. Son pseudo, ses réglages et le nom de sa mascotte restent. Pour confirmer, écris son pseudo : $nickname';
  }

  @override
  String get switchPlayerButton => 'Changer de joueur';

  @override
  String get editProfileButton => 'Modifier mon profil';

  @override
  String get deleteProfileButton => 'Supprimer ce joueur';

  @override
  String get profileEditTitle => 'Modifier mon profil';

  @override
  String get saveProfileButton => 'Enregistrer';

  @override
  String deleteProfileTitle(String nickname) {
    return 'Supprimer $nickname ?';
  }

  @override
  String deleteProfileMessage(String nickname) {
    return 'Toute sa progression sera effacée. Pour confirmer, écris son pseudo : $nickname';
  }

  @override
  String get deleteProfileConfirm => 'Supprimer';

  @override
  String get quizQuitTooltip => 'Quitter le quiz';

  @override
  String quizProgressLabel(int current, int total) {
    return 'Question $current sur $total';
  }

  @override
  String get quizTimeLeftLabel => 'Temps restant';

  @override
  String quizMultiplicationUnit(int number) {
    return 'Table de $number';
  }

  @override
  String get quizTrueFalseLabel => 'Vrai ou faux ?';

  @override
  String get quizHintMultipleChoice => 'Touche la bonne réponse';

  @override
  String get quizHintTrueFalse => 'Ce calcul est-il juste ?';

  @override
  String get quizFindOperationMultiplication => 'Quelle multiplication donne';

  @override
  String quizFindOperationSpokenMultiplication(int result) {
    return 'Quelle multiplication donne $result ?';
  }

  @override
  String get quizObjectsPictureLabel => 'Des mangues à compter';

  @override
  String quizObjectsPictureCounted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mangues',
      one: '1 mangue',
    );
    return '$_temp0';
  }

  @override
  String quizBundlesPictureLabel(int tens, int ones) {
    String _temp0 = intl.Intl.pluralLogic(
      tens,
      locale: localeName,
      other: '$tens paquets de dix',
      one: '1 paquet de dix',
      zero: 'Aucun paquet de dix',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ones,
      locale: localeName,
      other: '$ones bâtonnets',
      one: '1 bâtonnet',
      zero: 'aucun bâtonnet',
    );
    return '$_temp0 et $_temp1';
  }

  @override
  String quizNumberLinePictureLabel(String numbers) {
    return 'Droite des nombres : $numbers';
  }

  @override
  String get quizHintFindOperation => 'Touche la bonne opération';

  @override
  String get quizMatchPairsTitle => 'Relie chaque opération à son résultat';

  @override
  String quizMatchPairsProgress(int count, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paires trouvées sur $total',
      one: '1 paire trouvée sur $total',
      zero: 'Aucune paire trouvée sur $total',
    );
    return '$_temp0';
  }

  @override
  String get quizMatchPairsHintStart =>
      'Touche une opération, puis son résultat';

  @override
  String quizMatchPairsHintResult(String operation) {
    return 'Touche maintenant le résultat de $operation';
  }

  @override
  String quizMatchPairsHintOperation(String result) {
    return 'Touche maintenant l\'opération qui donne $result';
  }

  @override
  String quizMatchPairsFound(String label) {
    return '$label, paire trouvée';
  }

  @override
  String get quizTrue => 'Vrai';

  @override
  String get quizFalse => 'Faux';

  @override
  String get quizKeypadErase => 'Effacer';

  @override
  String get quizKeypadValidate => 'Valider';

  @override
  String get quizFeedbackRight => 'Bravo !';

  @override
  String get quizFeedbackWrong => 'Presque !';

  @override
  String get quizFeedbackTimeUp => 'Temps écoulé !';

  @override
  String get quizLightning => 'Éclair !';

  @override
  String quizMirrorReminder(String fact) {
    return 'Retiens aussi : $fact';
  }

  @override
  String quizHelpTitle(String unit) {
    return 'Fiche d\'aide · $unit';
  }

  @override
  String quizHelpDotGridLabel(int rows, int columns) {
    String _temp0 = intl.Intl.pluralLogic(
      rows,
      locale: localeName,
      other: '$rows rangées',
      one: '1 rangée',
    );
    String _temp1 = intl.Intl.pluralLogic(
      columns,
      locale: localeName,
      other: '$columns points',
      one: '1 point',
    );
    return '$_temp0 de $_temp1';
  }

  @override
  String get quizContinue => 'Continuer';

  @override
  String get quizQuitTitle => 'Quitter le quiz ?';

  @override
  String get quizQuitMessage =>
      'Tes réponses comptent pour ta progression, mais cette partie ne te donnera pas de récompense.';

  @override
  String get quizQuitConfirm => 'Quitter';

  @override
  String get quizQuitCancel => 'Continuer à jouer';

  @override
  String get quizSpokenTimes => 'fois';

  @override
  String get quizSpokenEquals => 'égale';

  @override
  String get quizSpokenBlank => 'combien';

  @override
  String get quizSpokenPlus => 'plus';

  @override
  String get quizSpokenLessThan => 'est plus petit que';

  @override
  String get quizSpokenGreaterThan => 'est plus grand que';

  @override
  String get quizSpokenHiddenNumber => 'nombre caché';

  @override
  String get quizModePath => 'Parcours';

  @override
  String get quizModeFreeTraining => 'Entraînement libre';

  @override
  String get quizModeTimeAttack => 'Contre-la-montre';

  @override
  String get quizModeSurvival => 'Survie';

  @override
  String quizLivesSpoken(int left, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: '$left vies sur $total',
      one: '1 vie sur $total',
      zero: 'Plus de vie',
    );
    return '$_temp0';
  }

  @override
  String get quizModeDailyReview => 'Révision du jour';

  @override
  String get quizModeMonsterHunt => 'Chasse aux monstres';

  @override
  String quizScoreSpoken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bonnes réponses',
      one: '1 bonne réponse',
      zero: 'Aucune bonne réponse',
    );
    return '$_temp0';
  }

  @override
  String quizClockLeftSpoken(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Encore $seconds secondes',
      one: 'Encore 1 seconde',
      zero: 'Plus de temps',
    );
    return '$_temp0';
  }

  @override
  String get resultsTitle => 'Partie terminée !';

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
      other: 'réussies',
      one: 'réussie',
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

    return '$secondsString s';
  }

  @override
  String get resultsAverageTimeLabel => 'en moyenne';

  @override
  String get resultsToReview => 'À revoir';

  @override
  String get resultsNothingToReview => 'Aucune erreur, bravo !';

  @override
  String get resultsContinue => 'Continuer';

  @override
  String get resultsReplay => 'Rejouer';

  @override
  String get pathStageDiscovery => 'Découverte';

  @override
  String get pathStageDiscoveryHint => 'La table et son astuce';

  @override
  String get pathStageTraining => 'Entraînement';

  @override
  String get pathStageTrainingHint => '10 questions mélangées';

  @override
  String get pathStageWriting => 'Écriture';

  @override
  String get pathStageWritingHint => 'Écris la réponse toi-même';

  @override
  String get pathStageSpeed => 'Vitesse';

  @override
  String get pathStageSpeedHint => '10 secondes par question';

  @override
  String get pathStageBoss => 'Combat de boss';

  @override
  String get pathStageBossHint => 'Bats le monstre de la table';

  @override
  String get pathStageReview => 'Révision';

  @override
  String get pathStageReviewHint => '15 questions sur les tables déjà vues';

  @override
  String pathStageNumbered(int number, String name) {
    return '$number · $name';
  }

  @override
  String pathCurrentStage(int number, int total, String name) {
    return 'Étape $number sur $total · $name';
  }

  @override
  String get pathPlay => 'Jouer';

  @override
  String get pathShowTable => 'Voir la table';

  @override
  String pathTableStars(int stars, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      stars,
      locale: localeName,
      other: '$stars étoiles sur $total',
      one: '1 étoile sur $total',
      zero: '0 étoile sur $total',
    );
    return '$_temp0';
  }

  @override
  String get pathCrownHint => 'Bats le boss pour gagner la couronne.';

  @override
  String get placementOfferTitle => 'Tu connais déjà des tables ?';

  @override
  String get placementOfferMessage =>
      'Réponds à une question par table, sans chrono. Chaque table que tu connais s\'ouvre tout de suite dans ton parcours.';

  @override
  String get placementOfferStart => 'Faire le test';

  @override
  String get placementOfferSkip => 'Passer';

  @override
  String placementQuestionProgress(int current, int total) {
    return 'Question $current sur $total';
  }

  @override
  String get placementUnknownAnswer => 'Je ne sais pas';

  @override
  String get placementQuitTooltip => 'Arrêter le test';

  @override
  String get placementQuitTitle => 'Arrêter le test ?';

  @override
  String get placementQuitMessage =>
      'Les tables déjà trouvées restent ouvertes dans ton parcours.';

  @override
  String get placementQuitCancel => 'Continuer le test';

  @override
  String get placementQuitConfirm => 'Arrêter';

  @override
  String placementResultTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tu connais déjà $count tables !',
      one: 'Tu connais déjà 1 table !',
      zero: 'Tout est à découvrir !',
    );
    return '$_temp0';
  }

  @override
  String placementResultSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Elles sont ouvertes dans ton parcours. Leurs étoiles restent à gagner.',
      one: 'Elle est ouverte dans ton parcours. Ses étoiles restent à gagner.',
      zero: 'Pas de souci, tu vas les apprendre une par une. Ton parcours commence par la table de 1.',
    );
    return '$_temp0';
  }

  @override
  String get placementLegendKnown => 'Déjà connue';

  @override
  String get placementLegendToDiscover => 'À découvrir';

  @override
  String placementTableKnown(String name) {
    return '$name, déjà connue';
  }

  @override
  String placementTableToDiscover(String name) {
    return '$name, à découvrir';
  }

  @override
  String get placementSeePath => 'Voir mon parcours';

  @override
  String get pathTableBack => 'Retour au parcours';

  @override
  String pathTableNodeDone(String name, int stars) {
    String _temp0 = intl.Intl.pluralLogic(
      stars,
      locale: localeName,
      other: '$stars étoiles',
      one: '1 étoile',
      zero: 'aucune étoile',
    );
    return '$name, terminée, $_temp0';
  }

  @override
  String pathTableNodeCurrent(String name) {
    return '$name, en cours';
  }

  @override
  String pathTableNodeOpen(String name) {
    return '$name, ouverte';
  }

  @override
  String pathTableNodeLocked(String name) {
    return '$name, verrouillée';
  }

  @override
  String pathReviewNodeLocked(String name) {
    return '$name, verrouillée';
  }

  @override
  String get pathLocked => 'Verrouillée';

  @override
  String starsLabel(int stars, int max) {
    String _temp0 = intl.Intl.pluralLogic(
      stars,
      locale: localeName,
      other: '$stars étoiles sur $max',
      one: '1 étoile sur $max',
      zero: 'Aucune étoile sur $max',
    );
    return '$_temp0';
  }

  @override
  String pathDiscoveryTitle(int number) {
    return 'Voici la table de $number';
  }

  @override
  String get pathDiscoveryProgress => 'Avant la première question';

  @override
  String get pathTipTitle => 'L\'astuce';

  @override
  String get pathDiscoveryStart => 'À moi de jouer';

  @override
  String pathMultiplicationTip(String table) {
    String _temp0 = intl.Intl.selectLogic(
      table,
      {
        '1': 'Multiplier par 1 ne change rien : 1 × 7 = 7.',
        '2': 'Multiplier par 2, c\'est ajouter le nombre à lui-même : 2 × 6 = 6 + 6.',
        '3': 'Les résultats avancent de 3 en 3 : 3, 6, 9, 12…',
        '4': 'Multiplier par 4, c\'est doubler deux fois : 4 × 6, c\'est le double de 12.',
        '5':
            'Les résultats de la table de 5 finissent toujours par 0 ou par 5.',
        '6': '6 fois un nombre pair finit par le même chiffre : 6 × 4 = 24.',
        '7': 'Pour 7 × 8, pense à 5, 6, 7, 8 : 56 = 7 × 8.',
        '8': 'Multiplier par 8, c\'est doubler trois fois : 8 × 3 = 24.',
        '9': 'Les deux chiffres du résultat font toujours 9 : 9 × 4 = 36 et 3 + 6 = 9.',
        '10': 'Multiplier par 10, c\'est ajouter un 0 à droite : 10 × 7 = 70.',
        '11': 'Jusqu\'à 11 × 9, on écrit le chiffre deux fois : 11 × 4 = 44.',
        'other':
            '12 fois un nombre, c\'est 10 fois plus 2 fois : 12 × 3 = 30 + 6.',
      },
    );
    return '$_temp0';
  }

  @override
  String get resultsStageTitle => 'Étape terminée !';

  @override
  String pathTableNodeCrowned(String label, String crown) {
    String _temp0 = intl.Intl.selectLogic(
      crown,
      {
        'golden': 'couronne dorée',
        'other': 'couronne',
      },
    );
    return '$label, $_temp0';
  }

  @override
  String quizBossTitleMultiplication(int number) {
    return 'Boss de la table de $number';
  }

  @override
  String get quizBossLife => 'Vie du boss';

  @override
  String quizBossLifeValue(int left, int total) {
    return '$left / $total';
  }

  @override
  String quizBossLifeSpoken(int left, int total) {
    return 'Vie du boss : $left sur $total';
  }

  @override
  String quizBossHit(int damage) {
    return 'Touché !\n−$damage';
  }

  @override
  String quizBossCriticalHit(int damage) {
    return 'Coup critique !\n−$damage';
  }

  @override
  String get quizBossStrikeBack => 'Riposte !';

  @override
  String get quizBossDefeated => 'Vaincu !';

  @override
  String get quizBossFled => 'Il s\'enfuit !';

  @override
  String get resultsBossDefeated => 'Boss vaincu !';

  @override
  String get resultsBossFled => 'Le monstre s\'est enfui';

  @override
  String rewardXpEarned(int xp) {
    return '+$xp';
  }

  @override
  String get rewardXpEarnedLabel => 'XP gagnés';

  @override
  String rewardXpEarnedInline(int xp) {
    return '+$xp XP';
  }

  @override
  String rewardLevel(int level) {
    return 'Niveau $level';
  }

  @override
  String rewardXpToNextLevel(int xp, int next) {
    return 'Encore $xp XP pour le niveau $next';
  }

  @override
  String rewardLevelProgressSpoken(int next) {
    return 'Progression vers le niveau $next';
  }

  @override
  String rewardNewBadgesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nouveaux badges',
      one: 'Nouveau badge',
    );
    return '$_temp0';
  }

  @override
  String get rewardBadgeFirstStep => 'Premier pas';

  @override
  String get rewardBadgePerfect => 'Sans-faute';

  @override
  String get rewardBadgeLightning => 'Éclair';

  @override
  String get rewardBadgeSprinter => 'Sprinter';

  @override
  String get rewardBadgeSurvivor => 'Survivant';

  @override
  String get rewardBadgeRegular => 'Régulier';

  @override
  String rewardBadgeTamerMultiplication(int number) {
    return 'Dompteur de la table de $number';
  }

  @override
  String get rewardBadgeAllFacts => 'Les 120';

  @override
  String get rewardBadgeFirstStepHint => 'Tu as terminé ta première étape.';

  @override
  String get rewardBadgePerfectHint => 'Une étape sans aucune erreur.';

  @override
  String get rewardBadgeLightningHint => '20 réponses éclair au total.';

  @override
  String get rewardBadgeSprinterHint =>
      '20 bonnes réponses en Contre-la-montre.';

  @override
  String get rewardBadgeSurvivorHint => '30 bonnes réponses en Survie.';

  @override
  String get rewardBadgeRegularHint => '7 jours de jeu d\'affilée.';

  @override
  String get rewardBadgeTamerHint => 'Tu as battu le boss de cette table.';

  @override
  String get rewardBadgeAllFactsHint =>
      'Tu maîtrises toutes les multiplications.';

  @override
  String rewardLevelUpTitle(int level) {
    return 'Niveau $level !';
  }

  @override
  String get rewardLevelUpHint => 'Tu passes au niveau supérieur, bravo.';

  @override
  String get rewardBadgeUnlocked => 'Nouveau badge !';

  @override
  String get rewardTapToContinue => 'Touche l\'écran pour continuer';

  @override
  String rewardStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get rewardNoStreak => 'Pas de série';

  @override
  String rewardStreakSpoken(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Série de $days jours',
      one: 'Série de 1 jour',
      zero: 'Pas de série',
    );
    return '$_temp0';
  }

  @override
  String get rewardDailyGoalTitle => 'Objectif du jour';

  @override
  String rewardDailyGoalValue(int earned, int goal) {
    return '$earned / $goal XP';
  }

  @override
  String rewardDailyGoalSpoken(int earned, int goal) {
    return 'Objectif du jour : $earned sur $goal XP';
  }

  @override
  String pathCrownsSpoken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count couronnes',
      one: '1 couronne',
      zero: 'Aucune couronne',
    );
    return '$_temp0';
  }

  @override
  String quizComboSpoken(int count) {
    return 'Combo de $count';
  }

  @override
  String quizComboMilestone(int count) {
    return 'Combo de $count !';
  }

  @override
  String mascotGoalReminder(int xp) {
    return 'Encore $xp XP pour ton objectif du jour !';
  }

  @override
  String get mascotGoalReached => 'Objectif du jour atteint, bravo !';

  @override
  String get mascotEncouragement => 'Pas grave, tu vas y arriver !';

  @override
  String mascotComboCheer(int count) {
    return 'Bravo, $count d\'affilée !';
  }

  @override
  String get mascotCardTitle => 'Ta mascotte grandit';

  @override
  String mascotCardStage(int stage, int total, int level) {
    return 'Stade $stage sur $total · prochain au niveau $level';
  }

  @override
  String mascotCardLastStage(int stage, int total) {
    return 'Stade $stage sur $total · taille maximale';
  }

  @override
  String mascotGrewTitle(String name) {
    return '$name a grandi !';
  }

  @override
  String mascotGrewHint(int stage, int total) {
    return 'Stade $stage sur $total';
  }

  @override
  String get mascotPageTitle => 'Ma mascotte';

  @override
  String get mascotOpenTooltip => 'Voir ma mascotte';

  @override
  String get mascotNameLabel => 'Son nom';

  @override
  String get mascotRename => 'Changer le nom';

  @override
  String get mascotAccessoriesTitle => 'Accessoires';

  @override
  String get mascotSlotHead => 'Tête';

  @override
  String get mascotSlotEyes => 'Yeux';

  @override
  String get mascotSlotNeck => 'Cou';

  @override
  String get mascotSlotBack => 'Dos';

  @override
  String get mascotAccessoryCap => 'Casquette';

  @override
  String get mascotAccessoryRoundGlasses => 'Lunettes rondes';

  @override
  String get mascotAccessoryCape => 'Cape';

  @override
  String get mascotAccessoryBowTie => 'Nœud papillon';

  @override
  String get mascotAccessoryScarf => 'Écharpe';

  @override
  String get mascotAccessoryWizardHat => 'Chapeau de magicien';

  @override
  String get mascotAccessorySunglasses => 'Lunettes de soleil';

  @override
  String get mascotAccessoryBackpack => 'Sac à dos';

  @override
  String get mascotAccessoryHeadphones => 'Casque audio';

  @override
  String get mascotAccessoryMedal => 'Médaille';

  @override
  String get mascotAccessoryWings => 'Ailes';

  @override
  String get mascotAccessoryKingCrown => 'Couronne de roi';

  @override
  String get mascotAccessoryPartyHat => 'Chapeau de fête';

  @override
  String get mascotAccessoryLightningGoggles => 'Lunettes éclair';

  @override
  String get mascotAccessoryGoldenCape => 'Cape dorée';

  @override
  String mascotUnlockCrown(int rank) {
    String _temp0 = intl.Intl.pluralLogic(
      rank,
      locale: localeName,
      other: 'À la ${rank}e couronne',
      one: 'À la 1re couronne',
    );
    return '$_temp0';
  }

  @override
  String get mascotUnlockRegular => 'Avec le badge Régulier';

  @override
  String get mascotUnlockLightning => 'Avec le badge Éclair';

  @override
  String get mascotUnlockAllFacts => 'Avec le badge Les 120';

  @override
  String mascotAccessoryWorn(String name) {
    return '$name, sur ta mascotte';
  }

  @override
  String mascotAccessoryLocked(String name, String hint) {
    return '$name, à débloquer. $hint';
  }

  @override
  String get trainingTitle => 'S\'entraîner';

  @override
  String get trainingSubtitle => 'Choisis une ou plusieurs tables.';

  @override
  String get trainingQuestionCountTitle => 'Combien de questions ?';

  @override
  String get trainingTimerTitle => 'Chrono';

  @override
  String get trainingWithTimer => 'Avec chrono';

  @override
  String get trainingWithoutTimer => 'Sans chrono';

  @override
  String get trainingNoTable => 'Choisis au moins une table';

  @override
  String get trainingLaunch => 'Lancer';

  @override
  String get challengesTitle => 'Défis';

  @override
  String get challengeTimeAttackSubtitle =>
      '60 secondes, un maximum de réponses';

  @override
  String get challengeSurvivalSubtitle => '3 vies, de plus en plus vite';

  @override
  String get challengeSurvivalTimerNote => 'Ici, le chrono reste actif.';

  @override
  String challengeDailyReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions choisies pour toi',
      one: '1 question choisie pour toi',
    );
    return '$_temp0';
  }

  @override
  String challengeDailyReviewDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count à revoir',
    );
    return '$_temp0';
  }

  @override
  String get challengeDailyReviewLocked =>
      'Joue d\'abord une étape du parcours';

  @override
  String get resultsNewRecord => 'Nouveau record !';

  @override
  String get resultsFirstRecord => 'Ton premier record';

  @override
  String trainingSummary(int tables, int questions) {
    String _temp0 = intl.Intl.pluralLogic(
      tables,
      locale: localeName,
      other: '$tables tables',
      one: '1 table',
    );
    return '$_temp0 · $questions questions';
  }

  @override
  String challengeRecord(int score) {
    return 'Record $score';
  }

  @override
  String resultsRecordBeaten(int previous) {
    return 'Ancien record : $previous';
  }

  @override
  String resultsRecordScore(int score) {
    String _temp0 = intl.Intl.pluralLogic(
      score,
      locale: localeName,
      other: '$score bonnes réponses',
      one: '1 bonne réponse',
    );
    return '$_temp0';
  }

  @override
  String challengeMonsterHuntSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count monstres à apprivoiser',
      one: '1 monstre à apprivoiser',
      zero: 'Aucun monstre pour l\'instant',
    );
    return '$_temp0';
  }

  @override
  String get duelTitle => 'Duel';

  @override
  String get challengeDuelSubtitle => '2 joueurs, 1 téléphone';

  @override
  String get challengeCodeCardTitle => 'J\'ai un code';

  @override
  String get challengeCodeCardSubtitle => 'Rejoue le défi d\'un ami';

  @override
  String get challengeShareButton => 'Défier un ami';

  @override
  String get challengeCodeToBeat => 'à battre';

  @override
  String get challengeCodeYours => 'Ton code de défi';

  @override
  String challengeCodeSemantics(String characters) {
    return 'Code de défi : $characters';
  }

  @override
  String get challengeCodeCopy => 'Copier le code';

  @override
  String get challengeCodeCopied => 'Code copié !';

  @override
  String get challengeCodeShareHint =>
      'Donne ce code à un ami : même mode, mêmes tables, et ton score à battre !';

  @override
  String get challengeCodeOr => 'ou';

  @override
  String get challengeCodeEntryTitle => 'Tu as reçu un code ?';

  @override
  String get challengeCodeEntryHint => 'ÉCRIS LE CODE ICI';

  @override
  String get challengeCodePlay => 'Jouer ce défi';

  @override
  String get challengeCodeErrorMalformed =>
      'Ce code n\'existe pas. Un code a 10 lettres et chiffres.';

  @override
  String get challengeCodeErrorAltered =>
      'Une lettre ou un chiffre ne va pas. Vérifie le code avec ton ami.';

  @override
  String get challengeCodeErrorVersion =>
      'Ce défi vient d\'une version plus récente de l\'app. Mets l\'app à jour pour le jouer.';

  @override
  String get challengeCodeTablesAll => 'toutes les tables';

  @override
  String challengeCodeTablesOne(int table) {
    return 'table de $table';
  }

  @override
  String challengeCodeTableItem(int table) {
    return 'de $table';
  }

  @override
  String challengeCodeTablesMany(String first, String last) {
    return 'tables $first et $last';
  }

  @override
  String get challengeCodeCardTablesAll => 'Toutes les tables';

  @override
  String challengeCodeCardTablesOne(int table) {
    return 'Table de $table';
  }

  @override
  String challengeCodeCardTablesMany(String first, String last) {
    return 'Tables $first et $last';
  }

  @override
  String challengeCodeSubtitle(String mode, String tables) {
    return '$mode · $tables';
  }

  @override
  String get challengeOutcomeWon => 'Défi gagné !';

  @override
  String get challengeOutcomeLost => 'Pas cette fois !';

  @override
  String get challengeOutcomeTie => 'Égalité !';

  @override
  String get challengeOutcomeToBeat => 'Score à battre';

  @override
  String get challengeOutcomeYours => 'Ton score';

  @override
  String challengeOutcomeCorrect(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bonnes réponses',
      one: 'bonne réponse',
      zero: 'bonne réponse',
    );
    return '$_temp0';
  }

  @override
  String challengeOutcomeMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bonnes réponses de plus',
      one: '1 bonne réponse de plus',
    );
    return '$_temp0';
  }

  @override
  String challengeOutcomeFewer(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bonnes réponses de moins',
      one: '1 bonne réponse de moins',
    );
    return '$_temp0';
  }

  @override
  String get challengeOutcomeSame => 'Autant de bonnes réponses';

  @override
  String get challengeOutcomeResend => 'Renvoyer un défi';

  @override
  String get challengeOutcomeBack => 'Retour aux défis';

  @override
  String get duelPickIntro =>
      'Posez le téléphone à plat entre vous deux. Le joueur du haut lit à l\'envers.';

  @override
  String get duelSideTop => 'Joueur du haut';

  @override
  String get duelSideBottom => 'Joueur du bas';

  @override
  String get duelGuest => 'Invité';

  @override
  String get duelGuestRule => 'Toutes les tables, sans XP';

  @override
  String get duelPickHint => 'Choisissez deux joueurs différents.';

  @override
  String get duelStart => 'C\'est parti !';

  @override
  String get duelPlayerTaken => 'Déjà choisi';

  @override
  String duelScore(int score, int target) {
    return '$score / $target';
  }

  @override
  String duelScoreSpoken(String name, int score, int target) {
    String _temp0 = intl.Intl.pluralLogic(
      score,
      locale: localeName,
      other: '$score bonnes réponses',
      one: '1 bonne réponse',
      zero: 'aucune bonne réponse',
    );
    return '$name : $_temp0 sur $target';
  }

  @override
  String get duelPause => 'Mettre le duel en pause';

  @override
  String get duelPauseTitle => 'Duel en pause';

  @override
  String get duelPauseMessage =>
      'Si vous arrêtez maintenant, personne ne gagne d\'XP.';

  @override
  String get duelResume => 'Reprendre';

  @override
  String get duelStop => 'Arrêter le duel';

  @override
  String get duelBlocked => 'Oups ! Attends un peu…';

  @override
  String duelAnswerRight(int answer) {
    return '$answer, bonne réponse';
  }

  @override
  String duelAnswerWrong(int answer) {
    return '$answer, mauvaise réponse';
  }

  @override
  String duelWinner(String name) {
    return '$name gagne !';
  }

  @override
  String duelXpEarned(int xp) {
    return '+$xp XP';
  }

  @override
  String get duelGuestNoXp => 'Pas d\'XP pour un invité';

  @override
  String get duelXpNotSaved => 'Les XP n\'ont pas pu être enregistrés.';

  @override
  String get duelReplay => 'Rejouer';

  @override
  String get duelQuit => 'Quitter';

  @override
  String get monstersPageTitle => 'Mes monstres';

  @override
  String get monstersIntro =>
      'Ces calculs te résistent encore. Réussis-les pour apprivoiser leurs monstres.';

  @override
  String get monstersEmpty =>
      'Aucun monstre en vue, bravo ! Un calcul raté deux fois deviendra un petit monstre à apprivoiser.';

  @override
  String get monsterToughnessVeryTough => 'Très coriace';

  @override
  String get monsterToughnessTough => 'Coriace';

  @override
  String get monsterToughnessAlmostTamed => 'Presque apprivoisé';

  @override
  String monsterWildSpoken(String fact, String toughness) {
    return 'Monstre $fact, $toughness';
  }

  @override
  String monsterTamedSpoken(String fact) {
    return 'Monstre $fact, apprivoisé';
  }

  @override
  String get monstersHuntButton => 'Lancer la chasse';

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
  String get monstersTamedTitle => 'Apprivoisés';

  @override
  String monstersTamedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count monstres',
      one: '1 monstre',
    );
    return '$_temp0';
  }

  @override
  String get pathMonstersOpenLittle => 'Voir mes petits monstres';

  @override
  String get leaderboardTitle => 'Classement';

  @override
  String get leaderboardWeekLabel => 'XP gagnés cette semaine';

  @override
  String get leaderboardResetHint => 'Remise à zéro lundi';

  @override
  String get leaderboardYou => 'C\'est toi';

  @override
  String leaderboardXp(int xp) {
    return '$xp XP';
  }

  @override
  String leaderboardEntrySpoken(String nickname, int rank, int xp) {
    return '$nickname, place $rank, $xp XP';
  }

  @override
  String leaderboardEntryYouSpoken(String nickname, int rank, int xp) {
    return '$nickname, c\'est toi, place $rank, $xp XP';
  }

  @override
  String leaderboardChaseBehind(int xp, String nickname) {
    return 'Encore $xp XP et tu rattrapes $nickname !';
  }

  @override
  String leaderboardChaseTied(String nickname) {
    return 'Tu es à égalité avec $nickname !';
  }

  @override
  String get leaderboardChaseLeading => 'Tu es en tête cette semaine !';

  @override
  String get leaderboardChaseNotStarted =>
      'Joue pour gagner tes premiers XP de la semaine !';

  @override
  String get leaderboardEntrySubtitle =>
      'Qui a gagné le plus d\'XP cette semaine ?';

  @override
  String get settingsShowLeaderboard => 'Afficher le classement';

  @override
  String get shopTitle => 'Boutique';

  @override
  String get shopEntrySubtitle => 'Avatars et thèmes à débloquer';

  @override
  String shopCoinBalance(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pièces',
      one: '1 pièce',
      zero: '0 pièce',
    );
    return '$_temp0';
  }

  @override
  String get shopTabAvatars => 'Avatars';

  @override
  String get shopTabThemes => 'Thèmes';

  @override
  String get shopWorn => 'Porté';

  @override
  String get shopActive => 'Actif';

  @override
  String get shopChoose => 'Choisir';

  @override
  String shopWornLabel(String name) {
    return '$name, porté';
  }

  @override
  String shopActiveLabel(String name) {
    return '$name, actif';
  }

  @override
  String shopChooseLabel(String name) {
    return 'Choisir $name';
  }

  @override
  String shopBuyLabel(String name, int price) {
    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: 'Acheter $name pour $price pièces',
      one: 'Acheter $name pour 1 pièce',
    );
    return '$_temp0';
  }

  @override
  String shopTooExpensiveLabel(String name, int price) {
    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: '$name, $price pièces : il te manque des pièces',
      one: '$name, 1 pièce : il te manque des pièces',
    );
    return '$_temp0';
  }

  @override
  String shopNotEnoughCoins(int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'Il te manque $missing pièces. Joue encore pour les gagner !',
      one: 'Il te manque 1 pièce. Joue encore pour la gagner !',
    );
    return '$_temp0';
  }

  @override
  String shopBuyTitle(String name) {
    return 'Acheter $name ?';
  }

  @override
  String shopBuyMessage(int price, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      price,
      locale: localeName,
      other: '$price pièces',
      one: '1 pièce',
    );
    String _temp1 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'Il t\'en restera $left.',
      one: 'Il t\'en restera 1.',
      zero: 'Il ne t\'en restera aucune.',
    );
    return 'Ça coûte $_temp0. $_temp1';
  }

  @override
  String get shopBuyConfirm => 'Acheter';

  @override
  String shopPurchased(String name) {
    return 'Bravo, $name est à toi ! Touche « Choisir » pour l\'utiliser.';
  }

  @override
  String shopEarnHint(int xpPerCoin, int coinsPerCrown, int coinsPerBadge) {
    return 'Gagne des pièces en jouant : 1 pièce tous les $xpPerCoin XP, $coinsPerCrown par couronne et $coinsPerBadge par badge.';
  }

  @override
  String get shopErrorNotEnoughCoins => 'Tu n\'as pas assez de pièces pour ça.';

  @override
  String get shopErrorAlreadyOwned => 'Tu l\'as déjà !';

  @override
  String get shopAvatarFox => 'Renard';

  @override
  String get shopAvatarPanda => 'Panda';

  @override
  String get shopAvatarRobot => 'Robot';

  @override
  String get shopAvatarAlien => 'Extraterrestre';

  @override
  String get shopAvatarUnicorn => 'Licorne';

  @override
  String get shopAvatarDragon => 'Dragon';

  @override
  String get shopAvatarNinja => 'Ninja';

  @override
  String get shopAvatarKing => 'Roi';

  @override
  String get shopThemeLavender => 'Lavande';

  @override
  String get shopThemeOcean => 'Océan';

  @override
  String get shopThemeForest => 'Forêt';

  @override
  String get shopThemeSunset => 'Coucher de soleil';

  @override
  String get shopThemeNight => 'Nuit';
}
