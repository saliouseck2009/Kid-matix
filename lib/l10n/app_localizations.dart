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

  /// Provisional application name, shown as the task-switcher title. Brand name: keep as is, do not translate.
  ///
  /// In fr, this message translates to:
  /// **'Kid Matix'**
  String get appTitle;

  /// Screen-reader label of the bottom tab bar of the main shell ("Main navigation"). Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'Navigation principale'**
  String get mainNavigationLabel;

  /// Label of the learning path tab in the bottom tab bar, also the title of its placeholder page. Noun ("Path"), one short word.
  ///
  /// In fr, this message translates to:
  /// **'Parcours'**
  String get tabLearningPath;

  /// Label of the free training tab in the bottom tab bar, also the title of its placeholder page. Infinitive verb ("Practice"), one short word.
  ///
  /// In fr, this message translates to:
  /// **'S\'entraîner'**
  String get tabTraining;

  /// Label of the challenges tab in the bottom tab bar, also the title of its placeholder page. Plural noun ("Challenges"), one short word.
  ///
  /// In fr, this message translates to:
  /// **'Défis'**
  String get tabChallenges;

  /// Label of the profile tab in the bottom tab bar, also the title of its placeholder page. Noun ("Profile"), one short word.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// Centered message on the placeholder page of a tab whose feature is not built yet ("Coming soon"). One line.
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

  /// Error shown to a child on the "Qui joue ?" screen or under the button of the player creation when the local database fails. Friendly tone, informal "tu", no technical words.
  ///
  /// In fr, this message translates to:
  /// **'Oups, on n\'a pas pu lire ou enregistrer tes données.'**
  String get errorStorage;

  /// Error shown on the "Qui joue ?" screen or the player creation when the chosen player was deleted in the meantime ("This player no longer exists").
  ///
  /// In fr, this message translates to:
  /// **'Ce joueur n\'existe plus.'**
  String get errorNotFound;

  /// Generic error shown to a child on the "Qui joue ?" screen or the player creation when nothing more precise is known. Friendly tone.
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

  /// Player level under the nickname on a player card of the "Qui joue ?" screen ("Level 4"). Short, one line in half the screen width.
  ///
  /// In fr, this message translates to:
  /// **'Niveau {level}'**
  String profileLevel(int level);

  /// Label of the dashed card that opens the creation of a player ("New player"). Fits on one line in half the screen width.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau joueur'**
  String get newPlayerButton;

  /// Footer of the "Qui joue ?" screen: how many players the phone can hold ("Up to 10 players on this phone"). One or two lines.
  ///
  /// In fr, this message translates to:
  /// **'{maxProfiles, plural, one{Jusqu\'à {maxProfiles} joueur sur ce téléphone.} other{Jusqu\'à {maxProfiles} joueurs sur ce téléphone.}}'**
  String profileLimitHint(int maxProfiles);

  /// Error under the button of the player creation when the phone already holds the maximum number of players ("There are already 10 players on this phone").
  ///
  /// In fr, this message translates to:
  /// **'{maxProfiles, plural, one{Il y a déjà {maxProfiles} joueur sur ce téléphone.} other{Il y a déjà {maxProfiles} joueurs sur ce téléphone.}}'**
  String profileLimitReached(int maxProfiles);

  /// Title at the top of the screen that creates a player ("New player"). Same French words as newPlayerButton but this one is a screen title. One line.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau joueur'**
  String get profileCreationTitle;

  /// Label above the nickname field of the player creation ("Your nickname"), informal "tu". One line.
  ///
  /// In fr, this message translates to:
  /// **'Ton pseudo'**
  String get nicknameLabel;

  /// Placeholder inside the empty nickname field of the player creation ("Type your nickname"). Imperative, informal "tu", one line.
  ///
  /// In fr, this message translates to:
  /// **'Écris ton pseudo'**
  String get nicknameHint;

  /// Hint under the nickname field of the player creation: allowed length and characters ("2 to 12 letters or digits"). One line.
  ///
  /// In fr, this message translates to:
  /// **'{maxLength, plural, one{{minLength} à {maxLength} lettre ou chiffre} other{{minLength} à {maxLength} lettres ou chiffres}}'**
  String nicknameRulesHint(int minLength, int maxLength);

  /// Error under the nickname field of the player creation when the nickname is too short ("At least 2 letters or digits are needed"). Speaks to a child, no blame.
  ///
  /// In fr, this message translates to:
  /// **'{minLength, plural, one{Il faut au moins {minLength} lettre ou chiffre.} other{Il faut au moins {minLength} lettres ou chiffres.}}'**
  String nicknameTooShort(int minLength);

  /// Error under the nickname field of the player creation when the nickname is too long ("No more than 12 letters or digits"). Speaks to a child, no blame.
  ///
  /// In fr, this message translates to:
  /// **'{maxLength, plural, one{Pas plus de {maxLength} lettre ou chiffre.} other{Pas plus de {maxLength} lettres ou chiffres.}}'**
  String nicknameTooLong(int maxLength);

  /// Error under the nickname field of the player creation when it contains another character (punctuation, emoji) ("Only letters, digits and spaces").
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

  /// Screen-reader label of one character of the avatar grid of the player creation ("Avatar 3"). Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'Avatar {number}'**
  String avatarOptionLabel(int number);

  /// Heading of the row of color swatches in the player creation ("Your color"), informal "tu". One line.
  ///
  /// In fr, this message translates to:
  /// **'Ta couleur'**
  String get colorPickerLabel;

  /// Screen-reader name of the violet color swatch of the player creation. Color adjective, one word. Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'Violet'**
  String get profileColorViolet;

  /// Screen-reader name of the green color swatch of the player creation. Color adjective, one word. Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'Vert'**
  String get profileColorGreen;

  /// Screen-reader name of the yellow color swatch of the player creation. Color adjective, one word. Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'Jaune'**
  String get profileColorYellow;

  /// Screen-reader name of the red color swatch of the player creation. Color adjective, one word. Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'Rouge'**
  String get profileColorRed;

  /// Screen-reader name of the blue color swatch of the player creation. Color adjective, one word. Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'Bleu'**
  String get profileColorBlue;

  /// Screen-reader name of the pink color swatch of the player creation. Color adjective, one word. Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'Rose'**
  String get profileColorPink;

  /// Main button of the player creation that creates the player and starts the game ("Let's go!"). One line on a full-width button.
  ///
  /// In fr, this message translates to:
  /// **'C\'est parti !'**
  String get createProfileButton;

  /// Button that closes a confirmation dialog without doing anything ("Cancel"). Infinitive verb, one word.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// Button of the Profile tab that goes back to the player selection so another child can play ("Switch player"). No data is lost. One line.
  ///
  /// In fr, this message translates to:
  /// **'Changer de joueur'**
  String get switchPlayerButton;

  /// Button of the Profile tab that opens the form to change the nickname, avatar or color ("Edit my profile"). Action label, informal first person; may differ from profileEditTitle, the title of the screen it opens. One line.
  ///
  /// In fr, this message translates to:
  /// **'Modifier mon profil'**
  String get editProfileButton;

  /// Destructive button at the bottom of the Profile tab that deletes the active player and all their progress ("Delete this player"). One line.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce joueur'**
  String get deleteProfileButton;

  /// Title at the top of the profile edit screen, where a player changes their nickname, avatar or color ("Edit my profile"). Screen title next to a back arrow, one line. Same French words as editProfileButton, the button that opens this screen, but a separate key: the title may be worded differently in other languages.
  ///
  /// In fr, this message translates to:
  /// **'Modifier mon profil'**
  String get profileEditTitle;

  /// Main button of the profile edit screen that saves the changes ("Save"). Infinitive verb, one line.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get saveProfileButton;

  /// Title of the dialog that confirms the deletion of a player ("Delete Awa?"). {nickname} is the child's nickname (up to 12 characters). Short question, one or two lines.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer {nickname} ?'**
  String deleteProfileTitle(String nickname);

  /// Body of the deletion dialog, read by a child, above a text field: everything the player earned is erased, and the child must type the nickname again in the field to confirm ("All their progress will be erased. To confirm, type their nickname: Awa"). {nickname} is the player's nickname, shown at the end so the child can copy it. Informal "tu", two or three lines.
  ///
  /// In fr, this message translates to:
  /// **'Toute sa progression sera effacée. Pour confirmer, écris son pseudo : {nickname}'**
  String deleteProfileMessage(String nickname);

  /// Destructive button of the deletion dialog, enabled once the nickname is typed again ("Delete"). Infinitive verb, one word.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get deleteProfileConfirm;
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
