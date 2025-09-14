import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../providers/drowsiness_provider.dart';
import '../widgets/neon_button.dart';
import '../widgets/detection_overlay.dart';

/// Real-time drowsiness detection screen with camera preview
class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> 
    with TickerProviderStateMixin {
  late AnimationController _alertController;
  late AnimationController _pulseController;
  bool _showingAlert = false;

  @override
  void initState() {
    super.initState();
    
    _alertController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    // Listen to drowsiness events
    _listenToEvents();
  }

  @override
  void dispose() {
    _alertController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _listenToEvents() {
    final drowsinessProvider = Provider.of<DrowsinessProvider>(context, listen: false);
    
    drowsinessProvider.eventStream.listen((event) {
      if (mounted) {
        _handleDrowsinessEvent(event);
      }
    });
  }

  void _handleDrowsinessEvent(event) {
    if (event.drowsinessLevel == DrowsinessState.critical ||
        event.drowsinessLevel == DrowsinessState.alert) {
      _showAlertOverlay(event);
    }
  }

  void _showAlertOverlay(event) {
    setState(() => _showingAlert = true);
    _alertController.forward();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          side: BorderSide(color: AppTheme.dangerNeon, width: 2),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: AppTheme.dangerNeon,
              size: AppConstants.largeIconSize,
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Text(
              'DROWSINESS DETECTED',
              style: TextStyle(
                color: AppTheme.dangerNeon,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You appear to be drowsy. This is dangerous while driving.',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            Text(
              'What would you like to do?',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          NeonOutlineButton(
            text: 'Dismiss',
            color: Colors.grey,
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _showingAlert = false);
              _alertController.reverse();
            },
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          NeonButton(
            text: 'Get Help',
            gradient: const LinearGradient(
              colors: [AppTheme.primaryNeon, AppTheme.accentNeon],
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(
                context,
                AppRoutes.chatbot,
                arguments: {'isEmergency': true},
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Consumer<DrowsinessProvider>(
        builder: (context, provider, child) {
          if (!provider.isInitialized) {
            return _buildInitializingScreen();
          }
          
          if (provider.cameraController == null || 
              !provider.cameraController!.value.isInitialized) {
            return _buildCameraErrorScreen();
          }
          
          return _buildDetectionScreen(provider);
        },
      ),
    );
  }

  Widget _buildInitializingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.darkBg, Color(0xFF1A1A2E)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                color: AppTheme.primaryNeon,
                strokeWidth: 4,
              ),
            ).animate().scale(duration: 800.ms),
            
            const SizedBox(height: AppConstants.paddingXLarge),
            
            Text(
              'Initializing AI Detection...',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.primaryNeon,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            Text(
              'Please wait while we set up the camera\nand machine learning models',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraErrorScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.darkBg, Color(0xFF2A1A1A)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingXLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                color: AppTheme.dangerNeon,
                size: 80,
              ).animate().shake(duration: 800.ms),
              
              const SizedBox(height: AppConstants.paddingXLarge),
              
              Text(
                'Camera Access Required',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.dangerNeon,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppConstants.paddingMedium),
              
              Text(
                'Drowsiness detection requires camera access to analyze your facial expressions and eye movements.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingXLarge),
              
              NeonButton(
                text: 'Retry Camera Setup',
                icon: Icons.refresh,
                onPressed: () async {
                  try {
                    final provider = Provider.of<DrowsinessProvider>(context, listen: false);
                    await provider.initialize();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error initializing camera: $e'),
                          backgroundColor: AppTheme.dangerNeon,
                        ),
                      );
                    }
                  }
                },
              ),
              
              const SizedBox(height: AppConstants.paddingMedium),
              
              NeonOutlineButton(
                text: 'Go Back',
                color: Colors.grey,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetectionScreen(DrowsinessProvider provider) {
    final cameraController = provider.cameraController!;
    
    return Stack(
      children: [
        // Camera preview (full screen)
        Positioned.fill(
          child: AspectRatio(
            aspectRatio: cameraController.value.aspectRatio,
            child: CameraPreview(cameraController),
          ),
        ),
        
        // Detection overlay
        DetectionOverlay(
          drowsinessState: provider.currentState,
          confidence: provider.currentConfidence,
          isMonitoring: provider.isMonitoring,
          detectionType: provider.lastDetectionType,
        ),
        
        // Top controls
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Row(
                  children: [
                    NeonIconButton(
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.pop(context),
                      color: Colors.white,
                    ),
                    
                    const Spacer(),
                    
                    // Status indicator
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingMedium,
                            vertical: AppConstants.paddingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(provider.currentState)
                                .withOpacity(0.2 + (_pulseController.value * 0.3)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(provider.currentState),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getStatusColor(provider.currentState),
                                ),
                              ),
                              const SizedBox(width: AppConstants.paddingSmall),
                              Text(
                                provider.statusMessage,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const Spacer(),
                    
                    NeonIconButton(
                      icon: Icons.chat,
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.chatbot),
                      color: AppTheme.primaryNeon,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    NeonIconButton(
                      icon: Icons.map,
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.maps),
                      tooltip: 'Find Places',
                    ),
                    
                    // Stop button
                    GestureDetector(
                      onTap: () async {
                        await provider.stopMonitoring();
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppTheme.dangerNeon, Colors.red],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.dangerNeon.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.stop,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ).animate().scale(duration: 200.ms),
                    
                    NeonIconButton(
                      icon: Icons.emergency,
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.emergency),
                      color: AppTheme.dangerNeon,
                      tooltip: 'Emergency',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(DrowsinessState state) {
    switch (state) {
      case DrowsinessState.normal:
        return AppTheme.accentNeon;
      case DrowsinessState.drowsy:
        return AppTheme.warningNeon;
      case DrowsinessState.alert:
        return Colors.orange;
      case DrowsinessState.critical:
        return AppTheme.dangerNeon;
    }
  }
}