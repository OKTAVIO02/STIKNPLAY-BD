import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'core/presentation/splash_page.dart';
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
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Rental PlayStation',
            
            // --- TEMA TERANG (LIGHT) ---
            theme: ThemeData(
              brightness: Brightness.light,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
              scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Abu sangat muda
              cardColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue, 
                foregroundColor: Colors.white,
                elevation: 0
              ),
              // Warna teks otomatis hitam
            ),

            // --- TEMA GELAP (DARK) ---
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
              scaffoldBackgroundColor: const Color(0xFF121212), // Hitam pekat
              cardColor: const Color(0xFF1E1E1E), // Abu gelap (untuk Card)
              dividerColor: Colors.white24,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E1E1E), 
                foregroundColor: Colors.white,
                elevation: 0
              ),
              // Warna teks otomatis putih
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Color(0xFF1E1E1E),
                selectedItemColor: Colors.blueAccent,
                unselectedItemColor: Colors.grey,
              )
            ),

            themeMode: themeMode, // Dikontrol Cubit
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}