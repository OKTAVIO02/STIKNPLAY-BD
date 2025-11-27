import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
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
  bool _isPasswordVisible = false; // Tambahan untuk mata password

  // --- LOGIKA LOGIN (TETAP SAMA SEPERTI SEBELUMNYA) ---
  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email dan Password wajib diisi!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName ?? user.email!.split('@')[0],
            'phoneNumber': '-', 
            'role': 'user',     
            'createdAt': DateTime.now(),
            'address': '-',
          });
        }

        String role = 'user';
        final freshDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (freshDoc.exists) {
          role = freshDoc.data()?['role'] ?? 'user';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Login Berhasil!"), backgroundColor: Colors.green));
          
          if (role == 'admin') {
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

  // --- TAMPILAN UI BARU (PREMIUM DESIGN) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background Gradient Mewah
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F2027), // Hitam Kebiruan
              Color(0xFF203A43), // Biru Gelap
              Color(0xFF2C5364), // Biru Laut Dalam
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. LOGO & HEADER
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                      boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
                    ),
                    child: const Icon(Icons.gamepad_rounded, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Selamat Datang",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Silakan masuk untuk mulai bermain",
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 40),

                  // 2. FORM INPUT (CARD GLASSMORPHISM)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1), // Transparan
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      children: [
                        // Input Email
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Email Address",
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Input Password
                        TextField(
                          controller: _passwordController,
                          style: const TextStyle(color: Colors.white),
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white70),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white54),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {}, 
                            child: Text("Lupa Password?", style: TextStyle(color: Colors.blue[200], fontSize: 12)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tombol Login Gradient
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF0072FF)]), // Electric Blue Gradient
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading 
                                ? const CircularProgressIndicator(color: Colors.white) 
                                : const Text("MASUK SEKARANG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 3. FOOTER REGISTER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Belum punya akun? ", style: TextStyle(color: Colors.white.withOpacity(0.7))),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
                        child: const Text("Daftar disini", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C6FF))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}