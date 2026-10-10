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
