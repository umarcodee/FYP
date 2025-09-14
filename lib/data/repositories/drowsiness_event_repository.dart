import 'package:hive/hive.dart';
import '../models/drowsiness_event.dart';

/// Repository for managing drowsiness events in local storage
class DrowsinessEventRepository {
  static const String _boxName = 'drowsiness_events';
  late Box<DrowsinessEvent> _box;

  /// Initialize the repository
  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<DrowsinessEvent>(_boxName);
    } else {
      _box = Hive.box<DrowsinessEvent>(_boxName);
    }
  }

  /// Add a new drowsiness event
  Future<void> addEvent(DrowsinessEvent event) async {
    await _box.put(event.id, event);
  }

  /// Update an existing drowsiness event
  Future<void> updateEvent(DrowsinessEvent event) async {
    await _box.put(event.id, event);
  }

  /// Delete a drowsiness event
  Future<void> deleteEvent(String eventId) async {
    await _box.delete(eventId);
  }

  /// Get a specific drowsiness event by ID
  DrowsinessEvent? getEvent(String eventId) {
    return _box.get(eventId);
  }

  /// Get all drowsiness events
  List<DrowsinessEvent> getAllEvents() {
    return _box.values.toList();
  }

  /// Get events sorted by date (newest first)
  List<DrowsinessEvent> getEventsSortedByDate() {
    final events = getAllEvents();
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events;
  }

  /// Get events by severity level
  List<DrowsinessEvent> getEventsBySeverity(String severity) {
    return _box.values.where((event) => event.severity == severity).toList();
  }

  /// Get events within a date range
  List<DrowsinessEvent> getEventsByDateRange(DateTime startDate, DateTime endDate) {
    return _box.values.where((event) {
      return event.timestamp.isAfter(startDate) && event.timestamp.isBefore(endDate);
    }).toList();
  }

  /// Get recent events (last N events)
  List<DrowsinessEvent> getRecentEvents({int limit = 10}) {
    final events = getEventsSortedByDate();
    return events.take(limit).toList();
  }

  /// Get events from today
  List<DrowsinessEvent> getTodayEvents() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return getEventsByDateRange(startOfDay, endOfDay);
  }

  /// Get events from this week
  List<DrowsinessEvent> getThisWeekEvents() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeek = startOfWeekDay.add(const Duration(days: 7));
    
    return getEventsByDateRange(startOfWeekDay, endOfWeek);
  }

  /// Get events from this month
  List<DrowsinessEvent> getThisMonthEvents() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);
    
    return getEventsByDateRange(startOfMonth, endOfMonth);
  }

  /// Get statistics for a date range
  Map<String, dynamic> getEventStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    List<DrowsinessEvent> events;
    
    if (startDate != null && endDate != null) {
      events = getEventsByDateRange(startDate, endDate);
    } else {
      events = getAllEvents();
    }

    final totalEvents = events.length;
    final severityCounts = <String, int>{};
    double totalConfidence = 0.0;
    
    for (final event in events) {
      severityCounts[event.severity] = (severityCounts[event.severity] ?? 0) + 1;
      totalConfidence += event.confidence;
    }

    final avgConfidence = totalEvents > 0 ? totalConfidence / totalEvents : 0.0;

    return {
      'totalEvents': totalEvents,
      'severityCounts': severityCounts,
      'averageConfidence': avgConfidence,
      'dateRange': {
        'start': startDate?.toIso8601String(),
        'end': endDate?.toIso8601String(),
      },
    };
  }

  /// Get daily statistics for the past N days
  List<Map<String, dynamic>> getDailyStatistics({int days = 7}) {
    final now = DateTime.now();
    final statistics = <Map<String, dynamic>>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final dayEvents = getEventsByDateRange(startOfDay, endOfDay);
      final stats = getEventStatistics(startDate: startOfDay, endDate: endOfDay);
      
      statistics.add({
        'date': startOfDay.toIso8601String(),
        'events': dayEvents.length,
        'averageConfidence': stats['averageConfidence'],
        'severityCounts': stats['severityCounts'],
      });
    }

    return statistics;
  }

  /// Search events by notes
  List<DrowsinessEvent> searchEventsByNotes(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _box.values.where((event) {
      return event.notes?.toLowerCase().contains(lowercaseQuery) ?? false;
    }).toList();
  }

  /// Get events count
  int getEventsCount() {
    return _box.length;
  }

  /// Get most frequent time of day for events
  Map<int, int> getEventsByHourOfDay() {
    final hourCounts = <int, int>{};
    
    for (final event in getAllEvents()) {
      final hour = event.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    return hourCounts;
  }

  /// Export events (for backup or analysis)
  List<Map<String, dynamic>> exportEvents() {
    return getAllEvents().map((event) {
      return {
        'id': event.id,
        'timestamp': event.timestamp.toIso8601String(),
        'severity': event.severity,
        'confidence': event.confidence,
        'duration': event.duration.inMilliseconds,
        'location': event.location != null ? {
          'latitude': event.location!.latitude,
          'longitude': event.location!.longitude,
        } : null,
        'notes': event.notes,
        'actionTaken': event.actionTaken,
      };
    }).toList();
  }

  /// Clear old events (keep only recent ones)
  Future<void> clearOldEvents({int keepDays = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
    final eventsToDelete = _box.values
        .where((event) => event.timestamp.isBefore(cutoffDate))
        .map((event) => event.id)
        .toList();

    for (final eventId in eventsToDelete) {
      await deleteEvent(eventId);
    }
  }

  /// Clear all events
  Future<void> clearAllEvents() async {
    await _box.clear();
  }

  /// Close the repository
  Future<void> close() async {
    if (_box.isOpen) {
      await _box.close();
    }
  }
}