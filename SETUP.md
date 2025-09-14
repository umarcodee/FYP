# FYP Project Setup Guide

## 🚀 Complete Setup Instructions

This guide will help you set up the Driver Monitoring and Assistance App project from scratch.

### Prerequisites

- **Flutter SDK**: 3.16.0 or higher
- **Dart**: 3.0.0 or higher
- **Android Studio** or **VS Code** with Flutter plugins
- **Physical device** (camera required for ML detection)
- **Google Cloud Console account** (for Maps API)

### Step-by-Step Setup

#### 1. Clone and Install Dependencies

```bash
git clone https://github.com/umarvibe/FYP.git
cd FYP
flutter pub get
```

#### 2. Configure Google Maps API

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the following APIs:
   - Google Maps SDK for Android
   - Google Maps SDK for iOS
   - Places API
   - Geocoding API
4. Create API credentials (API Key)
5. Restrict the API key to your app (optional but recommended)

#### 3. Add API Keys

**Android Configuration:**
- Open `android/app/src/main/AndroidManifest.xml`
- Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key

**iOS Configuration:**
- Add API key to `ios/Runner/AppDelegate.swift` if needed

**App Constants:**
- Open `lib/core/constants/app_constants.dart`
- Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key

#### 4. Add Required Assets

**Font Files:**
1. Download Orbitron font from [Google Fonts](https://fonts.google.com/specimen/Orbitron)
2. Replace placeholders in `assets/fonts/` with actual font files:
   - `Orbitron-Regular.ttf`
   - `Orbitron-Bold.ttf`

**Sound Files:**
1. Add alert sound files to `assets/sounds/`:
   - `alert_beep.mp3` (drowsiness alert sound)
   - `emergency_alert.mp3` (emergency alert sound)

#### 5. Generate Type Adapters (if needed)

If you make changes to the Hive models, regenerate adapters:

```bash
flutter packages pub run build_runner build
```

Note: The project includes manually created adapter files that work with the current models.

#### 6. Platform-Specific Setup

**Android:**
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34
- All required permissions are already configured in AndroidManifest.xml

**iOS:**
- Minimum iOS: 11.0
- All required permissions are configured in Info.plist
- Background modes enabled for continuous monitoring

#### 7. Run the App

```bash
# For development
flutter run

# For release build
flutter build apk
# or
flutter build ios
```

### 🔧 Configuration Options

#### ML Kit Detection Parameters

Adjust detection sensitivity in `lib/core/constants/app_constants.dart`:

```dart
static const double eyeClosureThreshold = 0.4;  // Lower = more sensitive
static const double yawnDetectionThreshold = 0.6;
static const int drowsinessDetectionFrames = 5;
```

#### Database Configuration

The app uses Hive for local storage. All configuration is handled automatically, but you can:
- Clear data: Delete app data or use in-app reset
- Backup: Use export functionality in settings
- Storage location: Handled by Hive automatically

### 🧪 Testing

#### Manual Testing Scenarios

1. **Detection Accuracy**: Test with various lighting conditions
2. **Emergency Response**: Verify SMS and location sharing work
3. **Performance**: Monitor battery usage during detection
4. **UI Responsiveness**: Test on different screen sizes

#### Common Issues

**Camera not working:**
- Ensure physical device (not emulator)
- Check camera permissions
- Verify front camera exists

**ML Kit errors:**
- Update Google Play Services on Android
- Check internet connection for initial model download
- Verify device compatibility

**Location services:**
- Enable location permissions
- Check GPS is enabled
- Verify Google Maps API key is valid

**SMS not sending:**
- Check SMS permissions
- Verify phone numbers are formatted correctly
- Test with actual phone numbers

### 📱 Project Structure

The project follows clean architecture with these main directories:

```
lib/
├── app/                     # App configuration and routing
├── core/                    # Core utilities and constants
│   ├── constants/           # App constants and enums
│   ├── theme/              # UI theme and styling
│   ├── utils/              # Utility functions
│   └── services/           # Core services
├── data/                   # Data layer
│   ├── models/             # Data models (Hive entities)
│   ├── repositories/       # Data repositories
│   └── database/           # Database configurations
├── presentation/           # UI layer
│   ├── screens/            # App screens
│   ├── widgets/            # Reusable UI components
│   └── providers/          # State management (Provider)
└── services/               # External service integrations
    ├── ml_service/         # ML Kit integration
    ├── location_service/   # GPS and mapping
    ├── sms_service/        # SMS functionality
    └── notification_service/ # Push notifications
```

### 🛡️ Security Notes

- **API Keys**: Keep your Google Maps API key secure
- **Permissions**: App requests minimal required permissions
- **Data Privacy**: All data stored locally, no cloud transmission
- **Emergency Contacts**: Managed locally and securely

### 🚧 Known Limitations

1. **ML Kit Dependency**: Requires Google Play Services on Android
2. **Camera Requirement**: Physical device needed for testing
3. **Battery Usage**: Continuous camera monitoring affects battery
4. **Network Dependency**: Maps and location services require internet

### 📞 Support

For issues or questions:
1. Check this SETUP.md file first
2. Review the main README.md for project details
3. Check the issue tracker on GitHub
4. Contact the development team

### 🔄 Development Workflow

1. Make changes to code
2. Test on physical device
3. Update documentation if needed
4. Submit pull request with description

---

**Happy coding! 🚗💻**