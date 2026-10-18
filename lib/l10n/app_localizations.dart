import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

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

  /// Button that runs a failed action again (load the players, save the profile). Infinitive verb, one line.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// Tooltip and screen-reader label of the back arrow at the top left of a screen, and label of the button that leaves the quiz screen when the quiz cannot start ("Back"). One short word.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get commonBack;

  /// Error shown to a child on the "Qui joue ?" screen, under the button of the player creation, and on the quiz and results screens when the local database fails. Friendly tone, informal "tu", no technical words.
  ///
  /// In fr, this message translates to:
  /// **'Oups, on n\'a pas pu lire ou enregistrer tes données.'**
  String get errorStorage;

  /// Error shown on the "Qui joue ?" screen or the player creation when the chosen player was deleted in the meantime ("This player no longer exists").
  ///
  /// In fr, this message translates to:
  /// **'Ce joueur n\'existe plus.'**
  String get errorNotFound;

  /// Generic error shown to a child on the "Qui joue ?" screen, the player creation, and the quiz and results screens when nothing more precise is known. Friendly tone.
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

  /// Player level under the nickname on a player card of the "Qui joue ?" screen, on the profile tab and on the player badge of the map header ("Level 4"). Short, one line in half the screen width.
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

  /// Streak figure on its tile of the Profile tab, above "de série" ("6 days").
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 jour} other{{count} jours}}'**
  String profileStreakDays(int count);

  /// Label under the streak figure on the Profile tab, completing it: "6 jours / de série" ("in a row").
  ///
  /// In fr, this message translates to:
  /// **'de série'**
  String get profileStreakLabel;

  /// Label under the number of crowned tables on the Profile tab ("crowns"); the number is shown above it.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{couronne} other{couronnes}}'**
  String profileCrownsLabel(int count);

  /// Label under the number of badges unlocked on the Profile tab ("badges"); the number is shown above it.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{badge} other{badges}}'**
  String profileBadgesLabel(int count);

  /// Title of the mastery grid card on the Profile tab: one row per multiplication table, one cell per fact ("My tables").
  ///
  /// In fr, this message translates to:
  /// **'Mes tables'**
  String get masteryGridTitle;

  /// Status of a fact never asked, in the legend of the mastery grid and read with each cell ("New"). Masculine: it qualifies "fait" (fact).
  ///
  /// In fr, this message translates to:
  /// **'Nouveau'**
  String get masteryStatusNotSeen;

  /// Status of a fact missed lately, in the legend of the mastery grid and read with each cell ("To review").
  ///
  /// In fr, this message translates to:
  /// **'À revoir'**
  String get masteryStatusToReview;

  /// Status of a fact being learned (boxes 2 and 3), in the legend of the mastery grid and read with each cell ("In progress").
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get masteryStatusInProgress;

  /// Status of a fact known but still slow, in the legend of the mastery grid and read with each cell ("Learned"). Masculine: it qualifies "fait".
  ///
  /// In fr, this message translates to:
  /// **'Acquis'**
  String get masteryStatusAcquired;

  /// Status of a fact known and fast, in the legend of the mastery grid and read with each cell ("Mastered"). Masculine: it qualifies "fait".
  ///
  /// In fr, this message translates to:
  /// **'Maîtrisé'**
  String get masteryStatusMastered;

  /// Screen-reader text of one cell of the mastery grid: the fact read aloud, then its status ("5 fois 7 égale 35, Maîtrisé").
  ///
  /// In fr, this message translates to:
  /// **'{fact}, {status}'**
  String masteryCellSpoken(String fact, String status);

  /// Title of the badge card of the Profile tab, listing the badges earned and to earn ("My badges").
  ///
  /// In fr, this message translates to:
  /// **'Mes badges'**
  String get rewardBadgesTitle;

  /// Screen-reader text of an earned badge on the Profile tab ("Lightning, earned"). Masculine: it qualifies "badge".
  ///
  /// In fr, this message translates to:
  /// **'{name}, obtenu'**
  String rewardBadgeEarnedSpoken(String name);

  /// Screen-reader text of a badge not earned yet on the Profile tab, with how to earn it ("Sprinter, to earn: 20 right answers in a time attack.").
  ///
  /// In fr, this message translates to:
  /// **'{name}, à obtenir : {hint}'**
  String rewardBadgeLockedSpoken(String name, String hint);

  /// Title of the card of the Profile tab showing the monster of each table, colored once its boss is defeated ("My monsters").
  ///
  /// In fr, this message translates to:
  /// **'Mes monstres'**
  String get pathMonstersTitle;

  /// Monsters defeated out of all, next to the title of the monster card ("3 of 12").
  ///
  /// In fr, this message translates to:
  /// **'{defeated} sur {total}'**
  String pathMonstersCount(int defeated, int total);

  /// Screen-reader text of a defeated monster in the monster card of the Profile tab ("Monster of the table of 5, defeated").
  ///
  /// In fr, this message translates to:
  /// **'Monstre de la table de {number}, vaincu'**
  String pathMonsterDefeatedSpoken(int number);

  /// Screen-reader text of a monster whose boss is still standing, shown as a gray shadow in the monster card ("Monster of the table of 5, not defeated yet").
  ///
  /// In fr, this message translates to:
  /// **'Monstre de la table de {number}, pas encore vaincu'**
  String pathMonsterHiddenSpoken(int number);

  /// Title of the settings screen of a player ("Settings"); also the tooltip of the settings button of the Profile tab.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// Name of the section of the settings screen grouping the sounds and the vibrations ("Sounds").
  ///
  /// In fr, this message translates to:
  /// **'Sons'**
  String get settingsSoundSection;

  /// Switch of the settings screen that turns the sound effects on or off ("Sounds").
  ///
  /// In fr, this message translates to:
  /// **'Sons'**
  String get settingsSound;

  /// Switch of the settings screen that turns the vibrations on or off ("Vibrations").
  ///
  /// In fr, this message translates to:
  /// **'Vibrations'**
  String get settingsVibration;

  /// Name of the section of the settings screen grouping the game settings ("Game").
  ///
  /// In fr, this message translates to:
  /// **'Jeu'**
  String get settingsGameSection;

  /// Name of the timer setting, above its three choices ("Timer").
  ///
  /// In fr, this message translates to:
  /// **'Chrono'**
  String get settingsTimer;

  /// Timer choice: the normal time per question ("Normal"). A third of a switch: keep it short.
  ///
  /// In fr, this message translates to:
  /// **'Normal'**
  String get settingsTimerNormal;

  /// Timer choice: 1.5 times more time per question ("Relaxed"). A third of a switch: keep it short.
  ///
  /// In fr, this message translates to:
  /// **'Détendu'**
  String get settingsTimerRelaxed;

  /// Timer choice: no timer ("None", literally "without"). A third of a switch: keep it short.
  ///
  /// In fr, this message translates to:
  /// **'Sans'**
  String get settingsTimerOff;

  /// Name of the daily goal setting, above its three choices of XP ("Daily goal").
  ///
  /// In fr, this message translates to:
  /// **'Objectif du jour'**
  String get settingsDailyGoal;

  /// Switch of the settings screen that opens every table and stage of the learning path ("Unlock everything").
  ///
  /// In fr, this message translates to:
  /// **'Tout débloquer'**
  String get settingsUnlockAll;

  /// Switch of the settings screen that replaces the animations by still screens ("Reduced motion").
  ///
  /// In fr, this message translates to:
  /// **'Animations réduites'**
  String get settingsReducedMotion;

  /// Tooltip of the cross button that closes a full screen such as the parental gate ("Close"). Infinitive verb, one word.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// Name of the section of the settings screen holding the export and the import of a player to and from a file ("Backup"). Noun, short section header.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde'**
  String get settingsBackupSection;

  /// Row of the settings screen, in the "Sauvegarde" section, that writes the player and all their progress to a file and opens the share sheet of the phone, after the parental gate ("Export my profile"). One line.
  ///
  /// In fr, this message translates to:
  /// **'Exporter mon profil'**
  String get backupExport;

  /// Row of the settings screen, in the "Sauvegarde" section, that opens the file picker to bring a player from a backup file onto this phone, after the parental gate ("Import a profile"). One line.
  ///
  /// In fr, this message translates to:
  /// **'Importer un profil'**
  String get backupImport;

  /// Snack bar of the settings screen, shown after the backup file was shared, telling how to use it on the other phone ("File ready! Open it in Kid Matix on the other phone, with 'Import a profile'."). The quoted label must match the settings row of the key backupImport. Informal "tu".
  ///
  /// In fr, this message translates to:
  /// **'Fichier prêt ! Ouvre-le dans Kid Matix sur l\'autre téléphone, avec « Importer un profil ».'**
  String get backupExportDone;

  /// Snack bar of the settings screen, shown after a backup file was imported as a new player of the phone ("Awa's profile imported! Find it with 'Switch player'."). The quoted label must match the Profile tab button of the key switchPlayerButton. Informal "tu"; "le" stands for the profile.
  ///
  /// In fr, this message translates to:
  /// **'Profil de {nickname} importé ! Retrouve-le avec « Changer de joueur ».'**
  String backupImportDone(String nickname);

  /// Snack bar of the settings screen, shown after a backup file replaced the player of the phone with the same nickname ("Awa's progress restored!").
  ///
  /// In fr, this message translates to:
  /// **'Progression de {nickname} restaurée !'**
  String backupImportReplaced(String nickname);

  /// Title of the dialog shown when the nickname of an imported backup is already used by a player of this phone ("Awa already exists").
  ///
  /// In fr, this message translates to:
  /// **'{nickname} existe déjà'**
  String backupConflictTitle(String nickname);

  /// Body of the dialog shown when the nickname of an imported backup is already used on this phone: what each choice does ("This phone already has a player Awa. The file holds Awa at level 5. Replace erases the current progress of Awa on this phone. Rename keeps both players.").
  ///
  /// In fr, this message translates to:
  /// **'Ce téléphone a déjà un joueur {nickname}. Le fichier contient {nickname} au niveau {level}.\n\nRemplacer efface la progression actuelle de {nickname} sur ce téléphone. Renommer garde les deux joueurs.'**
  String backupConflictMessage(String nickname, int level);

  /// Destructive button of the nickname conflict dialog: the player of the phone is replaced by the file ("Replace"). Infinitive verb, one word.
  ///
  /// In fr, this message translates to:
  /// **'Remplacer'**
  String get backupConflictReplace;

  /// Button of the nickname conflict dialog: the imported player gets another nickname, both players are kept ("Rename"). Infinitive verb, one word.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get backupConflictRename;

  /// Title of the dialog asking another nickname for the imported player ("New nickname").
  ///
  /// In fr, this message translates to:
  /// **'Nouveau pseudo'**
  String get backupRenameTitle;

  /// Text of the dialog asking another nickname for the imported player ("Choose another nickname for the imported player."). Informal "tu".
  ///
  /// In fr, this message translates to:
  /// **'Choisis un autre pseudo pour le joueur importé.'**
  String get backupRenameMessage;

  /// Button of the rename dialog that imports the backup under the nickname typed ("Import"). Infinitive verb, one word.
  ///
  /// In fr, this message translates to:
  /// **'Importer'**
  String get backupRenameConfirm;

  /// Error snack bar of the settings screen, shown when the file picked for an import is not a Kid Matix backup or is damaged ("This file is not a Kid Matix backup, or it is damaged.").
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier n\'est pas une sauvegarde Kid Matix, ou il est abîmé.'**
  String get errorBackupInvalid;

  /// Error snack bar of the settings screen, shown when the file picked for an import was written by a newer version of the app ("This backup comes from a newer version of Kid Matix. Update the app, then try again."). Informal "tu".
  ///
  /// In fr, this message translates to:
  /// **'Cette sauvegarde vient d\'une version plus récente de Kid Matix. Mets l\'app à jour, puis réessaie.'**
  String get errorBackupVersion;

  /// Title of the parental gate, a full screen shown before exporting or importing a backup ("Ask an adult"). Informal "tu", addressed to the child.
  ///
  /// In fr, this message translates to:
  /// **'Demande à un adulte'**
  String get parentalGateTitle;

  /// Text of the parental gate, above a number written in words that the adult types in digits ("This action is for adults. Write this number in digits:"). The number in words is spelled by code per language, not by this key. Informal "tu".
  ///
  /// In fr, this message translates to:
  /// **'Cette action est réservée aux adultes. Écris ce nombre en chiffres :'**
  String get parentalGateMessage;

  /// Label of the field of the parental gate where the adult types the number in digits ("Number in digits").
  ///
  /// In fr, this message translates to:
  /// **'Nombre en chiffres'**
  String get parentalGateAnswerLabel;

  /// Button of the parental gate that checks the number typed ("Confirm"). Infinitive verb, one word.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get parentalGateConfirm;

  /// Name of the section of the settings screen holding the daily reminder ("Reminder"), mockup 13. Short section header, one line, a noun.
  ///
  /// In fr, this message translates to:
  /// **'Rappel'**
  String get settingsReminderSection;

  /// Switch of the settings screen that turns the daily reminder notification on or off for the whole phone ("Daily reminder"), mockup 13. Off by default; switching it on asks for the notification permission. Switch label: one line, a noun phrase, not a verb.
  ///
  /// In fr, this message translates to:
  /// **'Rappel quotidien'**
  String get settingsReminderDaily;

  /// Row of the settings screen showing the time of the daily reminder, such as 17:00; tapping it opens the time picker ("Reminder time"), mockup 13. Greyed while the reminder is off.
  ///
  /// In fr, this message translates to:
  /// **'Heure du rappel'**
  String get settingsReminderTime;

  /// Message shown at the bottom of the settings screen when the phone refuses the notifications after the daily reminder is switched on; the switch goes back off ("Notifications are blocked. Allow them in the phone settings to get the reminder."). Read by a child or a parent, informal "tu". Shown in a snack bar, at most 2 lines.
  ///
  /// In fr, this message translates to:
  /// **'Les notifications sont bloquées. Autorise-les dans les réglages du téléphone pour recevoir le rappel.'**
  String get settingsReminderPermissionDenied;

  /// Message shown at the bottom of the settings screen when the daily reminder cannot be saved or scheduled ("Oops, the reminder could not be set."). Friendly tone, no technical words. Shown in a snack bar, at most 2 lines.
  ///
  /// In fr, this message translates to:
  /// **'Oups, le rappel n\'a pas pu être réglé.'**
  String get settingsReminderError;

  /// Name of the section of the settings screen where the language of the app is chosen for the whole phone ("Language"). Short section header, one line, a noun.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguageSection;

  /// First choice of the "Langue" section of the settings screen: the app follows the language of the phone (French when the phone speaks none of the app's languages). One line, radio button label.
  ///
  /// In fr, this message translates to:
  /// **'Langue du téléphone'**
  String get settingsLanguageSystem;

  /// Choice of the "Langue" section of the settings screen: the French language, always written in French whatever the language of the app. Do not translate.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageNameFrench;

  /// Choice of the "Langue" section of the settings screen: the English language, always written in English whatever the language of the app. Do not translate.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageNameEnglish;

  /// Choice of the "Langue" section of the settings screen: the Spanish language, always written in Spanish whatever the language of the app. Do not translate.
  ///
  /// In fr, this message translates to:
  /// **'Español'**
  String get languageNameSpanish;

  /// Message shown at the bottom of the settings screen when the language chosen cannot be saved; the previous language comes back ("Oops, the language could not be saved."). Friendly tone, no technical words. Shown in a snack bar, at most 2 lines.
  ///
  /// In fr, this message translates to:
  /// **'Oups, la langue n\'a pas pu être enregistrée.'**
  String get settingsLanguageError;

  /// Message of the daily reminder notification, under the app name; tapping it opens the app ("It's time for your tables!"). Neutral: the phone is shared by several children, so no nickname. Short, fits on one line of a notification.
  ///
  /// In fr, this message translates to:
  /// **'C\'est l\'heure de tes tables !'**
  String get reminderNotificationBody;

  /// Name of the notification category of the daily reminder, shown by Android in the notification settings of the app ("Daily reminder"). Short, one line: Android lists it as the title of a notification category. Kept apart from settingsReminderDaily on purpose, though the French is the same.
  ///
  /// In fr, this message translates to:
  /// **'Rappel quotidien'**
  String get reminderChannelName;

  /// Description of the notification category of the daily reminder, shown by Android in the notification settings of the app ("Reminds you to play every day at the chosen time."). One short sentence; speaks to the child with the informal "tu", though a parent may read it in the phone settings.
  ///
  /// In fr, this message translates to:
  /// **'Te rappelle de jouer chaque jour à l\'heure choisie.'**
  String get reminderChannelDescription;

  /// Name of the section of the settings screen holding the actions on the player: reset and delete ("This player").
  ///
  /// In fr, this message translates to:
  /// **'Ce joueur'**
  String get settingsPlayerSection;

  /// Destructive action of the settings screen that erases the progress of the player, after a confirmation ("Reset my progress").
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser ma progression'**
  String get resetProgressButton;

  /// Confirm button of the progress reset dialog, enabled once the nickname is typed again ("Reset").
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get resetProgressConfirm;

  /// Message shown briefly after the progress of the player was erased ("Your progress is back to zero."). Talks to the child (informal tu).
  ///
  /// In fr, this message translates to:
  /// **'Ta progression est remise à zéro.'**
  String get resetProgressDone;

  /// One choice of the daily goal setting ("50 XP"). A third of a switch: keep it short.
  ///
  /// In fr, this message translates to:
  /// **'{xp} XP'**
  String settingsDailyGoalXp(int xp);

  /// Title of the dialog confirming the reset of the progress of a player ("Reset Awa?").
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser {nickname} ?'**
  String resetProgressTitle(String nickname);

  /// Message of the dialog confirming the reset of the progress of a player: what is erased, what stays, and how to confirm by typing the nickname.
  ///
  /// In fr, this message translates to:
  /// **'Ses étoiles, couronnes, badges, XP et records seront effacés. Son pseudo, ses réglages et le nom de sa mascotte restent. Pour confirmer, écris son pseudo : {nickname}'**
  String resetProgressMessage(String nickname);

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

  /// Tooltip and screen-reader label of the cross at the top left of the quiz screen ("Leave the quiz").
  ///
  /// In fr, this message translates to:
  /// **'Quitter le quiz'**
  String get quizQuitTooltip;

  /// Screen-reader label of the quiz progress bar ("Question 4 of 10"). Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'Question {current} sur {total}'**
  String quizProgressLabel(int current, int total);

  /// Screen-reader label of the timer bar of the quiz ("Time left"). Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'Temps restant'**
  String get quizTimeLeftLabel;

  /// Small label above a multiplication question naming its table ("Table of 5"). One short line in a pill.
  ///
  /// In fr, this message translates to:
  /// **'Table de {number}'**
  String quizMultiplicationUnit(int number);

  /// Small label above a true-or-false question ("True or false?"). One short line in a pill.
  ///
  /// In fr, this message translates to:
  /// **'Vrai ou faux ?'**
  String get quizTrueFalseLabel;

  /// Hint in a dashed box under the four answer buttons of a multiple-choice question ("Tap the right answer"). Speaks to a child with "tu".
  ///
  /// In fr, this message translates to:
  /// **'Touche la bonne réponse'**
  String get quizHintMultipleChoice;

  /// Hint in a dashed box under the true and false buttons, asking whether the calculation shown is right ("Is this calculation right?"). One or two short lines.
  ///
  /// In fr, this message translates to:
  /// **'Ce calcul est-il juste ?'**
  String get quizHintTrueFalse;

  /// Words at the top of the question card of a "find the operation" question in the multiplication domain ("Which multiplication gives"). The result follows on its own line in a big yellow box, so the sentence stays open and has no question mark: phrase it so the number can come right after it. One line.
  ///
  /// In fr, this message translates to:
  /// **'Quelle multiplication donne'**
  String get quizFindOperationMultiplication;

  /// What a screen reader says for the question card of a "find the operation" question in the multiplication domain ("Which multiplication gives 24?"), in place of the words and the result shown. {result} is the product the player must reach. Never shown.
  ///
  /// In fr, this message translates to:
  /// **'Quelle multiplication donne {result} ?'**
  String quizFindOperationSpokenMultiplication(int result);

  /// What a screen reader says for the drawing of mangoes in a counting question ("Mangoes to count"); it does not tell how many, since that is the answer. Never shown.
  ///
  /// In fr, this message translates to:
  /// **'Des mangues à compter'**
  String get quizObjectsPictureLabel;

  /// What a screen reader says for the drawing of mangoes on a help card, where the number is given ("7 mangoes"). Never shown.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 mangue} other{{count} mangues}}'**
  String quizObjectsPictureCounted(int count);

  /// What a screen reader says for a drawing of bundles of ten sticks and loose sticks ("3 bundles of ten and 4 sticks"). {tens} counts the bundles, {ones} the loose sticks. Never shown.
  ///
  /// In fr, this message translates to:
  /// **'{tens, plural, =0{Aucun paquet de dix} =1{1 paquet de dix} other{{tens} paquets de dix}} et {ones, plural, =0{aucun bâtonnet} =1{1 bâtonnet} other{{ones} bâtonnets}}'**
  String quizBundlesPictureLabel(int tens, int ones);

  /// What a screen reader says for a drawn number line ("Number line: 2, 4, 6, 8, 10"). {numbers} lists its numbers from left to right, separated by commas, with quizSpokenHiddenNumber for a number to find. Never shown.
  ///
  /// In fr, this message translates to:
  /// **'Droite des nombres : {numbers}'**
  String quizNumberLinePictureLabel(String numbers);

  /// Hint in a dashed box under the four operation buttons of a "find the operation" question ("Tap the right operation"). Imperative verb, speaks to a child with "tu"; one or two short lines.
  ///
  /// In fr, this message translates to:
  /// **'Touche la bonne opération'**
  String get quizHintFindOperation;

  /// Title at the top of a "match the pairs" question, in place of the question card, above two columns: four operations and their four results ("Match each operation with its result"). Imperative verb, speaks to a child with "tu"; two lines at most.
  ///
  /// In fr, this message translates to:
  /// **'Relie chaque opération à son résultat'**
  String get quizMatchPairsTitle;

  /// Line under the title of a "match the pairs" question counting the pairs already matched ("1 pair found out of 4"); also read aloud by screen readers when it changes. {count} is the number of pairs found, {total} the number of pairs of the question (4). One line.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune paire trouvée sur {total}} =1{1 paire trouvée sur {total}} other{{count} paires trouvées sur {total}}}'**
  String quizMatchPairsProgress(int count, int total);

  /// Hint in a dashed box under a "match the pairs" question before anything is selected ("Tap an operation, then its result"). Speaks to a child with "tu"; one or two lines.
  ///
  /// In fr, this message translates to:
  /// **'Touche une opération, puis son résultat'**
  String get quizMatchPairsHintStart;

  /// Hint in the dashed box under a "match the pairs" board once the player has tapped an operation ("Now tap the result of 5 × 6"); also read aloud by screen readers. {operation} is the operation as shown on its button, digits and the × sign. Speaks to a child with "tu"; one or two lines.
  ///
  /// In fr, this message translates to:
  /// **'Touche maintenant le résultat de {operation}'**
  String quizMatchPairsHintResult(String operation);

  /// Hint in the dashed box under a "match the pairs" board once the player has tapped a result first ("Now tap the operation that gives 30"); also read aloud by screen readers. {result} is the number shown on the result button. Speaks to a child with "tu"; one or two lines.
  ///
  /// In fr, this message translates to:
  /// **'Touche maintenant l\'opération qui donne {result}'**
  String quizMatchPairsHintOperation(String result);

  /// What a screen reader says for an operation or a result button already matched in a "match the pairs" question ("5 times 6, pair found"). {label} is the button as spoken words: an operation ("5 fois 6") or a number ("30"). Never shown.
  ///
  /// In fr, this message translates to:
  /// **'{label}, paire trouvée'**
  String quizMatchPairsFound(String label);

  /// Label of the button that says the statement is true ("True"). One word.
  ///
  /// In fr, this message translates to:
  /// **'Vrai'**
  String get quizTrue;

  /// Label of the button that says the statement is false ("False"). One word.
  ///
  /// In fr, this message translates to:
  /// **'Faux'**
  String get quizFalse;

  /// Tooltip and screen-reader label of the keypad key that erases the last digit ("Erase"). Infinitive verb.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get quizKeypadErase;

  /// Label of the keypad key that submits the typed number ("Submit"). Infinitive verb, one word.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get quizKeypadValidate;

  /// Title of the green message after a right answer ("Well done!"). One short line.
  ///
  /// In fr, this message translates to:
  /// **'Bravo !'**
  String get quizFeedbackRight;

  /// Title of the red message after a wrong answer ("Almost!"). Encouraging, never blaming. One short line.
  ///
  /// In fr, this message translates to:
  /// **'Presque !'**
  String get quizFeedbackWrong;

  /// Title of the red message when the time to answer ran out ("Time is up!"). One short line.
  ///
  /// In fr, this message translates to:
  /// **'Temps écoulé !'**
  String get quizFeedbackTimeUp;

  /// Mention next to the title of the green message when the right answer came in under 3 seconds ("Lightning!"). One short word.
  ///
  /// In fr, this message translates to:
  /// **'Éclair !'**
  String get quizLightning;

  /// Line under the red message after a wrong answer, recalling that the same operation the other way round gives the same result ("Remember too: 8 × 7 = 56"). One short line.
  ///
  /// In fr, this message translates to:
  /// **'Retiens aussi : {fact}'**
  String quizMirrorReminder(String fact);

  /// Title of the help card shown in place of the question after two mistakes on the same fact: "Help card" followed by the name of the unit it shows, such as "Fiche d'aide · Table de 7". One short line; keep the middle dot.
  ///
  /// In fr, this message translates to:
  /// **'Fiche d\'aide · {unit}'**
  String quizHelpTitle(String unit);

  /// Caption under the grid of dots that pictures a multiplication, also read by screen readers ("7 rows of 8 dots" for 7 × 8).
  ///
  /// In fr, this message translates to:
  /// **'{rows, plural, =1{1 rangée} other{{rows} rangées}} de {columns, plural, =1{1 point} other{{columns} points}}'**
  String quizHelpDotGridLabel(int rows, int columns);

  /// Button under the answer feedback that shows the next question ("Continue"). Infinitive verb.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get quizContinue;

  /// Title of the dialog that confirms leaving a quiz ("Leave the quiz?").
  ///
  /// In fr, this message translates to:
  /// **'Quitter le quiz ?'**
  String get quizQuitTitle;

  /// Body of the dialog that confirms leaving a quiz: the answers given still help the child progress, but the game gives no reward. Informal "tu".
  ///
  /// In fr, this message translates to:
  /// **'Tes réponses comptent pour ta progression, mais cette partie ne te donnera pas de récompense.'**
  String get quizQuitMessage;

  /// Button of the quit dialog that leaves the quiz ("Leave"). Infinitive verb, one word.
  ///
  /// In fr, this message translates to:
  /// **'Quitter'**
  String get quizQuitConfirm;

  /// Button of the quit dialog that goes back to the quiz ("Keep playing").
  ///
  /// In fr, this message translates to:
  /// **'Continuer à jouer'**
  String get quizQuitCancel;

  /// Word read by the screen reader for the multiplication sign of a question ("times"). The reader joins the words in the order of the operation: number, this word, number, "quizSpokenEquals", then a number or "quizSpokenBlank", such as "5 fois 7 égale combien". Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'fois'**
  String get quizSpokenTimes;

  /// Word read by the screen reader for the equals sign of a question ("equals"), as in "5 fois 7 égale combien". Joined with the other words in the order of the operation. Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'égale'**
  String get quizSpokenEquals;

  /// Word read by the screen reader for the missing number at the end of a question ("how much"), as in "5 fois 7 égale combien". Joined with the other words in the order of the operation. Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'combien'**
  String get quizSpokenBlank;

  /// Word read by the screen reader for the plus sign of a number written as its tens and ones ("plus"), as in "30 plus 4 égale 34". Joined with the other words in the order of the operation. Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'plus'**
  String get quizSpokenPlus;

  /// Words read by the screen reader for the sign < between two numbers ("is less than"), as in "34 est plus petit que 43". Joined with the numbers around it. Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'est plus petit que'**
  String get quizSpokenLessThan;

  /// Words read by the screen reader for the sign > between two numbers ("is greater than"), as in "58 est plus grand que 49". Joined with the numbers around it. Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'est plus grand que'**
  String get quizSpokenGreaterThan;

  /// Words read by the screen reader for the tick of a number line whose number the player must find ("hidden number"), inside the list of the numbers of the line, such as "2, 4, 6, nombre caché, 10". Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'nombre caché'**
  String get quizSpokenHiddenNumber;

  /// Name of the game mode shown under the results title after a stage of the learning path ("Learning path"), after the table name and a middle dot.
  ///
  /// In fr, this message translates to:
  /// **'Parcours'**
  String get quizModePath;

  /// Name of the free training mode, shown under the results title ("Free training").
  ///
  /// In fr, this message translates to:
  /// **'Entraînement libre'**
  String get quizModeFreeTraining;

  /// Name of the time attack challenge (as many right answers as possible in 60 seconds), shown under the results title and on the challenges screen ("Against the clock").
  ///
  /// In fr, this message translates to:
  /// **'Contre-la-montre'**
  String get quizModeTimeAttack;

  /// Name of the survival challenge (3 lives, less and less time per question), shown under the results title and on the challenges screen ("Survival").
  ///
  /// In fr, this message translates to:
  /// **'Survie'**
  String get quizModeSurvival;

  /// Screen-reader text of the hearts at the top of a survival quiz, whose visible content is only hearts, full or emptied ("2 lives out of 3", "No life left").
  ///
  /// In fr, this message translates to:
  /// **'{left, plural, =0{Plus de vie} =1{1 vie sur {total}} other{{left} vies sur {total}}}'**
  String quizLivesSpoken(int left, int total);

  /// Name of the daily review (10 questions on the facts the player should review), shown as the title of its card on the challenges screen and under the results title ("Daily review").
  ///
  /// In fr, this message translates to:
  /// **'Révision du jour'**
  String get quizModeDailyReview;

  /// Name of the monster hunt (10 questions on the facts the player keeps missing, drawn as little monsters), shown as the title of its card on the challenges screen and under the results title ("Monster hunt").
  ///
  /// In fr, this message translates to:
  /// **'Chasse aux monstres'**
  String get quizModeMonsterHunt;

  /// Screen-reader text of the live score pill of a quiz against the clock, whose visible text is only the number.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune bonne réponse} =1{1 bonne réponse} other{{count} bonnes réponses}}'**
  String quizScoreSpoken(int count);

  /// Screen-reader text of the bar showing the time left to play a whole quiz against the clock ("{seconds} seconds left").
  ///
  /// In fr, this message translates to:
  /// **'{seconds, plural, =0{Plus de temps} =1{Encore 1 seconde} other{Encore {seconds} secondes}}'**
  String quizClockLeftSpoken(int seconds);

  /// Big title of the results screen after a quiz ("Game over!" in a cheerful sense, "All done!"). One line.
  ///
  /// In fr, this message translates to:
  /// **'Partie terminée !'**
  String get resultsTitle;

  /// Line under the results title: the unit and the mode of the quiz, such as "Table de 5 · Entraînement libre", or the stage name after a stage of the learning path, such as "Table de 5 · Entraînement". Keep the middle dot.
  ///
  /// In fr, this message translates to:
  /// **'{unit} · {mode}'**
  String resultsSubtitle(String unit, String mode);

  /// Big number of a results tile: right answers out of the scored questions ("9 / 10"). Keep it short, it shares a row with another tile.
  ///
  /// In fr, this message translates to:
  /// **'{correct} / {total}'**
  String resultsCorrectCount(int correct, int total);

  /// Small label under the right-answer count of the results ("right"), agreeing in number with the count. Feminine in French because it stands for "questions réussies". One word.
  ///
  /// In fr, this message translates to:
  /// **'{correct, plural, one{réussie} other{réussies}}'**
  String resultsCorrectLabel(int correct);

  /// Big number of a results tile: average answer time in seconds with one decimal ("2,4 s"). Keep the unit abbreviated.
  ///
  /// In fr, this message translates to:
  /// **'{seconds} s'**
  String resultsAverageTime(double seconds);

  /// Small label under the average answer time of the results ("on average").
  ///
  /// In fr, this message translates to:
  /// **'en moyenne'**
  String get resultsAverageTimeLabel;

  /// Heading of the results card listing the facts the child missed ("To review").
  ///
  /// In fr, this message translates to:
  /// **'À revoir'**
  String get resultsToReview;

  /// Shown in the "To review" card when the child missed nothing ("No mistake, well done!").
  ///
  /// In fr, this message translates to:
  /// **'Aucune erreur, bravo !'**
  String get resultsNothingToReview;

  /// Main button of the results screen, back to the home ("Continue"). Infinitive verb.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get resultsContinue;

  /// Second button of the results screen, plays the same quiz again ("Play again"). Infinitive verb.
  ///
  /// In fr, this message translates to:
  /// **'Rejouer'**
  String get resultsReplay;

  /// Name of stage 1 of a table in the learning path ("Discovery"): the whole table and its tip.
  ///
  /// In fr, this message translates to:
  /// **'Découverte'**
  String get pathStageDiscovery;

  /// One-line description under the name of the Discovery stage ("The table and its tip").
  ///
  /// In fr, this message translates to:
  /// **'La table et son astuce'**
  String get pathStageDiscoveryHint;

  /// Name of stage 2 of a table ("Training"): the 10 facts shuffled, answers to pick.
  ///
  /// In fr, this message translates to:
  /// **'Entraînement'**
  String get pathStageTraining;

  /// One-line description under the name of the Training stage ("10 shuffled questions").
  ///
  /// In fr, this message translates to:
  /// **'10 questions mélangées'**
  String get pathStageTrainingHint;

  /// Name of stage 3 of a table ("Writing"): the child writes the answers.
  ///
  /// In fr, this message translates to:
  /// **'Écriture'**
  String get pathStageWriting;

  /// One-line description under the name of the Writing stage ("Write the answer yourself"). Talks to the child.
  ///
  /// In fr, this message translates to:
  /// **'Écris la réponse toi-même'**
  String get pathStageWritingHint;

  /// Name of stage 4 of a table ("Speed"): every format with a timer.
  ///
  /// In fr, this message translates to:
  /// **'Vitesse'**
  String get pathStageSpeed;

  /// One-line description under the name of the Speed stage ("10 seconds per question").
  ///
  /// In fr, this message translates to:
  /// **'10 secondes par question'**
  String get pathStageSpeedHint;

  /// Name of stage 5 of a table ("Boss fight").
  ///
  /// In fr, this message translates to:
  /// **'Combat de boss'**
  String get pathStageBoss;

  /// One-line description under the name of the boss stage ("Beat the monster of the table"). Talks to the child.
  ///
  /// In fr, this message translates to:
  /// **'Bats le monstre de la table'**
  String get pathStageBossHint;

  /// Name of the review stage that follows every group of 3 tables on the map ("Review").
  ///
  /// In fr, this message translates to:
  /// **'Révision'**
  String get pathStageReview;

  /// Description of the review stage ("15 questions on the tables already seen").
  ///
  /// In fr, this message translates to:
  /// **'15 questions sur les tables déjà vues'**
  String get pathStageReviewHint;

  /// Title of a stage card with its number, such as "1 · Découverte". Keep the middle dot.
  ///
  /// In fr, this message translates to:
  /// **'{number} · {name}'**
  String pathStageNumbered(int number, String name);

  /// Line of the call card next to the current table on the map, such as "Étape 2 sur 5 · Entraînement" ("Stage 2 of 5 · Training").
  ///
  /// In fr, this message translates to:
  /// **'Étape {number} sur {total} · {name}'**
  String pathCurrentStage(int number, int total, String name);

  /// Button that starts the next stage, on the map and on the table detail ("Play").
  ///
  /// In fr, this message translates to:
  /// **'Jouer'**
  String get pathPlay;

  /// Button at the bottom of the table detail that shows the whole table and its tip ("See the table").
  ///
  /// In fr, this message translates to:
  /// **'Voir la table'**
  String get pathShowTable;

  /// Stars of a table on its detail screen, out of the stars it can earn ("3 stars out of 15").
  ///
  /// In fr, this message translates to:
  /// **'{stars, plural, =0{0 étoile sur {total}} =1{1 étoile sur {total}} other{{stars} étoiles sur {total}}}'**
  String pathTableStars(int stars, int total);

  /// Hint under the stars of a table on its detail screen ("Beat the boss to win the crown."). Talks to the child.
  ///
  /// In fr, this message translates to:
  /// **'Bats le boss pour gagner la couronne.'**
  String get pathCrownHint;

  /// Header of the placement test offer, the full screen shown right after a new player is created ("Do you already know some tables?"). A table is a multiplication table. Talks to the child (informal tu). Two short lines at most.
  ///
  /// In fr, this message translates to:
  /// **'Tu connais déjà des tables ?'**
  String get placementOfferTitle;

  /// Text under the title of the placement test offer ("Answer one question per table, no timer. Each table you know opens right away in your path."). The path is the map of tables the child plays through. Talks to the child (informal tu).
  ///
  /// In fr, this message translates to:
  /// **'Réponds à une question par table, sans chrono. Chaque table que tu connais s\'ouvre tout de suite dans ton parcours.'**
  String get placementOfferMessage;

  /// Primary full-width button of the placement test offer that starts the 12 questions ("Take the test"). One line, short.
  ///
  /// In fr, this message translates to:
  /// **'Faire le test'**
  String get placementOfferStart;

  /// Secondary full-width button of the placement test offer that skips the test and opens the path with the table of 1 only. "Passer" is an infinitive verb meaning "Skip", not "Pass". One line, short.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get placementOfferSkip;

  /// What a screen reader says for the progress bar at the top of a placement test question ("Question 3 of 12"). Not shown on screen.
  ///
  /// In fr, this message translates to:
  /// **'Question {current} sur {total}'**
  String placementQuestionProgress(int current, int total);

  /// Text button under the keypad of a placement test question: the child does not know the answer and goes to the next question ("I don't know"). Said by the child (first person). One line.
  ///
  /// In fr, this message translates to:
  /// **'Je ne sais pas'**
  String get placementUnknownAnswer;

  /// Tooltip and screen-reader text of the cross icon at the top left of a placement test question, that leaves the test ("Stop the test"). "Arrêter" is an infinitive verb. Short.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter le test'**
  String get placementQuitTooltip;

  /// Title of the dialog confirming that the child leaves the placement test, shown by the cross or the system back ("Stop the test?"). Talks to the child. One line.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter le test ?'**
  String get placementQuitTitle;

  /// Body of the dialog confirming that the child leaves the placement test ("The tables already found stay open in your path."). Talks to the child (informal tu).
  ///
  /// In fr, this message translates to:
  /// **'Les tables déjà trouvées restent ouvertes dans ton parcours.'**
  String get placementQuitMessage;

  /// Dialog button that stays in the placement test ("Go on with the test"). "Continuer" is an infinitive verb. Short, one line.
  ///
  /// In fr, this message translates to:
  /// **'Continuer le test'**
  String get placementQuitCancel;

  /// Dialog button that leaves the placement test for the path ("Stop"). "Arrêter" is an infinitive verb. One word if possible.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter'**
  String get placementQuitConfirm;

  /// Header of the placement test result screen, with the number of tables the child already knows ("You already know 3 tables!"); with none, "Everything is to discover!". Talks to the child (informal tu). Two short lines at most.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Tout est à découvrir !} =1{Tu connais déjà 1 table !} other{Tu connais déjà {count} tables !}}'**
  String placementResultTitle(int count);

  /// Text under the title of the placement test result. With one table or more: "It is / They are open in your path. Its / Their stars are still to win." ("Elle"/"Elles" stands for the tables found; their stages are open but hold no star yet). With none: a kind text saying the child will learn them one by one and the path starts with the table of 1. Talks to the child (informal tu).
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Pas de souci, tu vas les apprendre une par une. Ton parcours commence par la table de 1.} =1{Elle est ouverte dans ton parcours. Ses étoiles restent à gagner.} other{Elles sont ouvertes dans ton parcours. Leurs étoiles restent à gagner.}}'**
  String placementResultSubtitle(int count);

  /// Legend label under the grid of the placement test result, next to the violet swatch: a table the child already knows ("Already known"; feminine in French because it agrees with "table"). One line, a few words.
  ///
  /// In fr, this message translates to:
  /// **'Déjà connue'**
  String get placementLegendKnown;

  /// Legend label under the grid of the placement test result, next to the light swatch: a table still to learn ("To discover"). One line, a few words.
  ///
  /// In fr, this message translates to:
  /// **'À découvrir'**
  String get placementLegendToDiscover;

  /// What a screen reader says for a tile of the placement test result grid when the table was found ("Table of 2, already known"). {name} is the table name of quizMultiplicationUnit. Not shown on screen.
  ///
  /// In fr, this message translates to:
  /// **'{name}, déjà connue'**
  String placementTableKnown(String name);

  /// What a screen reader says for a tile of the placement test result grid when the table was not found ("Table of 7, to discover"). {name} is the table name of quizMultiplicationUnit. Not shown on screen.
  ///
  /// In fr, this message translates to:
  /// **'{name}, à découvrir'**
  String placementTableToDiscover(String name);

  /// Primary full-width button that leaves the placement test for the path ("See my path"): on the result screen, and on the error screen when the test cannot be built or saved. One line.
  ///
  /// In fr, this message translates to:
  /// **'Voir mon parcours'**
  String get placementSeePath;

  /// Tooltip and screen-reader label of the back arrow of the table detail ("Back to the learning path").
  ///
  /// In fr, this message translates to:
  /// **'Retour au parcours'**
  String get pathTableBack;

  /// Screen-reader label of a finished table on the map ("Table of 1, done, 3 stars").
  ///
  /// In fr, this message translates to:
  /// **'{name}, terminée, {stars, plural, =0{aucune étoile} =1{1 étoile} other{{stars} étoiles}}'**
  String pathTableNodeDone(String name, int stars);

  /// Screen-reader label of the current table on the map ("Table of 5, in progress").
  ///
  /// In fr, this message translates to:
  /// **'{name}, en cours'**
  String pathTableNodeCurrent(String name);

  /// Screen-reader label of a table opened by "Tout débloquer" and not started ("Table of 7, open").
  ///
  /// In fr, this message translates to:
  /// **'{name}, ouverte'**
  String pathTableNodeOpen(String name);

  /// Screen-reader label of a locked table on the map ("Table of 3, locked").
  ///
  /// In fr, this message translates to:
  /// **'{name}, verrouillée'**
  String pathTableNodeLocked(String name);

  /// Screen-reader label of a review node on the map that is not open yet ("Review, locked"). `name` is the name of the review stage ("Révision", feminine in French).
  ///
  /// In fr, this message translates to:
  /// **'{name}, verrouillée'**
  String pathReviewNodeLocked(String name);

  /// Screen-reader label of the lock icon of a stage that is not open yet ("Locked").
  ///
  /// In fr, this message translates to:
  /// **'Verrouillée'**
  String get pathLocked;

  /// Screen-reader label of a row of stars ("2 stars out of 3").
  ///
  /// In fr, this message translates to:
  /// **'{stars, plural, =0{Aucune étoile sur {max}} =1{1 étoile sur {max}} other{{stars} étoiles sur {max}}}'**
  String starsLabel(int stars, int max);

  /// Title of the Discovery stage that shows a whole multiplication table ("Here is the table of 5").
  ///
  /// In fr, this message translates to:
  /// **'Voici la table de {number}'**
  String pathDiscoveryTitle(int number);

  /// Screen-reader label of the empty progress bar at the top of the Discovery stage ("Before the first question").
  ///
  /// In fr, this message translates to:
  /// **'Avant la première question'**
  String get pathDiscoveryProgress;

  /// Title of the tip card of the Discovery stage ("The tip").
  ///
  /// In fr, this message translates to:
  /// **'L\'astuce'**
  String get pathTipTitle;

  /// Button at the bottom of the Discovery stage that starts its questions ("My turn to play"). Spoken by the child.
  ///
  /// In fr, this message translates to:
  /// **'À moi de jouer'**
  String get pathDiscoveryStart;

  /// Tip of a multiplication table, shown at its Discovery stage. `table` is the number of the table as text, from 1 to 12; `other` is the table of 12. One or two short sentences for a child of 6 to 11, with an example.
  ///
  /// In fr, this message translates to:
  /// **'{table, select, 1{Multiplier par 1 ne change rien : 1 × 7 = 7.} 2{Multiplier par 2, c\'est ajouter le nombre à lui-même : 2 × 6 = 6 + 6.} 3{Les résultats avancent de 3 en 3 : 3, 6, 9, 12…} 4{Multiplier par 4, c\'est doubler deux fois : 4 × 6, c\'est le double de 12.} 5{Les résultats de la table de 5 finissent toujours par 0 ou par 5.} 6{6 fois un nombre pair finit par le même chiffre : 6 × 4 = 24.} 7{Pour 7 × 8, pense à 5, 6, 7, 8 : 56 = 7 × 8.} 8{Multiplier par 8, c\'est doubler trois fois : 8 × 3 = 24.} 9{Les deux chiffres du résultat font toujours 9 : 9 × 4 = 36 et 3 + 6 = 9.} 10{Multiplier par 10, c\'est ajouter un 0 à droite : 10 × 7 = 70.} 11{Jusqu\'à 11 × 9, on écrit le chiffre deux fois : 11 × 4 = 44.} other{12 fois un nombre, c\'est 10 fois plus 2 fois : 12 × 3 = 30 + 6.}}'**
  String pathMultiplicationTip(String table);

  /// Title of the results screen after a stage of the learning path ("Stage done!").
  ///
  /// In fr, this message translates to:
  /// **'Étape terminée !'**
  String get resultsStageTitle;

  /// Screen-reader label of a table whose boss is defeated: the label of the table followed by its crown ("Table of 1, done, 3 stars, crown"). `crown` is `golden` once every fact of the table is mastered, `crown` otherwise.
  ///
  /// In fr, this message translates to:
  /// **'{label}, {crown, select, golden{couronne dorée} other{couronne}}'**
  String pathTableNodeCrowned(String label, String crown);

  /// Title of the boss fight screen of a multiplication table ("Boss of the table of 5").
  ///
  /// In fr, this message translates to:
  /// **'Boss de la table de {number}'**
  String quizBossTitleMultiplication(int number);

  /// Label above the life bar of the boss ("Boss life").
  ///
  /// In fr, this message translates to:
  /// **'Vie du boss'**
  String get quizBossLife;

  /// Hit points left out of the total, right of the life label, such as "7 / 12". Keep the slash.
  ///
  /// In fr, this message translates to:
  /// **'{left} / {total}'**
  String quizBossLifeValue(int left, int total);

  /// Screen-reader label of the life bar of the boss ("Boss life: 7 out of 12").
  ///
  /// In fr, this message translates to:
  /// **'Vie du boss : {left} sur {total}'**
  String quizBossLifeSpoken(int left, int total);

  /// Bubble next to the monster after a right answer, on two lines: the exclamation, then the hit points taken with a minus sign (U+2212), such as "Hit!" then "−1". Keep the line break; each line stays one or two words.
  ///
  /// In fr, this message translates to:
  /// **'Touché !\n−{damage}'**
  String quizBossHit(int damage);

  /// Bubble next to the monster after a right answer under 3 seconds, on two lines: the exclamation, then the hit points taken with a minus sign (U+2212), such as "Critical hit!" then "−2". Keep the line break; each line stays short.
  ///
  /// In fr, this message translates to:
  /// **'Coup critique !\n−{damage}'**
  String quizBossCriticalHit(int damage);

  /// Bubble next to the monster after a wrong answer: the monster strikes back, but the child loses nothing ("Strike back!").
  ///
  /// In fr, this message translates to:
  /// **'Riposte !'**
  String get quizBossStrikeBack;

  /// Bubble when the boss loses its last hit point ("Defeated!").
  ///
  /// In fr, this message translates to:
  /// **'Vaincu !'**
  String get quizBossDefeated;

  /// Bubble when the boss flees after the last question of the fight ("It runs away!").
  ///
  /// In fr, this message translates to:
  /// **'Il s\'enfuit !'**
  String get quizBossFled;

  /// Title of the results after a won boss fight ("Boss defeated!").
  ///
  /// In fr, this message translates to:
  /// **'Boss vaincu !'**
  String get resultsBossDefeated;

  /// Title of the results after a boss fight where the monster fled; the child can try again ("The monster ran away"). No blame.
  ///
  /// In fr, this message translates to:
  /// **'Le monstre s\'est enfui'**
  String get resultsBossFled;

  /// Big number of the first results tile: the XP earned by the quiz, such as "+130". The unit is in the label under it (rewardXpEarnedLabel); keep only the sign and the number.
  ///
  /// In fr, this message translates to:
  /// **'+{xp}'**
  String rewardXpEarned(int xp);

  /// Label under the XP earned on the first results tile ("XP earned"). XP means experience points. Short, one line in a third of the screen width.
  ///
  /// In fr, this message translates to:
  /// **'XP gagnés'**
  String get rewardXpEarnedLabel;

  /// XP earned by a quiz, written on one line with its unit, such as "+210 XP" at the right of the band of the challenge comparison screen. XP means experience points.
  ///
  /// In fr, this message translates to:
  /// **'+{xp} XP'**
  String rewardXpEarnedInline(int xp);

  /// Level of the player, bold title of the level card on the results screen ("Level 4"). Short, one line.
  ///
  /// In fr, this message translates to:
  /// **'Niveau {level}'**
  String rewardLevel(int level);

  /// Right of the level on the level card of the results: the XP still missing for the next level ("70 more XP for level 5"). Short, one line.
  ///
  /// In fr, this message translates to:
  /// **'Encore {xp} XP pour le niveau {next}'**
  String rewardXpToNextLevel(int xp, int next);

  /// Screen-reader label of the bar towards the next level ("Progress towards level 5").
  ///
  /// In fr, this message translates to:
  /// **'Progression vers le niveau {next}'**
  String rewardLevelProgressSpoken(int next);

  /// Title of the results card listing the badges the quiz unlocked ("New badge" or "New badges"). Only shown when at least one badge was unlocked. Short, one line.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Nouveau badge} other{Nouveaux badges}}'**
  String rewardNewBadgesTitle(int count);

  /// Name of the badge for completing a first stage ("First step"). Short: title of the badge celebration and of the badge list of the results.
  ///
  /// In fr, this message translates to:
  /// **'Premier pas'**
  String get rewardBadgeFirstStep;

  /// Name of the badge for completing a stage at 100 % ("Flawless", noun). Short: title of the badge celebration and of the badge list of the results.
  ///
  /// In fr, this message translates to:
  /// **'Sans-faute'**
  String get rewardBadgePerfect;

  /// Name of the badge for 20 lightning answers in all ("Lightning", noun). Short: title of the badge celebration and of the badge list of the results.
  ///
  /// In fr, this message translates to:
  /// **'Éclair'**
  String get rewardBadgeLightning;

  /// Name of the badge for 20 right answers in one time attack ("Sprinter", a fast runner). Short: title of the badge celebration and of the badge list of the results.
  ///
  /// In fr, this message translates to:
  /// **'Sprinter'**
  String get rewardBadgeSprinter;

  /// Name of the badge for 30 right answers in one survival game ("Survivor"). Short: title of the badge celebration and of the badge list of the results.
  ///
  /// In fr, this message translates to:
  /// **'Survivant'**
  String get rewardBadgeSurvivor;

  /// Name of the badge for a 7-day streak ("Steady", adjective describing the player). Short: title of the badge celebration and of the badge list of the results.
  ///
  /// In fr, this message translates to:
  /// **'Régulier'**
  String get rewardBadgeRegular;

  /// Name of the badge for defeating the boss of a multiplication table ("Tamer of the table of 7"). Title of the badge celebration and of the badge list of the results; one or two lines.
  ///
  /// In fr, this message translates to:
  /// **'Dompteur de la table de {number}'**
  String rewardBadgeTamerMultiplication(int number);

  /// Name of the badge for mastering the 120 multiplication facts ("The 120"). Short: title of the badge celebration and of the badge list of the results.
  ///
  /// In fr, this message translates to:
  /// **'Les 120'**
  String get rewardBadgeAllFacts;

  /// Line under the badge name in its celebration ("You completed your first stage."). Talks to the child.
  ///
  /// In fr, this message translates to:
  /// **'Tu as terminé ta première étape.'**
  String get rewardBadgeFirstStepHint;

  /// Line under the Sans-faute badge in its celebration ("A stage without a single mistake."). One or two lines.
  ///
  /// In fr, this message translates to:
  /// **'Une étape sans aucune erreur.'**
  String get rewardBadgePerfectHint;

  /// Line under the Éclair badge in its celebration ("20 lightning answers in all."). One or two lines.
  ///
  /// In fr, this message translates to:
  /// **'20 réponses éclair au total.'**
  String get rewardBadgeLightningHint;

  /// Line under the Sprinter badge in its celebration ("20 right answers in a time attack."). One or two lines.
  ///
  /// In fr, this message translates to:
  /// **'20 bonnes réponses en Contre-la-montre.'**
  String get rewardBadgeSprinterHint;

  /// Line under the Survivant badge in its celebration and on the Profile tab ("30 right answers in survival."). One or two lines.
  ///
  /// In fr, this message translates to:
  /// **'30 bonnes réponses en Survie.'**
  String get rewardBadgeSurvivorHint;

  /// Line under the Régulier badge in its celebration ("7 days of play in a row."). One or two lines.
  ///
  /// In fr, this message translates to:
  /// **'7 jours de jeu d\'affilée.'**
  String get rewardBadgeRegularHint;

  /// Line under a tamer badge in its celebration ("You beat the boss of this table."). Talks to the child (informal tu). One or two lines.
  ///
  /// In fr, this message translates to:
  /// **'Tu as battu le boss de cette table.'**
  String get rewardBadgeTamerHint;

  /// Line under the Les 120 badge in its celebration ("You master every multiplication."). Talks to the child (informal tu). One or two lines.
  ///
  /// In fr, this message translates to:
  /// **'Tu maîtrises toutes les multiplications.'**
  String get rewardBadgeAllFactsHint;

  /// Big title of the full-screen celebration when the player reaches a new level ("Level 5!"). Short, one line.
  ///
  /// In fr, this message translates to:
  /// **'Niveau {level} !'**
  String rewardLevelUpTitle(int level);

  /// Line under the level-up title ("You move up a level, well done."). Talks to the child.
  ///
  /// In fr, this message translates to:
  /// **'Tu passes au niveau supérieur, bravo.'**
  String get rewardLevelUpHint;

  /// Small title above the badge name in its full-screen celebration ("New badge!"). Short, one line.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau badge !'**
  String get rewardBadgeUnlocked;

  /// Hint at the bottom of a full-screen celebration: one tap closes it ("Tap the screen to go on"). Imperative, informal tu; also the accessibility label of the dismiss barrier. One line.
  ///
  /// In fr, this message translates to:
  /// **'Touche l\'écran pour continuer'**
  String get rewardTapToContinue;

  /// Streak pill, next to a flame icon, on the player cards of "Qui joue ?" and on the map header ("6 days"): days of play in a row. Never shown for 0 (rewardNoStreak is shown instead). Very short, a few characters.
  ///
  /// In fr, this message translates to:
  /// **'{days, plural, =1{1 jour} other{{days} jours}}'**
  String rewardStreakDays(int days);

  /// Streak pill of a player without a current streak, on the player cards of "Qui joue ?" and on the map header ("No streak"). Very short, one line.
  ///
  /// In fr, this message translates to:
  /// **'Pas de série'**
  String get rewardNoStreak;

  /// Screen-reader label of the streak pill: days of play in a row ("6-day streak", "No streak" for 0).
  ///
  /// In fr, this message translates to:
  /// **'{days, plural, =0{Pas de série} =1{Série de 1 jour} other{Série de {days} jours}}'**
  String rewardStreakSpoken(int days);

  /// Title of the daily goal card under the map header ("Daily goal"). Short, one line.
  ///
  /// In fr, this message translates to:
  /// **'Objectif du jour'**
  String get rewardDailyGoalTitle;

  /// XP earned today out of the daily goal, right of the title of the daily goal card ("30 / 50 XP"). Short, one line.
  ///
  /// In fr, this message translates to:
  /// **'{earned} / {goal} XP'**
  String rewardDailyGoalValue(int earned, int goal);

  /// Screen-reader label of the daily goal bar ("Daily goal: 30 out of 50 XP").
  ///
  /// In fr, this message translates to:
  /// **'Objectif du jour : {earned} sur {goal} XP'**
  String rewardDailyGoalSpoken(int earned, int goal);

  /// Screen-reader label of the crown pill on the map header: the pill shows only a crown icon and the number ("3 crowns").
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune couronne} =1{1 couronne} other{{count} couronnes}}'**
  String pathCrownsSpoken(int count);

  /// Screen-reader label of the combo pill in the quiz header, which shows only a flame icon and the number: right answers in a row ("Combo of 5").
  ///
  /// In fr, this message translates to:
  /// **'Combo de {count}'**
  String quizComboSpoken(int count);

  /// Mention next to the title of the green message ("Bravo !") when the right answers in a row reach 3, 5 or 10 ("Combo of 5!"). Short, one line.
  ///
  /// In fr, this message translates to:
  /// **'Combo de {count} !'**
  String quizComboMilestone(int count);

  /// Bubble of the mascot on the map while the daily goal is not reached ("{xp} more XP for your daily goal!"). Talks to the child.
  ///
  /// In fr, this message translates to:
  /// **'Encore {xp} XP pour ton objectif du jour !'**
  String mascotGoalReminder(int xp);

  /// Bubble of the mascot on the map once the daily goal is reached ("Daily goal reached, well done!").
  ///
  /// In fr, this message translates to:
  /// **'Objectif du jour atteint, bravo !'**
  String get mascotGoalReached;

  /// Bubble of the mascot on the question card after a mistake ("No worries, you'll get there!"). Warm, never blaming.
  ///
  /// In fr, this message translates to:
  /// **'Pas grave, tu vas y arriver !'**
  String get mascotEncouragement;

  /// Bubble of the mascot on the question card at a combo milestone ("Well done, {count} in a row!").
  ///
  /// In fr, this message translates to:
  /// **'Bravo, {count} d\'affilée !'**
  String mascotComboCheer(int count);

  /// Title of the mascot card of the Profile tab ("Your mascot is growing"). One short line.
  ///
  /// In fr, this message translates to:
  /// **'Ta mascotte grandit'**
  String get mascotCardTitle;

  /// Line of the mascot card: the stage and the level of the next one ("Stage 1 of 5 · next at level 5"). Keep the middle dot.
  ///
  /// In fr, this message translates to:
  /// **'Stade {stage} sur {total} · prochain au niveau {level}'**
  String mascotCardStage(int stage, int total, int level);

  /// Line of the mascot card once the mascot reached its last stage ("Stage 5 of 5 · fully grown").
  ///
  /// In fr, this message translates to:
  /// **'Stade {stage} sur {total} · taille maximale'**
  String mascotCardLastStage(int stage, int total);

  /// Title of the celebration when the mascot reaches a new stage ("Lim grew!"); {name} is the name the child gave it.
  ///
  /// In fr, this message translates to:
  /// **'{name} a grandi !'**
  String mascotGrewTitle(String name);

  /// Line under the growth celebration ("Stage 2 of 5").
  ///
  /// In fr, this message translates to:
  /// **'Stade {stage} sur {total}'**
  String mascotGrewHint(int stage, int total);

  /// Title of the mascot screen opened from the Profile tab ("My mascot").
  ///
  /// In fr, this message translates to:
  /// **'Ma mascotte'**
  String get mascotPageTitle;

  /// Screen-reader label of the mascot card of the Profile tab, which opens the mascot screen ("See my mascot").
  ///
  /// In fr, this message translates to:
  /// **'Voir ma mascotte'**
  String get mascotOpenTooltip;

  /// Label of the field where the child names the mascot ("Its name").
  ///
  /// In fr, this message translates to:
  /// **'Son nom'**
  String get mascotNameLabel;

  /// Button that saves the new name of the mascot ("Change the name").
  ///
  /// In fr, this message translates to:
  /// **'Changer le nom'**
  String get mascotRename;

  /// Title of the list of accessories on the mascot screen ("Accessories").
  ///
  /// In fr, this message translates to:
  /// **'Accessoires'**
  String get mascotAccessoriesTitle;

  /// Name of the group of accessories worn on the head ("Head").
  ///
  /// In fr, this message translates to:
  /// **'Tête'**
  String get mascotSlotHead;

  /// Name of the group of accessories worn on the eyes ("Eyes").
  ///
  /// In fr, this message translates to:
  /// **'Yeux'**
  String get mascotSlotEyes;

  /// Name of the group of accessories worn on the neck ("Neck").
  ///
  /// In fr, this message translates to:
  /// **'Cou'**
  String get mascotSlotNeck;

  /// Name of the group of accessories worn on the back ("Back").
  ///
  /// In fr, this message translates to:
  /// **'Dos'**
  String get mascotSlotBack;

  /// Name of a mascot accessory ("Cap").
  ///
  /// In fr, this message translates to:
  /// **'Casquette'**
  String get mascotAccessoryCap;

  /// Name of a mascot accessory ("Round glasses").
  ///
  /// In fr, this message translates to:
  /// **'Lunettes rondes'**
  String get mascotAccessoryRoundGlasses;

  /// Name of a mascot accessory ("Cape").
  ///
  /// In fr, this message translates to:
  /// **'Cape'**
  String get mascotAccessoryCape;

  /// Name of a mascot accessory ("Bow tie").
  ///
  /// In fr, this message translates to:
  /// **'Nœud papillon'**
  String get mascotAccessoryBowTie;

  /// Name of a mascot accessory ("Scarf").
  ///
  /// In fr, this message translates to:
  /// **'Écharpe'**
  String get mascotAccessoryScarf;

  /// Name of a mascot accessory ("Wizard hat").
  ///
  /// In fr, this message translates to:
  /// **'Chapeau de magicien'**
  String get mascotAccessoryWizardHat;

  /// Name of a mascot accessory ("Sunglasses").
  ///
  /// In fr, this message translates to:
  /// **'Lunettes de soleil'**
  String get mascotAccessorySunglasses;

  /// Name of a mascot accessory ("Backpack").
  ///
  /// In fr, this message translates to:
  /// **'Sac à dos'**
  String get mascotAccessoryBackpack;

  /// Name of a mascot accessory ("Headphones").
  ///
  /// In fr, this message translates to:
  /// **'Casque audio'**
  String get mascotAccessoryHeadphones;

  /// Name of a mascot accessory ("Medal").
  ///
  /// In fr, this message translates to:
  /// **'Médaille'**
  String get mascotAccessoryMedal;

  /// Name of a mascot accessory ("Wings").
  ///
  /// In fr, this message translates to:
  /// **'Ailes'**
  String get mascotAccessoryWings;

  /// Name of a mascot accessory ("King's crown").
  ///
  /// In fr, this message translates to:
  /// **'Couronne de roi'**
  String get mascotAccessoryKingCrown;

  /// Name of a mascot accessory ("Party hat").
  ///
  /// In fr, this message translates to:
  /// **'Chapeau de fête'**
  String get mascotAccessoryPartyHat;

  /// Name of a mascot accessory ("Lightning goggles").
  ///
  /// In fr, this message translates to:
  /// **'Lunettes éclair'**
  String get mascotAccessoryLightningGoggles;

  /// Name of a mascot accessory ("Golden cape").
  ///
  /// In fr, this message translates to:
  /// **'Cape dorée'**
  String get mascotAccessoryGoldenCape;

  /// How to unlock a locked accessory: win the n-th crown ("With the 3rd crown"). Shown under the accessory tile, one short line. French ordinals stay plain text, not superscript: "1re" for 1 (couronne is feminine), "{rank}e" otherwise.
  ///
  /// In fr, this message translates to:
  /// **'{rank, plural, =1{À la 1re couronne} other{À la {rank}e couronne}}'**
  String mascotUnlockCrown(int rank);

  /// How to unlock an accessory earned with the Régulier badge ("With the Steady badge").
  ///
  /// In fr, this message translates to:
  /// **'Avec le badge Régulier'**
  String get mascotUnlockRegular;

  /// How to unlock an accessory earned with the Éclair badge ("With the Lightning badge").
  ///
  /// In fr, this message translates to:
  /// **'Avec le badge Éclair'**
  String get mascotUnlockLightning;

  /// How to unlock an accessory earned with the Les 120 badge ("With The 120 badge").
  ///
  /// In fr, this message translates to:
  /// **'Avec le badge Les 120'**
  String get mascotUnlockAllFacts;

  /// Screen-reader label of an accessory the mascot wears ("Cap, on your mascot"). Accessory names have mixed grammatical genders, so the wording must not agree with {name}. Talks to the child (informal tu).
  ///
  /// In fr, this message translates to:
  /// **'{name}, sur ta mascotte'**
  String mascotAccessoryWorn(String name);

  /// Screen-reader label of a locked accessory with how to unlock it ("Cape, to unlock. With the 3rd crown"). Accessory names have mixed grammatical genders, so the wording must not agree with {name}; {hint} is a full phrase starting with a capital letter (mascotUnlock* keys).
  ///
  /// In fr, this message translates to:
  /// **'{name}, à débloquer. {hint}'**
  String mascotAccessoryLocked(String name, String hint);

  /// Title of the free training screen, where the child picks tables, a question count and the timer ("Practise").
  ///
  /// In fr, this message translates to:
  /// **'S\'entraîner'**
  String get trainingTitle;

  /// Line under the title of the free training screen ("Pick one or more tables."). Talks to the child (informal tu).
  ///
  /// In fr, this message translates to:
  /// **'Choisis une ou plusieurs tables.'**
  String get trainingSubtitle;

  /// Title above the choice of 10, 20 or 30 questions on the free training screen ("How many questions?").
  ///
  /// In fr, this message translates to:
  /// **'Combien de questions ?'**
  String get trainingQuestionCountTitle;

  /// Title above the timer choice on the free training screen ("Timer").
  ///
  /// In fr, this message translates to:
  /// **'Chrono'**
  String get trainingTimerTitle;

  /// Choice of a timer on each question of the free training ("With timer"). Half of a two-option switch: keep it short.
  ///
  /// In fr, this message translates to:
  /// **'Avec chrono'**
  String get trainingWithTimer;

  /// Choice of no timer for the free training ("No timer"). Half of a two-option switch: keep it short.
  ///
  /// In fr, this message translates to:
  /// **'Sans chrono'**
  String get trainingWithoutTimer;

  /// Line above the disabled "Lancer" button of the free training while no table is chosen ("Pick at least one table").
  ///
  /// In fr, this message translates to:
  /// **'Choisis au moins une table'**
  String get trainingNoTable;

  /// Button that starts the free training ("Start").
  ///
  /// In fr, this message translates to:
  /// **'Lancer'**
  String get trainingLaunch;

  /// Title of the challenges screen ("Challenges").
  ///
  /// In fr, this message translates to:
  /// **'Défis'**
  String get challengesTitle;

  /// Line under "Contre-la-montre" on its card of the challenges screen ("60 seconds, as many answers as you can").
  ///
  /// In fr, this message translates to:
  /// **'60 secondes, un maximum de réponses'**
  String get challengeTimeAttackSubtitle;

  /// Line under "Survie" on its card of the challenges screen ("3 lives, faster and faster").
  ///
  /// In fr, this message translates to:
  /// **'3 vies, de plus en plus vite'**
  String get challengeSurvivalSubtitle;

  /// Small line on the Survie card, shown only to a player who turned the timer off in the settings: survival keeps its timer anyway ("Here, the timer stays on."). Talks to the child. One line.
  ///
  /// In fr, this message translates to:
  /// **'Ici, le chrono reste actif.'**
  String get challengeSurvivalTimerNote;

  /// Line under "Révision du jour" on its card of the challenges screen ("10 questions chosen for you"). Talks to the child (informal tu).
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 question choisie pour toi} other{{count} questions choisies pour toi}}'**
  String challengeDailyReviewSubtitle(int count);

  /// Yellow pill at the end of the daily review card: number of facts whose review date has passed ("8 to review"). Short; hidden when no fact is due.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, other{{count} à revoir}}'**
  String challengeDailyReviewDue(int count);

  /// Line under "Révision du jour" on its greyed-out card while the player has never been asked a fact ("Play a stage of the path first"). Talks to the child (informal tu).
  ///
  /// In fr, this message translates to:
  /// **'Joue d\'abord une étape du parcours'**
  String get challengeDailyReviewLocked;

  /// Title of the card on the results of a time attack that beat the player's best score ("New record!").
  ///
  /// In fr, this message translates to:
  /// **'Nouveau record !'**
  String get resultsNewRecord;

  /// Line of the new record card on the results when the player had no record yet ("Your first record"). Talks to the child (informal tu).
  ///
  /// In fr, this message translates to:
  /// **'Ton premier record'**
  String get resultsFirstRecord;

  /// Summary above the "Lancer" button of the free training: tables chosen, a middle dot, then the question count ("2 tables · 10 questions").
  ///
  /// In fr, this message translates to:
  /// **'{tables, plural, =1{1 table} other{{tables} tables}} · {questions} questions'**
  String trainingSummary(int tables, int questions);

  /// Best score of the player, shown at the end of a challenge card ("Best 18"). Short.
  ///
  /// In fr, this message translates to:
  /// **'Record {score}'**
  String challengeRecord(int score);

  /// Line of the new record card on the results, with the record just beaten ("Previous best: 15").
  ///
  /// In fr, this message translates to:
  /// **'Ancien record : {previous}'**
  String resultsRecordBeaten(int previous);

  /// Score of the new record on its card of the results ("18 right answers").
  ///
  /// In fr, this message translates to:
  /// **'{score, plural, =1{1 bonne réponse} other{{score} bonnes réponses}}'**
  String resultsRecordScore(int score);

  /// Line under "Chasse aux monstres" on its card of the challenges screen: how many little monsters (facts the player keeps missing) wait to be tamed ("3 monsters to tame"); a neutral line when there is none ("No monster for now").
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun monstre pour l\'instant} =1{1 monstre à apprivoiser} other{{count} monstres à apprivoiser}}'**
  String challengeMonsterHuntSubtitle(int count);

  /// Name of the duel on one phone, on its card of the challenges screen and at the top of the player choice ("Duel").
  ///
  /// In fr, this message translates to:
  /// **'Duel'**
  String get duelTitle;

  /// Line under "Duel" on its card of the challenges screen ("2 players, 1 phone").
  ///
  /// In fr, this message translates to:
  /// **'2 joueurs, 1 téléphone'**
  String get challengeDuelSubtitle;

  /// Title of the dashed card at the bottom of the challenges screen, and of the screen it opens, where the child types the code a friend gave ("I have a code"). The child speaks in the first person. Short, one line.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai un code'**
  String get challengeCodeCardTitle;

  /// Line under "J'ai un code" on its card of the challenges screen ("Replay a friend's challenge"). Imperative. Talks to the child (informal tu). One line.
  ///
  /// In fr, this message translates to:
  /// **'Rejoue le défi d\'un ami'**
  String get challengeCodeCardSubtitle;

  /// Button at the end of a free training or a time attack, and title of the screen it opens showing the challenge code to give to a friend ("Challenge a friend"). "Défier" is an infinitive verb. One line.
  ///
  /// In fr, this message translates to:
  /// **'Défier un ami'**
  String get challengeShareButton;

  /// Small line under the score in the yellow badge of the challenge code card: the score is the one the friend has to beat ("to beat"). Very short: the badge is narrow.
  ///
  /// In fr, this message translates to:
  /// **'à battre'**
  String get challengeCodeToBeat;

  /// Small line above the big challenge code on the "Défier un ami" screen ("Your challenge code"). Talks to the child (informal tu). One line.
  ///
  /// In fr, this message translates to:
  /// **'Ton code de défi'**
  String get challengeCodeYours;

  /// Screen-reader text of the big challenge code: the characters are given one by one, separated by spaces, so they are spelled ("Challenge code: K 7 M 2…").
  ///
  /// In fr, this message translates to:
  /// **'Code de défi : {characters}'**
  String challengeCodeSemantics(String characters);

  /// Yellow button under the challenge code: copies it to the clipboard ("Copy the code"). "Copier" is an infinitive verb. One line.
  ///
  /// In fr, this message translates to:
  /// **'Copier le code'**
  String get challengeCodeCopy;

  /// Short message shown in a snackbar at the bottom of the screen once the challenge code is copied ("Code copied!"). One line.
  ///
  /// In fr, this message translates to:
  /// **'Code copié !'**
  String get challengeCodeCopied;

  /// Line under the challenge code card: what giving the code does ("Give this code to a friend: same mode, same tables, and your score to beat!"). The friend's questions come from the code, so they may differ from the ones the player just had. Talks to the child (informal tu). Up to three centered lines.
  ///
  /// In fr, this message translates to:
  /// **'Donne ce code à un ami : même mode, mêmes tables, et ton score à battre !'**
  String get challengeCodeShareHint;

  /// Word in the middle of the line separating the shown code from the code entry on the "Défier un ami" screen ("or"). One short lowercase word.
  ///
  /// In fr, this message translates to:
  /// **'ou'**
  String get challengeCodeOr;

  /// Title of the card where the child types a challenge code received from a friend ("Did you get a code?"). Talks to the child (informal tu). One line.
  ///
  /// In fr, this message translates to:
  /// **'Tu as reçu un code ?'**
  String get challengeCodeEntryTitle;

  /// Placeholder of the challenge code field ("Type the code here"). Written in capital letters because the field turns what the child types into capitals, as in the mockup; keep it in capitals in languages that have them. Talks to the child (informal tu). One line, about 20 characters.
  ///
  /// In fr, this message translates to:
  /// **'ÉCRIS LE CODE ICI'**
  String get challengeCodeEntryHint;

  /// Button under the challenge code field: checks the code and starts its game ("Play this challenge"). "Jouer" is an infinitive verb. One line.
  ///
  /// In fr, this message translates to:
  /// **'Jouer ce défi'**
  String get challengeCodePlay;

  /// Message under the code field when what was typed is not a challenge code: wrong length or a character that codes never use ("This code does not exist. A code has 10 letters and digits."). Talks to the child (informal tu). Kind, never blaming; up to two lines.
  ///
  /// In fr, this message translates to:
  /// **'Ce code n\'existe pas. Un code a 10 lettres et chiffres.'**
  String get challengeCodeErrorMalformed;

  /// Message under the code field when the check character shows a typing mistake: a character changed or two swapped ("A letter or a digit is wrong. Check the code with your friend."). Talks to the child (informal tu). Kind, never blaming; up to two lines.
  ///
  /// In fr, this message translates to:
  /// **'Une lettre ou un chiffre ne va pas. Vérifie le code avec ton ami.'**
  String get challengeCodeErrorAltered;

  /// Message under the code field when the code was made by a newer version of the app, whose questions this one cannot draw ("This challenge comes from a newer version of the app. Update the app to play it."). Talks to the child (informal tu). Up to three lines.
  ///
  /// In fr, this message translates to:
  /// **'Ce défi vient d\'une version plus récente de l\'app. Mets l\'app à jour pour le jouer.'**
  String get challengeCodeErrorVersion;

  /// Tables of a challenge when it covers the 12 tables, after the mode in the subtitle of the comparison screen ("all the tables"). Lowercase: it follows "Contre-la-montre ·". The capitalized form on its own line is challengeCodeCardTablesAll.
  ///
  /// In fr, this message translates to:
  /// **'toutes les tables'**
  String get challengeCodeTablesAll;

  /// Tables of a challenge on one table, after the mode in the subtitle of the comparison screen ("table of 7"). Lowercase: it follows "Contre-la-montre ·". The capitalized form on its own line is challengeCodeCardTablesOne.
  ///
  /// In fr, this message translates to:
  /// **'table de {table}'**
  String challengeCodeTablesOne(int table);

  /// One table in the list of the tables of a challenge, such as "de 2" in "tables de 2, de 5 et de 7". Used by challengeCodeTablesMany and challengeCodeCardTablesMany; the items are joined by ", " in code.
  ///
  /// In fr, this message translates to:
  /// **'de {table}'**
  String challengeCodeTableItem(int table);

  /// Tables of a challenge on several tables, after the mode in the subtitle of the comparison screen ("tables de 2, de 5 et de 7"): first is every table but the last, each written with challengeCodeTableItem and separated by commas; last is the last one, written the same way. Lowercase: it follows "Contre-la-montre ·". The capitalized form on its own line is challengeCodeCardTablesMany.
  ///
  /// In fr, this message translates to:
  /// **'tables {first} et {last}'**
  String challengeCodeTablesMany(String first, String last);

  /// Tables of a challenge covering the 12 tables, on their own line under the mode in the violet card of the "Défier un ami" screen ("All the tables"). Starts with a capital letter: it begins its line. One line.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les tables'**
  String get challengeCodeCardTablesAll;

  /// Tables of a challenge on one table, on their own line under the mode in the violet card of the "Défier un ami" screen ("Table of 7"). Starts with a capital letter: it begins its line. One line.
  ///
  /// In fr, this message translates to:
  /// **'Table de {table}'**
  String challengeCodeCardTablesOne(int table);

  /// Tables of a challenge on several tables, on their own line under the mode in the violet card of the "Défier un ami" screen ("Tables de 2 et de 5"): first is every table but the last, each written with challengeCodeTableItem and separated by commas; last is the last one, written the same way. Starts with a capital letter: it begins its line.
  ///
  /// In fr, this message translates to:
  /// **'Tables {first} et {last}'**
  String challengeCodeCardTablesMany(String first, String last);

  /// Line under the title of the challenge score comparison: the mode and the tables of the challenge ("Contre-la-montre · tables de 2 et de 5").
  ///
  /// In fr, this message translates to:
  /// **'{mode} · {tables}'**
  String challengeCodeSubtitle(String mode, String tables);

  /// Big title of the comparison screen when the child beat the score of the code ("Challenge won!"). Joyful, one line.
  ///
  /// In fr, this message translates to:
  /// **'Défi gagné !'**
  String get challengeOutcomeWon;

  /// Big title of the comparison screen when the child did not reach the score of the code; kind, never discouraging ("Not this time!"). One line.
  ///
  /// In fr, this message translates to:
  /// **'Pas cette fois !'**
  String get challengeOutcomeLost;

  /// Big title of the comparison screen when the child made exactly the score of the code ("It's a tie!"). One line.
  ///
  /// In fr, this message translates to:
  /// **'Égalité !'**
  String get challengeOutcomeTie;

  /// Label of the white card of the comparison screen: the score the friend made, written in the code ("Score to beat"). Short: the card is half the screen wide.
  ///
  /// In fr, this message translates to:
  /// **'Score à battre'**
  String get challengeOutcomeToBeat;

  /// Label of the violet card of the comparison screen: the child's score ("Your score"). Talks to the child (informal tu). Short: the card is half the screen wide.
  ///
  /// In fr, this message translates to:
  /// **'Ton score'**
  String get challengeOutcomeYours;

  /// Line under the big score of each card of the comparison screen; the number itself is shown above it, so the text has no number ("right answer(s)"). Short: the card is half the screen wide.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{bonne réponse} =1{bonne réponse} other{bonnes réponses}}'**
  String challengeOutcomeCorrect(int count);

  /// Difference shown in the yellow band of the comparison screen when the child won ("3 more right answers"). One line, beside the XP earned.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 bonne réponse de plus} other{{count} bonnes réponses de plus}}'**
  String challengeOutcomeMore(int count);

  /// Difference shown in the yellow band of the comparison screen when the child lost ("2 fewer right answers"). One line, beside the XP earned.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 bonne réponse de moins} other{{count} bonnes réponses de moins}}'**
  String challengeOutcomeFewer(int count);

  /// Text of the yellow band of the comparison screen on a tie ("As many right answers"). One line, beside the XP earned.
  ///
  /// In fr, this message translates to:
  /// **'Autant de bonnes réponses'**
  String get challengeOutcomeSame;

  /// Main button of the comparison screen: makes a new code with the same questions and the child's score to beat ("Send a challenge back"). "Renvoyer" is an infinitive verb. One line.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer un défi'**
  String get challengeOutcomeResend;

  /// Second button of the comparison screen: back to the challenges tab ("Back to the challenges"). One line.
  ///
  /// In fr, this message translates to:
  /// **'Retour aux défis'**
  String get challengeOutcomeBack;

  /// Line under the title of the duel player choice: how to hold the phone ("Lay the phone flat between you. The top player reads upside down."). Talks to both children (vous).
  ///
  /// In fr, this message translates to:
  /// **'Posez le téléphone à plat entre vous deux. Le joueur du haut lit à l\'envers.'**
  String get duelPickIntro;

  /// Section title in the duel player choice: the list where the player of the upside-down top half is chosen ("Top player"). One line.
  ///
  /// In fr, this message translates to:
  /// **'Joueur du haut'**
  String get duelSideTop;

  /// Section title in the duel player choice: the list where the player of the bottom half is chosen ("Bottom player"). One line.
  ///
  /// In fr, this message translates to:
  /// **'Joueur du bas'**
  String get duelSideBottom;

  /// Choice for someone who has no profile on the phone; also the name shown on their half of the duel ("Guest"). Short.
  ///
  /// In fr, this message translates to:
  /// **'Invité'**
  String get duelGuest;

  /// Small line under "Invité" in the player choice: a guest plays every table and earns no XP ("All tables, no XP"). Short.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les tables, sans XP'**
  String get duelGuestRule;

  /// Line above the disabled start button of the duel player choice while the two players are not chosen or are the same ("Pick two different players."). Talks to both children (vous).
  ///
  /// In fr, this message translates to:
  /// **'Choisissez deux joueurs différents.'**
  String get duelPickHint;

  /// Button at the bottom of the duel player choice that starts the duel once both players are chosen ("Let's go!"). Short, one line.
  ///
  /// In fr, this message translates to:
  /// **'C\'est parti !'**
  String get duelStart;

  /// Screen-reader hint, in the duel player choice, of a player already chosen for the other half, who cannot be picked twice ("Already picked"; masculine singular past participle, may refer to a girl or a boy).
  ///
  /// In fr, this message translates to:
  /// **'Déjà choisi'**
  String get duelPlayerTaken;

  /// Score of a player on their half of the duel: right answers / answers that win ("4 / 10").
  ///
  /// In fr, this message translates to:
  /// **'{score} / {target}'**
  String duelScore(int score, int target);

  /// Screen-reader text of a player's progress bar on their half of the duel: nickname (or "Invité"), then right answers out of the answers that win, with a plural on the score ("Moussa: 4 right answers out of 10").
  ///
  /// In fr, this message translates to:
  /// **'{name} : {score, plural, =0{aucune bonne réponse} =1{1 bonne réponse} other{{score} bonnes réponses}} sur {target}'**
  String duelScoreSpoken(String name, int score, int target);

  /// Tooltip of the round pause button between the two halves of the duel ("Pause the duel").
  ///
  /// In fr, this message translates to:
  /// **'Mettre le duel en pause'**
  String get duelPause;

  /// Title of the dialog opened by the pause button of the duel ("Duel paused").
  ///
  /// In fr, this message translates to:
  /// **'Duel en pause'**
  String get duelPauseTitle;

  /// Text of the pause dialog of the duel ("If you stop now, nobody earns XP."). Talks to both children (vous).
  ///
  /// In fr, this message translates to:
  /// **'Si vous arrêtez maintenant, personne ne gagne d\'XP.'**
  String get duelPauseMessage;

  /// Button of the pause dialog that goes back to the duel ("Resume").
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get duelResume;

  /// Button of the pause dialog that stops the duel and goes back to the player choice ("Stop the duel").
  ///
  /// In fr, this message translates to:
  /// **'Arrêter le duel'**
  String get duelStop;

  /// Line on the half of a player who just gave a wrong answer: their buttons are blocked for 2 seconds while the right answer shows ("Oops! Wait a moment…"). Talks to that child (informal tu). Short, one line.
  ///
  /// In fr, this message translates to:
  /// **'Oups ! Attends un peu…'**
  String get duelBlocked;

  /// Screen-reader label of the answer button showing the right answer after a mistake in the duel ("42, right answer").
  ///
  /// In fr, this message translates to:
  /// **'{answer}, bonne réponse'**
  String duelAnswerRight(int answer);

  /// Screen-reader label of the answer button the player tapped by mistake in the duel ("36, wrong answer").
  ///
  /// In fr, this message translates to:
  /// **'{answer}, mauvaise réponse'**
  String duelAnswerWrong(int answer);

  /// Title of the end of the duel, with the winner's nickname, or "Invité" ("Awa wins!").
  ///
  /// In fr, this message translates to:
  /// **'{name} gagne !'**
  String duelWinner(String name);

  /// XP a player of the phone earned in the duel, on the end screen ("+120 XP").
  ///
  /// In fr, this message translates to:
  /// **'+{xp} XP'**
  String duelXpEarned(int xp);

  /// Line instead of the XP for a guest on the end screen of the duel ("No XP for a guest").
  ///
  /// In fr, this message translates to:
  /// **'Pas d\'XP pour un invité'**
  String get duelGuestNoXp;

  /// Line on the end screen of the duel when the phone failed to save the XP ("The XP could not be saved.").
  ///
  /// In fr, this message translates to:
  /// **'Les XP n\'ont pas pu être enregistrés.'**
  String get duelXpNotSaved;

  /// Button of the end screen of the duel that starts a new duel between the same players ("Play again", infinitive verb). Short, one line.
  ///
  /// In fr, this message translates to:
  /// **'Rejouer'**
  String get duelReplay;

  /// Button of the end screen of the duel that goes back to the challenges screen ("Leave", infinitive verb). Short, one line.
  ///
  /// In fr, this message translates to:
  /// **'Quitter'**
  String get duelQuit;

  /// Title of the « Mes monstres » screen, which lists the facts the player keeps missing as little monsters to tame ("My monsters").
  ///
  /// In fr, this message translates to:
  /// **'Mes monstres'**
  String get monstersPageTitle;

  /// Line under the title of the « Mes monstres » screen ("These sums still resist you. Get them right to tame their monsters."). Talks to the child (informal tu).
  ///
  /// In fr, this message translates to:
  /// **'Ces calculs te résistent encore. Réussis-les pour apprivoiser leurs monstres.'**
  String get monstersIntro;

  /// Encouraging text of the « Mes monstres » screen when no fact is a monster ("No monster in sight, well done! A sum missed twice will become a little monster to tame."). Talks to the child (informal tu).
  ///
  /// In fr, this message translates to:
  /// **'Aucun monstre en vue, bravo ! Un calcul raté deux fois deviendra un petit monstre à apprivoiser.'**
  String get monstersEmpty;

  /// Label on the right of a monster whose fact was missed lately, the hardest to tame ("Very tough"). Short.
  ///
  /// In fr, this message translates to:
  /// **'Très coriace'**
  String get monsterToughnessVeryTough;

  /// Label on the right of a monster whose fact is improving ("Tough"). Short.
  ///
  /// In fr, this message translates to:
  /// **'Coriace'**
  String get monsterToughnessTough;

  /// Label on the right of a monster whose fact is one step from being known ("Almost tamed"). Short.
  ///
  /// In fr, this message translates to:
  /// **'Presque apprivoisé'**
  String get monsterToughnessAlmostTamed;

  /// What a screen reader says for a monster still to tame on the « Mes monstres » screen ("Monster 7 times 8, very tough").
  ///
  /// In fr, this message translates to:
  /// **'Monstre {fact}, {toughness}'**
  String monsterWildSpoken(String fact, String toughness);

  /// What a screen reader says for a tamed monster of the « Apprivoisés » collection ("Monster 6 times 7, tamed").
  ///
  /// In fr, this message translates to:
  /// **'Monstre {fact}, apprivoisé'**
  String monsterTamedSpoken(String fact);

  /// Main button of the « Mes monstres » screen: starts the monster hunt quiz ("Start the hunt").
  ///
  /// In fr, this message translates to:
  /// **'Lancer la chasse'**
  String get monstersHuntButton;

  /// Second line of the "Lancer la chasse" button: number of questions of the hunt ("10 questions").
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 question} other{{count} questions}}'**
  String monstersHuntQuestions(int count);

  /// Title of the collection of tamed monsters at the bottom of the « Mes monstres » screen ("Tamed").
  ///
  /// In fr, this message translates to:
  /// **'Apprivoisés'**
  String get monstersTamedTitle;

  /// Number of tamed monsters, at the right of "Apprivoisés" ("4 monsters").
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 monstre} other{{count} monstres}}'**
  String monstersTamedCount(int count);

  /// Link at the bottom of the "Mes monstres" card of the Profile tab: opens the screen of the little monsters, the facts the player keeps missing ("See my little monsters").
  ///
  /// In fr, this message translates to:
  /// **'Voir mes petits monstres'**
  String get pathMonstersOpenLittle;

  /// Title of the weekly leaderboard screen, where the players of the phone are ranked by the XP earned this week, and of its card on the Profile tab ("Leaderboard"). Short, one line.
  ///
  /// In fr, this message translates to:
  /// **'Classement'**
  String get leaderboardTitle;

  /// Line under the title of the leaderboard: the players are ranked by the XP earned since Monday ("XP earned this week"). One line, shares the row with the "Remise à zéro lundi" pill.
  ///
  /// In fr, this message translates to:
  /// **'XP gagnés cette semaine'**
  String get leaderboardWeekLabel;

  /// Pill at the right of "XP gagnés cette semaine" on the leaderboard: the ranking starts again from zero every Monday ("Reset on Monday"). Short.
  ///
  /// In fr, this message translates to:
  /// **'Remise à zéro lundi'**
  String get leaderboardResetHint;

  /// Dark tag under the nickname of the active player on the leaderboard, so the child finds themselves ("That's you"). Informal "tu", short.
  ///
  /// In fr, this message translates to:
  /// **'C\'est toi'**
  String get leaderboardYou;

  /// XP earned this week by a player of the leaderboard, under the rank on a podium step and at the right of each row ("310 XP"). XP means experience points. Short, one line.
  ///
  /// In fr, this message translates to:
  /// **'{xp} XP'**
  String leaderboardXp(int xp);

  /// Screen-reader text of a player of the leaderboard ("Moussa, rank 1, 420 XP"). Neutral wording, no gendered ordinal.
  ///
  /// In fr, this message translates to:
  /// **'{nickname}, place {rank}, {xp} XP'**
  String leaderboardEntrySpoken(String nickname, int rank, int xp);

  /// Screen-reader text of the active player on the leaderboard ("Awa, that's you, rank 2, 310 XP"). Neutral wording, no gendered ordinal.
  ///
  /// In fr, this message translates to:
  /// **'{nickname}, c\'est toi, place {rank}, {xp} XP'**
  String leaderboardEntryYouSpoken(String nickname, int rank, int xp);

  /// What the mascot says at the bottom of the leaderboard: the XP the active player needs to catch up with the player just above ("110 more XP and you catch up with Moussa!"). Informal "tu", encouraging.
  ///
  /// In fr, this message translates to:
  /// **'Encore {xp} XP et tu rattrapes {nickname} !'**
  String leaderboardChaseBehind(int xp, String nickname);

  /// What the mascot says at the bottom of the leaderboard when the active player has as many XP this week as the player just above, who is listed before them because ties are ordered by nickname ("You are tied with Moussa!"). Informal "tu".
  ///
  /// In fr, this message translates to:
  /// **'Tu es à égalité avec {nickname} !'**
  String leaderboardChaseTied(String nickname);

  /// What the mascot says at the bottom of the leaderboard when the active player is first with XP this week ("You are leading this week!"). Informal "tu", cheerful.
  ///
  /// In fr, this message translates to:
  /// **'Tu es en tête cette semaine !'**
  String get leaderboardChaseLeading;

  /// What the mascot says at the bottom of the leaderboard when nobody has earned XP yet this week, for instance on Monday morning ("Play to earn your first XP of the week!"). Informal "tu".
  ///
  /// In fr, this message translates to:
  /// **'Joue pour gagner tes premiers XP de la semaine !'**
  String get leaderboardChaseNotStarted;

  /// Line under "Classement" on the card of the Profile tab that opens the weekly leaderboard ("Who earned the most XP this week?"). One short line.
  ///
  /// In fr, this message translates to:
  /// **'Qui a gagné le plus d\'XP cette semaine ?'**
  String get leaderboardEntrySubtitle;

  /// Switch of the settings screen, in the "Jeu" section, that shows or hides the weekly leaderboard for every player of the phone; when off, its card disappears from the Profile tab ("Show the leaderboard"). Infinitive verb, one line.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le classement'**
  String get settingsShowLeaderboard;

  /// Title of the shop screen (mockup 22) and of its card on the Profile tab, where a player spends the coins earned by playing on avatars and color themes ("Shop"). One word.
  ///
  /// In fr, this message translates to:
  /// **'Boutique'**
  String get shopTitle;

  /// Line under "Boutique" on the card of the Profile tab that opens the shop ("Avatars and themes to unlock"). One short line.
  ///
  /// In fr, this message translates to:
  /// **'Avatars et thèmes à débloquer'**
  String get shopEntrySubtitle;

  /// Screen-reader label of the coin pill: how many coins the player can spend in the shop ("240 coins"). Only the number is displayed, next to a yellow coin.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 pièce} =1{1 pièce} other{{count} pièces}}'**
  String shopCoinBalance(int count);

  /// Tab of the shop that lists the avatars ("Avatars"). One word.
  ///
  /// In fr, this message translates to:
  /// **'Avatars'**
  String get shopTabAvatars;

  /// Tab of the shop that lists the color themes of the app ("Themes"). One word.
  ///
  /// In fr, this message translates to:
  /// **'Thèmes'**
  String get shopTabThemes;

  /// Label of the button under the avatar the player wears now, in the shop ("Worn"). One short word, masculine (un avatar).
  ///
  /// In fr, this message translates to:
  /// **'Porté'**
  String get shopWorn;

  /// Label of the button under the color theme the player applied, in the shop ("Active"). One short word, masculine (un thème).
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get shopActive;

  /// Button under an avatar or a theme the player owns but does not use: wears the avatar or applies the theme ("Choose"). Infinitive verb, one word.
  ///
  /// In fr, this message translates to:
  /// **'Choisir'**
  String get shopChoose;

  /// Screen-reader label of the button under the avatar the player wears ("Fox, worn"). Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'{name}, porté'**
  String shopWornLabel(String name);

  /// Screen-reader label of the button under the theme the player applied ("Ocean, active"). Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'{name}, actif'**
  String shopActiveLabel(String name);

  /// Screen-reader label of the "Choisir" button under an avatar or a theme the player owns ("Choose Fox"). Never displayed.
  ///
  /// In fr, this message translates to:
  /// **'Choisir {name}'**
  String shopChooseLabel(String name);

  /// Screen-reader label of the price button under an item the player can afford; it opens the purchase confirmation ("Buy Fox for 80 coins"). Never displayed. Prices go from 80 to 300 coins; the plural follows the price.
  ///
  /// In fr, this message translates to:
  /// **'{price, plural, =1{Acheter {name} pour 1 pièce} other{Acheter {name} pour {price} pièces}}'**
  String shopBuyLabel(String name, int price);

  /// Screen-reader label of the greyed price button under an item the player cannot afford yet ("King, 300 coins: you need more coins"). Never displayed. Informal "tu"; the plural follows the price.
  ///
  /// In fr, this message translates to:
  /// **'{price, plural, =1{{name}, 1 pièce : il te manque des pièces} other{{name}, {price} pièces : il te manque des pièces}}'**
  String shopTooExpensiveLabel(String name, int price);

  /// Message shown at the bottom of the shop when the player taps the greyed price of an item they cannot afford ("You need 60 more coins. Keep playing to earn them!"). Encouraging tone, informal "tu".
  ///
  /// In fr, this message translates to:
  /// **'{missing, plural, =1{Il te manque 1 pièce. Joue encore pour la gagner !} other{Il te manque {missing} pièces. Joue encore pour les gagner !}}'**
  String shopNotEnoughCoins(int missing);

  /// Title of the dialog that confirms a purchase in the shop ("Buy Fox?"). The item is drawn under it.
  ///
  /// In fr, this message translates to:
  /// **'Acheter {name} ?'**
  String shopBuyTitle(String name);

  /// Text of the purchase confirmation dialog: the price and the coins left after it ("It costs 80 coins. You will have 160 left."; with 0 left: "You will have none left."). Informal "tu"; each plural follows its own number.
  ///
  /// In fr, this message translates to:
  /// **'Ça coûte {price, plural, =1{1 pièce} other{{price} pièces}}. {left, plural, =0{Il ne t\'en restera aucune.} =1{Il t\'en restera 1.} other{Il t\'en restera {left}.}}'**
  String shopBuyMessage(int price, int left);

  /// Button of the purchase confirmation dialog that spends the coins ("Buy"). Infinitive verb, one word. Coins only: no real money.
  ///
  /// In fr, this message translates to:
  /// **'Acheter'**
  String get shopBuyConfirm;

  /// Message shown at the bottom of the shop after a purchase ("Well done, Fox is yours! Tap Choose to use it."). Cheerful tone, informal "tu"; "Choisir" is the button of the item.
  ///
  /// In fr, this message translates to:
  /// **'Bravo, {name} est à toi ! Touche « Choisir » pour l\'utiliser.'**
  String shopPurchased(String name);

  /// Hint at the bottom of the shop grid that tells how coins are earned ("Earn coins by playing: 1 coin every 10 XP, 20 per crown and 10 per badge"). A crown is won by beating the boss of a table, a badge by an achievement. Informal "tu".
  ///
  /// In fr, this message translates to:
  /// **'Gagne des pièces en jouant : 1 pièce tous les {xpPerCoin} XP, {coinsPerCrown} par couronne et {coinsPerBadge} par badge.'**
  String shopEarnHint(int xpPerCoin, int coinsPerCrown, int coinsPerBadge);

  /// Message shown at the bottom of the shop when a purchase is refused because the player lacks coins ("You do not have enough coins for that"). Informal "tu".
  ///
  /// In fr, this message translates to:
  /// **'Tu n\'as pas assez de pièces pour ça.'**
  String get shopErrorNotEnoughCoins;

  /// Message shown at the bottom of the shop when a purchase is refused because the player already owns the item ("You already have it!"). Informal "tu".
  ///
  /// In fr, this message translates to:
  /// **'Tu l\'as déjà !'**
  String get shopErrorAlreadyOwned;

  /// Name of an avatar of the shop, an orange fox ("Fox"). Read by screen readers and in the purchase dialog. One word.
  ///
  /// In fr, this message translates to:
  /// **'Renard'**
  String get shopAvatarFox;

  /// Name of an avatar of the shop, a panda ("Panda"). Read by screen readers and in the purchase dialog. One word.
  ///
  /// In fr, this message translates to:
  /// **'Panda'**
  String get shopAvatarPanda;

  /// Name of an avatar of the shop, a robot ("Robot"). Read by screen readers and in the purchase dialog. One word.
  ///
  /// In fr, this message translates to:
  /// **'Robot'**
  String get shopAvatarRobot;

  /// Name of an avatar of the shop, a green alien ("Alien"). Read by screen readers and in the purchase dialog. One word.
  ///
  /// In fr, this message translates to:
  /// **'Extraterrestre'**
  String get shopAvatarAlien;

  /// Name of an avatar of the shop, a unicorn ("Unicorn"). Read by screen readers and in the purchase dialog. One word.
  ///
  /// In fr, this message translates to:
  /// **'Licorne'**
  String get shopAvatarUnicorn;

  /// Name of an avatar of the shop, a dragon ("Dragon"). Read by screen readers and in the purchase dialog. One word.
  ///
  /// In fr, this message translates to:
  /// **'Dragon'**
  String get shopAvatarDragon;

  /// Name of an avatar of the shop, a ninja ("Ninja"). Read by screen readers and in the purchase dialog. One word.
  ///
  /// In fr, this message translates to:
  /// **'Ninja'**
  String get shopAvatarNinja;

  /// Name of an avatar of the shop, a king with a crown ("King"). Read by screen readers and in the purchase dialog. One word.
  ///
  /// In fr, this message translates to:
  /// **'Roi'**
  String get shopAvatarKing;

  /// Name of the default color theme of the app, lavender and violet ("Lavender"), shown under its picture in the shop. One word.
  ///
  /// In fr, this message translates to:
  /// **'Lavande'**
  String get shopThemeLavender;

  /// Name of a color theme of the shop, in blues ("Ocean"), shown under its picture. One word.
  ///
  /// In fr, this message translates to:
  /// **'Océan'**
  String get shopThemeOcean;

  /// Name of a color theme of the shop, in greens ("Forest"), shown under its picture. One word.
  ///
  /// In fr, this message translates to:
  /// **'Forêt'**
  String get shopThemeForest;

  /// Name of a color theme of the shop, in oranges ("Sunset"), shown under its picture in a half-width card. Short.
  ///
  /// In fr, this message translates to:
  /// **'Coucher de soleil'**
  String get shopThemeSunset;

  /// Name of the dark color theme of the shop: light text on a deep blue ground ("Night"), shown under its picture. One word.
  ///
  /// In fr, this message translates to:
  /// **'Nuit'**
  String get shopThemeNight;
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
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
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
