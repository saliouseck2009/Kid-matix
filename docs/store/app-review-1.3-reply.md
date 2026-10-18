# App Review — reply to the Guideline 1.3 questions (Kids Category)

Automated request received on 16 October 2026 for the submission of version
1.0.1 (build 3). Apple asks four questions about Guideline 1.3; paste the
block below as a reply to that message in App Store Connect (App Review
message thread of the submission).

Facts behind every answer: `docs/release/audit-1.0.md`, the privacy policy
(`docs/store/privacy-policy-en.md`) and the dependency list of
`pubspec.yaml`. Nothing in `lib/` performs a network call: there is no HTTP
client, no socket, no WebView and no URL launcher in the app code.

## Reply to paste

> Thank you for the questions. Kid Matix is an offline, single-device
> learning app for children. It has no account, no sign-up, no backend of
> our own, and it makes no network request. Detailed answers below.
>
> **1. Does the app include third-party analytics?**
> No. The app contains no analytics SDK of any kind — no Firebase/Google
> Analytics, no AppsFlyer, Adjust, Amplitude, Mixpanel, Sentry, Crashlytics
> or similar. No usage, event or crash data is collected or transmitted.
> Uncaught errors are written to the local device console only (our
> `CrashReporter` interface has a single implementation, `LogCrashReporter`,
> which calls the system log and nothing else).
>
> **2. Does the app include third-party advertising?**
> No. The app contains no advertising SDK, shows no ads of any kind
> (banner, interstitial, rewarded or native), has no in-app purchases, no
> cross-promotion and no external links. The advertising identifier (IDFA)
> is not read and App Tracking Transparency is never requested, because no
> tracking takes place.
>
> **3. Will the data be shared with any third parties?**
> No. No data is shared with anyone, including us, the developer. There is
> no server, no API and no network connection: all data created in the app
> stays in the app's own container on the device (SQLite database and
> UserDefaults). The database file is explicitly excluded from iCloud
> backup (`isExcludedFromBackup = true` in our AppDelegate), so the game
> data is not copied off the device even by system backup.
>
> The only way any data can leave the device is an explicit, user-initiated
> export: in Settings, an adult can export one child profile to a file and
> then share it with the system share sheet (for example to move a profile
> to another device). This is initiated by the user, the destination is
> chosen by the user in the iOS share sheet, nothing is sent to us, and
> both the export and the import are placed behind a parental gate (the
> adult must type, in digits, a number that is written out in words).
>
> **4. Is the app collecting any user or device data for purposes beyond
> third-party analytics or third-party advertising?**
> No data is collected, in Apple's sense of the word: nothing is
> transmitted off the device. The app does store data locally, on the
> device only, purely to make the game work. Up to 10 player profiles can
> be created on one device, and for each profile the app stores locally:
>
> - the nickname chosen by the child (2–12 characters; the app advises
>   using a nickname rather than a real name), plus the avatar and colour
>   picked from those built into the app;
> - learning progress: answers given, answer times, mastery level per
>   multiplication fact, stars, crowns, XP, level, daily streak, badges and
>   personal records;
> - the mascot's name and the accessories it wears;
> - the player's settings: sound, vibration, timer, daily goal, reduced
>   animations.
>
> This local data is used only to display progress, choose which questions
> to review next, and award in-game rewards. It is never profiled, never
> enriched, never sent anywhere. Deleting a player in the app erases that
> player's data; deleting the app erases everything.
>
> No device identifier is read or stored. The app requests one permission
> only, and only if the parent turns on the optional daily reminder:
> notifications, which are scheduled locally on the device. The app never
> asks for camera, microphone, location, contacts, photos or tracking.
> The in-app leaderboard is local: it only ranks the profiles that exist on
> that same device.
>
> **One technical note, for completeness.** Our iOS binary links Apple's
> GameKit framework, because the cross-platform plugin we use on Android
> for Google Play Games sign-in (`games_services`) also covers Game Center.
> On iOS no Game Center feature is used at all: the Game Center capability
> is not enabled for the app, no leaderboard or achievement is configured,
> the sign-in call is explicitly restricted to Android in our code, and
> nothing Game Center-related is ever displayed to the child. No data is
> collected or transmitted through it.
>
> Our privacy policy states all of the above and is published here:
> https://saliouseck2009.github.io/Kid-matix/store/privacy-policy-en.html
>
> Happy to provide any further detail you need.

## Notes for the owner

- The last paragraph ("One technical note") discloses the GameKit linkage.
  It is honest and pre-empts a binary-scan question, but it is the only
  part that is not a plain "no". Keep it: a reviewer who sees GameKit in an
  unexplained Kids app binary is likelier to reject than one who was told.
- The claim "restricted to Android in our code" is true as of this commit:
  `_signInToGameServices()` in `lib/main.dart` returns at once unless
  `defaultTargetPlatform` is Android. The plugin stays in the iOS binary
  (it is one cross-platform package), so the reply says the call never
  runs, not that the framework is gone. Ship this guard in the next build;
  the reply can be sent before it.
- The App Privacy answers already filed ("No data collected") stay correct;
  no change is needed there.
