import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'features/home/presentation/home_page.dart'; // <-- HAPUS ATAU COMMENT INI
import 'core/presentation/splash_page.dart'; // <-- TAMBAHKAN INI (Arahkan ke file splash baru)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rental PlayStation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      // home: const HomePage(), // <-- GANTI INI
      home: const SplashPage(), // <-- JADI INI
    );
  }
}