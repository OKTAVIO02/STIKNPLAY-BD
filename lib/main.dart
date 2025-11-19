import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'firebase_options.dart';

// Import Halaman Awal
import 'core/presentation/splash_page.dart';

// Import Theme Cubit yang baru dibuat
import 'core/presentation/theme_cubit.dart'; 

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
    // 1. Bungkus MaterialApp dengan BlocProvider ThemeCubit
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Rental PlayStation',
            
            // 2. Konfigurasi Tema Terang (Light)
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light, // Mode Terang
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Abu muda
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),

            // 3. Konfigurasi Tema Gelap (Dark)
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark, // Mode Gelap
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF121212), // Hitam pekat
              cardColor: const Color(0xFF1E1E1E), // Abu gelap untuk Card
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E1E1E),
                foregroundColor: Colors.white,
              ),
            ),

            // 4. Logic Pemilihan Tema (Dikontrol oleh Cubit)
            themeMode: themeMode, 
            
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}