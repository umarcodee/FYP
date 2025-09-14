import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

/// Service for handling push notifications and local alerts
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Request permissions for iOS
    await _requestPermissions();

    _isInitialized = true;
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Handle notification tap
  void _onNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Show drowsiness alert notification
  Future<void> showDrowsinessAlert({
    String title = '🚨 Drowsiness Detected',
    String body = 'Please take a break! Signs of drowsiness detected.',
  }) async {
    await _showNotification(
      id: 1,
      title: title,
      body: body,
      payload: 'drowsiness_alert',
      priority: Priority.high,
      importance: Importance.high,
    );
  }

  /// Show emergency alert notification
  Future<void> showEmergencyAlert({
    String title = '🆘 Emergency Alert',
    String body = 'Emergency situation detected. Contacts have been notified.',
  }) async {
    await _showNotification(
      id: 2,
      title: title,
      body: body,
      payload: 'emergency_alert',
      priority: Priority.max,
      importance: Importance.max,
    );
  }

  /// Show location sharing notification
  Future<void> showLocationSharingAlert({
    String title = '📍 Location Shared',
    String body = 'Your location has been shared with emergency contacts.',
  }) async {
    await _showNotification(
      id: 3,
      title: title,
      body: body,
      payload: 'location_shared',
      priority: Priority.defaultPriority,
      importance: Importance.defaultImportance,
    );
  }

  /// Show monitoring status notification
  Future<void> showMonitoringStatusNotification({
    String title = '👁️ Driver Monitoring Active',
    String body = 'Monitoring your alertness for safety.',
    bool ongoing = true,
  }) async {
    await _showNotification(
      id: 4,
      title: title,
      body: body,
      payload: 'monitoring_status',
      priority: Priority.low,
      importance: Importance.low,
      ongoing: ongoing,
    );
  }

  /// Show general information notification
  Future<void> showInfoNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: payload ?? 'info',
      priority: Priority.defaultPriority,
      importance: Importance.defaultImportance,
    );
  }

  /// Show scheduled notification (for reminders)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'scheduled_channel',
          'Scheduled Notifications',
          channelDescription: 'Scheduled notifications for reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Show periodic notification (for regular reminders)
  Future<void> showPeriodicNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    String? payload,
  }) async {
    await _flutterLocalNotificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      repeatInterval,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'periodic_channel',
          'Periodic Notifications',
          channelDescription: 'Periodic notifications for regular reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Show basic notification
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    Priority priority = Priority.defaultPriority,
    Importance importance = Importance.defaultImportance,
    bool ongoing = false,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'alerts_channel',
      'Driver Alerts',
      channelDescription: 'Notifications for driver safety alerts',
      importance: importance,
      priority: priority,
      ongoing: ongoing,
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
    );

    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }
    
    return true; // Assume enabled for iOS
  }
}