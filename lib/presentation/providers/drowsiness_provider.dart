import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/database_service.dart';
import '../../core/services/notification_service.dart';
import '../../data/models/drowsiness_event.dart';

/// Provider for managing drowsiness detection state and ML Kit integration
class DrowsinessProvider extends ChangeNotifier {
  // Camera and ML Kit
  CameraController? _cameraController;
  late FaceDetector _faceDetector;
  bool _isDetecting = false;
  bool _isInitialized = false;
  
  // Detection state
  DrowsinessState _currentState = DrowsinessState.normal;
  bool _isMonitoring = false;
  DateTime? _lastAlertTime;
  
  // Detection counters for consistency
  int _eyesClosedFrames = 0;
  int _yawningFrames = 0;
  int _faceNotDetectedFrames = 0;
  
  // Detection statistics
  double _currentConfidence = 0.0;
  DetectionType? _lastDetectionType;
  
  // Stream controllers for real-time updates
  final StreamController<DrowsinessEvent> _eventStreamController = 
      StreamController<DrowsinessEvent>.broadcast();
  
  // Getters
  CameraController? get cameraController => _cameraController;
  bool get isInitialized => _isInitialized;
  bool get isMonitoring => _isMonitoring;
  DrowsinessState get currentState => _currentState;
  double get currentConfidence => _currentConfidence;
  DetectionType? get lastDetectionType => _lastDetectionType;
  Stream<DrowsinessEvent> get eventStream => _eventStreamController.stream;
  
  /// Initialize camera and ML Kit face detector
  Future<void> initialize() async {
    try {
      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }
      
      // Use front camera for driver monitoring
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      
      // Initialize camera controller
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      await _cameraController!.initialize();
      
      // Initialize ML Kit face detector
      final options = FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableContours: false,
        enableTracking: true,
        minFaceSize: 0.1,
        performanceMode: FaceDetectorMode.fast,
      );
      
      _faceDetector = FaceDetector(options: options);
      
