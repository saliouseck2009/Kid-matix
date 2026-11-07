# Marketing videos

Films the real app on an emulator, then cuts the recording into a vertical
video for TikTok, Reels or Shorts. Nothing here ships: the scenarios live in
`integration_test/marketing/`, the scripts in `tool/marketing/`, and `lib/`
is untouched. The videos go to `marketing/videos/`, which git ignores.

```
integration_test/marketing/
├── first_launch_test.dart   ~10 s: a child creates the player "Awa"
├── play_stage_test.dart     ~35 s: Awa discovers the table of 5
├── boss_fight_test.dart     ~32 s: Awa defeats the boss of the table of 5
├── review_mistake_test.dart ~35 s: 7 × 8 missed, back a little later, the
│                            mastery grid of the Profile tab
├── duel_test.dart           ~16 s: "Qui joue ?" with three players, a duel
├── offline_play_test.dart   ~11 s: a stage played with the airplane mode on
├── path_scroll_test.dart    ~7 s: the map scrolls from the table of 1 to 5
├── mascot_growth_test.dart  ~33 s: level 5 reached, the mascot grows, its
│                            page with the cap on
├── full_demo_test.dart      ~50 s: first launch to the first results
└── support/
    ├── marketing_harness.dart   clean start, seed, pauses, gestures
    └── demo_player.dart         the demo player and their progress
tool/marketing/
├── record.sh    emulator or simulator + scenario -> raw recording
├── edit.sh      raw recording -> 1080x1920 MP4 with texts and end card
└── driver.dart  flutter drive entry point
```

## Make a video

```bash
# 1. Film. The raw file lands in marketing/videos/raw/.
bash tool/marketing/record.sh android first_launch

# 2. Cut, caption, add the end card.
bash tool/marketing/edit.sh \
  --input marketing/videos/raw/first_launch-android-<date>.mp4 \
  --output marketing/videos/first_launch.mp4 \
  --duration 10 \
  --caption "0-4|Crée ton *joueur*" \
  --caption "4-10|et apprends tes *tables* !"
```

Needs the Android SDK (emulator, `adb`) or Xcode, and `ffmpeg` with libass
(`brew install ffmpeg`; `edit.sh` installs it when it is missing).

## record.sh

`bash tool/marketing/record.sh <android|ios> <scenario>`

1. Uses the running emulator or simulator, or starts one (`AVD=<name>` /
   `IOS_DEVICE="<name>"` to choose it). When several run, `DEVICE=` picks
   one by its serial (`adb devices`) or its simulator UDID.
2. Locks portrait, sets the animation scales back to 1 and switches the
   status bar to demo mode: 9:41, full battery, full signal, no
   notification. The status bar is restored at the end. With
   `AIRPLANE_MODE=1` (Android only) the take runs with the airplane mode
   on and its icon in the status bar; the demo status bar hides that icon,
   so this take keeps the real one (real time and battery). The mode is
   put back as it was at the end.
3. Runs the scenario with `flutter drive`, in profile mode on Android. The
   iOS simulator cannot run a profile build, so iOS uses a debug build
   (`MODE=debug|profile` overrides the choice).
4. Records the screen with `adb shell screenrecord` or
   `xcrun simctl io recordVideo`, from the scenario's `MARKETING:START` line
   to its `MARKETING:END` line: the build and the install are never in the
   recording.

The `flutter drive` output is in `tool/logs/marketing-<scenario>.log`.

**A scenario erases every player of the device it runs on** (database and
preferences), so each take starts from the same phone. Emulator or
simulator only; never a phone a child plays on. On Android the profile
build also replaces an installed copy of the app.

`screenrecord` stops after 3 minutes: keep a scenario under that.

## edit.sh

`bash tool/marketing/edit.sh --input <raw> --output <video> [options]`

| Option | Effect |
| --- | --- |
| `--start S` | Start of the clip of `--input` in the recording, in seconds (default 0) |
| `--duration S` | Length of the clip of `--input` (default: all) |
| `--clip FILE[:START[:DURATION]]` | A clip of a recording; repeat it to chain clips, in order with the title cards. `--input` is one `--clip` |
| `--title "N\|TEXT"` | A 2-second violet card: `N` in big, then the text |
| `--caption "FROM-TO\|TEXT"` | Text from `FROM` to `TO` seconds of the clip. `*word*` is yellow, `\n` starts a second line. Repeatable |
| `--caption-y PX` | Top of the banner (default 150, below the TikTok header) |
| `--fit pad\|crop` | `pad` (default) keeps the whole screen with violet side bars; `crop` fills the frame and cuts the top and bottom |
| `--format vertical\|square` | `vertical` (default): 1080x1920. `square`: 1080x1080, the phone screen centered on the violet background under a title, the banner at the bottom (LinkedIn, X) |
| `--square-title TEXT` | Title of the square format (default "Kid Matix · les tables de multiplication en jouant") |
| `--footer TEXT` | Text on a violet pill at the bottom edge for the whole video (end card excluded), such as the app's name |
| `--max-size MB` | Re-encodes at a lower bit rate when the file is bigger; WhatsApp takes 16 MB at most |
| `--no-end-card` | Leaves the end card out |

