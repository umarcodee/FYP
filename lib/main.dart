import 'package:flutter/material.dart';
import 'Screens/splashscreen.dart';
import 'Screens/drowsiness_screen.dart';
import 'Screens/analytics_screen.dart';
import 'services/database_service.dart';

late DatabaseService dbService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive Database
  dbService = DatabaseService();
  await dbService. initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver Monitoring App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DrowsinessScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Detection',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// ================== SETTINGS SCREEN ==================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  double _sensitivityLevel = 0.5;

  @override
  Widget build(BuildContext context) {
    final cyan = Colors.cyanAccent;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.1,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔔 ALERTS SECTION
              Text(
                'Alerts & Notifications',
                style: TextStyle(
                  color: cyan,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Sound Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: cyan, width: 1),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[900],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.volume_up, color: Colors.cyanAccent),
                        const SizedBox(width: 12),
                        const Text(
                          'Sound Alert',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    Switch(
                      value: _soundEnabled,
                      onChanged: (value) {
                        setState(() {
                          _soundEnabled = value;
                        });
                      },
                      activeColor: cyan,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Vibration Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border. all(color: cyan, width: 1),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[900],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.vibration, color: Colors.cyanAccent),
                        const SizedBox(width: 12),
                        const Text(
                          'Vibration',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    Switch(
                      value: _vibrationEnabled,
                      onChanged: (value) {
                        setState(() {
                          _vibrationEnabled = value;
                        });
                      },
                      activeColor: cyan,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ⚙️ DETECTION SETTINGS
              Text(
                'Detection Sensitivity',
                style: TextStyle(
                  color: cyan,
                  fontSize: 18,
                  fontWeight: FontWeight. bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: cyan, width: 1),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[900],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sensitivity Level',
                          style: TextStyle(
                            color: cyan,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(_sensitivityLevel * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: cyan,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _sensitivityLevel,
                      onChanged: (value) {
                        setState(() {
                          _sensitivityLevel = value;
                        });
                      },
                      min: 0.0,
                      max: 1.0,
                      activeColor: cyan,
                      inactiveColor: Colors.grey[700],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 📊 INFO SECTION
              Text(
                'Information',
                style: TextStyle(
                  color: cyan,
                  fontSize: 18,
                  fontWeight: FontWeight. bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border. all(color: cyan, width: 1),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[900],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'App Version',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          '1.0.0',
                          style: TextStyle(color: cyan, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Database',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          'Hive',
                          style: TextStyle(color: cyan, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape. circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Active',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}