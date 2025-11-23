import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

// Import Halaman Tujuan
import '../../features/auth/presentation/login_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/home/presentation/admin_dashboard_page.dart';

// IMPORT WIDGET LOTTIE YANG SUDAH KITA BUAT
import 'ps_loading_widget.dart'; 

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // 1. Tahan tampilan Splash selama 3 detik agar Lottie-nya puas dilihat
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    // 2. Cek apakah user sedang login?
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // --- LOGIKA PEMISAHAN ADMIN VS USER ---
      // Ganti email ini dengan email admin asli Anda
      const String adminEmail = "admin@gmail.com"; 

      if (user.email == adminEmail) {
        // Jika Admin -> Ke Dashboard Admin
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const AdminDashboardPage())
        );
      } else {
        // Jika User Biasa -> Ke Home Page
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const HomePage())
        );
      }
    } else {
      // 3. Jika belum login -> Ke Halaman Login
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const LoginPage())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background putih bersih agar Lottie terlihat jelas
      backgroundColor: const Color.fromARGB(255, 209, 237, 243), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- ANIMASI LOTTIE PLAYSTATION ---
            // Kita panggil widget yang sudah dibuat tadi
            const PsLoadingWidget(size: 250), 
            
            const SizedBox(height: 20),
            
            // Teks Judul Aplikasi
            Text(
              "PS RENTAL PRO",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.blue[900], // Biru Tua
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Sewa Console Jadi Mudah",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}