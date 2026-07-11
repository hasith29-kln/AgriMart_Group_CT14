import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E5E16),
      body: Stack(
        children: [
          // Background decorative shapes
          Positioned.fill(child: CustomPaint(painter: _BackgroundPainter())),

          // Hanging lamps (top area)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: CustomPaint(painter: _LampsPainter()),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                const Spacer(
                  flex: 3,
                ), // Reduced top space to move everything up
                // ── Logo Icon ──
                Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D6B1E),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      'assets/images/agrimart_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── App Name ──
                const Text(
                  'AgriMart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                  ),
                ),

                const SizedBox(height: 8),

                // ── Tagline ──
                const Text(
                  'Connecting Farmers & Buyers\nthrough Agricultural Officers',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFB5CE9F),
                    fontSize: 14,
                    height: 1.5,
                    letterSpacing: 0,
                  ),
                ),

                const SizedBox(
                  height: 48,
                ), // Fixed space between tagline and buttons
                // ── Buttons ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF5A8441,
                            ), // Lighter green fill
                            side: const BorderSide(
                              color: Colors.white,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Create Account Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2E5E16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(
                  flex: 4,
                ), // Increased bottom space to push buttons up
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Background Shapes Painter ──────────────────────────────────────────────

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lightGreen = Paint()
      ..color = const Color(0xFFDCE9C8)
      ..style = PaintingStyle.fill;

    final darkGreen = Paint()
      ..color = const Color(0xFF244D0F)
      ..style = PaintingStyle.fill;

    // ── Top-right dark shape (drawn first so it's behind the light shape) ──
    final topRight = Path()
      ..moveTo(size.width * 0.20, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.04) // Reduced height
      ..lineTo(size.width * 0.10, size.height * 0.16) // Reduced height
      ..close();
    canvas.drawPath(topRight, darkGreen);

    // ── Top-left light shape ──
    final topLeft = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.45, 0) // Top edge
      ..lineTo(size.width * 0.58, size.height * 0.11) // Reduced height
      // Rounded corner at the bottom right of this shape
      ..quadraticBezierTo(
        size.width * 0.61,
        size.height * 0.15,
        size.width * 0.52,
        size.height * 0.17,
      )
      ..lineTo(0, size.height * 0.24) // Reduced height
      ..close();
    canvas.drawPath(topLeft, lightGreen);

    // ── Bottom-left dark shape  ──
    final bottomLeft = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height * 0.82)
      ..lineTo(0, size.height * 0.95)
      ..close();
    canvas.drawPath(bottomLeft, darkGreen);

    // ── Bottom-right light shape  ──
    final bottomRight = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width * 0.50, size.height)
      ..lineTo(size.width * 0.38, size.height * 0.84)
      ..quadraticBezierTo(
        size.width * 0.37,
        size.height * 0.79,
        size.width * 0.48,
        size.height * 0.76,
      )
      ..lineTo(size.width, size.height * 0.70)
      ..close();
    canvas.drawPath(bottomRight, lightGreen);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Lamps Painter ──────────────────────────────────────────────────────────

class _LampsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wirePaint = Paint()
      ..color = const Color(0xFF64B5F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final lampBody = Paint()
      ..color = const Color(0xFFD8DCC8)
      ..style = PaintingStyle.fill;

    final lampShade = Paint()
      ..color = const Color(0xFFEBEFDF)
      ..style = PaintingStyle.fill;

    // Draw two lamps
    _drawLamp(
      canvas,
      size.width * 0.22,
      size.height * 0.72,
      wirePaint,
      lampBody,
      lampShade,
    );
    _drawLamp(
      canvas,
      size.width * 0.45,
      size.height * 0.60,
      wirePaint,
      lampBody,
      lampShade,
    );
  }

  void _drawLamp(
    Canvas canvas,
    double x,
    double y,
    Paint wire,
    Paint body,
    Paint shade,
  ) {
    // Wire from top
    canvas.drawLine(Offset(x, 0), Offset(x, y), wire);

    // Lamp neck
    final neckRect = Rect.fromCenter(
      center: Offset(x, y + 8),
      width: 8,
      height: 16,
    );
    canvas.drawRect(neckRect, body);

    // Lamp shade (trapezoid shape)
    final shadePath = Path()
      ..moveTo(x - 6, y + 8)
      ..lineTo(x + 6, y + 8)
      ..lineTo(x + 34, y + 44)
      ..lineTo(x - 34, y + 44)
      ..close();
    canvas.drawPath(shadePath, shade);

    // Lamp shade bottom line accent
    final linePaint = Paint()
      ..color = const Color(0xFFB0B8A0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(x - 34, y + 44), Offset(x + 34, y + 44), linePaint);

    // Cap on top of shade
    final capPath = Path()
      ..moveTo(x - 8, y + 8)
      ..quadraticBezierTo(x, y + 2, x + 8, y + 8);
    canvas.drawPath(capPath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
