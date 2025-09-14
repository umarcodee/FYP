import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../../core/constants/app_constants.dart';

/// Service for handling ML Kit face detection for drowsiness monitoring
class FaceDetectionService {
  static final FaceDetectionService _instance = FaceDetectionService._internal();
  factory FaceDetectionService() => _instance;
  FaceDetectionService._internal();

  late FaceDetector _faceDetector;
  bool _isInitialized = false;

  /// Initialize the face detector
  Future<void> initialize() async {
    if (_isInitialized) return;

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
        enableClassification: true,
        enableTracking: true,
        minFaceSize: 0.1,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    _isInitialized = true;
  }

  /// Detect faces and analyze for drowsiness indicators
  Future<DrowsinessResult> detectDrowsiness(CameraImage image) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final inputImage = _convertCameraImage(image);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return DrowsinessResult(
          isDrowsy: false,
          confidence: 0.0,
          eyesOpen: true,
          mouthOpen: false,
          headPose: HeadPose.neutral,
        );
      }

      final face = faces.first;
      
      // Analyze eye openness
      final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
      final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;
      final eyesOpen = (leftEyeOpen + rightEyeOpen) / 2 > AppConstants.eyeClosureThreshold;

      // Analyze mouth openness (yawning)
      final mouthOpen = _detectYawn(face);

      // Analyze head pose
      final headPose = _analyzeHeadPose(face);

      // Calculate drowsiness confidence
      final confidence = _calculateDrowsinessConfidence(
        leftEyeOpen,
        rightEyeOpen,
        mouthOpen,
        headPose,
      );

      return DrowsinessResult(
        isDrowsy: confidence > 0.6,
        confidence: confidence,
        eyesOpen: eyesOpen,
        mouthOpen: mouthOpen,
        headPose: headPose,
      );
    } catch (e) {
      return DrowsinessResult(
        isDrowsy: false,
        confidence: 0.0,
        eyesOpen: true,
        mouthOpen: false,
        headPose: HeadPose.neutral,
      );
    }
  }

  /// Convert CameraImage to InputImage for ML Kit processing
  InputImage _convertCameraImage(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final InputImageRotation imageRotation = InputImageRotation.rotation0deg;

    final InputImageFormat inputImageFormat = InputImageFormat.nv21;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    return InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
  }

  /// Detect yawning based on mouth landmarks
  bool _detectYawn(Face face) {
    // This is a simplified yawn detection based on mouth open probability
    // In a real implementation, you might use mouth landmarks for more accuracy
    return false; // Placeholder - ML Kit doesn't provide mouth open probability directly
  }

  /// Analyze head pose for driver attention
  HeadPose _analyzeHeadPose(Face face) {
    final headEulerAngleY = face.headEulerAngleY;
    final headEulerAngleZ = face.headEulerAngleZ;

    if (headEulerAngleY != null && headEulerAngleY.abs() > 30) {
      return headEulerAngleY > 0 ? HeadPose.lookingRight : HeadPose.lookingLeft;
    }

    if (headEulerAngleZ != null && headEulerAngleZ.abs() > 20) {
      return HeadPose.tilted;
    }

    return HeadPose.neutral;
  }

  /// Calculate overall drowsiness confidence score
  double _calculateDrowsinessConfidence(
    double leftEyeOpen,
    double rightEyeOpen,
    bool mouthOpen,
    HeadPose headPose,
  ) {
    double confidence = 0.0;

    // Eye closure factor (most important)
    final eyeClosureFactor = 1.0 - ((leftEyeOpen + rightEyeOpen) / 2);
    confidence += eyeClosureFactor * 0.7;

    // Yawning factor
    if (mouthOpen) {
      confidence += 0.2;
    }

    // Head pose factor
    if (headPose != HeadPose.neutral) {
      confidence += 0.1;
    }

    return confidence.clamp(0.0, 1.0);
  }

  /// Dispose resources
  void dispose() {
    if (_isInitialized) {
      _faceDetector.close();
      _isInitialized = false;
    }
  }
}

/// Result of drowsiness detection analysis
class DrowsinessResult {
  final bool isDrowsy;
  final double confidence;
  final bool eyesOpen;
  final bool mouthOpen;
  final HeadPose headPose;

  DrowsinessResult({
    required this.isDrowsy,
    required this.confidence,
    required this.eyesOpen,
    required this.mouthOpen,
    required this.headPose,
  });
}

/// Enum for head pose analysis
enum HeadPose {
  neutral,
  lookingLeft,
  lookingRight,
  tilted,
}