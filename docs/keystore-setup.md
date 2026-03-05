# Release Keystore Setup

## Prerequisites
- Java 17 installed (`java -version` should show 17.x)

## Step 1: Generate the upload keystore

Run this command **outside the repo** (never commit the .jks file):

```bash
keytool -genkey -v \
  -keystore ~/.android/upload-keystore.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

You will be prompted for:
- Store password (remember this)
- Key password (can be same as store password)
- Your name, organization, city, state, country

## Step 2: Create android/key.properties

Create `android/key.properties` (this file is gitignored — never commit it):

```
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=/home/<your-username>/.android/upload-keystore.jks
```

On macOS/Linux the path is typically: `~/.android/upload-keystore.jks`
On Windows: `C:\\Users\\<username>\\.android\\upload-keystore.jks`

## Step 3: Verify signing config in build.gradle.kts

The file `android/app/build.gradle.kts` already reads from `key.properties`.
Open it and confirm the `signingConfigs.release` block references `../key.properties`.

## Step 4: Build signed release AAB

```bash
flutter build appbundle --flavor prod --release --dart-define=APP_ENV=prod
```

## IMPORTANT: Backup
- Store the `.jks` file and both passwords in a secure password manager
- Google Play uses this key permanently — losing it means you cannot update your app
- Consider enrolling in Google Play App Signing for additional security

## References
- [Flutter deployment docs](https://docs.flutter.dev/deployment/android#create-an-upload-keystore)
- [Google Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756)