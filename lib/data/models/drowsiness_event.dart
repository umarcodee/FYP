import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';

part 'drowsiness_event.g.dart';

/// Model class for storing drowsiness detection events
@HiveType(typeId: 0)
class DrowsinessEvent extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final DetectionType detectionType;

  @HiveField(3)
  final DrowsinessState drowsinessLevel;

  @HiveField(4)
  final double confidenceScore;

  @HiveField(5)
  final String? location;

  @HiveField(6)
  final double? latitude;

  @HiveField(7)
  final double? longitude;

  @HiveField(8)
  final Duration duration;

  @HiveField(9)
  final bool emergencyTriggered;

  @HiveField(10)
  final String? notes;

  DrowsinessEvent({
    required this.id,
    required this.timestamp,
    required this.detectionType,
    required this.drowsinessLevel,
    required this.confidenceScore,
    this.location,
    this.latitude,
    this.longitude,
    this.duration = Duration.zero,
    this.emergencyTriggered = false,
    this.notes,
  });

  /// Factory constructor to create DrowsinessEvent from JSON
  factory DrowsinessEvent.fromJson(Map<String, dynamic> json) {
    return DrowsinessEvent(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      detectionType: DetectionType.values[json['detectionType'] as int],
      drowsinessLevel: DrowsinessState.values[json['drowsinessLevel'] as int],
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      location: json['location'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      duration: Duration(milliseconds: json['duration'] as int? ?? 0),
      emergencyTriggered: json['emergencyTriggered'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  /// Convert DrowsinessEvent to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'detectionType': detectionType.index,
      'drowsinessLevel': drowsinessLevel.index,
      'confidenceScore': confidenceScore,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'duration': duration.inMilliseconds,
      'emergencyTriggered': emergencyTriggered,
      'notes': notes,
    };
  }

  /// Get formatted timestamp string
  String get formattedTimestamp {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} '
           '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  /// Get detection type description
  String get detectionTypeDescription {
    switch (detectionType) {
      case DetectionType.eyesClosed:
        return 'Eyes Closed';
      case DetectionType.yawning:
        return 'Yawning';
      case DetectionType.headNodding:
        return 'Head Nodding';
      case DetectionType.faceNotDetected:
        return 'Face Not Detected';
    }
  }

  /// Get drowsiness level description
  String get drowsinessLevelDescription {
    switch (drowsinessLevel) {
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

  /// Get severity color based on drowsiness level
  int get severityColor {
    switch (drowsinessLevel) {
      case DrowsinessState.normal:
        return 0xFF00FF00; // Green
      case DrowsinessState.drowsy:
        return 0xFFFFFF00; // Yellow
      case DrowsinessState.alert:
        return 0xFFFF8800; // Orange
      case DrowsinessState.critical:
        return 0xFFFF0040; // Red
    }
  }

  /// Check if this event requires emergency action
  bool get requiresEmergencyAction {
    return drowsinessLevel == DrowsinessState.critical || 
           emergencyTriggered ||
           confidenceScore > 0.8;
  }

  @override
  String toString() {
    return 'DrowsinessEvent{'
           'id: $id, '
           'timestamp: $timestamp, '
           'type: $detectionTypeDescription, '
           'level: $drowsinessLevelDescription, '
           'confidence: ${(confidenceScore * 100).toStringAsFixed(1)}%'
           '}';
  }

  /// Create a copy of this event with updated fields
  DrowsinessEvent copyWith({
    String? id,
    DateTime? timestamp,
    DetectionType? detectionType,
    DrowsinessState? drowsinessLevel,
    double? confidenceScore,
    String? location,
    double? latitude,
    double? longitude,
    Duration? duration,
    bool? emergencyTriggered,
    String? notes,
  }) {
    return DrowsinessEvent(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      detectionType: detectionType ?? this.detectionType,
      drowsinessLevel: drowsinessLevel ?? this.drowsinessLevel,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      duration: duration ?? this.duration,
      emergencyTriggered: emergencyTriggered ?? this.emergencyTriggered,
      notes: notes ?? this.notes,
    );
  }
}