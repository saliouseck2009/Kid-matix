# Performance of version 1.0 on an entry-level phone

Measured on 2026-10-11 on a Samsung Galaxy A16 (SM-A166P, Android 16,
90 Hz screen), release build (`flutter build apk --release`), with the
phone unlocked and plugged in. Targets of F11-02: start in under
2 seconds, 60 frames per second during a quiz.

## Cold start

Method: `am force-stop`, then `am start`, five times in a row.

| Measure | Result |
| --- | --- |
| Window first shown, reported by Android (`wm_activity_launch_time`) | 0.8 to 1.2 s |
| Map of the learning path on screen, found by polling screenshots | 1.8 to 2.3 s |
| First start after the install (Android optimizes the app) | 4.5 s |

The screenshot polling has a resolution of about 0.4 s, so the real
time to the map is a little under the figures. The start is at the
target, with no margin: the splash screen shows the mascot meanwhile.

## Frames during a quiz

Method: the Discovery stage of the table of 1 played to the end (10
questions, the 2 badge celebrations and the results), frame statistics
of the app surface taken from the compositor
(`dumpsys SurfaceFlinger --timestats`).

| Measure | Result |
| --- | --- |
| Frames presented | 7 646 |
| Frames dropped by the compositor | 0 |
| Interval between frames at 10 or 11 ms (90 Hz cadence) | 99.0 % |
| Intervals of 22 to 114 ms (a missed frame, mostly at screen changes) | 22 frames, 0.3 % |
| Intervals of about 100 ms or 1 s | idle: the quiz redraws only on its 100 ms tick, or waits for a tap |

The quiz runs at the 90 Hz of the screen; the few missed frames are at
the opening of a celebration or of the results.

## Automated frame test

`integration_test/quiz_perf_test.dart` plays a stage and records the
timeline of its frames into `build/quiz_perf.timeline_summary.json`:

```bash
flutter drive --profile --no-dds --driver=test_driver/perf_driver.dart \
  --target=integration_test/quiz_perf_test.dart -d <device>
```

It cannot run on the Galaxy A16: the Flutter tool never connects to the
VM service on that phone (Android 16). On the Android emulator (API 36)
it gives, over 219 frames, a build time of 0.8 ms on average and 5.9 ms
at worst, and a raster time of 4.8 ms on average; the emulator renders
without a real GPU, so its raster figures do not reflect a phone.

## Known startup cost

The cold start is close to the 2 s target. If it has to go down later:
the database opens and the three hooks register at startup, and the
first screen waits for the profile session to restore.
