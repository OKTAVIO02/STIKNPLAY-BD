import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PsLoadingWidget extends StatelessWidget {
  // Ukuran default jika tidak diatur
  final double size;

  const PsLoadingWidget({super.key, this.size = 150});

  @override
  Widget build(BuildContext context) {
    // Menggunakan Center agar animasi selalu di tengah
    return Center(
      // Menggunakan Lottie.network untuk mengambil animasi dari internet langsung.
      // Jika Anda nanti punya file .json sendiri, ganti jadi Lottie.asset('assets/...')
      child: Lottie.network(
        // URL Animasi Lottie Controller Putih (Contoh Publik)
        'https://assets2.lottiefiles.com/packages/lf20_u4yrau.json',
        width: size,
        height: size,
        fit: BoxFit.contain,
        // Opsional: Memberi warna jika ingin mengubah warna default animasi
        // color: Colors.blue[800], 
      ),
    );
  }
}