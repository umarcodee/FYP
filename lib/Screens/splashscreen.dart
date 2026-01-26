
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _scanController;
  late AnimationController _particleController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scanAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse Animation (Neon glow)
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);
    _pulseController.repeat();

    // Rotate Animation (Circle rotation)
    _rotateController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _rotateAnimation = CurvedAnimation(parent: _rotateController, curve: Curves.linear);
    _rotateController.  repeat();

    // Scan Animation (Scanning line)
    _scanController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _scanAnimation = CurvedAnimation(parent: _scanController, curve: Curves.easeInOut);
    _scanController.repeat();

    // Particle Animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _particleAnimation = CurvedAnimation(parent: _particleController, curve: Curves.linear);
    _particleController. repeat();

    // Navigate after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator. of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _scanController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Classic Cyan Neon
    const neonCyan = Color(0xFF00FFFF);
    const darkCyan = Color(0xFF00B8CC);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23), // Dark space background
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ✨ SPACE BACKGROUND WITH STARS
          CustomPaint(
            painter: StarfieldPainter(
              animationValue: _particleAnimation. value,
            ),
            size: Size. infinite,
          ),

          // ✨ ANIMATED GRID BACKGROUND
          Opacity(
            opacity: 0.08,
            child: CustomPaint(
              painter: GridPainter(
                animationValue: _scanAnimation.value,
              ),
              size: Size.infinite,
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✨ ROTATING CIRCLE WITH SCAN EFFECT
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating ring
                    AnimatedBuilder(
                      animation: _rotateAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotateAnimation.value * 2 * math.pi,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: neonCyan. withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Middle pulsing ring
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        final scale = 0.8 + (_pulseAnimation.value * 0.15);
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: neonCyan,
                                  width: 2,
                                ),
                                boxShadow: [
                            BoxShadow(
                            color: neonCyan.withValues(
                            alpha: 0.4 + (_pulseAnimation.value * 0.4),
                          ),
                          blurRadius: 20 + (_pulseAnimation.value * 25),
                          spreadRadius: 5 + (_pulseAnimation.value * 8),
                        ),
                        ],
                        ),
                        ),
                        );
                      },
                    ),

                    // Scanning line effect
                    AnimatedBuilder(
                      animation: _scanAnimation,
                      builder: (context, child) {
                        final offset = (_scanAnimation.value * 2 - 1) * 60;
                        return CustomPaint(
                          painter: ScanlinePainter(
                            offset: offset,
                            color: neonCyan,
                          ),
                          size: const Size(130, 130),
                        );
                      },
                    ),

                    // Center eye icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0F0F23). withValues(alpha: 0.5),
                        border: Border. all(
                          color: neonCyan,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: neonCyan,
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '👁️',
                          style: TextStyle(fontSize: 60),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // Title with glow
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow effect behind text
                    Text(
                      'Driver Monitoring',
                      style: TextStyle(
                        color: neonCyan. withValues(alpha: 0.2),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'Driver Monitoring',
                      style: TextStyle(
                        color: neonCyan,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: neonCyan.withValues(alpha: 0.6),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Drowsiness Detection System',
                  style: TextStyle(
                    color: neonCyan.withValues(alpha: 0.8),
                    fontSize: 14,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 80),

                // Loading indicator
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        color: neonCyan,
                        strokeWidth: 3,
                        backgroundColor: neonCyan.withValues(alpha: 0.2),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Status text
                Text(
                  'Initializing System...',
                  style: TextStyle(
                    color: neonCyan.withValues(alpha: 0.9),
                    fontSize: 14,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ✨ NEON BORDER (Sides)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final glowIntensity = 1 - (_pulseAnimation.value - 0.5). abs() * 2;
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: neonCyan.withValues(
                        alpha: 0.6 + (glowIntensity * 0.4),
                      ),
                      width: 3,
                    ),
                    right: BorderSide(
                      color: neonCyan. withValues(
                        alpha: 0.6 + (glowIntensity * 0.4),
                      ),
                      width: 3,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: neonCyan.withValues(
                        alpha: 0.4 + (glowIntensity * 0.3),
                      ),
                      blurRadius: 20 + (glowIntensity * 15),
                      spreadRadius: 5 + (glowIntensity * 5),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ✨ STARFIELD PAINTER (Space effect)
class StarfieldPainter extends CustomPainter {
  final double animationValue;

  StarfieldPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round;

    final random = math.Random(42);

    for (int i = 0; i < 120; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size. height;

      // Twinkling effect
      final twinkle = (math.sin(animationValue * 2 * math.pi + i) + 1) / 2;
      paint.color = Colors.white.withValues(alpha: twinkle * 0.7);

      canvas.drawCircle(
        Offset(x, y),
        1 + (random.nextDouble() * 1.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(StarfieldPainter oldDelegate) => true;
}

// ✨ GRID PAINTER (Futuristic grid)
class GridPainter extends CustomPainter {
  final double animationValue;

  GridPainter({required this. animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..strokeWidth = 1;

    const gridSize = 40.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
    canvas.drawLine(
    Offset(x, 0),
    Offset(x, size.height),
    paint,
    );
    }

    // Horizontal lines with animation
    for (double y = 0; y < size.height; y += gridSize) {
    final offset = animationValue * size.height;
    canvas.drawLine(
    Offset(0, (y + offset) % size.height),
    Offset(size.width, (y + offset) % size.height),
    paint,
    );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => true;
}

// ✨ SCANLINE PAINTER (Scanning effect)
class ScanlinePainter extends CustomPainter {
  final double offset;
  final Color color;

  ScanlinePainter({required this.offset, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color. withValues(alpha: 0.7)
      ..strokeWidth = 2;

    final y = (size.height / 2) + offset;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(ScanlinePainter oldDelegate) => true;
}