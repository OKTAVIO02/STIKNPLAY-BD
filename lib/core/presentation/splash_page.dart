import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- BAGIAN INI YANG DIPERBAIKI (MENAMBAHKAN FOLDER 'features') ---
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/onboarding_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/home/presentation/admin_dashboard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  // --- LOGIKA UTAMA APLIKASI ---
  void _checkAuthAndNavigate() async {
    // 1. Tahan 3 detik agar Logo terlihat (Branding)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // 2. Cek apakah user sudah pernah login?
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // === JIKA SUDAH LOGIN ===
      // Cek Role-nya (Admin atau User?)
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final role = doc.data()?['role'] ?? 'user';

        if (mounted) {
          if (role == 'admin') {
            // Masuk Dashboard Admin
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardPage()));
          } else {
            // Masuk Home User
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
          }
        }
      } catch (e) {
        // Jika error (misal internet mati), lempar ke Login demi keamanan
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    } else {
      // === JIKA BELUM LOGIN (USER BARU) ===
      // Arahkan ke ONBOARDING PAGE (Perkenalan)
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnboardingPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background Gradient Gelap Mewah
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO GLOWING
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF00C6FF).withOpacity(0.5), blurRadius: 30, spreadRadius: 5)
                ],
              ),
              child: const Icon(Icons.gamepad_rounded, size: 80, color: Colors.white),
            ),
            
            const SizedBox(height: 30),
            
            // TEKS BRANDING
            const Text(
              "PS RENTAL PRO",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 3),
            ),
            const SizedBox(height: 10),
            Text(
              "Sewa Console Jadi Lebih Mudah",
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
            ),

            const SizedBox(height: 60),

            // LOADING
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C6FF))),
          ],
        ),
      ),
    );
  }
}