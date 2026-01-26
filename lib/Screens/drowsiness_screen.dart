import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/app_config.dart';
import '../models/detection_models.dart';
import '../services/yawn_detector.dart';
import '../main.dart';

/// ================== STATE ENUM ==================
enum DrowsyState { normal, drowsyActive, drowsyHold }

/// ================== ALERT SERVICE ==================
class AlertService {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;
  Timer? _soundStopTimer;

  Future<void> startLoop() async {
    if (_playing) return;
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(DrowsinessConfig.alertSoundAsset));
      _playing = true;
    } catch (e) {
      debugPrint('Alert start error: $e');
      _playing = false;
    }
  }

  Future<void> stopAfterDelay(int delaySeconds) async {
    _soundStopTimer?.cancel();
    _soundStopTimer = Timer(Duration(seconds: delaySeconds), () async {
      await stop();
    });
  }

  Future<void> stop() async {
    if (! _playing) return;
    _soundStopTimer?.cancel();
    try {
      await _player.stop();
    } catch (_) {}
    _playing = false;
  }

  Future<void> dispose() async {
    _soundStopTimer?.cancel();
    try {
      await _player.stop();
      await _player.release();
    } catch (_) {}
    _playing = false;
  }
}

/// ================== MAIN SCREEN ==================
class DrowsinessScreen extends StatefulWidget {
  const DrowsinessScreen({Key?  key}) : super(key: key);

  @override
  State<DrowsinessScreen> createState() => _DrowsinessScreenState();
}

