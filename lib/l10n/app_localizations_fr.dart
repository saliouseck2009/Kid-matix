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
  String get quizProvisionalStart => 'Jouer à la table de 5';

  @override
  String get quizModeFreeTraining => 'Entraînement libre';

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
}
