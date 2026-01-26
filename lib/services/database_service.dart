import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/detection_models.dart';

/// Hive Database Service - Local Storage
class DatabaseService {
  static const String eventsBoxName = 'detection_events';

  late Box<DetectionEvent> _eventsBox;

  /// Initialize Hive Database
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      // Register adapter for DetectionEvent
      if (! Hive.isAdapterRegistered(0)) {
        Hive. registerAdapter(DetectionEventAdapter());
      }

      // Open box
      _eventsBox = await Hive.openBox<DetectionEvent>(eventsBoxName);
      debugPrint('✅ Database initialized successfully');
    } catch (e) {
      debugPrint('❌ Database init error: $e');
      rethrow;
    }
  }

  /// Add detection event to database
  Future<void> addEvent(DetectionEvent event) async {
    try {
      await _eventsBox.add(event);
      debugPrint('✅ Event saved: ${event.eventType} at ${event.formattedTime}');
    } catch (e) {
      debugPrint('❌ Error saving event: $e');
    }
  }

  /// Get all events
  List<DetectionEvent> getAllEvents() {
    try {
      return _eventsBox.values.toList();
    } catch (e) {
      debugPrint('❌ Error getting all events: $e');
      return [];
    }
  }

  /// Get today's events
  List<DetectionEvent> getTodayEvents() {
    try {
      final today = DateTime.now();
      return _eventsBox.values.where((event) {
        return event.timestamp.year == today.year &&
            event.timestamp.month == today. month &&
            event.timestamp. day == today.day;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting today events: $e');
      return [];
    }
  }

  /// Count events by type (today)
  Map<String, int> countEventsByType() {
    try {
      final events = getTodayEvents();
      return {
        'drowsy': events.where((e) => e.eventType == 'drowsy').length,
        'yawn': events.where((e) => e.eventType == 'yawn').length,
        'alert': events.where((e) => e.eventType == 'alert').length,
      };
    } catch (e) {
      debugPrint('❌ Error counting events: $e');
      return {'drowsy': 0, 'yawn': 0, 'alert': 0};
    }
  }

  /// Get last N events
  List<DetectionEvent> getLastEvents(int count) {
    try {
      final all = getAllEvents();
      all.sort((a, b) => b.timestamp.compareTo(a. timestamp));
      return all.take(count).toList();
    } catch (e) {
      debugPrint('❌ Error getting last events: $e');
      return [];
    }
  }

  /// Get statistics for today
  Future<Map<String, dynamic>> getTodayStats() async {
    try {
      final events = getTodayEvents();
      final eventsByType = countEventsByType();

      return {
        'totalEvents': events.length,
        'drowsyCount': eventsByType['drowsy'] ?? 0,
        'yawnCount': eventsByType['yawn'] ?? 0,
        'alertCount': eventsByType['alert'] ?? 0,
        'lastUpdated': DateTime.now(),
      };
    } catch (e) {
      debugPrint('❌ Error getting stats: $e');
      return {};
    }
  }

  /// Clear all events
  Future<void> clearAllEvents() async {
    try {
      await _eventsBox. clear();
      debugPrint('✅ All events cleared');
    } catch (e) {
      debugPrint('❌ Error clearing events: $e');
    }
  }

  /// Dispose/Close database
  Future<void> dispose() async {
    try {
      await Hive.close();
      debugPrint('✅ Database closed');
    } catch (e) {
      debugPrint('❌ Error closing database: $e');
    }
  }
}