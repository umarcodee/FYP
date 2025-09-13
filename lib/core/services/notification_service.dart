import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import '../constants/app_constants.dart';

/// Service for managing notifications and audio alerts
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static final AudioPlayer _audioPlayer = AudioPlayer();
  
  static bool _isInitialized = false;

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Android initialization settings
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization settings
      const DarwinInitializationSettings iosSettings = 
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      // Combined initialization settings
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      // Initialize plugin
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      // Create notification channels for Android
      await _createNotificationChannels();
      
      _isInitialized = true;
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  /// Create notification channels for Android
  static Future<void> _createNotificationChannels() async {
    // Drowsiness alerts channel
    const AndroidNotificationChannel drowsinessChannel = 
        AndroidNotificationChannel(
      AppConstants.drowsinessChannelId,
      AppConstants.drowsinessChannelName,
      description: 'Notifications for driver drowsiness detection',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      ledColor: Color(0xFF00FFFF),
    );
    
    // Emergency alerts channel
    const AndroidNotificationChannel emergencyChannel = 
        AndroidNotificationChannel(
      AppConstants.emergencyChannelId,
      AppConstants.emergencyChannelName,
      description: 'Critical emergency notifications',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      ledColor: Color(0xFFFF0040),
    );
    
    // Register channels
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(drowsinessChannel);
    
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(emergencyChannel);
  }

  /// Handle notification tap events
  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle navigation based on payload if needed
  }

  /// Show drowsiness detection alert
  static Future<void> showDrowsinessAlert({
    required String title,
    required String message,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = 
          AndroidNotificationDetails(
        AppConstants.drowsinessChannelId,
        AppConstants.drowsinessChannelName,
        channelDescription: 'Driver drowsiness detected',
        importance: Importance.high,
        priority: Priority.high,
        color: Color(0xFF00FFFF),
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        vibrationPattern: [0, 1000, 500, 1000],
        enableLights: true,
        ledColor: Color(0xFF00FFFF),
        ledOnMs: 1000,
        ledOffMs: 500,
      );
      
      const DarwinNotificationDetails iosDetails = 
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'alert_sound.aiff',
      );
      
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        message,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      print('Error showing drowsiness alert: $e');
    }
  }

  /// Show emergency alert notification
  static Future<void> showEmergencyAlert({
    required String title,
    required String message,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = 
          AndroidNotificationDetails(
        AppConstants.emergencyChannelId,
        AppConstants.emergencyChannelName,
        channelDescription: 'Critical emergency alert',
        importance: Importance.max,
        priority: Priority.max,
        color: Color(0xFFFF0040),
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        vibrationPattern: [0, 1000, 500, 1000, 500, 1000],
        enableLights: true,
        ledColor: Color(0xFFFF0040),
        ledOnMs: 500,
        ledOffMs: 500,
        ongoing: true, // Make it persistent
      );
      
      const DarwinNotificationDetails iosDetails = 
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'emergency_sound.aiff',
        interruptionLevel: InterruptionLevel.critical,
      );
      
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        message,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      print('Error showing emergency alert: $e');
    }
  }

  /// Play audio alert
  static Future<void> playAlertSound({bool isEmergency = false}) async {
    try {
      final soundPath = isEmergency 
          ? AppConstants.emergencySoundPath
          : AppConstants.alertSoundPath;
      
      await _audioPlayer.stop(); // Stop any currently playing sound
      await _audioPlayer.play(AssetSource(soundPath.replaceFirst('assets/', '')));
      
      // For emergency sounds, repeat multiple times
      if (isEmergency) {
        await _repeatEmergencySound();
      }
    } catch (e) {
      print('Error playing alert sound: $e');
      // Fallback to system beep if audio file fails
      _playSystemBeep();
    }
  }

  /// Repeat emergency sound for critical alerts
  static Future<void> _repeatEmergencySound() async {
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(seconds: 1));
      await _audioPlayer.play(
        AssetSource(AppConstants.emergencySoundPath.replaceFirst('assets/', ''))
      );
    }
  }

  /// Play system beep as fallback
  static void _playSystemBeep() {
    // This would trigger system notification sound
    showDrowsinessAlert(
      title: 'Alert',
      message: 'Drowsiness detected',
    );
  }

  /// Stop all audio playback
  static Future<void> stopAllSounds() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      print('Error canceling notifications: $e');
    }
  }

  /// Cancel specific notification
  static Future<void> cancelNotification(int notificationId) async {
    try {
      await _notifications.cancel(notificationId);
    } catch (e) {
      print('Error canceling notification $notificationId: $e');
    }
  }

  /// Request notification permissions (iOS)
  static Future<bool> requestPermissions() async {
    try {
      final bool? result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
      
      return result ?? false;
    } catch (e) {
      print('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    try {
      final bool? result = await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      
      return result ?? false;
    } catch (e) {
      print('Error checking notification status: $e');
      return false;
    }
  }

  /// Show scheduled notification (for reminders)
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String message,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = 
          AndroidNotificationDetails(
        AppConstants.drowsinessChannelId,
        AppConstants.drowsinessChannelName,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
      
      const DarwinNotificationDetails iosDetails = 
          DarwinNotificationDetails();
      
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _notifications.zonedSchedule(
        id,
        title,
        message,
        // Convert DateTime to TZDateTime - simplified for now
        scheduledDate as dynamic,
        notificationDetails,
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: 
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  /// Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      print('Error getting pending notifications: $e');
      return [];
    }
  }

  /// Dispose resources
  static Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      print('Error disposing notification service: $e');
    }
  }
}