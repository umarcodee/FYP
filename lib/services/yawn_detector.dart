import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class YawnDetector {
  static const double mouthOpenThreshold = 0.5;
  static const int minYawnFrames = 5;
  static const int cooldownFrames = 30; // Cooldown between detections

  int _yawnFrameCount = 0;
  int _cooldownCounter = 0;
  bool _isInYawnState = false;

  bool detectYawn(Face face) {
    // Cooldown check - prevent multiple detections in quick succession
    if (_cooldownCounter > 0) {
      _cooldownCounter--;
      return false;
    }

    // Get mouth openness probability
    final mouthOpen = face.smilingProbability ??  0.0;

    // Detect if mouth is open
    if (mouthOpen > mouthOpenThreshold) {
      _yawnFrameCount++;

      // If enough frames show open mouth, it's a yawn
      if (_yawnFrameCount >= minYawnFrames && ! _isInYawnState) {
        _isInYawnState = true;
        _cooldownCounter = cooldownFrames; // Start cooldown
        _yawnFrameCount = 0; // Reset frame count
        return true; // YAWN DETECTED!
      }
    } else {
      // Mouth is closed - reset yawn state
      _yawnFrameCount = 0;
      _isInYawnState = false;
    }

    return false;
  }

  // Reset detector
  void reset() {
    _yawnFrameCount = 0;
    _cooldownCounter = 0;
    _isInYawnState = false;
  }
}