import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Cubit ini menyimpan status: Apakah Dark Mode atau Light Mode?
class ThemeCubit extends Cubit<ThemeMode> {
  // Default: Light Mode
  ThemeCubit() : super(ThemeMode.light);

  // Fungsi untuk mengubah tema
  void toggleTheme(bool isDark) {
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}