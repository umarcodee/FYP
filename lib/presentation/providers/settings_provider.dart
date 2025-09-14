import 'package:flutter/foundation.dart';
import '../../core/services/database_service.dart';

/// Provider for managing app settings and preferences
class SettingsProvider extends ChangeNotifier {
  // Settings keys
  static const String _isDarkModeKey = 'isDarkMode';
  static const String _enableNotificationsKey = 'enableNotifications';
  static const String _enableSmsAlertsKey = 'enableSmsAlerts';
  static const String _enableVoiceChatKey = 'enableVoiceChat';
  static const String _alertVolumeKey = 'alertVolume';
  static const String _detectionSensitivityKey = 'detectionSensitivity';
  static const String _autoStartMonitoringKey = 'autoStartMonitoring';
  static const String _emergencyAutoCallKey = 'emergencyAutoCall';
  static const String _locationServicesKey = 'locationServices';
  static const String _dataRetentionDaysKey = 'dataRetentionDays';
  
  // Settings values
  bool _isDarkMode = true; // Default to dark mode for futuristic theme
  bool _enableNotifications = true;
  bool _enableSmsAlerts = true;
  bool _enableVoiceChat = true;
  double _alertVolume = 0.8;
  double _detectionSensitivity = 0.7;
  bool _autoStartMonitoring = false;
  bool _emergencyAutoCall = false;
  bool _locationServices = true;
  int _dataRetentionDays = 30;
  
  bool _isInitialized = false;

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get enableNotifications => _enableNotifications;
  bool get enableSmsAlerts => _enableSmsAlerts;
  bool get enableVoiceChat => _enableVoiceChat;
  double get alertVolume => _alertVolume;
  double get detectionSensitivity => _detectionSensitivity;
  bool get autoStartMonitoring => _autoStartMonitoring;
  bool get emergencyAutoCall => _emergencyAutoCall;
  bool get locationServices => _locationServices;
  int get dataRetentionDays => _dataRetentionDays;
  bool get isInitialized => _isInitialized;

