import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/booking_repository.dart';
import '../data/booking_model.dart';

abstract class BookingState {}
class BookingInitial extends BookingState {}
class BookingLoading extends BookingState {}
class BookingSuccess extends BookingState {}
class BookingFailure extends BookingState {
  final String message;
  BookingFailure(this.message);
}

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _repository;

  BookingCubit(this._repository) : super(BookingInitial());

  // Fungsi Submit Booking (Langsung simpan ke DB)
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