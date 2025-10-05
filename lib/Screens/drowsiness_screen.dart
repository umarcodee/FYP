import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for WriteBuffer
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

class DrowsinessScreen extends StatefulWidget {
  const DrowsinessScreen({Key? key}) : super(key: key);

  @override
  State<DrowsinessScreen> createState() => _DrowsinessScreenState();
}

class _DrowsinessScreenState extends State<DrowsinessScreen> {
  CameraController? _controller;
  late FaceDetector _faceDetector;
  bool _isProcessing = false;
  bool _isDetecting = false;
  bool _isDrowsy = false;
  String _status = "Tap Start to begin detection";
  Timer? _alertTimer;
  int _closedEyesFrameCount = 0;
  bool _cameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initFaceDetector();
  }

  @override
  void dispose() {
    _stopCamera();
    _faceDetector.close();
    super.dispose();
  }

  void _initFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableClassification: true, // Enable eye open/closed classification
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
  }

  Future<void> _startCamera() async {
    setState(() {
      _status = "Initializing...";
    });

    // Request camera permission
    final status = await Permission.camera.request();
    if (status.isDenied) {
      setState(() {
        _status = "Camera permission denied";
      });
      return;
    }

    // Get available cameras
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() {
        _status = "No cameras available";
      });
      return;
    }

    // Select front camera
    final camera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    // Initialize controller with lowest resolution for better performance
    _controller = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.yuv420 // Better for ML Kit on Android
          : ImageFormatGroup.bgra8888, // For iOS
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;

      _cameraInitialized = true;

      // Start image stream with error handling
      await _controller!.startImageStream(_processImage);

      setState(() {
        _isDetecting = true;
        _status = "Detecting...";
      });
    } catch (e) {
      setState(() {
        _status = "Camera error: ${e.toString().split('\n').first}";
      });
      print("Camera error: $e");
    }
  }

  void _stopCamera() {
    _alertTimer?.cancel();

    if (_controller != null) {
      if (_controller!.value.isStreamingImages) {
        _controller!.stopImageStream();
      }
      _controller!.dispose();
      _controller = null;
    }

    setState(() {
      _isDetecting = false;
      _cameraInitialized = false;
      _status = "Tap Start to begin detection";
      _isDrowsy = false;
      _closedEyesFrameCount = 0;
    });
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isProcessing || !mounted) return;
    _isProcessing = true;

    try {
      final inputImage = _convertCameraImageToInputImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);

      if (!mounted || !_isDetecting) {
        _isProcessing = false;
        return;
      }

      // Update UI based on face detection results
      if (faces.isEmpty) {
        if (mounted) {
          setState(() {
            _status = "No face detected";
            _isDrowsy = false;
          });
        }
        _closedEyesFrameCount = 0;
      } else {
        final face = faces.first;
        final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
        final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;

        // Check for drowsiness - eyes closed for multiple consecutive frames
        if (leftEyeOpen < 0.3 && rightEyeOpen < 0.3) {
          _closedEyesFrameCount++;

          // If eyes closed for more than 10 frames (about 1-2 seconds), consider drowsy
          if (_closedEyesFrameCount > 10) {
            if (mounted) {
              setState(() {
                _status = "Drowsy detected! Eyes closed.";
                _isDrowsy = true;
              });
            }
            _playAlert();
          }
        } else {
          _closedEyesFrameCount = 0;
          if (mounted) {
            setState(() {
              _status = "Eyes open - All good!";
              _isDrowsy = false;
            });
          }
          _alertTimer?.cancel();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = "Processing error: ${e.toString().split('\n').first}";
        });
      }
      print("ML processing error: $e");
    }

    _isProcessing = false;
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    final camera = _controller?.description;
    if (camera == null) return null;

    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
        InputImageRotation.rotation0deg;

    // Handle different formats based on platform
    InputImageFormat? format;
    if (image.format.group == ImageFormatGroup.yuv420) {
      format = InputImageFormat.yuv420;
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      format = InputImageFormat.bgra8888;
    } else if (image.format.group == ImageFormatGroup.jpeg) {
      format = InputImageFormat.yuv420; // Best approximation for JPEG in ML Kit
    }

    if (format == null) return null;

    // Construct plane data
    try {
      if (Platform.isAndroid) {
        // For Android YUV420 format (most common for ML Kit on Android)
        final bytes = _concatenatePlanes(image.planes);

        final inputImageMetadata = InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes[0].bytesPerRow,
        );

        return InputImage.fromBytes(
          bytes: bytes,
          metadata: inputImageMetadata,
        );
      } else {
        // For iOS BGRA format
        final bytes = _concatenatePlanes(image.planes);

        final inputImageMetadata = InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes[0].bytesPerRow,
        );

        return InputImage.fromBytes(
          bytes: bytes,
          metadata: inputImageMetadata,
        );
      }
    } catch (e) {
      print("Error converting image: $e");
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

  void _playAlert() {
    if (_alertTimer?.isActive ?? false) return;
    _alertTimer = Timer(const Duration(seconds: 2), () {
      // Here you could add vibration or sound alert
      // You would need to add packages like flutter_vibrate or audioplayers
    });
  }

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 28),
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.cyanAccent, width: 2),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.24),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _cameraInitialized && _controller != null && _controller!.value.isInitialized
                    ? CameraPreview(_controller!)
                    : Center(
                  child: _isDetecting
                      ? const CircularProgressIndicator(color: Colors.cyanAccent)
                      : const Icon(
                    Icons.camera_alt,
                    color: Colors.cyanAccent,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              _status,
              style: TextStyle(
                color: _isDrowsy ? Colors.redAccent : Colors.cyanAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: _isDrowsy
                        ? Colors.redAccent.withOpacity(0.15)
                        : Colors.cyanAccent.withOpacity(0.15),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: _isDetecting ? _stopCamera : _startCamera,
              child: Container(
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 36),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                      color:
                      _isDetecting ? Colors.redAccent : Colors.cyanAccent,
                      width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: (_isDetecting
                          ? Colors.redAccent
                          : Colors.cyanAccent)
                          .withOpacity(0.4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Text(
                  _isDetecting ? "Stop Detection" : "Start Detection",
                  style: TextStyle(
                    color: _isDetecting ? Colors.redAccent : Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 42),
        ],
      ),
    );
  }
}