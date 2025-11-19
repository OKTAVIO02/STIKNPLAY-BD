import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/console_model.dart';
import '../data/home_repository.dart';

// --- STATES ---
abstract class HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final List<ConsoleModel> consoles;
  HomeLoaded(this.consoles);
}
class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

// --- CUBIT ---
class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;
  
  // Variabel Private: Untuk menyimpan BACKUP data asli dari Firebase
  // Gunanya agar saat search dihapus, data bisa kembali muncul semua
  List<ConsoleModel> _allConsoles = [];

  HomeCubit(this._repository) : super(HomeLoading());

  // Fungsi 1: Ambil Data dari Firebase
  void loadConsoles() {
    try {
      _repository.getConsoles().listen((data) {
        _allConsoles = data; // Simpan ke backup
        emit(HomeLoaded(data)); // Tampilkan ke UI
      }, onError: (error) {
        emit(HomeError(error.toString()));
      });
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  // Fungsi 2: Pencarian (Filter Data)
  void searchConsole(String query) {
    // Jika data belum siap, jangan lakukan apa-apa
    if (_allConsoles.isEmpty) return;

    if (query.isEmpty) {
      // Kalau kotak search kosong, tampilkan SEMUA data dari backup
      emit(HomeLoaded(_allConsoles));
    } else {
      // Kalau ada ketikan, filter list backup berdasarkan Nama
      final filteredList = _allConsoles.where((console) {
        return console.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
      
      emit(HomeLoaded(filteredList));
    }
  }
}