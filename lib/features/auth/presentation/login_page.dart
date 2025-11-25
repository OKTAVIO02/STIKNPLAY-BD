import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // PENTING
import 'register_page.dart';
import '../../home/presentation/home_page.dart';
import '../../home/presentation/admin_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // --- FUNGSI LOGIN YANG DIPERBARUI ---
  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email dan Password wajib diisi!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Proses Login ke Authentication
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // 2. CEK APAKAH DATA USER ADA DI FIRESTORE?
        // Ini solusi untuk akun lama yang belum masuk database
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // JIKA BELUM ADA: Buat data baru sekarang juga!
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName ?? user.email!.split('@')[0],
            'phoneNumber': '-', // Default kosong
            'role': 'user',     // Default user biasa
            'createdAt': DateTime.now(),
            'address': '-',
          });
        }

        // 3. Ambil Role (Peran) User untuk Penentuan Halaman
        String role = 'user';
        // Kita ambil ulang data (karena barusan mungkin baru dibuat)
        final freshDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (freshDoc.exists) {
          role = freshDoc.data()?['role'] ?? 'user';
        }

        // 4. Arahkan Halaman (Admin vs User)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Login Berhasil!"), backgroundColor: Colors.green));
          
          // Cek Email Admin Manual (Backup) atau Role dari Database
          const String adminEmail = "admin@gmail.com"; 
          
          if (user.email == adminEmail || role == 'admin') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardPage()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login Gagal";
      if (e.code == 'user-not-found') message = "Email tidak terdaftar.";
      else if (e.code == 'wrong-password') message = "Password salah.";
      else if (e.code == 'invalid-email') message = "Format email salah.";
      
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Logo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                  child: Icon(Icons.videogame_asset, size: 80, color: Colors.blue[800]),
                ),
                const SizedBox(height: 30),
                
                Text("Selamat Datang!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                const Text("Silakan login untuk melanjutkan", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 40),

                // Input Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                // Input Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),

                // Lupa Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {}, // Nanti bisa ditambah fitur lupa password
                    child: const Text("Lupa Password?"),
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol Login
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("MASUK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 30),

                // Link ke Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                      },
                      child: Text("Daftar Sekarang", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800])),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}