import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// Status card widget displaying current drowsiness detection status
class StatusCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final DrowsinessState status;
  final double confidence;

  const StatusCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    this.confidence = 0.0,
  });

  @override
  State<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Start pulsing animation for alert states
    if (_shouldPulse()) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(StatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (_shouldPulse() && !_pulseController.isAnimating) {
      _pulseController.repeat();
    } else if (!_shouldPulse() && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool _shouldPulse() {
    return widget.status == DrowsinessState.drowsy ||
           widget.status == DrowsinessState.alert ||
           widget.status == DrowsinessState.critical;
  }

  Color _getStatusColor() {
    switch (widget.status) {
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
    switch (widget.status) {
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
    switch (widget.status) {
      case DrowsinessState.normal:
        return 'Normal';
      case DrowsinessState.drowsy:
        return 'Drowsy';
      case DrowsinessState.alert:
        return 'Alert';
      case DrowsinessState.critical:
        return 'Critical';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseValue = _shouldPulse() ? _pulseController.value : 0.0;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.paddingXLarge),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkCard,
                AppTheme.darkCard.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius + 4),
            border: Border.all(
              color: statusColor.withOpacity(0.5 + (pulseValue * 0.3)),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.2 + (pulseValue * 0.2)),
                blurRadius: 15 + (pulseValue * 10),
                spreadRadius: 2 + (pulseValue * 3),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with status indicator
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingSmall),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: statusColor,
                      size: AppConstants.largeIconSize,
                    ),
                  ),
                  
                  const SizedBox(width: AppConstants.paddingMedium),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          widget.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                      vertical: AppConstants.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      _getStatusText().toUpperCase(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Confidence indicator (only show if confidence > 0)
              if (widget.confidence > 0) ...[
                const SizedBox(height: AppConstants.paddingLarge),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Confidence Level',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${(widget.confidence * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.paddingSmall),
                    
                    // Confidence progress bar
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: widget.confidence.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                statusColor.withOpacity(0.7),
                                statusColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.4),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Additional status information
              if (widget.status != DrowsinessState.normal) ...[
                const SizedBox(height: AppConstants.paddingLarge),
                
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: statusColor,
                        size: AppConstants.iconSize,
                      ),
                      
                      const SizedBox(width: AppConstants.paddingSmall),
                      
                      Expanded(
                        child: Text(
                          _getStatusMessage(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _getStatusMessage() {
    switch (widget.status) {
      case DrowsinessState.normal:
        return 'All systems monitoring normally.';
      case DrowsinessState.drowsy:
        return 'Drowsiness detected. Consider taking a break.';
      case DrowsinessState.alert:
        return 'Alert level increased. Please find a safe place to rest.';
      case DrowsinessState.critical:
        return 'CRITICAL: Immediate action required. Pull over safely now.';
    }
  }
}