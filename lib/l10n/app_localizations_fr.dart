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
  String get comingSoonMessage => 'Bientôt disponible';

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
  String get quizModePath => 'Parcours';

  @override
  String get quizModeFreeTraining => 'Entraînement libre';

  @override
  String get quizModeTimeAttack => 'Contre-la-montre';

  @override
  String quizScoreSpoken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bonnes réponses',
      one: '1 bonne réponse',
      zero: 'Aucune bonne réponse',
    );
    return '$_temp0';
  }

  @override
  String quizClockLeftSpoken(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Encore $seconds secondes',
      one: 'Encore 1 seconde',
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
}
