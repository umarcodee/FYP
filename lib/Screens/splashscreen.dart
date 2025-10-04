import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate some loading (e.g., initialization, loading assets)
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Neon effect for the app icon
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.7),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.visibility, // Use a relevant icon
                size: 80,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(height: 28),
            // App Title with glowing effect
            Text(
              "Driver Monitoring",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.cyanAccent,
                shadows: [
                  Shadow(
                    blurRadius: 16.0,
                    color: Colors.cyanAccent,
                    offset: Offset(0, 0),
                  ),
                ],
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "AI-Powered Safety Assistant",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),
            // Futuristic loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
              backgroundColor: Colors.white24,
            ),
          ],
        ),
      ),
    );
  }
}