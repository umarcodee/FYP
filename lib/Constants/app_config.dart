/// Application Configuration Constants

class DrowsinessConfig {
  // Drowsiness Detection Settings
  static const int minClosedFramesForDrowsy = 10;
  static const double eyeClosedProbThreshold = 0.30;
  static const int holdRedSeconds = 1;

  // Head Pose Detection Settings
  static const double headDownThreshold = -15.0; // Euler X angle (tilted down)
  static const int minFramesForHeadDown = 15;

  // Audio Settings
  static const String alertSoundAsset = 'sounds/alarm.mp3';

  // Animation Settings
  static const int pulseAnimationDuration = 900;

  // Yawn Detection Settings
  static const double mouthOpenThreshold = 0.5;
  static const int minYawnFrames = 5;
}

class AppColors {
  // Neon Colors
  static const int cyanColor = 0xFF00FFFF;
  static const int redAlert = 0xFFFF0000;
  static const int blackBg = 0xFF000000;
}

class AppStrings {
  static const String appTitle = 'Driver Monitoring';
  static const String detectingMessage = 'Detecting... ';
  static const String drowsyDetected = 'Drowsy detected!';
  static const String yawnDetected = 'Yawn detected!';
  static const String noFaceDetected = 'No face detected';
  static const String eyesOpen = 'Eyes open - All good!';
}
