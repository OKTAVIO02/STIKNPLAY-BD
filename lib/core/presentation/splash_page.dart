import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math' as math;

import '../../features/auth/presentation/login_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/home/presentation/admin_dashboard_page.dart';
import 'ps_loading_widget.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 9));
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();

    _controller.forward();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 9));
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      const adminEmail = "admin@gmail.com";
      if (user.email == adminEmail) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const AdminDashboardPage()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // TYPING TEXT — TANPA FONT CUSTOM (PAKAI SYSTEM FONT YANG SUDAH KEREN)
  Widget _buildTypingText(String text, double progress) {
    final visibleCount = (text.length * progress).floor();

    return RichText(
      text: TextSpan(
        style: const TextStyle(height: 0.9),
        children: text.split('').asMap().entries.map((e) {
          int idx = e.key;
          String char = e.value;
          bool show = idx <= visibleCount;
          bool isSpecial = char == 'N' || char == 'Y';

          return WidgetSpan(
            child: AnimatedOpacity(
              opacity: show ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 100),
              child: AnimatedSlide(
                offset: show ? Offset.zero : const Offset(0, 0.5),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                child: Text(
                  char,
                  style: TextStyle(
                    fontSize: 58,
                    fontWeight: FontWeight.w900,
                    letterSpacing: char == 'Y' ? 10 : 3,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: isSpecial
                            ? [const Color(0xFF00D4FF), const Color(0xFF0099FF)]
                            : [
                                const Color(0xFF0088CC),
                                const Color(0xFF00C2FF)
                              ],
                      ).createShader(const Rect.fromLTWH(0, 0, 300, 100)),
                    shadows: [
                      Shadow(
                          color: Colors.white.withOpacity(0.9), blurRadius: 16),
                      Shadow(
                          color: Colors.black26,
                          offset: const Offset(3, 5),
                          blurRadius: 10),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCDF6FF),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [Color(0xFFCDF6FF), Color(0xFFB3EFFF)],
              ),
            ),
          ),

          // Particle effect
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: ParticlePainter(_pulseController.value),
              );
            },
          ),

          // Main content — PAS DI TENGAH
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final progress = _controller.value;
                final logoScale = Curves.elasticOut
                    .transform((progress * 1.5).clamp(0.0, 1.0));
                final logoOpacity = (progress * 2.5).clamp(0.0, 1.0);
                final titleProgress = ((progress - 0.4) / 0.3).clamp(0.0, 1.0);
                final subtitleProgress =
                    ((progress - 0.6) / 0.4).clamp(0.0, 1.0);

                return Opacity(
                  opacity: logoOpacity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glow + Logo
                      SizedBox(
                        width: 320,
                        height: 320,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: 1.0 +
                                  math.sin(_pulseController.value *
                                          math.pi *
                                          2) *
                                      0.15,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(colors: [
                                    Colors.white.withOpacity(0.4),
                                    Colors.transparent,
                                  ]),
                                ),
                              ),
                            ),
                            Transform.scale(
                              scale: logoScale,
                              child: Transform.rotate(
                                angle: progress < 0.25 ? progress * 8 : 0,
                                child: const PsLoadingWidget(size: 240),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Judul StickNPlayY
                      Opacity(
                        opacity: titleProgress,
                        child: _buildTypingText("StickNPlayY", titleProgress),
                      ),

                      const SizedBox(height: 18),

                      // Subtitle
                      Opacity(
                        opacity: subtitleProgress,
                        child: const Text(
                          "Sewa Console Jadi Mudah",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF005577),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 90),

                      // Loading bar
                      if (progress > 0.7)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 70),
                          child: LinearProgressIndicator(
                            value: (progress - 0.7) / 0.3,
                            minHeight: 5,
                            borderRadius: BorderRadius.circular(3),
                            backgroundColor: Colors.white38,
                            valueColor:
                                const AlwaysStoppedAnimation(Color(0xFF00DDFF)),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Particle Painter
class ParticlePainter extends CustomPainter {
  final double anim;
  ParticlePainter(this.anim);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.5);
    for (int i = 0; i < 28; i++) {
      double t = (anim + i * 0.09) % 1;
      double angle = t * math.pi * 2;
      double radius = 90 + math.sin(t * math.pi) * 70;
      double x = size.width / 2 + math.cos(angle) * radius;
      double y = size.height / 2 + math.sin(angle) * radius;
      double s = 2 + math.sin(t * math.pi) * 2.5;
      canvas.drawCircle(Offset(x, y), s, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
