import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class AccidentDetector {
  static const double accidentThreshold = 15.0; // Reduced threshold for easier detection
  
  StreamSubscription<UserAccelerometerEvent>? _subscription;
  final Function(double force) onAccidentDetected;

  AccidentDetector({required this.onAccidentDetected});

  void start() {
    // We use UserAccelerometer to get acceleration without gravity
    _subscription = userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      // Calculate total magnitude of acceleration (G-force)
      // Vector magnitude = sqrt(x^2 + y^2 + z^2)
      double force = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (force > accidentThreshold) {
        onAccidentDetected(force);
      }
    });
  }

  void stop() {
    _subscription?.cancel();
  }
}
