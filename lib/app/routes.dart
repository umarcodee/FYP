import 'package:flutter/material.dart';

import '../presentation/screens/home_screen.dart';
import '../presentation/screens/detection_screen.dart';
import '../presentation/screens/chatbot_screen.dart';
import '../presentation/screens/maps_screen.dart';
import '../presentation/screens/logs_screen.dart';
import '../presentation/screens/settings_screen.dart';
import '../presentation/screens/emergency_screen.dart';

/// Application route management with named routes
class AppRoutes {
  // Route names
  static const String home = '/';
  static const String detection = '/detection';
  static const String chatbot = '/chatbot';
  static const String maps = '/maps';
  static const String logs = '/logs';
  static const String settings = '/settings';
  static const String emergency = '/emergency';

  /// Generate routes based on route name
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _createRoute(const HomeScreen());
      
      case detection:
        return _createRoute(const DetectionScreen());
      
      case chatbot:
        final args = settings.arguments as Map<String, dynamic>?;
        return _createRoute(ChatbotScreen(
          isEmergency: args?['isEmergency'] ?? false,
        ));
      
      case maps:
        final args = settings.arguments as Map<String, dynamic>?;
        return _createRoute(MapsScreen(
          searchType: args?['searchType'] ?? 'rest_stops',
        ));
      
      case logs:
        return _createRoute(const LogsScreen());
      
      case settings:
        return _createRoute(const SettingsScreen());
      
      case emergency:
        return _createRoute(const EmergencyScreen());
      
      default:
        return _createRoute(
          const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }

  /// Create custom page route with slide transition
  static PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Futuristic slide transition from bottom
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutQuart;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }
}