Captions are timed on the finished video (title cards included, end card
excluded). A contact sheet with timestamps helps to place them:

```bash
ffmpeg -i <raw>.mp4 -vf "fps=1,scale=150:-1,drawtext=text='%{pts\:hms}':fontsize=24:fontcolor=white:box=1:boxcolor=black,tile=10x4" -frames:v 1 sheet.png
```

Output: 1080x1920, 30 frames per second, H.264 (`yuv420p`, `faststart`),
no audio track — the music is added in the publishing app. Texts use
`assets/fonts/Fredoka-Variable.ttf`, white on a violet `#5B3DF5` banner,
yellow `#FFC531` for the words between stars. The end card lasts 3 seconds:
the app icon, "Kid Matix", "Gratuit · sans pub · sans Internet" and
"Android et iPhone". Its texts are constants at the top of the script.

Keep a caption under about 26 characters per line: a longer one leaves the
frame. Leave the bottom 400 pixels free of anything important: TikTok
draws its own texts there.

Recent phones are taller than 9:16 (9:20 for the default emulator, about
9:19.5 for the iPhone simulators), so `pad` leaves a violet bar on each
side of their recordings. A virtual device of 1080x1920 fills the frame
exactly. Create it once, then film on it:

```bash
avdmanager create avd -n KidMatix_Marketing -d pixel_2 \
  -k "system-images;android-36;google_apis;arm64-v8a"
AVD=KidMatix_Marketing bash tool/marketing/record.sh android first_launch
```

A dedicated device also keeps the takes away from the emulator used for
development: while that one runs, start the marketing device by hand
(`emulator -avd KidMatix_Marketing -port 5556`) and pass
`DEVICE=emulator-5556`.

## The demo video, vertical and square

One take of `full_demo`, cut to keep five questions, exported twice:

```bash
AVD=KidMatix_Marketing bash tool/marketing/record.sh android full_demo
C=(--clip <full_demo>.mp4:0.5:29.5 --clip <full_demo>.mp4:36:9.3 \
   --clip <full_demo>.mp4:45.5:4.5 \
   --caption "1-6|Crée ton *joueur*" --caption "12-15|Ton *parcours*" \
   --caption "16.5-20|La table et son *astuce*" \
   --caption "21.5-26|*Touche* la bonne réponse" \
   --caption "35-38|Badge *Premier pas* !" \
   --caption "39.5-42.5|*3 étoiles* et des XP")
bash tool/marketing/edit.sh --output marketing/videos/04-demo-vertical.mp4 "${C[@]}"
bash tool/marketing/edit.sh --format square \
  --output marketing/videos/04-demo-carre.mp4 "${C[@]}"
```

A new player who skips the placement test starts with the table of 1:
that is the stage the demo plays.

## WhatsApp statuses

One sentence each, the app's name at the bottom, no end card, under 16 MB:

```bash
DART_DEFINES=MARKETING_BOSS_TABLE=7 AVD=KidMatix_Marketing \
  bash tool/marketing/record.sh android boss_fight
e() { bash tool/marketing/edit.sh --no-end-card --footer "Kid Matix" --max-size 16 "$@"; }
e --output marketing/videos/05a-combo.mp4 --clip <play_stage>.mp4:7.3:9.7 \
  --caption "0.5-9.7|Les tables, c'est un *jeu*"
e --output marketing/videos/05b-boss.mp4 --clip <boss_fight-7>.mp4:18.5:4 \
  --clip <boss_fight-7>.mp4:26:3 --caption "0.5-7|Il a battu le *boss* de la table de 7"
e --output marketing/videos/05c-mascotte.mp4 --clip <mascot_growth>.mp4:26.8:6.2 \
  --caption "0.5-6.2|Sa *mascotte* grandit avec lui"
```

`MARKETING_BOSS_TABLE` picks the table of the boss scenario; a table
further down the path than the demo player's is reached with the "Tout
débloquer" setting, written by the seed.

## Short shots without text

The screen recorder writes a frame only when the screen changes, so a
recording ends on its last change: a clip that asks for more holds its
last frame (`tpad` in `edit.sh`). The shots of 2026-11-06:

```bash
e() { bash tool/marketing/edit.sh --no-end-card "$@"; }
e --output marketing/videos/plans/03a-parcours.mp4 --clip <path_scroll>.mp4:0.7:6
e --output marketing/videos/plans/03b-quiz.mp4 --clip <play_stage>.mp4:7.3:6
e --output marketing/videos/plans/03c-mascotte.mp4 \
  --clip <mascot_growth>.mp4:27.3:2.8 --clip <mascot_growth>.mp4:31:3.2
e --output marketing/videos/plans/03d-resultats.mp4 --clip <play_stage>.mp4:28:5
```

The mascot grows with the level (`MascotRules.stageLevels`: stage 2 at
level 5); `seedMascotGrower()` puts Awa at 980 XP so one stage takes her
there, and the celebration shows on the map.

