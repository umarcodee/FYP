import 'package:hive_flutter/hive_flutter.dart';
import '../models/emergency_contact.dart';
import '../models/drowsiness_event.dart';
import '../models/nearby_place.dart';

/// Configuration class for Hive database initialization
class HiveConfig {
  static bool _isInitialized = false;

  /// Initialize Hive with all required type adapters
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Hive Flutter
    await Hive.initFlutter();

    // Register type adapters
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(EmergencyContactAdapter());
    }
    
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(DrowsinessEventAdapter());
    }
    
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(NearbyPlaceAdapter());
    }

    _isInitialized = true;
  }

  /// Open all required boxes
  static Future<void> openBoxes() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Open emergency contacts box
    if (!Hive.isBoxOpen('emergency_contacts')) {
      await Hive.openBox<EmergencyContact>('emergency_contacts');
    }

    // Open drowsiness events box
    if (!Hive.isBoxOpen('drowsiness_events')) {
      await Hive.openBox<DrowsinessEvent>('drowsiness_events');
    }

    // Open nearby places box (for caching)
    if (!Hive.isBoxOpen('nearby_places')) {
      await Hive.openBox<NearbyPlace>('nearby_places');
    }

    // Open settings box
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }

    // Open app state box
    if (!Hive.isBoxOpen('app_state')) {
      await Hive.openBox('app_state');
    }
  }

  /// Close all boxes
  static Future<void> closeBoxes() async {
    await Hive.close();
  }

  /// Clear all data (for testing or reset)
  static Future<void> clearAllData() async {
    await Hive.deleteFromDisk();
    _isInitialized = false;
  }

  /// Get box names
  static List<String> getBoxNames() {
    return [
      'emergency_contacts',
      'drowsiness_events',
      'nearby_places',
      'settings',
      'app_state',
    ];
  }

  /// Check if all boxes are open
  static bool areAllBoxesOpen() {
    return getBoxNames().every((boxName) => Hive.isBoxOpen(boxName));
  }

  /// Get database size information
  static Map<String, dynamic> getDatabaseInfo() {
    final info = <String, dynamic>{};
    
    for (final boxName in getBoxNames()) {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        info[boxName] = {
          'isOpen': true,
          'length': box.length,
          'keys': box.keys.toList(),
        };
      } else {
        info[boxName] = {
          'isOpen': false,
          'length': 0,
          'keys': [],
        };
      }
    }

    return info;
  }

  /// Compact all boxes (optimize storage)
  static Future<void> compactAllBoxes() async {
    for (final boxName in getBoxNames()) {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).compact();
      }
    }
  }

  /// Backup database to map (for export)
  static Map<String, dynamic> backupDatabase() {
    final backup = <String, dynamic>{};
    
    for (final boxName in getBoxNames()) {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        backup[boxName] = Map<String, dynamic>.from(box.toMap());
      }
    }

    return backup;
  }

  /// Restore database from backup
  static Future<void> restoreDatabase(Map<String, dynamic> backup) async {
    await clearAllData();
    await initialize();
    await openBoxes();

    for (final boxName in backup.keys) {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        final boxData = backup[boxName] as Map<String, dynamic>;
        
        for (final key in boxData.keys) {
          await box.put(key, boxData[key]);
        }
      }
    }
  }
}