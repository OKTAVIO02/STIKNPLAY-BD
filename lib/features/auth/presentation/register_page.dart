import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart'; // Pastikan import ini benar

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controller
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // State
  bool _isLoading = false;
  bool _isPasswordVisible = false; 
  bool _isConfirmPasswordVisible = false; 

  // --- LOGIKA REGISTER ---
  void _register() async {
    // 1. Validasi Input Kosong
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Semua kolom wajib diisi!")));
      return;
    }

    // 2. Validasi Password Sama
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password tidak sama!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 3. Buat Akun di Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 4. Simpan Data User ke Firestore (Database)
      String uid = userCredential.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'displayName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': '-', // Default kosong
        'address': '-',     // Default kosong
        'photoURL': null,   // Default kosong (akan pakai inisial/asset)
        'role': 'user',     // Default jadi User biasa
        'createdAt': DateTime.now(),
      });

      // 5. Update Nama di Auth (Biar sinkron)
      await userCredential.user!.updateDisplayName(_nameController.text.trim());

      // 6. SUKSES -> LOGOUT -> PINDAH KE LOGIN PAGE
      await FirebaseAuth.instance.signOut(); // Logout sesi register

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Akun Berhasil Dibuat! Silakan Login."), 
            backgroundColor: Colors.green
          )
        );
        
        // Pindah ke Halaman Login (Hapus riwayat back)
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (context) => const LoginPage()), 
          (route) => false
        );
      }

    } on FirebaseAuthException catch (e) {
      String message = "Registrasi Gagal";
      if (e.code == 'weak-password') message = "Password terlalu lemah (min 6 karakter).";
      else if (e.code == 'email-already-in-use') message = "Email sudah terdaftar.";
      else if (e.code == 'invalid-email') message = "Format email salah.";
      
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- TAMPILAN UI (DARK LUXURY) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background Gradient Gelap
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. HEADER
                  const Text(
                    "Buat Akun Baru",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Gabung sekarang dan mulai main!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 30),

                  // 2. FORM INPUT (GLASS CARD)
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
                        // Input Nama
                        _buildPremiumTextField(
                          controller: _nameController,
                          hint: "Nama Lengkap",
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 16),

                        // Input Email
                        _buildPremiumTextField(
                          controller: _emailController,
                          hint: "Email Address",
                          icon: Icons.email_outlined,
                          inputType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        // Input Password
                        _buildPremiumTextField(
                          controller: _passwordController,
                          hint: "Password",
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          isVisible: _isPasswordVisible,
                          onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                        const SizedBox(height: 16),

                        // Input Konfirmasi Password
                        _buildPremiumTextField(
                          controller: _confirmPasswordController,
                          hint: "Ulangi Password",
                          icon: Icons.lock_reset_rounded,
                          isPassword: true,
                          isVisible: _isConfirmPasswordVisible,
                          onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                        ),
                        
                        const SizedBox(height: 30),

                        // Tombol Daftar
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF0072FF)]), // Electric Blue
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading 
                                ? const CircularProgressIndicator(color: Colors.white) 
                                : const Text("DAFTAR SEKARANG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 3. FOOTER (Ke Login)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Sudah punya akun? ", style: TextStyle(color: Colors.white.withOpacity(0.7))),
                      GestureDetector(
                        onTap: () => Navigator.pop(context), // Kembali ke Login
                        child: const Text("Masuk disini", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C6FF))),
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

  // --- WIDGET HELPER TEXTFIELD ---
  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: isPassword && !isVisible,
      keyboardType: inputType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white54),
              onPressed: onToggleVisibility,
            )
          : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}