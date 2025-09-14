import 'package:sms_advanced/sms_advanced.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/emergency_contact.dart';
import '../location_service/location_service.dart';

/// Service for handling SMS functionality and emergency notifications
class SmsService {
  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  final SmsAdvanced _smsAdvanced = SmsAdvanced();
  final LocationService _locationService = LocationService();

  /// Initialize SMS service and request permissions
  Future<bool> initialize() async {
    try {
      // Request SMS permission
      final status = await Permission.sms.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }

  /// Check if SMS permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.sms.status;
    return status == PermissionStatus.granted;
  }

  /// Send emergency SMS to a contact
  Future<bool> sendEmergencySms(EmergencyContact contact, {
    String? customMessage,
    bool includeLocation = true,
  }) async {
    if (!await hasPermission()) {
      return false;
    }

    try {
      String message = customMessage ?? _getDefaultEmergencyMessage();

      // Add location if requested and available
      if (includeLocation) {
        final position = await _locationService.getCurrentLocation();
        if (position != null) {
          final address = await _locationService.getAddressFromCoordinates(
            position.latitude,
            position.longitude,
          );
          
          message += '\n\nCurrent Location:\n';
          message += 'Address: $address\n';
          message += 'Coordinates: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}\n';
          message += 'Google Maps: https://maps.google.com/maps?q=${position.latitude},${position.longitude}';
        }
      }

      final SmsMessage smsMessage = SmsMessage(
        contact.phoneNumber,
        message,
      );

      final result = await _smsAdvanced.sendSms(smsMessage);
      return result != null;
    } catch (e) {
      return false;
    }
  }

  /// Send emergency SMS to multiple contacts
  Future<Map<String, bool>> sendEmergencySmsToContacts(
    List<EmergencyContact> contacts, {
    String? customMessage,
    bool includeLocation = true,
  }) async {
    final Map<String, bool> results = {};

    for (final contact in contacts) {
      if (contact.enableSmsAlerts) {
        final success = await sendEmergencySms(
          contact,
          customMessage: customMessage,
          includeLocation: includeLocation,
        );
        results[contact.id] = success;

        // Add a small delay between messages to avoid spam detection
        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        results[contact.id] = false;
      }
    }

    return results;
  }

  /// Send drowsiness alert SMS
  Future<bool> sendDrowsinessAlert(EmergencyContact contact) async {
    const message = '🚨 DROWSINESS ALERT 🚨\n\n'
        'The driver monitoring system has detected signs of drowsiness. '
        'The driver may need assistance or should pull over safely.\n\n'
        'This is an automated safety alert from the Driver Monitoring App.';

    return await sendEmergencySms(
      contact,
      customMessage: message,
      includeLocation: true,
    );
  }

  /// Send emergency alert SMS
  Future<bool> sendEmergencyAlert(EmergencyContact contact) async {
    const message = '🆘 EMERGENCY ALERT 🆘\n\n'
        'An emergency situation has been detected by the driver monitoring system. '
        'Immediate assistance may be required.\n\n'
        'This is an automated emergency alert from the Driver Monitoring App.';

    return await sendEmergencySms(
      contact,
      customMessage: message,
      includeLocation: true,
    );
  }

  /// Send custom alert SMS
  Future<bool> sendCustomAlert(
    EmergencyContact contact,
    String alertType,
    String message,
  ) async {
    final fullMessage = '⚠️ $alertType ALERT ⚠️\n\n$message\n\n'
        'This is an automated alert from the Driver Monitoring App.';

    return await sendEmergencySms(
      contact,
      customMessage: fullMessage,
      includeLocation: true,
    );
  }

  /// Send test SMS to verify contact
  Future<bool> sendTestSms(EmergencyContact contact) async {
    const message = '📱 Driver Monitoring App - Test Message\n\n'
        'This is a test message to verify your contact information. '
        'You have been added as an emergency contact.\n\n'
        'If you received this message, the setup is working correctly.';

    return await sendEmergencySms(
      contact,
      customMessage: message,
      includeLocation: false,
    );
  }

  /// Get inbox messages (for debugging or message history)
  Future<List<SmsMessage>> getInboxMessages() async {
    if (!await hasPermission()) {
      return [];
    }

    try {
      final messages = await _smsAdvanced.getInboxSms(
        columns: [SmsColumns.ID, SmsColumns.ADDRESS, SmsColumns.BODY, SmsColumns.DATE],
        sortOrder: [OrderBy(SmsColumns.DATE, sort: Sort.DESC)],
        count: 50,
      );

      return messages;
    } catch (e) {
      return [];
    }
  }

  /// Get sent messages (for tracking emergency SMS)
  Future<List<SmsMessage>> getSentMessages() async {
    if (!await hasPermission()) {
      return [];
    }

    try {
      final messages = await _smsAdvanced.getSent(
        columns: [SmsColumns.ID, SmsColumns.ADDRESS, SmsColumns.BODY, SmsColumns.DATE],
        sortOrder: [OrderBy(SmsColumns.DATE, sort: Sort.DESC)],
        count: 50,
      );

      return messages;
    } catch (e) {
      return [];
    }
  }

  /// Format phone number for SMS
  String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Add + if not present and number doesn't start with it
    if (!cleaned.startsWith('+') && !cleaned.startsWith('00')) {
      // Assume local number, you might want to add country code logic here
      cleaned = '+1$cleaned'; // Default to US country code
    }
    
    return cleaned;
  }

  /// Validate phone number format
  bool isValidPhoneNumber(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Basic validation: should have at least 10 digits
    final digitsOnly = cleaned.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 10 && digitsOnly.length <= 15;
  }

  /// Get default emergency message
  String _getDefaultEmergencyMessage() {
    return '🚨 EMERGENCY ALERT 🚨\n\n'
        'An emergency has been detected by the Driver Monitoring System. '
        'Please check on the driver\'s safety.\n\n'
        'Time: ${DateTime.now().toString()}\n'
        'This is an automated safety alert.';
  }
}