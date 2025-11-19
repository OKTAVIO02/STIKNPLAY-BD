import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

import '../../features/home/presentation/home_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/home/presentation/admin_dashboard_page.dart'; // Import Admin

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  // --- SETTING EMAIL ADMIN ---
  final String adminEmail = "admin@gmail.com"; // GANTI INI DENGAN EMAIL ADMIN ANDA

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
    _navigateToNextPage();
  }

  _navigateToNextPage() async {
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // --- LOGIKA PEMISAHAN ---
        if (currentUser.email == adminEmail) {
           // JIKA ADMIN -> Masuk Dashboard Admin
           Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
          );
        } else {
           // JIKA USER BIASA -> Masuk Home User
           Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        // BELUM LOGIN
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.gamepad_rounded, size: 80, color: Colors.blue[800]),
              ),
              const SizedBox(height: 20),
              const Text("STIKNPLAY", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
            ],
          ),
        ),
      ),
    );
  }
}