# Signing and sending the builds to the stores

The project is ready to sign; the keys and the store accounts belong to
the owner and never enter the repository.

## Android (Google Play)

1. Create the upload key once, and keep it with its passwords somewhere
   safe (a password manager); losing it means asking Google to reset it:

   ```bash
   keytool -genkey -v -keystore ~/kid-matix-upload.jks -keyalg RSA \
     -keysize 2048 -validity 10000 -alias upload
   ```

2. Create `android/key.properties` (ignored by git):

   ```properties
   storePassword=<password of the keystore>
   keyPassword=<password of the key>
   keyAlias=upload
   storeFile=/Users/<you>/kid-matix-upload.jks
   ```

3. Build the bundle: `bash tool/build_release.sh android`. Without
   `key.properties` the script stops; `android/app/build.gradle.kts`
   falls back to the debug key only for local and CI release builds.
4. In the Play Console: create the app "Kid Matix", turn on Play App
   Signing, upload `build/app/outputs/bundle/release/app-release.aab` to
   the internal testing track, add the testers' emails, fill the target
   audience and content forms (drafts in `docs/store/`).

## iOS (App Store)

1. In Xcode, open `ios/Runner.xcworkspace`, target Runner, "Signing &
   Capabilities": choose the Apple developer team; keep automatic signing.
2. Build: `bash tool/build_release.sh ios`.
3. Upload `build/ios/ipa/*.ipa` with the Transporter app (or
   `xcrun altool`), then add it to TestFlight internal testing in App
   Store Connect, with the Kids category forms (drafts in `docs/store/`).

## Obfuscation and symbols

Both builds are obfuscated (`--obfuscate`); the symbols needed to read a
crash trace are written to `build/symbols/`. Keep a copy of that folder
for every version sent to the stores.

## Identifiers to confirm before the first upload

They cannot change once an app is published:

- Android application id: `sn.ckroot.kid_matix.kid_matix`
- iOS bundle id: `sn.ckroot.kidmatix.kidMatix`
