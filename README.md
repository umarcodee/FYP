# Driver Monitoring and Assistance App

AI-powered Flutter app for **driver drowsiness monitoring** and **accident-triggered SOS assistance** using on-device ML (Google ML Kit) and phone sensors.

---

## Features

- **Drowsiness detection (on-device):** eye-closure + head-down detection using Google ML Kit Face Detection.
- **Yawn detection:** additional fatigue signal.
- **Alerts:** looping alarm sound + text-to-speech guidance.
- **Accident detection:** detects high **G-force** events (sudden impact) and triggers an SOS flow.
- **Analytics:** logs detection events locally and shows stats.
- **Settings:** control sound/vibration toggles and detection sensitivity.
- **Nearby rest areas:** quick navigation to a map screen to find nearby rest places.

---

## SOS / Emergency (Accident) Information

The app includes an **SOS flow** that is automatically triggered when an accident is detected via phone sensors (G-force monitoring).

### What happens when an accident is detected?

- The UI shows **“ACCIDENT DETECTED”** and switches to an emergency alert state.
- The app plays the alert sound in a loop.
- The in-app voice assistant speaks: **“Accident detected, Initializing SOS”**.
- An **`accident`** event is stored in the local database for analytics/history.

### Important notes

- **This is an assistance feature, not a replacement for emergency services.**
- Actual calling/SMS/location sharing behavior depends on your implementation and device permissions. If you add SMS/calling/location later, document the exact behavior here.

---

## Project Structure (lib/)

Based on the current repository structure:

```
lib/
  Constants/
    app_config.dart
  models/
    detection_models.dart
    detection_models.g.dart
  services/
    accident_detector.dart
    database_service.dart
    tts_service.dart
    yawn_detector.dart
  Screens/
    analytics_screen.dart
    drowsiness_screen.dart
    home_screen.dart
    map_screen.dart
    splashscreen.dart
  main.dart
```

---

## Tech Stack

- **Flutter / Dart**
- **ML:** `google_mlkit_face_detection`
- **Camera:** `camera`
- **Audio:** `audioplayers`
- **Permissions:** `permission_handler`
- **Local storage:** Hive (via `DatabaseService`)
- **Text to Speech:** (via `TtsService`)

---

## How it works (high level)

### Drowsiness detection

- The front camera streams frames.
- ML Kit Face Detection provides:
  - `leftEyeOpenProbability` / `rightEyeOpenProbability`
  - `headEulerAngleX` (head pose)
- The app enters a drowsy state if:
  - both eyes are below the configured threshold for a number of frames, **or**
  - head-down angle crosses the configured threshold.

### Event logging

The app stores events like:

- `drowsy`
- `yawn`
- `accident`

in the local database.

---

## Setup

### Prerequisites

- Flutter SDK installed
- A **physical device** is recommended (camera + sensors required)

### Install & Run

```sh
git clone https://github.com/umarcodee/FYP.git
cd FYP
flutter pub get
flutter run
```

---

## Permissions

The app may request (depending on your platform setup):

- Camera
- Microphone (only if enabled later)
- Location (if your map screen uses live location)

Make sure Android/iOS permission strings are configured properly.

---

## Support

For support and questions: **Muhammad Umar — 03072500966**

---

## Disclaimer

This app is designed to assist drivers but **must not** replace alertness and responsible driving. If you are in an emergency, contact local emergency services immediately.