      _isInitialized = true;
      notifyListeners();
      
    } catch (e) {
      print('Error initializing drowsiness detection: $e');
      throw Exception('Failed to initialize camera and ML Kit: $e');
    }
  }

  /// Start monitoring for drowsiness
  Future<void> startMonitoring() async {
    if (!_isInitialized || _isMonitoring) return;
    
    try {
      _isMonitoring = true;
      _resetCounters();
      
      // Start camera image stream for real-time processing
      await _cameraController!.startImageStream(_processImage);
      
      notifyListeners();
    } catch (e) {
      print('Error starting monitoring: $e');
      _isMonitoring = false;
      notifyListeners();
    }
  }

  /// Stop monitoring for drowsiness
  Future<void> stopMonitoring() async {
    if (!_isMonitoring) return;
    
    try {
      _isMonitoring = false;
      
      if (_cameraController?.value.isStreamingImages == true) {
        await _cameraController!.stopImageStream();
      }
      
      _resetCounters();
      _currentState = DrowsinessState.normal;
      
      notifyListeners();
    } catch (e) {
      print('Error stopping monitoring: $e');
    }
  }

  /// Process camera image for face detection
  Future<void> _processImage(CameraImage image) async {
    if (_isDetecting || !_isMonitoring) return;
    
    _isDetecting = true;
    
    try {
      // Convert CameraImage to InputImage for ML Kit
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) return;
      
      // Detect faces
      final faces = await _faceDetector.processImage(inputImage);
      
      // Process detection results
      await _processFaceDetection(faces);
      
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      _isDetecting = false;
    }
  }

  /// Convert CameraImage to InputImage
  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final camera = _cameraController?.description;
      if (camera == null) return null;
      
      // Create input image metadata
      final imageRotation = InputImageRotationValue.fromRawValue(
        camera.sensorOrientation,
      );
      if (imageRotation == null) return null;
      
      final inputImageFormat = InputImageFormatValue.fromRawValue(
        image.format.raw,
      );
      if (inputImageFormat == null) return null;
      
      final planeData = image.planes.map(
        (plane) => InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        ),
      ).toList();
      
      final inputImageData = InputImageData(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        imageRotation: imageRotation,
        inputImageFormat: inputImageFormat,
        planeData: planeData,
      );
      
      return InputImage.fromBytes(
        bytes: image.planes.first.bytes,
        inputImageData: inputImageData,
      );
    } catch (e) {
      print('Error converting camera image: $e');
      return null;
    }
  }

  /// Process face detection results
  Future<void> _processFaceDetection(List<Face> faces) async {
    if (faces.isEmpty) {
      _handleNoFaceDetected();
      return;
    }
    
    // Reset face not detected counter
    _faceNotDetectedFrames = 0;
    
    // Process the first (primary) face
    final face = faces.first;
    
    // Check for drowsiness indicators
    _checkEyesClosed(face);
    _checkYawning(face);
    
    // Update detection state based on counters
    _updateDetectionState();
  }

  /// Handle case when no face is detected
  void _handleNoFaceDetected() {
    _faceNotDetectedFrames++;
    
    if (_faceNotDetectedFrames >= AppConstants.drowsinessDetectionFrames) {
      _triggerAlert(
        DetectionType.faceNotDetected,
        DrowsinessState.alert,
        0.8,
      );
    }
  }

  /// Check if eyes are closed
  void _checkEyesClosed(Face face) {
    // Use left and right eye open probability
    final leftEyeOpenProbability = face.leftEyeOpenProbability ?? 1.0;
    final rightEyeOpenProbability = face.rightEyeOpenProbability ?? 1.0;
    
    final averageEyeOpenProbability = 
        (leftEyeOpenProbability + rightEyeOpenProbability) / 2.0;
    
    if (averageEyeOpenProbability < AppConstants.eyeClosureThreshold) {
      _eyesClosedFrames++;
    } else {
      _eyesClosedFrames = 0;
    }
    
    // Update current confidence
    _currentConfidence = 1.0 - averageEyeOpenProbability;
  }

  /// Check if person is yawning
  void _checkYawning(Face face) {
    // Estimate yawning based on mouth opening
    // This is a simplified approach - in a real implementation,
    // you might use more sophisticated landmark analysis
    final smilingProbability = face.smilingProbability ?? 0.0;
    
    // Inverse correlation: less smiling + other indicators might suggest yawning
    // In practice, you'd analyze mouth landmarks more precisely
    if (smilingProbability < 0.1 && _currentConfidence > 0.3) {
      _yawningFrames++;
    } else {
      _yawningFrames = max(0, _yawningFrames - 1);
    }
  }

  /// Update detection state based on frame counters
  void _updateDetectionState() {
    DrowsinessState newState = DrowsinessState.normal;
    DetectionType? detectionType;
    double confidence = _currentConfidence;
    
    // Check for critical drowsiness (eyes closed for extended period)
    if (_eyesClosedFrames >= AppConstants.drowsinessDetectionFrames * 2) {
      newState = DrowsinessState.critical;
      detectionType = DetectionType.eyesClosed;
      confidence = min(1.0, _currentConfidence + 0.3);
    }
    // Check for drowsiness (eyes closed)
    else if (_eyesClosedFrames >= AppConstants.drowsinessDetectionFrames) {
      newState = DrowsinessState.drowsy;
      detectionType = DetectionType.eyesClosed;
    }
    // Check for yawning
    else if (_yawningFrames >= AppConstants.drowsinessDetectionFrames) {
      newState = DrowsinessState.alert;
      detectionType = DetectionType.yawning;
      confidence = min(1.0, _currentConfidence + 0.2);
    }
    
    // Trigger alert if state changed to drowsy or worse
    if (newState != DrowsinessState.normal && newState != _currentState) {
      if (detectionType != null) {
        _triggerAlert(detectionType, newState, confidence);
      }
    }
    
    _currentState = newState;
    _lastDetectionType = detectionType;
    notifyListeners();
  }

  /// Trigger drowsiness alert
  Future<void> _triggerAlert(
    DetectionType detectionType,
    DrowsinessState state,
    double confidence,
  ) async {
    // Check cooldown period
    if (_lastAlertTime != null) {
      final timeSinceLastAlert = DateTime.now().difference(_lastAlertTime!);
      if (timeSinceLastAlert < AppConstants.alertCooldown) {
        return;
      }
    }
    
    _lastAlertTime = DateTime.now();
    
    try {
      // Create drowsiness event
      final event = DrowsinessEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        detectionType: detectionType,
        drowsinessLevel: state,
        confidenceScore: confidence,
        emergencyTriggered: state == DrowsinessState.critical,
      );
      
      // Save to database
      await DatabaseService.saveDrowsinessEvent(event);
      
      // Send to stream
      _eventStreamController.add(event);
      
      // Show notification
      await _showAlert(event);
      
      // Play audio alert
      await NotificationService.playAlertSound(
        isEmergency: state == DrowsinessState.critical,
      );
      
    } catch (e) {
      print('Error triggering alert: $e');
    }
  }

  /// Show appropriate alert based on drowsiness level
  Future<void> _showAlert(DrowsinessEvent event) async {
    final title = event.drowsinessLevel == DrowsinessState.critical
        ? 'CRITICAL: Driver Drowsiness'
        : 'Alert: Drowsiness Detected';
    
    final message = 'Detection: ${event.detectionTypeDescription}\n'
                   'Confidence: ${(event.confidenceScore * 100).toStringAsFixed(1)}%';
    
    if (event.drowsinessLevel == DrowsinessState.critical) {
      await NotificationService.showEmergencyAlert(
        title: title,
        message: message,
        payload: event.id,
      );
    } else {
      await NotificationService.showDrowsinessAlert(
        title: title,
        message: message,
        payload: event.id,
      );
    }
  }

  /// Reset all detection counters
  void _resetCounters() {
    _eyesClosedFrames = 0;
    _yawningFrames = 0;
    _faceNotDetectedFrames = 0;
    _currentConfidence = 0.0;
    _lastDetectionType = null;
  }

  /// Get detection status message
  String get statusMessage {
    if (!_isMonitoring) return AppConstants.statusPaused;
    
    switch (_currentState) {
      case DrowsinessState.normal:
        return AppConstants.statusNormal;
      case DrowsinessState.drowsy:
      case DrowsinessState.alert:
      case DrowsinessState.critical:
        return AppConstants.statusAlert;
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    stopMonitoring();
    _cameraController?.dispose();
    _faceDetector.close();
    _eventStreamController.close();
    super.dispose();
  }
}