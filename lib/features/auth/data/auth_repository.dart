import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Fungsi Login
  Future<User?> login({required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      // Menangani error spesifik (misal: password salah)
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Terjadi kesalahan login: $e");
    }
  }

  // Fungsi Register (Daftar)
  Future<User?> register({required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Gagal mendaftar: $e");
    }
  }

  // Fungsi Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Cek siapa yang sedang login sekarang
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
