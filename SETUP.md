# Setup Guide

## 1. Create the Flutter project scaffold

Run once in this folder (fills in android/, ios/, etc.):

```bash
flutter create . --project-name contact_networking_pro --org com.antigravity
```

## 2. Patch Android permissions

In `android/app/src/main/AndroidManifest.xml`, add inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_CONTACTS"/>
<uses-permission android:name="android.permission.WRITE_CONTACTS"/>

<queries>
    <package android:name="com.linkedin.android"/>
    <package android:name="com.whatsapp"/>
</queries>
```

Also set `minSdkVersion 21` in `android/app/build.gradle`:

```gradle
defaultConfig {
    minSdkVersion 21
    targetSdkVersion 34
    ...
}
```

## 3. Patch iOS permissions

In `ios/Runner/Info.plist`, add inside the root `<dict>`:

```xml
<key>NSCameraUsageDescription</key>
<string>Used to scan business cards and QR codes.</string>
<key>NSContactsUsageDescription</key>
<string>Used to save scanned contacts to your address book.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to pick images containing QR codes.</string>
```

## 4. Run locally

```bash
flutter pub get
flutter run
```

## 5. Build & release

Push a tag to trigger GitHub Actions:

```bash
git tag v1.0.0
git push origin v1.0.0
```

This produces:
- **Android**: `app-release.apk` — install directly
- **iOS**: `ContactNetworkingPro.ipa` — sideload with [AltStore](https://altstore.io) or [Sideloadly](https://sideloadly.io) using a free Apple ID

> iOS sideloaded apps expire after **7 days** and need re-signing.
> AltStore auto-refreshes when connected to the same Wi-Fi as AltServer.
