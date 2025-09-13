import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Overlay widget for detection screen showing face detection status
class DetectionOverlay extends StatefulWidget {
  final DrowsinessState drowsinessState;
  final double confidence;
  final bool isMonitoring;
  final DetectionType? detectionType;

  const DetectionOverlay({
    super.key,
    required this.drowsinessState,
    required this.confidence,
    required this.isMonitoring,
    this.detectionType,
  });

  @override
  State<DetectionOverlay> createState() => _DetectionOverlayState();
}

class _DetectionOverlayState extends State<DetectionOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scanlineController;
  late AnimationController _alertPulseController;
  late Animation<double> _scanlineAnimation;

  @override
  void initState() {
    super.initState();
    
    _scanlineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _alertPulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scanlineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanlineController,
      curve: Curves.easeInOut,
    ));

    _updateAlertAnimation();
  }

  @override
  void didUpdateWidget(DetectionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drowsinessState != widget.drowsinessState) {
      _updateAlertAnimation();
    }
  }

  void _updateAlertAnimation() {
    if (widget.drowsinessState == DrowsinessState.alert ||
        widget.drowsinessState == DrowsinessState.critical) {
      _alertPulseController.repeat(reverse: true);
    } else {
      _alertPulseController.stop();
      _alertPulseController.reset();
    }
  }

  @override
  void dispose() {
    _scanlineController.dispose();
    _alertPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Face detection frame
        _buildDetectionFrame(),
        
        // Scanning animation
        if (widget.isMonitoring) _buildScanningAnimation(),
        
        // Detection info overlay
        _buildInfoOverlay(),
        
        // Alert overlay
        if (widget.drowsinessState != DrowsinessState.normal)
          _buildAlertOverlay(),
      ],
    );
  }

  Widget _buildDetectionFrame() {
    final frameColor = _getFrameColor();
    
    return Center(
      child: Container(
        width: 280,
        height: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: frameColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: frameColor.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Corner indicators
            ..._buildCornerIndicators(frameColor),
            
            // Center crosshair
            if (widget.isMonitoring)
              Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(color: frameColor, width: 2),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerIndicators(Color color) {
    return [
      // Top-left corner
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: 4),
              left: BorderSide(color: color, width: 4),
            ),
          ),
        ),
      ),
      
      // Top-right corner
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: 4),
              right: BorderSide(color: color, width: 4),
            ),
          ),
        ),
      ),
      
      // Bottom-left corner
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: 4),
              left: BorderSide(color: color, width: 4),
            ),
          ),
        ),
      ),
      
      // Bottom-right corner
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: 4),
              right: BorderSide(color: color, width: 4),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildScanningAnimation() {
    return Center(
      child: SizedBox(
        width: 280,
        height: 350,
        child: AnimatedBuilder(
          animation: _scanlineAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                // Horizontal scanline
                Positioned(
                  top: _scanlineAnimation.value * 320 + 15,
                  left: 15,
                  right: 15,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          _getFrameColor(),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getFrameColor().withOpacity(0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Vertical scanline
                Positioned(
                  left: _scanlineAnimation.value * 250 + 15,
                  top: 15,
                  bottom: 15,
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          _getFrameColor(),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getFrameColor().withOpacity(0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoOverlay() {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Column(
        children: [
          // Detection status
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingMedium,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: _getFrameColor().withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getStatusIcon(),
                      color: _getFrameColor(),
                      size: AppConstants.iconSize,
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Text(
                      _getStatusText(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                if (widget.confidence > 0) ...[
                  const SizedBox(height: AppConstants.paddingSmall),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Confidence: ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '${(widget.confidence * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getFrameColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                
                if (widget.detectionType != null) ...[
                  const SizedBox(height: AppConstants.paddingSmall),
                  
                  Text(
                    'Type: ${_getDetectionTypeText()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertOverlay() {
    return AnimatedBuilder(
      animation: _alertPulseController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _getFrameColor().withOpacity(
              0.1 + (_alertPulseController.value * 0.2)
            ),
          ),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(AppConstants.paddingXLarge),
              padding: const EdgeInsets.all(AppConstants.paddingXLarge),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: _getFrameColor(),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getFrameColor().withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning,
                    color: _getFrameColor(),
                    size: 60,
                  ).animate().shake(duration: 600.ms),
                  
                  const SizedBox(height: AppConstants.paddingLarge),
                  
                  Text(
                    _getAlertTitle(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: _getFrameColor(),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: AppConstants.paddingMedium),
                  
                  Text(
                    _getAlertMessage(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getFrameColor() {
    switch (widget.drowsinessState) {
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

  IconData _getStatusIcon() {
    switch (widget.drowsinessState) {
      case DrowsinessState.normal:
        return Icons.visibility;
      case DrowsinessState.drowsy:
        return Icons.warning_amber;
      case DrowsinessState.alert:
        return Icons.error_outline;
      case DrowsinessState.critical:
        return Icons.crisis_alert;
    }
  }

  String _getStatusText() {
    switch (widget.drowsinessState) {
      case DrowsinessState.normal:
        return 'MONITORING ACTIVE';
      case DrowsinessState.drowsy:
        return 'DROWSINESS DETECTED';
      case DrowsinessState.alert:
        return 'HIGH ALERT';
      case DrowsinessState.critical:
        return 'CRITICAL ALERT';
    }
  }

  String _getDetectionTypeText() {
    switch (widget.detectionType) {
      case DetectionType.eyesClosed:
        return 'Eyes Closed';
      case DetectionType.yawning:
        return 'Yawning';
      case DetectionType.headNodding:
        return 'Head Nodding';
      case DetectionType.faceNotDetected:
        return 'Face Not Detected';
      case null:
        return 'Normal';
    }
  }

  String _getAlertTitle() {
    switch (widget.drowsinessState) {
      case DrowsinessState.drowsy:
        return 'DROWSINESS DETECTED';
      case DrowsinessState.alert:
        return 'ALERT: TAKE ACTION';
      case DrowsinessState.critical:
        return 'CRITICAL: STOP NOW';
      case DrowsinessState.normal:
        return '';
    }
  }

  String _getAlertMessage() {
    switch (widget.drowsinessState) {
      case DrowsinessState.drowsy:
        return 'You appear to be getting drowsy. Consider taking a break soon.';
      case DrowsinessState.alert:
        return 'Significant drowsiness detected. Please find a safe place to rest.';
      case DrowsinessState.critical:
        return 'DANGER: Critical drowsiness level. Pull over immediately!';
      case DrowsinessState.normal:
        return '';
    }
  }
}