Driver Monitoring and Assistance App
🚗 AI-Powered Driver Safety Assistant
A comprehensive Flutter application that uses ML Kit for real-time driver drowsiness detection and provides intelligent assistance to ensure road safety.
✨ Features
🎯 Core Functionality
•	Real-time Drowsiness Detection: Uses ML Kit for face detection, eye closure, and yawn detection
•	Live Camera Preview: Front camera monitoring with futuristic UI overlay
•	Alert System: Audio, visual, and haptic alerts for drowsiness detection
•	Emergency Response: Automatic emergency contact notification and location sharing
🤖 AI Assistant
•	Intelligent Chatbot: Context-aware assistant for driver guidance
•	Rest Suggestions: Personalized recommendations for breaks and rest stops
•	Emergency Mode: Priority support during critical situations
•	Voice Interaction: Future-ready voice chat capabilities
📍 Location Services
•	Nearby Places: Find rest stops, gas stations, hospitals, restaurants, and hotels
•	Google Maps Integration: Real-time navigation and directions
•	Location Sharing: Emergency location broadcasting to contacts
•	Live GPS Tracking: Continuous location monitoring during drives
📊 Data & Analytics
•	Event Logging: Comprehensive drowsiness event history
•	Statistics Dashboard: Daily, weekly, and monthly analytics
•	Export Functionality: Data export for health monitoring
•	Performance Insights: Detection accuracy and pattern analysis
⚙️ Advanced Settings
•	Detection Sensitivity: Adjustable ML model parameters
•	Notification Preferences: Customizable alert types and volumes
•	Emergency Contacts: Manage emergency contact list and SMS alerts
•	Dark Mode Theme: Futuristic neon-accented UI design
🏗️ Architecture
Project Structure
lib/

Tech Stack
•	Frontend: Flutter 3.16+ with Dart
•	State Management: Provider pattern
•	Database: Hive (local NoSQL)
•	ML/AI: Google ML Kit (Face Detection)
•	Maps: Google Maps API
•	Camera: Camera plugin with ML integration
•	Notifications: Flutter Local Notifications
•	Location: Geolocator plugin
•	SMS: SMS Advanced plugin
•	UI: Custom neon-themed components with animations
📱 Screens
1.	Home Screen - Main dashboard with monitoring controls
2.	Detection Screen - Live camera feed with ML overlay
3.	Chatbot Screen - AI assistant for driver guidance
4.	Maps Screen - Nearby places finder with categories
5.	Logs Screen - Event history and analytics
6.	Settings Screen - App configuration and preferences
7.	Emergency Screen - Critical situation response
8. Splash Screen - App loading and initialization
      🚀 Setup Instructions
      Prerequisites
      •	Flutter SDK 3.16.0 or higher
      •	Dart 3.0.0 or higher
      •	Android Studio / VS Code with Flutter plugins
      •	Physical device (camera required for ML detection)
      Installation
1.	Clone the repository
2.	git clone https://github.com/umarvibe/FYP.git
      cd FYP
3.	Install dependencies
      flutter pub get
4.	Configure API Keys
      o	Get Google Maps API key from Google Cloud Console
      o	Replace YOUR_GOOGLE_MAPS_API_KEY in:
      	android/app/src/main/AndroidManifest.xml
      	lib/core/constants/app_constants.dart
5.	Generate Hive adapters
      flutter packages pub run build_runner build
6.	Run the app
      flutter run
      Platform-Specific Setup
      Android
      •	Minimum SDK: 21
      •	Target SDK: 34
      •	Permissions automatically requested at runtime
      iOS
      •	Minimum iOS: 11.0
      •	Camera and location permissions configured in Info.plist
      •	Background modes enabled for continuous monitoring
      🔧 Configuration
      ML Kit Detection Parameters
      // Adjust in app_constants.dart
      static const double eyeClosureThreshold = 0.4;
      static const double yawnDetectionThreshold = 0.6;
      static const int drowsinessDetectionFrames = 5;
      Notification Settings
      // Customize alert behaviors
      static const String alertSoundPath = 'assets/sounds/alert_beep.mp3';
      static const Duration alertCooldown = Duration(seconds: 10);
      🛡️ Security & Privacy
      •	Local Data Storage: All detection data stored locally using Hive
      •	No Cloud Dependency: ML processing happens on-device
      •	Privacy First: No personal data transmitted to servers
      •	Secure SMS: Emergency contacts managed locally
      •	Permissions: Minimal required permissions requested
      🔄 State Management
      Uses Provider pattern for reactive state management:
      •	DrowsinessProvider: ML detection state and camera management
      •	LocationProvider: GPS and nearby places functionality
      •	SettingsProvider: App preferences and configuration
      •	ChatbotProvider: AI assistant conversation management
      🧪 Testing
      Manual Testing Scenarios
1.	Detection Accuracy: Test with various lighting conditions
2.	Emergency Response: Verify SMS and location sharing
3.	Performance: Monitor battery usage during detection
4.	UI Responsiveness: Test on different screen sizes
      🚧 Known Limitations
1.	ML Kit Dependency: Requires Google Play Services on Android
2.	Camera Requirement: Physical device needed for testing
3.	Battery Usage: Continuous camera monitoring affects battery
4.	Network Dependency: Maps and location services require internet
      🔮 Future Enhancements
      Planned Features
      •	Advanced ML Models: Custom drowsiness detection training
      •	Wearable Integration: Smartwatch heart rate monitoring
      •	Fleet Management: Multi-driver dashboard for companies
      •	Cloud Sync: Optional cloud backup with encryption
      •	Voice Commands: Complete voice-controlled interface
      •	Passenger Mode: Detection for multiple occupants
      Technical Improvements
      •	Offline Maps: Cached map data for remote areas
      •	Edge Computing: On-device AI model optimization
      •	Real-time Sync: Multi-device synchronization
      •	Advanced Analytics: Machine learning insights
      📄 License
      This project is licensed under the MIT License.
      👥 Contributors
      •	Development Team: AI-Powered Safety Solutions
      •	Project Focus: Driver Safety and Road Accident Prevention
      •	Technology: Flutter + ML Kit + Advanced AI Integration
      📞 Support
      For support and questions: Muhammad Umar 03072500966
      🙏 Acknowledgments
      •	Google ML Kit: Face detection capabilities
      •	Flutter Team: Excellent cross-platform framework
      •	Community: Open source packages and resources
      •	Safety Organizations: Road safety research and guidelines
________________________________________
⚠️ Important: This app is designed to assist drivers but should not replace alertness and responsible driving. Always prioritize road safety and follow traffic regulations.
