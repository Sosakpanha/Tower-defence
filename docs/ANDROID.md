# Building and running on Android

Status on the dev machine when this was written: Godot 4.7.2 editor installed, but
**no export templates, no JDK, no Android SDK** (the editor settings already point at
`~/Library/Android/sdk` and a debug keystore path, but neither exists yet).
`export_presets.cfg` (preset "Android", package `com.sosakpanha.kingdomdefence`,
arm64-v8a only, landscape set in `project.godot`, no Gradle build) is committed.

## One-time setup (macOS)

1. **Export templates.** Godot editor: Editor > Manage Export Templates > Download and Install
   (must match the editor version, e.g. 4.7.2). They land in
   `~/Library/Application Support/Godot/export_templates/<version>/`.
2. **JDK 17.** `brew install --cask temurin@17`, then check `/usr/libexec/java_home -V`.
3. **Android SDK.** Easiest: install Android Studio, open SDK Manager and install
   *Android SDK Platform 35*, *Platform-Tools*, *Build-Tools 35.0.1*, *Command-line Tools (latest)*,
   *CMake 3.10.2* and *NDK r28b* (versions per the Godot docs for your editor version).
   SDK path is normally `~/Library/Android/sdk`.
4. **Debug keystore** (Godot expects the path in its editor settings):
   ```
   mkdir -p "$HOME/Library/Application Support/Godot/keystores"
   keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore \
     "$HOME/Library/Application Support/Godot/keystores/debug.keystore" -storepass android \
     -dname "CN=Android Debug,O=Android,C=US" -validity 9999 -deststoretype pkcs12
   ```
5. **Editor Settings** (Editor > Editor Settings > Export > Android): set *Java SDK Path*
   (output of `/usr/libexec/java_home -v 17`), *Android SDK Path*, *Debug Keystore* =
   the file above, user `androiddebugkey`, password `android`.

## Phone setup

Settings > About phone > tap *Build number* 7 times; then Developer options > enable
*USB debugging*. Plug in via USB and accept the RSA prompt. `~/Library/Android/sdk/platform-tools/adb devices`
should list it.

## Build

Command line (from the project root):
```
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-debug Android build/game.apk
~/Library/Android/sdk/platform-tools/adb install -r build/game.apk
```
Or in the editor: Project > Export > Android > *Export Project*, or the Android
"one-click deploy" button (top right) with the phone connected.

## Release build (Play Store later)

Create a release keystore with `keytool -genkeypair -v -keystore release.keystore -alias key -keyalg RSA -validity 10000`,
fill *Keystore > Release / User / Password* in the preset (keep secrets out of git; use the
`GODOT_ANDROID_KEYSTORE_RELEASE_*` env vars), turn on *Gradle Build* + `.aab` format, and export release.

## Things to check on the phone

- Landscape lock and immersive mode; the game keeps 16:9 and letterboxes other aspects.
  Notch/cutout: bars from letterboxing usually cover it; if a corner button is clipped, tell us.
- Building is tap-to-preview, tap-again-to-build. Tap a tower to upgrade/sell, tap outside the grid to deselect.
- Pressing Home or switching apps pauses the game.
- Rendering uses `gl_compatibility` (works on all phones).

## Automated test of touch logic (desktop)

`Godot --path . --script tools/touch_test.gd` sends synthetic touch events and prints PASS/FAIL lines.