  /// Initialize settings from database
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _loadSettings();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing settings: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Load all settings from database
  Future<void> _loadSettings() async {
    try {
      _isDarkMode = DatabaseService.getSetting(_isDarkModeKey, true) ?? true;
      _enableNotifications = DatabaseService.getSetting(_enableNotificationsKey, true) ?? true;
      _enableSmsAlerts = DatabaseService.getSetting(_enableSmsAlertsKey, true) ?? true;
      _enableVoiceChat = DatabaseService.getSetting(_enableVoiceChatKey, true) ?? true;
      _alertVolume = DatabaseService.getSetting(_alertVolumeKey, 0.8) ?? 0.8;
      _detectionSensitivity = DatabaseService.getSetting(_detectionSensitivityKey, 0.7) ?? 0.7;
      _autoStartMonitoring = DatabaseService.getSetting(_autoStartMonitoringKey, false) ?? false;
      _emergencyAutoCall = DatabaseService.getSetting(_emergencyAutoCallKey, false) ?? false;
      _locationServices = DatabaseService.getSetting(_locationServicesKey, true) ?? true;
      _dataRetentionDays = DatabaseService.getSetting(_dataRetentionDaysKey, 30) ?? 30;
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  /// Toggle dark mode
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await DatabaseService.saveSetting(_isDarkModeKey, value);
    notifyListeners();
  }

  /// Toggle notifications
  Future<void> setNotifications(bool value) async {
    _enableNotifications = value;
    await DatabaseService.saveSetting(_enableNotificationsKey, value);
    notifyListeners();
  }

  /// Toggle SMS alerts
  Future<void> setSmsAlerts(bool value) async {
    _enableSmsAlerts = value;
    await DatabaseService.saveSetting(_enableSmsAlertsKey, value);
    notifyListeners();
  }

  /// Toggle voice chat
  Future<void> setVoiceChat(bool value) async {
    _enableVoiceChat = value;
    await DatabaseService.saveSetting(_enableVoiceChatKey, value);
    notifyListeners();
  }

  /// Set alert volume
  Future<void> setAlertVolume(double value) async {
    _alertVolume = value.clamp(0.0, 1.0);
    await DatabaseService.saveSetting(_alertVolumeKey, _alertVolume);
    notifyListeners();
  }

  /// Set detection sensitivity
  Future<void> setDetectionSensitivity(double value) async {
    _detectionSensitivity = value.clamp(0.1, 1.0);
    await DatabaseService.saveSetting(_detectionSensitivityKey, _detectionSensitivity);
    notifyListeners();
  }

  /// Toggle auto start monitoring
  Future<void> setAutoStartMonitoring(bool value) async {
    _autoStartMonitoring = value;
    await DatabaseService.saveSetting(_autoStartMonitoringKey, value);
    notifyListeners();
  }

  /// Toggle emergency auto call
  Future<void> setEmergencyAutoCall(bool value) async {
    _emergencyAutoCall = value;
    await DatabaseService.saveSetting(_emergencyAutoCallKey, value);
    notifyListeners();
  }

  /// Toggle location services
  Future<void> setLocationServices(bool value) async {
    _locationServices = value;
    await DatabaseService.saveSetting(_locationServicesKey, value);
    notifyListeners();
  }

  /// Set data retention period
  Future<void> setDataRetentionDays(int value) async {
    _dataRetentionDays = value.clamp(1, 365);
    await DatabaseService.saveSetting(_dataRetentionDaysKey, _dataRetentionDays);
    notifyListeners();
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    try {
      _isDarkMode = true;
      _enableNotifications = true;
      _enableSmsAlerts = true;
      _enableVoiceChat = true;
      _alertVolume = 0.8;
      _detectionSensitivity = 0.7;
      _autoStartMonitoring = false;
      _emergencyAutoCall = false;
      _locationServices = true;
      _dataRetentionDays = 30;
      
      // Save all defaults
      await Future.wait([
        DatabaseService.saveSetting(_isDarkModeKey, _isDarkMode),
        DatabaseService.saveSetting(_enableNotificationsKey, _enableNotifications),
        DatabaseService.saveSetting(_enableSmsAlertsKey, _enableSmsAlerts),
        DatabaseService.saveSetting(_enableVoiceChatKey, _enableVoiceChat),
        DatabaseService.saveSetting(_alertVolumeKey, _alertVolume),
        DatabaseService.saveSetting(_detectionSensitivityKey, _detectionSensitivity),
        DatabaseService.saveSetting(_autoStartMonitoringKey, _autoStartMonitoring),
        DatabaseService.saveSetting(_emergencyAutoCallKey, _emergencyAutoCall),
        DatabaseService.saveSetting(_locationServicesKey, _locationServices),
        DatabaseService.saveSetting(_dataRetentionDaysKey, _dataRetentionDays),
      ]);
      
      notifyListeners();
    } catch (e) {
      print('Error resetting settings: $e');
    }
  }

  /// Export settings as JSON
  Map<String, dynamic> exportSettings() {
    return {
      'isDarkMode': _isDarkMode,
      'enableNotifications': _enableNotifications,
      'enableSmsAlerts': _enableSmsAlerts,
      'enableVoiceChat': _enableVoiceChat,
      'alertVolume': _alertVolume,
      'detectionSensitivity': _detectionSensitivity,
      'autoStartMonitoring': _autoStartMonitoring,
      'emergencyAutoCall': _emergencyAutoCall,
      'locationServices': _locationServices,
      'dataRetentionDays': _dataRetentionDays,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Import settings from JSON
  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      if (settings.containsKey('isDarkMode')) {
        await setDarkMode(settings['isDarkMode'] as bool? ?? true);
      }
      if (settings.containsKey('enableNotifications')) {
        await setNotifications(settings['enableNotifications'] as bool? ?? true);
      }
      if (settings.containsKey('enableSmsAlerts')) {
        await setSmsAlerts(settings['enableSmsAlerts'] as bool? ?? true);
      }
      if (settings.containsKey('enableVoiceChat')) {
        await setVoiceChat(settings['enableVoiceChat'] as bool? ?? true);
      }
      if (settings.containsKey('alertVolume')) {
        await setAlertVolume((settings['alertVolume'] as num?)?.toDouble() ?? 0.8);
      }
      if (settings.containsKey('detectionSensitivity')) {
        await setDetectionSensitivity((settings['detectionSensitivity'] as num?)?.toDouble() ?? 0.7);
      }
      if (settings.containsKey('autoStartMonitoring')) {
        await setAutoStartMonitoring(settings['autoStartMonitoring'] as bool? ?? false);
      }
      if (settings.containsKey('emergencyAutoCall')) {
        await setEmergencyAutoCall(settings['emergencyAutoCall'] as bool? ?? false);
      }
      if (settings.containsKey('locationServices')) {
        await setLocationServices(settings['locationServices'] as bool? ?? true);
      }
      if (settings.containsKey('dataRetentionDays')) {
        await setDataRetentionDays(settings['dataRetentionDays'] as int? ?? 30);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error importing settings: $e');
      throw Exception('Failed to import settings: $e');
    }
  }

  /// Get sensitivity description
  String get sensitivityDescription {
    if (_detectionSensitivity <= 0.3) return 'Low';
    if (_detectionSensitivity <= 0.7) return 'Medium';
    return 'High';
  }

  /// Get volume description
  String get volumeDescription {
    if (_alertVolume <= 0.3) return 'Low';
    if (_alertVolume <= 0.7) return 'Medium';
    return 'High';
  }

  /// Get retention description
  String get retentionDescription {
    if (_dataRetentionDays <= 7) return '1 Week';
    if (_dataRetentionDays <= 30) return '1 Month';
    if (_dataRetentionDays <= 90) return '3 Months';
    return '${(_dataRetentionDays / 30).round()} Months';
  }

  /// Validate settings
  bool validateSettings() {
    return _alertVolume >= 0.0 && 
           _alertVolume <= 1.0 &&
           _detectionSensitivity >= 0.1 && 
           _detectionSensitivity <= 1.0 &&
           _dataRetentionDays >= 1 && 
           _dataRetentionDays <= 365;
  }
}