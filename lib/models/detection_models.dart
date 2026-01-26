import 'package:hive/hive.dart';

part 'detection_models.g.dart';

/// Drowsiness Detection States
enum DrowsyState { normal, drowsyActive, drowsyHold }

/// Yawn Detection States
enum YawnState { normal, yawning, yawnDetected }

/// Detection Event Model (Hive)
@HiveType(typeId: 0)
class DetectionEvent extends HiveObject {
  @HiveField(0)
  late DateTime timestamp;

  @HiveField(1)
  late String eventType;

  @HiveField(2)
  late int durationMs;

  @HiveField(3)
  double?  confidenceScore;

  DetectionEvent({
    required this.timestamp,
    required this.eventType,
    required this.durationMs,
    this.confidenceScore,
  });

  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp. minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString(). padLeft(2, '0');
    return "$h:$m:$s";
  }

  String get eventEmoji {
    switch (eventType) {
      case 'drowsy':
        return '👁️';
      case 'yawn':
        return '😴';
      case 'alert':
        return '🚨';
      default:
        return '📍';
    }
  }
}

/// Driving Session Model
class DrivingSession {
  DateTime startTime;
  DateTime endTime;
  int drowsyCount;
  int yawnCount;
  List<DetectionEvent> events;

  DrivingSession({
    required this.startTime,
    required this.endTime,
    required this.drowsyCount,
    required this. yawnCount,
    required this.events,
  });

  int get durationMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  String get formattedDuration {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return "$h:${m.toString().padLeft(2, '0')}";
  }
}