## What the scenarios guarantee

- **Demo player only.** The nickname is "Awa", the placeholder of the
  mockups. No real child, no face, no real name.
- **Same quiz on every take.** `RandomSource` is registered with a fixed
  seed (`marketingSeed` in `marketing_harness.dart`) before the app's own
  registrations, which `GetIt.skipDoubleRegistration` then ignores. Change
  the seed to film another draw.
- **Silent app.** `SoundPlayer` and `Vibrator` are replaced the same way
  by implementations that do nothing.
- **Normal animations.** Reduced motion stays off, and `record.sh` resets
  the animation scales of the emulator.
- **French.** The language preference is set to French before the app
  starts, whatever the language of the emulator.
- **Nothing leaves the emulator.** The Play Games channel is answered
  locally, so no sign-in sheet covers the take.
- **Readable pace.** About 0.8 s before each answer (`answerPause`), 0.6 s
  between other gestures (`gesturePause`).

Preloaded progress of `seedDemoPlayer()` (`demo_player.dart`), written
straight into the sqflite tables once the app has started and before the
recording does: tables 1, 2 and 10 crowned (five stages at three stars,
their facts "acquired"), 650 XP so level 4, and a streak of 6 days that
ended yesterday — today's quiz makes it 7 on screen.

## The boss video

`boss_fight` plays the rules of the app as they are: a right answer under
3 seconds is an "Éclair", a critical hit worth 2 of the 12 hit points of
the boss; a slower right answer is worth 1; a mistake makes the boss
strike back. The fight is a list of `BossMove`s (`_fight` in the
scenario), each answered on the quiz's own clock. The scenario then walks
through the badge sheets, holds the results, and goes back to the map
where the table wears its new crown. The crown is drawn at once: version
1.0.1 has no landing animation for it.

```bash
AVD=KidMatix_Marketing bash tool/marketing/record.sh android boss_fight
bash tool/marketing/edit.sh --input marketing/videos/raw/boss_fight-<date>.mp4 \
  --output marketing/videos/01-boss.mp4 --start 0.5 \
  --caption "0-2|Ton enfant peut-il battre ce *boss* ?" \
  --caption "3-5|*Coup critique* !" \
  --caption "19.5-22.5|*Boss vaincu* !"
bash tool/marketing/edit.sh --input marketing/videos/raw/boss_fight-<date>.mp4 \
  --output marketing/videos/01-boss-brut.mp4 --start 0.5 --no-end-card
```

The caption times above fit the draw of `_randomSeed`; another seed draws
other formats and shifts the moments.

## The "three things" video

Three takes, cut and chained with title cards:

```bash
AVD=KidMatix_Marketing bash tool/marketing/record.sh android review_mistake
AVD=KidMatix_Marketing bash tool/marketing/record.sh android duel
AIRPLANE_MODE=1 AVD=KidMatix_Marketing bash tool/marketing/record.sh android offline_play
bash tool/marketing/edit.sh --output marketing/videos/02-trois-choses.mp4 \
  --title "1|Les erreurs reviennent au bon moment" \
  --clip <review_mistake>.mp4:5.9:6.6 --clip <review_mistake>.mp4:30:3 \
  --title "2|Plusieurs enfants, un seul téléphone" \
  --clip <duel>.mp4:1.5:3 --clip <duel>.mp4:8.5:7.5 \
  --title "3|Ça marche sans Internet" \
  --clip <offline_play>.mp4:1.5:9 \
  --caption "3-6|Une *erreur* ? Elle *revient* un peu plus tard" \
  --caption "26.8-29.8|Mode avion : tout marche *sans Internet*"
```

The clip times fit the takes of 2026-11-06; read new ones from a contact
sheet. In `review_mistake`, 7 × 8 is missed when it comes as a question of
its own (`_randomSeed` picks such a draw); the app brings a missed fact
back two questions later (`SubmitAnswerUseCase.retryDelay`).

Known limits:

- The taps are sent inside Flutter, so the recording shows the buttons
  being pressed but no finger or touch mark.
- Letters are sent straight to the text field: the system keyboard, which
  would cover half of the screen, never opens.
- After the reward sheets of the results, the test pointer events no
  longer reach the widgets (the navigator keeps absorbing them,
  flutter/flutter#4770), so the scenarios press those buttons from code
  (`pressButton`, `pressIconButton`): the recording shows no press
  animation on them.
- On a 9:16 device the banner covers the top of the app. Keep the texts
  for the moments when the header does not matter, or move the banner
  with `--caption-y`.

## Add a scenario

1. Copy `play_stage_test.dart` to
   `integration_test/marketing/<name>_test.dart`.
2. Start with `startApp(tester)` or `startApp(tester, seed: seedDemoPlayer)`,
   drive the app with `tapText`, `tapWhenShown`, `typeSlowly`, `playQuiz`
   and `pause`, and finish with `endScenario(tester)`.
3. `bash tool/marketing/record.sh android <name>`.

A scenario follows the texts of the screens in French; when a label
changes in `lib/l10n/app_fr.arb`, update the scenario.
