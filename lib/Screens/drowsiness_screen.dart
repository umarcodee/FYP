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
import '../services/tts_service.dart';
import '../services/accident_detector.dart';
import '../main.dart';
import 'map_screen.dart';

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
  const DrowsinessScreen({super.key});

  @override
  State<DrowsinessScreen> createState() => _DrowsinessScreenState();
}

class _DrowsinessScreenState extends State<DrowsinessScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  late FaceDetector _faceDetector;
  final AlertService _alertService = AlertService();
  final TtsService _ttsService = TtsService();
  late YawnDetector _yawnDetector;
  late AccidentDetector _accidentDetector;

  bool _isProcessing = false;
  bool _isDetecting = false;
  bool _cameraInitialized = false;

  int _closedEyesFrameCount = 0;
  
  int _drowsyCount = 0;
  int _yawnCount = 0;

  DrowsyState _state = DrowsyState.normal;
  String _status = "Detection starting...";
  bool _autoStartTriggered = false;
  bool _isAccidentActive = false;

  Timer? _holdTimer;
  Timer? _recoveryTimer;
  bool _inAlertCycle = false;
  bool _isBotSpeaking = false;

  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;
  late AnimationController _botSpeakController;
  late AnimationController _accidentAnimController;

  late Animation<double> _pulse;
  late Animation<double> _glowAnimation;
  late Animation<double> _botMouthAnimation;
  late Animation<double> _accidentScaleAnimation;

  @override
  void initState() {
    super. initState();
    _yawnDetector = YawnDetector();
    _initFaceDetector();
    _initAccidentDetector();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulse = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowAnimation = CurvedAnimation(parent: _glowController, curve: Curves.easeInOut);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _botSpeakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _botMouthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _botSpeakController, curve: Curves.easeInOut),
    );

    _accidentAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _accidentScaleAnimation = CurvedAnimation(parent: _accidentAnimController, curve: Curves.elasticOut);

    Future.delayed(const Duration(seconds: 3), () {
      if (! mounted || _autoStartTriggered) return;
      _autoStartTriggered = true;
      _startCamera();
    });
  }

  void _initAccidentDetector() {
    _accidentDetector = AccidentDetector(
      onAccidentDetected: (force) {
        _handleAccident(force);
      },
    );
    _accidentDetector.start();
  }

  void _handleAccident(double force) async {
    if (_isAccidentActive) return;
    
    setState(() {
      _isAccidentActive = true;
      _status = "⚠️ ACCIDENT DETECTED! ⚠️";
    });
    
    _runAccidentCycle();
    
    await dbService.addEvent(DetectionEvent(
      timestamp: DateTime.now(),
      eventType: 'accident',
      durationMs: 0,
      confidenceScore: force / 100,
    ));
  }

  Future<void> _runAccidentCycle() async {
    if (_inAlertCycle) return;
    _inAlertCycle = true;

    while (_isAccidentActive && mounted) {
      _accidentAnimController.forward();
      _startAlertAnimations();

      await _alertService.startLoop();
      await Future.delayed(const Duration(seconds: 2));

      if (!_isAccidentActive) break;

      await _alertService.stop();
      setState(() => _isBotSpeaking = true);
      _botSpeakController.repeat(reverse: true);
      
      await _ttsService.speak("Accident detected, Initializing SOS");
      
      if (mounted) {
        _botSpeakController.stop();
        setState(() => _isBotSpeaking = false);
      }

      if (!_isAccidentActive) break;
    }
    
    _inAlertCycle = false;
    _accidentAnimController.reverse();
    _alertService.stop();
    _ttsService.stop();
    _stopAlertAnimations();
  }

  @override
  void dispose() {
    _stopCamera();
    _faceDetector.close();
    _accidentDetector.stop();
    _alertService.dispose();
    _ttsService.stop();
    _pulseController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    _botSpeakController.dispose();
    _accidentAnimController.dispose();
    _holdTimer?.cancel();
    _recoveryTimer?.cancel();
    super.dispose();
  }

  void _initFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableClassification: true,
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
  }

  Future<void> _startCamera() async {
    setState(() => _status = "Initializing...");
    final camStatus = await Permission.camera.request();
    if (camStatus.isDenied) return;

    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();
      if (! mounted) return;
      _cameraInitialized = true;
      await _controller!.startImageStream(_processImage);
      setState(() {
        _isDetecting = true;
        _status = "Detecting...";
      });
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  void _stopCamera() {
    if (_controller != null) {
      _controller!.dispose();
      _controller = null;
    }
    _holdTimer?.cancel();
    _recoveryTimer?.cancel();
    _inAlertCycle = false;
    _isBotSpeaking = false;
    _isAccidentActive = false;
    _alertService.stop();
    _ttsService.stop();
    _stopAlertAnimations();

    setState(() {
      _isDetecting = false;
      _cameraInitialized = false;
      _state = DrowsyState.normal;
    });
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

      final faces = await _faceDetector.processImage(inputImage);
      if (! mounted || !_isDetecting) {
        _isProcessing = false;
        return;
      }

      if (faces.isEmpty) {
        _handleNoFace();
      } else {
        final face = _largestFace(faces);

        // 1. EYES CLOSED CHECK
        final leftProb = face.leftEyeOpenProbability ?? 1.0;
        final rightProb = face.rightEyeOpenProbability ?? 1.0;
        final eyesClosed = (leftProb < DrowsinessConfig.eyeClosedProbThreshold &&
            rightProb < DrowsinessConfig.eyeClosedProbThreshold);

        // 2. HEAD POSE CHECK
        final headX = face.headEulerAngleX ?? 0.0;
        final headDown = headX < DrowsinessConfig.headDownThreshold;

        if (eyesClosed || headDown) {
          _closedEyesFrameCount++;
          if (_closedEyesFrameCount > DrowsinessConfig.minClosedFramesForDrowsy) {
            _enterDrowsy();
          }
        } else {
          _recoverIfNeeded();
        }

        // 3. YAWN CHECK
        if (_yawnDetector.detectYawn(face)) {
          _handleYawnDetected();
        }
      }
    } catch (e) {
      debugPrint("Processing error: $e");
    }
    _isProcessing = false;
  }

  void _enterDrowsy() async {
    if (_state == DrowsyState.drowsyActive) return;
    _holdTimer?.cancel();
    _recoveryTimer?.cancel();
    
    setState(() => _drowsyCount++);
    
    await dbService.addEvent(DetectionEvent(
      timestamp: DateTime.now(),
      eventType: 'drowsy',
      durationMs: 1000,
    ));

    _state = DrowsyState.drowsyActive;
    _status = AppStrings.drowsyDetected;
    _startAlertAnimations();
    _runAlertCycle();
  }

  Future<void> _runAlertCycle() async {
    if (_inAlertCycle) return;
    _inAlertCycle = true;

    while (_state == DrowsyState.drowsyActive && mounted) {
      await _alertService.startLoop();
      await Future.delayed(const Duration(seconds: 2));

      if (_state != DrowsyState.drowsyActive) break;

      await _alertService.stop();
      setState(() => _isBotSpeaking = true);
      _botSpeakController.repeat(reverse: true);
      
      await _ttsService.speak("Please wake up and focus on driving");
      
      if (mounted) {
        _botSpeakController.stop();
        setState(() => _isBotSpeaking = false);
      }

      if (_state != DrowsyState.drowsyActive) break;
    }
    _inAlertCycle = false;
  }

  void _startAlertAnimations() {
    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
    _shimmerController.repeat(reverse: true);
  }

  void _stopAlertAnimations() {
    _pulseController.stop();
    _glowController.stop();
    _shimmerController.stop();
    _botSpeakController.stop();
    _accidentAnimController.reverse();
  }

  void _recoverIfNeeded() {
    _closedEyesFrameCount = 0;
    if (_state == DrowsyState.drowsyActive || _isAccidentActive) {
      _startHold();
    } else if (_state != DrowsyState.drowsyHold) {
      setState(() => _status = AppStrings.eyesOpen);
    }
  }

  void _handleYawnDetected() async {
    setState(() => _yawnCount++);
    await dbService.addEvent(DetectionEvent(
      timestamp: DateTime.now(),
      eventType: 'yawn',
      durationMs: 500,
    ));
    await _alertService.startLoop();
    Timer(const Duration(seconds: 1), () => _alertService.stop());
  }

  void _handleNoFace() {
    _closedEyesFrameCount = 0;
    if (_isAccidentActive) {
      setState(() => _status = "⚠️ NO FACE DETECTED - ACCIDENT ACTIVE! ⚠️");
      return;
    }

    if (_state == DrowsyState.drowsyActive || _state == DrowsyState.drowsyHold) {
      _startHold(noFace: true);
    } else {
      setState(() {
        _status = AppStrings.noFaceDetected;
        _state = DrowsyState.normal;
      });
    }
  }

  void _startHold({bool noFace = false}) {
    if (_state == DrowsyState.drowsyHold) return;
    
    _holdTimer?.cancel();
    _recoveryTimer?.cancel();
    
    setState(() {
      _state = DrowsyState.drowsyHold;
      _status = noFace ? AppStrings.noFaceDetected : "Recovering...";
    });

    _recoveryTimer = Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;
      
      await _alertService.stop();
      await _ttsService.stop();
      _isAccidentActive = false; 
      _inAlertCycle = false;
      _stopAlertAnimations();
      
      _finishHold(noFace: noFace);
    });
  }

  void _finishHold({bool noFace = false}) {
    setState(() {
      _isBotSpeaking = false;
      _state = DrowsyState.normal;
      _status = noFace ? AppStrings.noFaceDetected : AppStrings.eyesOpen;
    });
  }

  Face _largestFace(List<Face> faces) {
    return faces.reduce((a, b) {
      final areaA = a.boundingBox.width * a.boundingBox.height;
      final areaB = b.boundingBox.width * b.boundingBox.height;
      return areaA > areaB ? a : b;
    });
  }

  InputImage? _convertImage(CameraImage image) {
    final camera = _controller?.description;
    if (camera == null) return null;
    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;
    final format = image.format.group == ImageFormatGroup.yuv420 ? InputImageFormat.yuv420 : InputImageFormat.bgra8888;
    
    try {
      final bytes = _concatenatePlanes(image.planes);
      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  bool get _showRedEffect => _state == DrowsyState.drowsyActive || _state == DrowsyState.drowsyHold || _isAccidentActive;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Drowsiness Detection", style: TextStyle(color: Colors.cyanAccent)),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatBox('Drowsy', _drowsyCount.toString(), '👁️'),
                  _buildStatBox('Yawns', _yawnCount.toString(), '🥱'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Stack(
                  children: [
                    if (_showRedEffect)
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) => Container(
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withValues(alpha: 0.6 + _glowAnimation.value * 0.4),
                                  blurRadius: 10 + (_glowAnimation.value * 20),
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.cyanAccent, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (_cameraInitialized && _controller != null)
                              CameraPreview(_controller!)
                            else
                              const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
                            
                            AnimatedBuilder(
                              animation: _pulse,
                              builder: (context, child) => Container(
                                color: Colors.redAccent.withValues(alpha: _showRedEffect ? (0.15 + _pulse.value * 0.25) : 0.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Accident Alert Overlay
              ScaleTransition(
                scale: _accidentScaleAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.5), blurRadius: 15)],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "ACCIDENT DETECTED",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              // PERMANENT Nearest Rest Areas Button at the bottom
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MapScreen()),
                    );
                  },
                  icon: const Icon(Icons.map),
                  label: const Text("Find Nearest Rest Area", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),

              if (!_isAccidentActive && _state == DrowsyState.normal)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.speed, color: Colors.cyanAccent, size: 14),
                      SizedBox(width: 8),
                      Text(
                        "G-Force Monitoring Active",
                        style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _status.contains("ACCIDENT") ? Colors.redAccent : (_showRedEffect ? Colors.redAccent : Colors.cyanAccent),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          Positioned(
            top: 10,
            right: 20,
            child: _buildChatbotIcon(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatbotIcon() {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _isBotSpeaking ? Colors.redAccent : Colors.cyanAccent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (_isBotSpeaking ? Colors.redAccent : Colors.cyanAccent).withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.black87,
                child: Icon(
                  Icons.face_retouching_natural,
                  color: _isBotSpeaking ? Colors.redAccent : Colors.cyanAccent,
                  size: 40,
                ),
              ),
              if (_isBotSpeaking)
                AnimatedBuilder(
                  animation: _botMouthAnimation,
                  builder: (context, child) {
                    return Positioned(
                      bottom: 22,
                      child: Container(
                        width: 12 + (_botMouthAnimation.value * 8),
                        height: 4 + (_botMouthAnimation.value * 6),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _isBotSpeaking ? "SPEAKING" : "ACTIVE",
          style: TextStyle(
            color: _isBotSpeaking ? Colors.redAccent : Colors.cyanAccent,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, String emoji) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.cyanAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          Text(value, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.cyanAccent, fontSize: 10)),
        ],
      ),
    );
  }
}
