/// Application constants and configuration values
class AppConstants {
  // App Information
  static const String appName = 'Driver Monitoring App';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered Driver Monitoring and Assistance';

  // ML Kit Detection Constants
  static const double eyeClosureThreshold = 0.4;
  static const double yawnDetectionThreshold = 0.6;
  static const int drowsinessDetectionFrames = 5; // Consecutive frames for detection
  static const Duration alertCooldown = Duration(seconds: 10);
  
  // Camera Configuration
  static const int cameraResolutionWidth = 640;
  static const int cameraResolutionHeight = 480;
  static const int targetFPS = 30;
  
  // Database Constants
  static const String drowsinessEventsBox = 'drowsiness_events';
  static const String settingsBox = 'app_settings';
  static const String emergencyContactsBox = 'emergency_contacts';
  
  // Location Service Constants
  static const double locationAccuracyThreshold = 100.0; // meters
  static const Duration locationUpdateInterval = Duration(seconds: 30);
  static const double nearbySearchRadius = 5000.0; // meters (5km)
  
  // Google Maps API
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  
  // Places Search Types
  static const String restStopsPlaceType = 'rest_area';
  static const String petrolPumpsPlaceType = 'gas_station';
  static const String hospitalsPlaceType = 'hospital';
  
  // Notification Constants
  static const String drowsinessChannelId = 'drowsiness_alerts';
  static const String drowsinessChannelName = 'Drowsiness Alerts';
  static const String emergencyChannelId = 'emergency_alerts';
  static const String emergencyChannelName = 'Emergency Alerts';
  
  // Audio Alerts
  static const String alertSoundPath = 'assets/sounds/alert_beep.mp3';
  static const String emergencySoundPath = 'assets/sounds/emergency_alert.mp3';
  
  // SMS Templates
  static const String emergencySmsTemplate = 
      'EMERGENCY: Driver drowsiness detected! '
      'Location: {location}\n'
      'Time: {timestamp}\n'
      'Please check on the driver immediately.';
  
  // Chatbot Configuration
  static const List<String> restSuggestions = [
    'Find a safe place to pull over immediately',
    'Take a 15-20 minute power nap',
    'Drink some water or caffeine',
    'Do some light stretching exercises',
    'Switch drivers if possible',
    'Consider staying overnight if you\'re very tired',
  ];
  
  static const List<String> chatbotGreetings = [
    'I noticed you might be feeling drowsy. How can I help?',
    'Your safety is important. Let\'s find you a safe place to rest.',
    'It looks like you need a break. What would you like to do?',
    'I\'m here to help keep you safe. Would you like me to find nearby rest stops?',
  ];
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // UI Constants
  static const double borderRadius = 16.0;
  static const double cardElevation = 8.0;
  static const double buttonHeight = 56.0;
  static const double iconSize = 24.0;
  static const double largeIconSize = 48.0;
  
  // Padding and Margins
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Detection Status Messages
  static const String statusAlert = 'DROWSINESS DETECTED';
  static const String statusNormal = 'MONITORING ACTIVE';
  static const String statusPaused = 'MONITORING PAUSED';
  static const String statusError = 'CAMERA ERROR';
  
  // Emergency Contact Validation
  static const int maxEmergencyContacts = 5;
  static const int minPhoneNumberLength = 10;
  static const int maxPhoneNumberLength = 15;
  
  // Data Retention
  static const int maxLogEntries = 1000;
  static const Duration logRetentionPeriod = Duration(days: 30);
  
  // Performance Constants
  static const int maxConcurrentDetections = 3;
  static const Duration detectionTimeout = Duration(seconds: 5);
  
  // Feature Flags
  static const bool enableVoiceChat = true;
  static const bool enableLocationServices = true;
  static const bool enableEmergencyAlerts = true;
  static const bool enableMLKitDetection = true;
}

/// Enumeration for drowsiness detection states
enum DrowsinessState {
  normal,
  drowsy,
  alert,
  critical,
}

/// Enumeration for detection types
enum DetectionType {
  eyesClosed,
  yawning,
  headNodding,
  faceNotDetected,
}

/// Enumeration for emergency alert types
enum EmergencyAlertType {
  drowsinessDetected,
  criticalDrowsiness,
  noResponse,
  manualTrigger,
}

/// Enumeration for nearby place search types
enum PlaceSearchType {
  restStops,
  petrolPumps,
  hospitals,
  restaurants,
  hotels,
}