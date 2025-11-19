import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Fungsi Login (Tetap)
  Future<User?> login({required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Terjadi kesalahan login: $e");
    }
  }

  // Fungsi Register (UPDATE: Tambah parameter username)
  Future<User?> register({
    required String username, // <--- Parameter Baru
    required String email, 
    required String password
  }) async {
    try {
      // 1. Buat Akun di Firebase
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // 2. Simpan Username ke Profil User (displayName)
      if (credential.user != null) {
        await credential.user!.updateDisplayName(username);
        await credential.user!.reload(); // Refresh data user
      }

      return _firebaseAuth.currentUser;
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

  // Cek User
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}