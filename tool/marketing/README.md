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
   notification. The status bar is restored at the end.
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
| `--start S` | Start of the clip in the recording, in seconds (default 0) |
| `--duration S` | Length of the clip, end card excluded (default: all) |
| `--caption "FROM-TO\|TEXT"` | Text from `FROM` to `TO` seconds of the clip. `*word*` is yellow, `\n` starts a second line. Repeatable |
| `--caption-y PX` | Top of the banner (default 150, below the TikTok header) |
| `--fit pad\|crop` | `pad` (default) keeps the whole screen with violet side bars; `crop` fills the frame and cuts the top and bottom |
| `--no-end-card` | Leaves the end card out |

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
other formats and shifts the moments. Read them from a contact sheet:

```bash
ffmpeg -i <raw>.mp4 -vf "fps=1,scale=150:-1,drawtext=text='%{pts\:hms}':fontsize=24:fontcolor=white:box=1:boxcolor=black,tile=10x4" -frames:v 1 sheet.png
```

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
