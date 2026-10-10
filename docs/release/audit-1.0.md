# Release audit — version 1.0

Task F11-08: version 1.0 makes no network call, embeds no SDK that talks to
a server, and installs in less than 40 MB.

- Date: 2026-10-10, on `main` at `9a3e5ae` (lot F10 merged: settings,
  sounds and vibrations).
- Tools: Flutter 3.47.6, Dart 3.13.5, Android build-tools 36.1.0, macOS.
- Builds: `flutter build apk --release --split-per-abi` and
  `flutter build appbundle --release`. Nothing was installed on a device.

## Verdict

| Check | Result |
| --- | --- |
| No network call in the app code | OK |
| No SDK that talks to a server (analytics, ads, crash reporting, cloud) | OK |
| No `INTERNET` permission in the release Android build | OK, nothing to fix |
| Installed APK under 40 MB | OK: 17.1 to 21.1 MB per ABI |
| Ready for store upload | Not yet: see "To fix before publication" |

## App code

- No `http`, `HttpClient`, `Socket`, `WebSocket`, `dart:io` or URL launcher
  anywhere in `lib/`. The only `Uri` calls are `Uri.encodeComponent` in
  `core/router/` to build in-app routes.
- Sounds: `AudioSoundPlayer` (`features/setting/data/datasources/`) plays
  only `AssetSource` files bundled in `assets/sounds/` (`right.wav`,
  `wrong.wav`, `celebration.wav`, 64 KB in all). No `UrlSource`.
- Vibrations: `HapticVibrator` uses Flutter's `HapticFeedback`
  (`lightImpact`, `mediumImpact`), which goes through the view's haptic
  feedback and needs no `VIBRATE` permission.
- Crash reporting: `LogCrashReporter` writes to the local log only.
- Fonts (Fredoka, Nunito) are bundled in `assets/fonts/`; no font is
  downloaded at runtime.

## Packages

Only the `dependencies` of `pubspec.yaml` and their transitive packages reach
the app; `dev_dependencies` (`flutter_test`, `flutter_lints`, `build_runner`,
`json_serializable`, `bloc_test`, `mocktail`, `sqflite_common_ffi`) are never
compiled into a release build.

### Direct

| Package | Version | What it does in the app | Network |
| --- | --- | --- | --- |
| `flutter`, `flutter_localizations` | SDK | Framework, French texts and formats | No |
| `flutter_bloc` | 9.1.1 | State management (with `bloc`, `provider`, `nested`) | No |
| `get_it` | 9.3.0 | Dependency injection | No |
| `go_router` | 18.0.2 | Navigation (with `logging`, `cupertino_ui`, `material_ui`) | No |
| `intl` | 0.20.3 | Date and number formats | No |
| `json_annotation` | 4.12.0 | Annotations of the local models | No |
| `meta` | 1.19.0 | Annotations | No |
| `path` | 1.9.1 | Database file path | No |
| `shared_preferences` | 2.5.6 | Device preferences (last player, last training) | No |
| `sqflite` | 2.4.4+1 | Local SQLite database | No |
| `uuid` | 4.6.0 | Ids generated on the phone (with `crypto`, `fixnum`) | No |
| `audioplayers` | 6.8.1 | Plays the bundled sounds | See below |

### Transitive, worth a note

| Package | Pulled by | Why it is harmless |
| --- | --- | --- |
| `http` 1.6.0 (+ `http_parser`, `web`) | `audioplayers` | Imported only by `AudioCache.fetchToMemory`, which `audioplayers` calls on the web platform only (`kIsWeb`). On Android and iOS the bundled asset is copied to a temporary file and played locally. The app never builds a `UrlSource` |
| `path_provider` 2.1.6 and its platform packages | `audioplayers` | Finds the temporary folder where `AudioCache` copies an asset |
| `jni` 1.1.0, `jni_flutter` 1.0.4+1 | `path_provider_android` | Calls the Android API from Dart; local only |
| `objective_c` 9.6.2 | `path_provider_foundation` | Calls the iOS API from Dart; local only |
| `hooks`, `code_assets`, `record_use`, `pub_semver` | `objective_c` | Build-time hooks for native assets; nothing at runtime |
| `file`, `synchronized`, `platform`, `plugin_platform_interface`, `async`, `collection`, `clock`, `characters`, `typed_data`, `source_span`, `string_scanner`, `term_glyph`, `args`, `package_config`, `ffi`, `vector_math`, `material_color_utilities`, `xdg_directories` | various | Pure helpers; no I/O to a server |

The Linux, Windows and web plugin packages (`*_linux`, `*_windows`,
`*_web`) are in the lock file but are not compiled into the Android or iOS
app.

No Firebase, Google Play Services, analytics, advertising, attribution,
crash-reporting or remote-config package is present, directly or
transitively.

## Android

### Manifests

