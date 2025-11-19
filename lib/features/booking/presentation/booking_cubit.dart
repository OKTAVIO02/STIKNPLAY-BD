import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/booking_model.dart';      // Perhatikan titiknya cuma dua (..)
import '../data/booking_repository.dart'; // Perhatikan titiknya cuma dua (..)

// --- STATES (Status Transaksi) ---
abstract class BookingState {}
class BookingInitial extends BookingState {} // Diam
class BookingLoading extends BookingState {} // Loading
class BookingSuccess extends BookingState {} // Berhasil
class BookingFailure extends BookingState {  // Gagal
  final String message;
  BookingFailure(this.message);
}

// --- CUBIT (Logika Transaksi) ---
class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _repository;

  BookingCubit(this._repository) : super(BookingInitial());

  Future<void> submitBooking(BookingModel booking) async {
    emit(BookingLoading());
    
    try {
      await _repository.createBooking(booking);
      emit(BookingSuccess());
    } catch (e) {
      emit(BookingFailure(e.toString()));
    }
  }
}