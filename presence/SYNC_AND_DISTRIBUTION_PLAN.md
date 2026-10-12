# Roadmap: Data Sync, Distribution & Updates

This document outlines the step-by-step process to implement cloud synchronization, distribute the app without the Play Store, and handle updates safely.

---

## Phase 1: Data Synchronization (Cloud Sync)

To allow users to sync data across devices, we will use **Firebase**.

### 1.1 Firebase Setup
- [ ] Create a project in the [Firebase Console](https://console.firebase.google.com/).
- [ ] Add an Android App to the project using your ID: `com.example.presence`.
- [ ] Download `google-services.json` and place it in `android/app/`.
- [ ] Configure the Firebase SDK in `android/build.gradle.kts` and `android/app/build.gradle.kts`.

### 1.2 Authentication (Accounts)
- [ ] Add `firebase_auth` dependency.
- [ ] Enable "Email/Password" sign-in in Firebase Console.
- [ ] Create a `LoginScreen` and `SignUpScreen`.
- [ ] Update `main.dart` to check if a user is logged in before showing the home screen.

### 1.3 Cloud Firestore (The "Source of Truth")
- [ ] Add `cloud_firestore` dependency.
- [ ] Define Firestore collections (e.g., `users/{uid}/groups`, `users/{uid}/adolescents`).
- [ ] **Sync Strategy:**
    - When data is saved locally in `sqflite`, also send a copy to Firestore.
    - When the app starts, check Firestore for changes and update the local database.

---

## Phase 2: App Distribution (Outside Play Store)

Since the Play Store is not an option yet, we will use **GitHub Releases** or **Direct APK Hosting**.

### 2.1 Prepare for Release
- [ ] **Crucial:** Generate a **Release Signing Key** (Keystore).
    - *Why?* If you change this key later, users will have to uninstall/reinstall and will lose their data.
- [ ] Configure `signingConfigs` in `android/app/build.gradle.kts` to use your new key.

### 2.2 Build the APK
- [ ] Run: `flutter build apk --release`.
- [ ] The APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

### 2.3 Hosting
- [ ] Create a GitHub repository for your project.
- [ ] Use the "Releases" feature to upload your `app-release.apk`.
- [ ] Share the direct download link with your users.

---

## Phase 3: Update Mechanism (Preserving Data)

Android handles updates automatically if the **Package Name** and **Signing Key** stay the same.

### 3.1 Versioning
- [ ] Increment `version` in `pubspec.yaml` for every update (e.g., `1.0.0+1` -> `1.0.1+2`).

### 3.2 In-App Update Notification
- [ ] Create a tiny file called `version.json` hosted on a server (or GitHub).
    ```json
    { "latest_version": "1.0.1", "download_url": "..." }
    ```
- [ ] In the app, add a check at startup:
    ```dart
    if (localVersion != remoteVersion) {
       showUpdateDialog();
    }
    ```
- [ ] When the user clicks "Update", they download the new APK. When they install it, Android **overwrites** the app but **keeps the SQLite database files intact**.

---

## Summary Checklist for YOU:

1. [ ] **Do not change** `applicationId = "com.example.presence"`.
2. [ ] **Create a Keystore** and keep it very safe (Back it up!).
3. [ ] **Set up Firebase** for the "Account" logic.