class _DrowsinessScreenState extends State<DrowsinessScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  late FaceDetector _faceDetector;
  final AlertService _alertService = AlertService();
  late YawnDetector _yawnDetector;

  bool _isProcessing = false;
  bool _isDetecting = false;
  bool _cameraInitialized = false;

  int _closedEyesFrameCount = 0;
  int _drowsyCount = 0;
  int _yawnCount = 0;

  DrowsyState _state = DrowsyState.normal;
  String _status = "Detection starting...";
  bool _autoStartTriggered = false;

  Timer? _holdTimer;


  // ✨ NEW: Multiple animations for better glow
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;

  late Animation<double> _pulse;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super. initState();
    _yawnDetector = YawnDetector();
    _initFaceDetector();

    // Main Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0,
      upperBound: 1,
    );
    _pulse = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

    // Glow Animation (Faster)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      lowerBound: 0,
      upperBound: 1,
    );
    _glowAnimation = CurvedAnimation(parent: _glowController, curve: Curves.easeInOut);

    // Shimmer Animation (Very Fast)
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0,
      upperBound: 1,
    );
    _shimmerAnimation = CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut);

    Future.delayed(const Duration(seconds: 3), () {
      if (! mounted || _autoStartTriggered) return;
      _autoStartTriggered = true;
      _startCamera();
    });
  }

  @override
  void dispose() {
    _stopCamera();
    _faceDetector.close();
    _alertService.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    _holdTimer?.cancel();
    super.dispose();
  }

  void _initFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableClassification: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
  }

  Future<void> _startCamera() async {
    setState(() => _status = "Initializing.. .");
    final camStatus = await Permission.camera.request();
    if (camStatus.isDenied || camStatus.isPermanentlyDenied) {
      setState(() {
        _status = camStatus.isPermanentlyDenied
            ? "Camera permission permanently denied.  Open settings."
            : "Camera permission denied";
      });
      if (camStatus.isPermanentlyDenied) {
        await openAppSettings();
      }
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() => _status = "No cameras available");
      return;
    }

    final camera = cameras. firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup:
      Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!. initialize();
      if (! mounted) return;
      _cameraInitialized = true;
      await _controller!.startImageStream(_processImage);
      setState(() {
        _isDetecting = true;
        _status = "Detecting...";
      });
    } catch (e) {
      setState(() => _status = "Camera error: ${e.toString(). split('\n').first}");
      debugPrint("Camera error: $e");
    }
  }

  void _stopCamera() {
    if (_controller != null) {
      if (_controller!.value. isStreamingImages) {
        _controller!. stopImageStream();
      }
      _controller! .dispose();
      _controller = null;
    }

    _holdTimer?.cancel();
    _alertService.stop();
    _pulseController.stop();
    _pulseController.reset();
    _glowController. stop();
    _glowController. reset();
    _shimmerController.stop();
    _shimmerController.reset();

    setState(() {
      _isDetecting = false;
      _cameraInitialized = false;
      _status = "Detection starting...";
      _state = DrowsyState.normal;
      _closedEyesFrameCount = 0;
    });

    _autoStartTriggered = false;
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isProcessing || ! mounted) return;
    _isProcessing = true;

    try {
      final inputImage = _convertImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final faces = await _faceDetector. processImage(inputImage);
      if (! mounted || !_isDetecting) {
        _isProcessing = false;
        return;
      }

      if (faces.isEmpty) {
        _handleNoFace();
      } else {
        final face = _largestFace(faces);

        // ===== DROWSINESS CHECK =====
        final leftProb = face.leftEyeOpenProbability ??  1.0;
        final rightProb = face.rightEyeOpenProbability ?? 1.0;
    final eyesClosed = (leftProb < DrowsinessConfig.eyeClosedProbThreshold &&
    rightProb < DrowsinessConfig.eyeClosedProbThreshold);

    if (eyesClosed) {
    _closedEyesFrameCount++;
    if (_closedEyesFrameCount > DrowsinessConfig.minClosedFramesForDrowsy) {
    _enterDrowsy();
    }
    } else {
    _recoverIfNeeded();
    }

    // ===== YAWN CHECK =====
    if (_yawnDetector.detectYawn(face)) {
    _handleYawnDetected();
    debugPrint('✅ Yawn detected and handled! ');
    }
    }
    } catch (e) {
    setState(() => _status = "Processing error: ${e.toString(). split('\n').first}");
    debugPrint("Processing error: $e");
    }

    _isProcessing = false;
  }

  void _handleYawnDetected() async {
    setState(() {
      _yawnCount++;
    });

    // Save to database
    final event = DetectionEvent(
      timestamp: DateTime.now(),
      eventType: 'yawn',
      durationMs: 500,
      confidenceScore: 0.85,
    );
    await dbService.addEvent(event);

    // Play alert sound
    await _alertService.startLoop();
    await _alertService.stopAfterDelay(1);

    debugPrint('🥱 Yawn count: $_yawnCount');
  }

  void _handleNoFace() {
    _closedEyesFrameCount = 0;
    if (_state == DrowsyState.drowsyActive || _state == DrowsyState.drowsyHold) {
      _startHold(noFace: true);
    } else {
      setState(() {
        _status = "No face detected";
        _state = DrowsyState.normal;
      });
    }
  }

  void _enterDrowsy() async {
    if (_state == DrowsyState.drowsyActive) return;
    _holdTimer?.cancel();

    setState(() {
      _drowsyCount++;
    });

    // Save to database
    final event = DetectionEvent(
      timestamp: DateTime.now(),
      eventType: 'drowsy',
      durationMs: 1000,
      confidenceScore: 0.9,
    );
    await dbService.addEvent(event);

    await _alertService.startLoop();

    // ✨ Start all animations
    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
    _shimmerController.repeat(reverse: true);

    setState(() {
      _state = DrowsyState.drowsyActive;
      _status = "Drowsy detected!  Eyes closed.  😴";
    });

    debugPrint('👁️ Drowsy count: $_drowsyCount');
  }

  void _recoverIfNeeded() {
    _closedEyesFrameCount = 0;
    if (_state == DrowsyState.drowsyActive) {
      _startHold();
    } else if (_state == DrowsyState.drowsyHold) {
      // Already holding – do nothing
    } else {
      setState(() {
        _status = "Eyes open - All good!  ✅";
      });
    }
  }

  void _startHold({bool noFace = false}) {
    _holdTimer?.cancel();
    _alertService.stopAfterDelay(DrowsinessConfig.holdRedSeconds);
    setState(() {
      _state = DrowsyState.drowsyHold;
      _status = noFace ? "No face detected" : "Drowsy detected!  Eyes closed. ";
    });
    _holdTimer = Timer(Duration(seconds: DrowsinessConfig.holdRedSeconds), () {
      if (!mounted) return;
      _finishHold(noFace: noFace);
    });
  }

  void _finishHold({bool noFace = false}) {
    _holdTimer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    _glowController.stop();
    _glowController.reset();
    _shimmerController.stop();
    _shimmerController. reset();

    setState(() {
      _state = DrowsyState.normal;
      _status = noFace ? "No face detected" : "Eyes open - All good! ";
    });
  }

  Face _largestFace(List<Face> faces) {
    return faces.reduce((a, b) {
      final areaA = a.boundingBox.width * a.boundingBox.height;
      final areaB = b.boundingBox.width * b.boundingBox.height;
      return areaA > areaB ? a : b;
    });
  }

  InputImage?  _convertImage(CameraImage image) {
    final camera = _controller?. description;
    if (camera == null) return null;
    final rotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.rotation0deg;

    InputImageFormat?  format;
    if (image. format. group == ImageFormatGroup.yuv420) {
      format = InputImageFormat.yuv420;
    } else if (image. format.group == ImageFormatGroup.bgra8888) {
      format = InputImageFormat.bgra8888;
    } else if (image.format.group == ImageFormatGroup.jpeg) {
      format = InputImageFormat.yuv420;
    }
    if (format == null) return null;

    try {
      final bytes = _concatenatePlanes(image.planes);
      final metadata = InputImageMetadata(
        size: Size(image.width. toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      );
      return InputImage. fromBytes(bytes: bytes, metadata: metadata);
    } catch (e) {
      debugPrint("Convert error: $e");
      return null;
    }
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done(). buffer.asUint8List();
  }

  bool get _showRedEffect =>
      _state == DrowsyState.drowsyActive || _state == DrowsyState.drowsyHold;

  @override
  Widget build(BuildContext context) {
    final cyan = Colors.cyanAccent;
    final red = Colors.redAccent;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Drowsiness Detection",
          style: TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.1,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox('Drowsy', _drowsyCount. toString(), '👁️'),
                _buildStatBox('Yawns', _yawnCount.toString(), '😴'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Camera Preview with Enhanced Glow
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                // ✨ OUTER GLOW LAYER (Animated Blur)
                if (_showRedEffect)
                  Positioned. fill(
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        final blurAmount = 8 + (_glowAnimation.value * 30);
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: red.withOpacity(0.6 + _glowAnimation.value * 0.4),
                                blurRadius: blurAmount,
                                spreadRadius: 5 + (_glowAnimation.value * 10),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                // Main Camera Container
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: cyan, width: 2),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: cyan.withOpacity(0.22), blurRadius: 14),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Camera Feed
                        if (_cameraInitialized &&
                            _controller != null &&
                            _controller!.value.isInitialized)
                          CameraPreview(_controller!)
                        else
                          Center(
                            child: _isDetecting
                                ? const CircularProgressIndicator(
                                color: Colors.cyanAccent)
                                : const Icon(Icons.camera_alt,
                                color: Colors.cyanAccent, size: 40),
                          ),

                        // ✨ LAYER 1: Main Pulse Overlay
                        AnimatedBuilder(
                          animation: _pulse,
                          builder: (context, child) {
                            final opacity =
                            _showRedEffect ?  (0.15 + _pulse.value * 0.25) : 0.0;
                            return Container(
                            color: red.withOpacity(opacity),
                            );
                          },
                        ),

                        // ✨ LAYER 2: Shimmer Effect
                        if (_showRedEffect)
                          AnimatedBuilder(
                            animation: _shimmerAnimation,
                            builder: (context, child) {
                              final opacity = (0.1 * _shimmerAnimation.value). clamp(0.0, 0.3);
                              return Container(
                                color: Colors.white.withOpacity(opacity),
                              );
                            },
                          ),

                        // ✨ LAYER 3: Border Glow Animation
                        if (_showRedEffect)
                          IgnorePointer(
                            ignoring: true,
                            child: AnimatedBuilder(
                              animation: _glowAnimation,
                              builder: (context, child) {
                                final borderWidth = 2 + (_glowAnimation.value * 3);
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: red.withOpacity(0.3 + _glowAnimation.value * 0.5),
                                      width: borderWidth,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _showRedEffect ? red : cyan,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: (_showRedEffect ? red : cyan). withOpacity(0.15),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isDetecting ? Icons.sensors : Icons.hourglass_bottom,
                color: _isDetecting ? cyan : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                _isDetecting
                    ? "Detection running"
                    : "Detection will start automatically",
                style: TextStyle(
                  color: _isDetecting ? cyan : Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              if (_status. contains("settings"))
                TextButton(
                  onPressed: openAppSettings,
                  child: const Text(
                    "Open Settings",
                    style: TextStyle(color: Colors.cyanAccent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.cyanAccent, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
