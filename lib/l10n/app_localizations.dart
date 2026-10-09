import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('fr')];

  /// Provisional application name.
  ///
  /// In fr, this message translates to:
  /// **'Kid Matix'**
  String get appTitle;

  /// Screen-reader label of the bottom tab bar.
  ///
  /// In fr, this message translates to:
  /// **'Navigation principale'**
  String get mainNavigationLabel;

  /// Label of the learning path tab.
  ///
  /// In fr, this message translates to:
  /// **'Parcours'**
  String get tabLearningPath;

  /// Label of the free training tab.
  ///
  /// In fr, this message translates to:
  /// **'S\'entraîner'**
  String get tabTraining;

  /// Label of the challenges tab.
  ///
  /// In fr, this message translates to:
  /// **'Défis'**
  String get tabChallenges;

  /// Label of the profile tab.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// Shown on a tab whose feature is not built yet.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get comingSoonMessage;

  /// Button that runs a failed action again (load the players, save the profile). Infinitive verb, one line.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// Tooltip and screen-reader label of the back arrow at the top left of a screen.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get commonBack;

  /// Shown to a child when the local database fails. Friendly tone, informal "tu".
  ///
  /// In fr, this message translates to:
  /// **'Oups, on n\'a pas pu lire ou enregistrer tes données.'**
  String get errorStorage;

  /// Shown when the chosen player was deleted in the meantime.
  ///
  /// In fr, this message translates to:
  /// **'Ce joueur n\'existe plus.'**
  String get errorNotFound;

  /// Generic error shown to a child when nothing more precise is known. Friendly tone.
  ///
  /// In fr, this message translates to:
  /// **'Oups, quelque chose s\'est mal passé.'**
  String get errorUnknown;

  /// Title of the player selection screen shown at launch ("Who is playing?"). Big title, one line.
  ///
  /// In fr, this message translates to:
  /// **'Qui joue ?'**
  String get whoIsPlayingTitle;

  /// Line under the title of the player selection screen; speaks to the child with "tu".
  ///
  /// In fr, this message translates to:
  /// **'Choisis ton joueur pour commencer.'**
  String get whoIsPlayingSubtitle;

  /// Player level under the nickname on a player card.
  ///
  /// In fr, this message translates to:
  /// **'Niveau {level}'**
  String profileLevel(int level);

  /// Label of the dashed card that opens the creation of a player ("New player"). Fits on one line in half the screen width.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau joueur'**
  String get newPlayerButton;

  /// Footer of the player selection screen: how many players the phone can hold.
  ///
  /// In fr, this message translates to:
  /// **'Jusqu\'à {maxProfiles} joueurs sur ce téléphone.'**
  String profileLimitHint(int maxProfiles);

  /// Shown when a child tries to create a player but the phone already holds the maximum.
  ///
  /// In fr, this message translates to:
  /// **'Il y a déjà {maxProfiles} joueurs sur ce téléphone.'**
  String profileLimitReached(int maxProfiles);

  /// Title of the screen that creates a player ("New player").
  ///
  /// In fr, this message translates to:
  /// **'Nouveau joueur'**
  String get profileCreationTitle;

  /// Label above the nickname field of the player creation ("Your nickname"), informal "tu".
  ///
  /// In fr, this message translates to:
  /// **'Ton pseudo'**
  String get nicknameLabel;

  /// Placeholder inside the empty nickname field ("Type your nickname").
  ///
  /// In fr, this message translates to:
  /// **'Écris ton pseudo'**
  String get nicknameHint;

  /// Hint under the nickname field: allowed length.
  ///
  /// In fr, this message translates to:
  /// **'{minLength} à {maxLength} lettres ou chiffres'**
  String nicknameRulesHint(int minLength, int maxLength);

  /// Error under the nickname field when it is too short. Speaks to a child, no blame.
  ///
  /// In fr, this message translates to:
  /// **'Il faut au moins {minLength} lettres ou chiffres.'**
  String nicknameTooShort(int minLength);

  /// Error under the nickname field when it is too long.
  ///
  /// In fr, this message translates to:
  /// **'Pas plus de {maxLength} lettres ou chiffres.'**
  String nicknameTooLong(int maxLength);

  /// Error under the nickname field when it contains another character (punctuation, emoji).
  ///
  /// In fr, this message translates to:
  /// **'Seulement des lettres, des chiffres et des espaces.'**
  String get nicknameInvalidCharacters;

  /// Error under the nickname field when another player of the phone already uses this nickname, ignoring case and accents. Wording from the specifications.
  ///
  /// In fr, this message translates to:
  /// **'Ce nom est déjà pris sur ce téléphone.'**
  String get nicknameTaken;

  /// Heading of the grid of 12 characters in the player creation ("Choose your avatar").
  ///
  /// In fr, this message translates to:
  /// **'Choisis ton avatar'**
  String get avatarPickerLabel;

  /// Screen-reader label of one character of the avatar grid.
  ///
  /// In fr, this message translates to:
  /// **'Avatar {number}'**
  String avatarOptionLabel(int number);

  /// Heading of the row of color swatches in the player creation ("Your color").
  ///
  /// In fr, this message translates to:
  /// **'Ta couleur'**
  String get colorPickerLabel;

  /// Screen-reader name of the violet color swatch.
  ///
  /// In fr, this message translates to:
  /// **'Violet'**
  String get profileColorViolet;

  /// Screen-reader name of the green color swatch.
  ///
  /// In fr, this message translates to:
  /// **'Vert'**
  String get profileColorGreen;

  /// Screen-reader name of the yellow color swatch.
  ///
  /// In fr, this message translates to:
  /// **'Jaune'**
  String get profileColorYellow;

  /// Screen-reader name of the red color swatch.
  ///
  /// In fr, this message translates to:
  /// **'Rouge'**
  String get profileColorRed;

  /// Screen-reader name of the blue color swatch.
  ///
  /// In fr, this message translates to:
  /// **'Bleu'**
  String get profileColorBlue;

  /// Screen-reader name of the pink color swatch.
  ///
  /// In fr, this message translates to:
  /// **'Rose'**
  String get profileColorPink;

  /// Main button that creates the player and starts the game ("Let's go!"). One line.
  ///
  /// In fr, this message translates to:
  /// **'C\'est parti !'**
  String get createProfileButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
