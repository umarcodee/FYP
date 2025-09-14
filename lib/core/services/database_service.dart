import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/drowsiness_event.dart';
import '../../data/models/emergency_contact.dart';
import '../constants/app_constants.dart';

/// Database service for managing local storage using Hive
class DatabaseService {
  static late Box<DrowsinessEvent> _drowsinessEventsBox;
  static late Box<EmergencyContact> _emergencyContactsBox;
  static late Box _settingsBox;

  /// Initialize Hive database with type adapters
  static Future<void> initializeDatabase() async {
    try {
      // Register type adapters
      Hive.registerAdapter(DrowsinessEventAdapter());
      Hive.registerAdapter(EmergencyContactAdapter());
      
      // Open boxes
      _drowsinessEventsBox = await Hive.openBox<DrowsinessEvent>(
        AppConstants.drowsinessEventsBox
      );
      
      _emergencyContactsBox = await Hive.openBox<EmergencyContact>(
        AppConstants.emergencyContactsBox
      );
      
      _settingsBox = await Hive.openBox(AppConstants.settingsBox);
      
      // Perform database cleanup
      await _performCleanup();
      
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }

  /// Perform database cleanup (remove old entries)
  static Future<void> _performCleanup() async {
    try {
      final cutoffDate = DateTime.now().subtract(AppConstants.logRetentionPeriod);
      final eventsToRemove = <int>[];
      
      // Find old events to remove
      for (int i = 0; i < _drowsinessEventsBox.length; i++) {
        final event = _drowsinessEventsBox.getAt(i);
        if (event?.timestamp.isBefore(cutoffDate) == true) {
          eventsToRemove.add(i);
        }
      }
      
      // Remove old events (in reverse order to maintain indices)
      for (int i = eventsToRemove.length - 1; i >= 0; i--) {
        await _drowsinessEventsBox.deleteAt(eventsToRemove[i]);
      }
      
      // Ensure we don't exceed max log entries
      while (_drowsinessEventsBox.length > AppConstants.maxLogEntries) {
        await _drowsinessEventsBox.deleteAt(0);
      }
      
    } catch (e) {
      print('Database cleanup error: $e');
    }
  }

  /// Save drowsiness event to database
  static Future<void> saveDrowsinessEvent(DrowsinessEvent event) async {
    try {
      await _drowsinessEventsBox.add(event);
      
      // Trigger cleanup if needed
      if (_drowsinessEventsBox.length > AppConstants.maxLogEntries + 10) {
        await _performCleanup();
      }
    } catch (e) {
      throw Exception('Failed to save drowsiness event: $e');
    }
  }

  /// Get all drowsiness events, sorted by timestamp (newest first)
  static List<DrowsinessEvent> getAllDrowsinessEvents() {
    try {
      final events = _drowsinessEventsBox.values.toList();
      events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return events;
    } catch (e) {
      print('Error retrieving drowsiness events: $e');
      return [];
    }
  }

  /// Get drowsiness events for a specific date range
  static List<DrowsinessEvent> getDrowsinessEventsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      final events = _drowsinessEventsBox.values.where((event) {
        return event.timestamp.isAfter(startDate) && 
               event.timestamp.isBefore(endDate);
      }).toList();
      
      events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return events;
    } catch (e) {
      print('Error retrieving events by date range: $e');
      return [];
    }
  }

  /// Get drowsiness events statistics
  static Map<String, dynamic> getDrowsinessStatistics() {
    try {
      final events = getAllDrowsinessEvents();
      final now = DateTime.now();
      
      // Today's events
      final todayEvents = events.where((event) {
        return event.timestamp.day == now.day &&
               event.timestamp.month == now.month &&
               event.timestamp.year == now.year;
      }).length;
      
      // This week's events
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final thisWeekEvents = events.where((event) {
        return event.timestamp.isAfter(weekStart);
      }).length;
      
      // This month's events
      final monthStart = DateTime(now.year, now.month, 1);
      final thisMonthEvents = events.where((event) {
        return event.timestamp.isAfter(monthStart);
      }).length;
      
      // Critical events count
      final criticalEvents = events.where((event) {
        return event.drowsinessLevel == DrowsinessState.critical;
      }).length;
      
      return {
        'totalEvents': events.length,
        'todayEvents': todayEvents,
        'thisWeekEvents': thisWeekEvents,
        'thisMonthEvents': thisMonthEvents,
        'criticalEvents': criticalEvents,
        'lastEventTime': events.isNotEmpty ? events.first.timestamp : null,
      };
    } catch (e) {
      print('Error calculating statistics: $e');
      return {
        'totalEvents': 0,
        'todayEvents': 0,
        'thisWeekEvents': 0,
        'thisMonthEvents': 0,
        'criticalEvents': 0,
        'lastEventTime': null,
      };
    }
  }

  /// Delete a specific drowsiness event
  static Future<void> deleteDrowsinessEvent(String eventId) async {
    try {
      final eventIndex = _drowsinessEventsBox.values.toList()
          .indexWhere((event) => event.id == eventId);
      
      if (eventIndex != -1) {
        await _drowsinessEventsBox.deleteAt(eventIndex);
      }
    } catch (e) {
      throw Exception('Failed to delete drowsiness event: $e');
    }
  }

  /// Clear all drowsiness events
  static Future<void> clearAllDrowsinessEvents() async {
    try {
      await _drowsinessEventsBox.clear();
    } catch (e) {
      throw Exception('Failed to clear drowsiness events: $e');
    }
  }

  /// Save emergency contact
  static Future<void> saveEmergencyContact(EmergencyContact contact) async {
    try {
      await _emergencyContactsBox.add(contact);
    } catch (e) {
      throw Exception('Failed to save emergency contact: $e');
    }
  }

  /// Get all emergency contacts
  static List<EmergencyContact> getAllEmergencyContacts() {
    try {
      final contacts = _emergencyContactsBox.values.toList();
      // Sort by primary contacts first, then by name
      contacts.sort((a, b) {
        if (a.isPrimary && !b.isPrimary) return -1;
        if (!a.isPrimary && b.isPrimary) return 1;
        return a.name.compareTo(b.name);
      });
      return contacts;
    } catch (e) {
      print('Error retrieving emergency contacts: $e');
      return [];
    }
  }

  /// Update emergency contact
  static Future<void> updateEmergencyContact(
    String contactId, 
    EmergencyContact updatedContact,
  ) async {
    try {
      final contactIndex = _emergencyContactsBox.values.toList()
          .indexWhere((contact) => contact.id == contactId);
      
      if (contactIndex != -1) {
        await _emergencyContactsBox.putAt(contactIndex, updatedContact);
      }
    } catch (e) {
      throw Exception('Failed to update emergency contact: $e');
    }
  }

  /// Delete emergency contact
  static Future<void> deleteEmergencyContact(String contactId) async {
    try {
      final contactIndex = _emergencyContactsBox.values.toList()
          .indexWhere((contact) => contact.id == contactId);
      
      if (contactIndex != -1) {
        await _emergencyContactsBox.deleteAt(contactIndex);
      }
    } catch (e) {
      throw Exception('Failed to delete emergency contact: $e');
    }
  }

  /// Save setting value
  static Future<void> saveSetting(String key, dynamic value) async {
    try {
      await _settingsBox.put(key, value);
    } catch (e) {
      throw Exception('Failed to save setting: $e');
    }
  }

  /// Get setting value
  static T? getSetting<T>(String key, [T? defaultValue]) {
    try {
      return _settingsBox.get(key, defaultValue: defaultValue) as T?;
    } catch (e) {
      print('Error retrieving setting $key: $e');
      return defaultValue;
    }
  }

  /// Delete setting
  static Future<void> deleteSetting(String key) async {
    try {
      await _settingsBox.delete(key);
    } catch (e) {
      throw Exception('Failed to delete setting: $e');
    }
  }

  /// Close all database boxes
  static Future<void> closeDatabase() async {
    try {
      await _drowsinessEventsBox.close();
      await _emergencyContactsBox.close();
      await _settingsBox.close();
    } catch (e) {
      print('Error closing database: $e');
    }
  }
}