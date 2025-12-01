import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BACKGROUND DARK LUXURY
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("Tentang Kami", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // LOGO APLIKASI
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF00C6FF).withOpacity(0.4), blurRadius: 30, spreadRadius: 5)
                    ],
                  ),
                  child: const Icon(Icons.gamepad_rounded, size: 80, color: Colors.white),
                ),
                
                const SizedBox(height: 20),
                const Text("PS RENTAL PRO", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
                Text("Versi 1.0.0", style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5))),

                const SizedBox(height: 40),

                // KARTU DESKRIPSI (GLASS STYLE)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Tentang Aplikasi",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF00C6FF)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "PS Rental Pro adalah solusi terbaik bagi para gamers yang ingin menikmati pengalaman bermain PlayStation terbaru tanpa harus membelinya. Kami menyediakan unit PS4 & PS5 dengan kualitas terbaik, stik original, dan koleksi game terlengkap.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // KONTAK DEVELOPER / TOKO
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      const Text("Hubungi Kami", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00C6FF))),
                      const SizedBox(height: 15),
                      _buildContactRow(Icons.email, "support@psrentalpro.com"),
                      const SizedBox(height: 10),
                      _buildContactRow(Icons.map, "Jl. Gamers No. 1, Jakarta"),
                      const SizedBox(height: 10),
                      _buildContactRow(Icons.language, "www.psrentalpro.com"),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                Text("© 2024 PS Rental Pro Inc.", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}