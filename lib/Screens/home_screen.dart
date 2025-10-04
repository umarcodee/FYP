import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget neonButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // width: double.infinity, // GridView will handle sizing
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.4),
              blurRadius: 14,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(color: Colors.cyanAccent, width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.05,
                shadows: [
                  Shadow(
                    color: Colors.cyanAccent,
                    blurRadius: 8,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      {
        'icon': Icons.visibility,
        'label': 'Drowsiness',
        'onTap': () {
          // Navigator.push(context, MaterialPageRoute(builder: (_) => DetectionScreen()));
        },
      },
      {
        'icon': Icons.analytics,
        'label': 'Analytics',
        'onTap': () {
          // Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsScreen()));
        },
      },
      {
        'icon': Icons.map,
        'label': 'Nearby',
        'onTap': () {
          // Navigator.push(context, MaterialPageRoute(builder: (_) => MapsScreen()));
        },
      },
      {
        'icon': Icons.chat_bubble_outline,
        'label': 'AI Assistant',
        'onTap': () {
          // Navigator.push(context, MaterialPageRoute(builder: (_) => ChatbotScreen()));
        },
      },
      {
        'icon': Icons.warning_amber_rounded,
        'label': 'Emergency',
        'onTap': () {
          // Navigator.push(context, MaterialPageRoute(builder: (_) => EmergencyScreen()));
        },
      },
      {
        'icon': Icons.settings,
        'label': 'Settings',
        'onTap': () {
          // Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
        },
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Driver Monitoring',
          style: TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.cyanAccent,
                blurRadius: 10,
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome text
              Center(
                child: Text(
                  'Welcome, Driver!',
                  style: TextStyle(
                    color: Colors.cyanAccent.shade100,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    shadows: [
                      Shadow(
                        color: Colors.cyanAccent.withOpacity(0.4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Grid of buttons
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.08, // Adjust for perfect box shape
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  physics: const BouncingScrollPhysics(),
                  children: buttons
                      .map((btn) => neonButton(
                    icon: btn['icon'] as IconData,
                    label: btn['label'] as String,
                    onTap: btn['onTap'] as VoidCallback,
                  ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 10),
              // App tagline
              Center(
                child: Text(
                  'AI-Powered Safety On The Road',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.1,
                    shadows: [
                      Shadow(
                        color: Colors.cyanAccent.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}