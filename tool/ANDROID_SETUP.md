# Android build setup

Everything below is already installed on this Mac. This file records what was
done so it can be reproduced on another machine, and documents the one step
that is deliberately left to you: production signing.

## What was installed

| Component | Version | Location |
|---|---|---|
| JDK | OpenJDK 17.0.20 | `/opt/homebrew/opt/openjdk@17` |
| Android cmdline-tools | build 15641748 | `~/Library/Android/sdk/cmdline-tools/latest` |
| Platform | android-36 | `~/Library/Android/sdk/platforms` |
| Build tools | 36.0.0 | `~/Library/Android/sdk/build-tools` |
| Platform tools | r37 | `~/Library/Android/sdk/platform-tools` |

JDK 17 specifically, because the project is on Gradle 8.12 / AGP 8.9.1.
The Homebrew *formula* (`openjdk@17`) was used rather than the cask, because
the cask needs `sudo` to write into `/Library/Java/JavaVirtualMachines`.

Flutter was pointed at both:

```bash
flutter config --android-sdk "$HOME/Library/Android/sdk"
flutter config --jdk-dir /opt/homebrew/opt/openjdk@17
```

These are stored in Flutter's own config, so **you do not need environment
variables set** for `flutter build apk` to work. They are only needed if you
invoke `sdkmanager`/`adb`/`gradle` directly:

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
```

To make that permanent, append those three lines to `~/.zshrc`.

## Reproducing on a fresh machine

```bash
brew install openjdk@17

SDK="$HOME/Library/Android/sdk"
mkdir -p "$SDK/cmdline-tools"
curl -Lo /tmp/clt.zip \
  https://dl.google.com/android/repository/commandlinetools-mac-15641748_latest.zip
unzip -q /tmp/clt.zip -d /tmp/clt && mv /tmp/clt/cmdline-tools "$SDK/cmdline-tools/latest"

export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export ANDROID_HOME="$SDK"
export PATH="$JAVA_HOME/bin:$SDK/cmdline-tools/latest/bin:$PATH"

yes | sdkmanager --licenses
sdkmanager --install "platform-tools" "platforms;android-36" "build-tools;36.0.0"

flutter config --android-sdk "$SDK"
flutter config --jdk-dir "$JAVA_HOME"
flutter doctor -v      # Android toolchain should be [✓]
```

## Building

```bash
flutter build apk --release --no-tree-shake-icons        # single APK
flutter build appbundle --release --no-tree-shake-icons  # Play Store AAB
```

Outputs land in `build/app/outputs/`.

`--no-tree-shake-icons` is required because the app builds `IconData` values
dynamically, which defeats the tree shaker's static analysis.

## Signing — the part left to you

`android/app/build.gradle` falls back to the **debug** signing key when
`android/key.properties` is absent. That produces a perfectly installable APK
for demos and sideloading, which is what the current build is.

Google Play will **not** accept a debug-signed artifact. When you are ready:

```bash
keytool -genkey -v \
  -keystore ~/hertwin-upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

It will ask for a password twice and some identity details. Then create
`android/key.properties`:

```properties
storePassword=<the password you chose>
keyPassword=<the password you chose>
keyAlias=upload
storeFile=/Users/<you>/hertwin-upload-keystore.jks
```

Rebuild and the release signing config activates automatically.

### Guard this file with your life

- `key.properties`, `*.jks` and `*.keystore` are all gitignored. Keep it that
  way — anyone with your upload key can publish an update impersonating you.
- **Back the keystore up somewhere you will still have in five years.** If you
  lose it you cannot update your own app; you would have to publish under a
  new package name and every existing user would have to reinstall.
- Do not paste the passwords into chat, tickets, or this repo.
- Enrolling in Play App Signing (Google holds the app signing key, you hold
  only the upload key) makes a lost upload key recoverable. Recommended.

## CI alternative

`.github/workflows/build-apk.yml` builds both APK and AAB on GitHub's runners,
so a teammate without a local Android SDK can still produce artifacts. Signing
material comes from repo secrets (`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`,
`KEY_ALIAS`, `KEY_PASSWORD`) and the workflow deletes it from the runner
afterwards. Without those secrets it falls back to debug signing.
