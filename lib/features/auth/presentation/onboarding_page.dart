import 'package:flutter/material.dart';
import 'login_page.dart'; // Pastikan import ini sesuai lokasi login_page.dart Anda

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Data Slide Onboarding
  final List<Map<String, dynamic>> _contents = [
    {
      "icon": Icons.gamepad_rounded,
      "title": "Sewa Console Jadi Mudah",
      "desc":
          "Pilih PlayStation favoritmu, tentukan durasi, dan mainkan sepuasnya tanpa ribet."
    },
    {
      "icon": Icons.delivery_dining_rounded,
      "title": "Antar Jemput Unit",
      "desc":
          "Bisa main di tempat atau bawa pulang. Kami siap antar unit ke rumahmu dengan aman."
    },
    {
      "icon": Icons.verified_user_rounded,
      "title": "Aman & Terpercaya",
      "desc":
          "Unit terawat, stik original, dan transaksi transparan dengan sistem denda otomatis."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BACKGROUND DARK LUXURY (Senada dengan Login & Home)
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- TOMBOL SKIP (Pojok Kanan Atas) ---
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage())),
                  child: const Text("LEWATI",
                      style: TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.bold)),
                ),
              ),

              // --- AREA GAMBAR & TEKS (SLIDER) ---
              Expanded(
                flex: 3,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemCount: _contents.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Lingkaran Icon Glowing (Glassmorphism)
                          Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0xFF00C6FF)
                                        .withOpacity(0.4),
                                    blurRadius: 30,
                                    spreadRadius: 5)
                              ],
                            ),
                            child: Icon(_contents[index]['icon'],
                                size: 100, color: Colors.white),
                          ),
                          const SizedBox(height: 40),

                          // Judul Slide
                          Text(
                            _contents[index]['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 15),

                          // Deskripsi Slide
                          Text(
                            _contents[index]['desc'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                                height: 1.5),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // --- AREA INDIKATOR & TOMBOL ---
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Indikator Titik-Titik
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_contents.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          height: 8,
                          width: _currentIndex == index
                              ? 25
                              : 8, // Titik aktif lebih panjang
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? const Color(0xFF00C6FF)
                                : Colors.grey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        );
                      }),
                    ),
                    const Spacer(),

                    // Tombol "Mulai Sekarang" / "Lanjut"
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 30),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentIndex == _contents.length - 1) {
                              // Jika slide terakhir, pindah ke Login
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()));
                            } else {
                              // Geser ke slide berikutnya
                              _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF00C6FF), // Electric Blue
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            elevation: 10,
                            shadowColor:
                                const Color(0xFF00C6FF).withOpacity(0.5),
                          ),
                          child: Text(
                            _currentIndex == _contents.length - 1
                                ? "MULAI SEKARANG"
                                : "LANJUT",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
