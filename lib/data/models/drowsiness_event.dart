import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';

part 'drowsiness_event.g.dart';

/// Model class for storing drowsiness detection events
@HiveType(typeId: 2)
class DrowsinessEvent extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String severity; // 'low', 'medium', 'high', 'critical'

  @HiveField(3)
  final double confidence;

  @HiveField(4)
  final Duration duration;

  @HiveField(5)
  final Position? location;

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final String? actionTaken;

  DrowsinessEvent({
    required this.id,
    required this.timestamp,
    required this.severity,
    required this.confidence,
    this.duration = Duration.zero,
    this.location,
    this.notes,
    this.actionTaken,
  });

  /// Factory constructor to create DrowsinessEvent from JSON
  factory DrowsinessEvent.fromJson(Map<String, dynamic> json) {
    Position? location;
    if (json['location'] != null) {
      final locationData = json['location'] as Map<String, dynamic>;
      location = Position(
        latitude: locationData['latitude'],
        longitude: locationData['longitude'],
        timestamp: DateTime.parse(locationData['timestamp']),
        accuracy: locationData['accuracy'],
        altitude: locationData['altitude'],
        heading: locationData['heading'],
        speed: locationData['speed'],
        speedAccuracy: locationData['speedAccuracy'],
        altitudeAccuracy: locationData['altitudeAccuracy'],
        headingAccuracy: locationData['headingAccuracy'],
      );
    }

    return DrowsinessEvent(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      severity: json['severity'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      duration: Duration(milliseconds: json['duration'] as int? ?? 0),
      location: location,
      notes: json['notes'] as String?,
      actionTaken: json['actionTaken'] as String?,
    );
  }

  /// Convert DrowsinessEvent to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity,
      'confidence': confidence,
      'duration': duration.inMilliseconds,
      'location': location != null ? {
        'latitude': location!.latitude,
        'longitude': location!.longitude,
        'timestamp': location!.timestamp.toIso8601String(),
        'accuracy': location!.accuracy,
        'altitude': location!.altitude,
        'heading': location!.heading,
        'speed': location!.speed,
        'speedAccuracy': location!.speedAccuracy,
        'altitudeAccuracy': location!.altitudeAccuracy,
        'headingAccuracy': location!.headingAccuracy,
      } : null,
      'notes': notes,
      'actionTaken': actionTaken,
    };
  }

  /// Get formatted timestamp string
  String get formattedTimestamp {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} '
           '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  /// Get severity description
  String get severityDescription {
    switch (severity) {
      case 'low':
        return 'Low Risk';
      case 'medium':
        return 'Medium Risk';
      case 'high':
        return 'High Risk';
      case 'critical':
        return 'Critical';
      default:
        return 'Unknown';
    }
  }

  /// Get severity color based on severity level
  int get severityColor {
    switch (severity) {
      case 'low':
        return 0xFF00FF00; // Green
      case 'medium':
        return 0xFFFFFF00; // Yellow
      case 'high':
        return 0xFFFF8800; // Orange
      case 'critical':
        return 0xFFFF0040; // Red
      default:
        return 0xFF808080; // Gray
    }
  }

  /// Check if this event requires emergency action
  bool get requiresEmergencyAction {
    return severity == 'critical' || confidence > 0.8;
  }

  @override
  String toString() {
    return 'DrowsinessEvent{'
           'id: $id, '
           'timestamp: $timestamp, '
           'severity: $severityDescription, '
           'confidence: ${(confidence * 100).toStringAsFixed(1)}%'
           '}';
  }

  /// Create a copy of this event with updated fields
  DrowsinessEvent copyWith({
    String? id,
    DateTime? timestamp,
    String? severity,
    double? confidence,
    Duration? duration,
    Position? location,
    String? notes,
    String? actionTaken,
  }) {
    return DrowsinessEvent(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      confidence: confidence ?? this.confidence,
      duration: duration ?? this.duration,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      actionTaken: actionTaken ?? this.actionTaken,
    );
  }
}