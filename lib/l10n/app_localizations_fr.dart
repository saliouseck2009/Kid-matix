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
    return 'Jusqu\'à $maxProfiles joueurs sur ce téléphone.';
  }

  @override
  String profileLimitReached(int maxProfiles) {
    return 'Il y a déjà $maxProfiles joueurs sur ce téléphone.';
  }

  @override
  String get profileCreationTitle => 'Nouveau joueur';

  @override
  String get nicknameLabel => 'Ton pseudo';

  @override
  String get nicknameHint => 'Écris ton pseudo';

  @override
  String nicknameRulesHint(int minLength, int maxLength) {
    return '$minLength à $maxLength lettres ou chiffres';
  }

  @override
  String nicknameTooShort(int minLength) {
    return 'Il faut au moins $minLength lettres ou chiffres.';
  }

  @override
  String nicknameTooLong(int maxLength) {
    return 'Pas plus de $maxLength lettres ou chiffres.';
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
}