| Manifest | `INTERNET` |
| --- | --- |
| `android/app/src/main/AndroidManifest.xml` (release) | Absent |
| `android/app/src/debug/AndroidManifest.xml` | Present, for hot reload and the debugger (Flutter default) |
| `android/app/src/profile/AndroidManifest.xml` | Present, for DevTools (Flutter default) |

The main manifest needs no change.

### Merged release manifest

Read from `build/app/intermediates/merged_manifests/release/` and checked on
the built APK with `aapt2 dump permissions`:

- The only permission is `<applicationId>.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`,
  a `signature`-level permission that AndroidX adds to every app targeting
  API 33 and more; it protects the app's own receivers and is not shown to
  the user.
- No plugin (`audioplayers_android`, `sqflite_android`,
  `shared_preferences_android`, `jni`, `jni_flutter`) adds a permission.
- `androidx.profileinstaller.ProfileInstallReceiver` is protected by
  `android.permission.DUMP` (system only).
- `<queries>` for `PROCESS_TEXT` is the Flutter default (text selection
  menu); it does not open anything by itself.
- `minSdkVersion` 24, `targetSdkVersion` 36.

### Sizes

| Output | Size |
| --- | --- |
| `app-armeabi-v7a-release.apk` | 17.1 MB |
| `app-arm64-v8a-release.apk` | 19.6 MB |
| `app-x86_64-release.apk` | 21.1 MB |
| `app-release.aab` | 54.0 MB |

- Every installed APK is about half the 40 MB target. In the arm64 APK,
  `libflutter.so` (engine) is 11.7 MB, `libapp.so` (Dart code) 6.6 MB, the
  Java code 0.9 MB, the fonts and sounds under 0.5 MB.
- Native libraries are stored uncompressed (`extractNativeLibs="false"`), so
  the space taken on the phone is close to the APK size, plus the player
  data.
- The bundle is larger because it carries the three ABIs and their native
  debug symbols (`BUNDLE-METADATA/.../debugsymbols`, about 22 MB
  compressed); Google Play keeps the symbols for crash reports and sends
  each phone only its own ABI, so a phone downloads about the size of one
  split APK.
- R8 shrinking runs on the release build (`build/app/outputs/mapping/`).
- The material icon font is tree-shaken from 1.6 MB to 5 KB. The build
  warns that `CupertinoIcons` is referenced without `cupertino_icons`;
  harmless (no Cupertino icon is drawn), but worth a look when the icon is
  done in F11-07.

## iOS

`ios/Runner/Info.plist`:

- No `NSAppTransportSecurity` exception, no usage description (camera,
  microphone, photos, location, tracking): the app asks for no permission.
- No background mode; `audioplayers` uses the `playback` audio session
  for short sounds only.
- `CFBundleDisplayName` is "Kid Matix".
- The plugins that touch "required reason" APIs ship their own privacy
  manifest: `shared_preferences_foundation` and `sqflite_darwin` carry a
  `PrivacyInfo.xcprivacy`. The app has none of its own.

The iOS build was not run in this audit (no signing); its size is to measure
with F11-11.

## To fix before publication

Not changed in this audit, since they touch files outside its scope or need
the owner's decision.

1. **Release signing (F11-11).** `android/app/build.gradle.kts` signs the
   release build with the debug key (`signingConfigs.getByName("debug")`).
   The APKs and bundle above cannot be uploaded to Google Play. Add an
   upload key read from a `key.properties` file kept out of git.
2. **Application id (F11-07 / F11-11).** `applicationId` and `namespace`
   are `sn.ckroot.kid_matix.kid_matix` (the Flutter default doubled, with
   its `TODO`). It cannot change after the first upload: choose it with the
   final name. Same for the iOS bundle identifier.
3. **System backup.** `android:allowBackup` is not set, so Android Auto
   Backup copies the database and preferences to the user's Google Drive
   account; on iOS the database in `Documents` goes into the iCloud backup.
   The specifications (section 16) say the phone's system backup is not
   used, and the privacy policy draft says no data leaves the phone.
   Either set `android:allowBackup="false"` (and exclude the files from
   iCloud backup), or keep the backup and say so in the privacy policy and
   the store forms. Owner's decision.
4. **Portrait only.** `AndroidManifest.xml` has no `screenOrientation` and
   `Info.plist` allows the landscape orientations; the app locks portrait at
   runtime only (`SystemChrome`). Restrict both files (already listed in
   `docs/status.md`, F1 gaps).
5. **App privacy manifest (iOS).** Add `ios/Runner/PrivacyInfo.xcprivacy`
   declaring no tracking and no collected data, so the App Store privacy
   report is complete. Optional for the app itself, recommended.
6. **Export compliance (iOS).** Add `ITSAppUsesNonExemptEncryption` = `NO`
   to `Info.plist`, so App Store Connect does not ask the question at every
   upload.
