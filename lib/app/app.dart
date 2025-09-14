import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../presentation/providers/settings_provider.dart';
import 'routes.dart';

/// Main application widget with theme and routing configuration
class DriverMonitoringApp extends StatelessWidget {
  const DriverMonitoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: 'Driver Monitoring App',
          debugShowCheckedModeBanner: false,
          
          // Futuristic dark theme with neon accents
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsProvider.isDarkMode 
              ? ThemeMode.dark 
              : ThemeMode.light,
          
          // Application routes
          onGenerateRoute: AppRoutes.onGenerateRoute,
          initialRoute: AppRoutes.home,
          
          // App-wide builder for custom configurations
          builder: (context, child) {
            return MediaQuery(
              // Prevent text scaling to maintain UI consistency
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}