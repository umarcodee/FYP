import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'app/app.dart';
import 'core/services/notification_service.dart';
import 'core/services/database_service.dart';
import 'presentation/providers/drowsiness_provider.dart';
import 'presentation/providers/location_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/chatbot_provider.dart';

/// Main entry point of the Driver Monitoring App
/// Initializes all necessary services and providers
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database
  await Hive.initFlutter();
  await DatabaseService.initializeDatabase();
  
  // Initialize notification service
  await NotificationService.initialize();
  
  // Set preferred orientations (portrait only for better ML detection)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Set system UI overlay style for futuristic theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(
    /// Multi-provider setup for state management
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DrowsinessProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ChatbotProvider()),
      ],
      child: const DriverMonitoringApp(),
    ),
  );
}