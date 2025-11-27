import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/booking_model.dart';
import '../data/booking_repository.dart';

// --- STATES ---
abstract class HistoryState {}
class HistoryLoading extends HistoryState {}
class HistoryLoaded extends HistoryState {
  final List<BookingModel> bookings;
  HistoryLoaded(this.bookings);
}
class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}

// --- CUBIT ---
class HistoryCubit extends Cubit<HistoryState> {
  final BookingRepository _repository;

  HistoryCubit(this._repository) : super(HistoryLoading());

  // Load data awal
  void loadHistory() {
    try {
      _repository.getBookings().listen((data) {
        emit(HistoryLoaded(data));
      }, onError: (error) {
        emit(HistoryError(error.toString()));
      });
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  // Fungsi baru: KEMBALIKAN UNIT
  Future<void> returnUnit(String bookingId, String consoleId, int calculatedFine) async {
    try {
      await _repository.finishBooking(bookingId, consoleId);
      // Kita tidak perlu emit state baru, karena Stream di loadHistory 
      // akan otomatis mendeteksi perubahan di Firebase dan update UI sendiri.
    } catch (e) {
      emit(HistoryError("Gagal update data: $e"));
    }
  }
}