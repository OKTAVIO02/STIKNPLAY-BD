import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_repository.dart';

// --- STATES ---
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

// --- CUBIT ---
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  // Logic Login
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _repository.login(email: email, password: password);
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthFailure("Login gagal. Periksa email dan password."));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // Logic Register (Update Disini)
  Future<void> register(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _repository.register(email: email, password: password);
      if (user != null) {
        // --- PERUBAHAN PENTING ---
        // Segera logout agar tidak auto-login
        await _repository.logout(); 
        
        emit(AuthSuccess(user));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}