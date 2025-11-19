import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_cubit.dart';
import 'register_page.dart'; 
import '../data/auth_repository.dart';

import '../../home/presentation/home_page.dart'; 
import '../../home/presentation/admin_dashboard_page.dart'; // Import Admin

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(AuthRepository()),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // --- SETTING EMAIL ADMIN ---
  final String adminEmail = "admin@gmail.com"; // GANTI DENGAN EMAIL ADMIN ANDA

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // --- LOGIKA PEMISAHAN DISINI ---
            if (state.user.email == adminEmail) {
              // JIKA ADMIN -> Ke Admin Dashboard
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const AdminDashboardPage())
              );
            } else {
              // JIKA USER BIASA -> Ke Home User
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const HomePage())
              );
            }
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${state.message}"), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          // ... (Bagian Tampilan UI di bawah ini SAMA PERSIS, tidak ada yang berubah) ...
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gamepad, size: 80, color: Colors.blue[800]),
                const SizedBox(height: 20),
                const Text("PS RENTAL STIKNPLAY LOGIN", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),

                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state is AuthLoading 
                      ? null 
                      : () {
                          context.read<AuthCubit>().login(
                            _emailController.text, 
                            _passwordController.text
                          );
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: state is AuthLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("MASUK"),
                  ),
                ),
                
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text("Belum punya akun? Daftar disini"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}