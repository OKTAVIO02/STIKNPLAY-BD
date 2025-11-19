import 'package:cloud_firestore/cloud_firestore.dart';
import 'console_model.dart';

class HomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. AMBIL DATA (Read)
  Stream<List<ConsoleModel>> getConsoles() {
    return _firestore.collection('consoles').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ConsoleModel.fromFirestore(doc);
      }).toList();
    });
  }

  // 2. TAMBAH DATA (Create)
  Future<void> addConsole(ConsoleModel console) async {
    try {
      final docRef = _firestore.collection('consoles').doc();
      final newConsole = ConsoleModel(
        id: docRef.id, 
        name: console.name,
        type: console.type,
        price: console.price,
        isAvailable: true,
        imageUrl: console.imageUrl,
      );
      await docRef.set(newConsole.toMap());
    } catch (e) {
      throw Exception("Gagal menambah unit: $e");
    }
  }

  // 3. UPDATE DATA (Edit)
  Future<void> updateConsole(ConsoleModel console) async {
    try {
      // Kita cari dokumen berdasarkan ID, lalu update isinya
      await _firestore.collection('consoles').doc(console.id).update({
        'name': console.name,
        'type': console.type,
        'price': console.price,
        'imageUrl': console.imageUrl,
        // isAvailable tidak diupdate disini agar status sewa tidak rusak
      });
    } catch (e) {
      throw Exception("Gagal mengupdate unit: $e");
    }
  }

  // 4. HAPUS DATA (Delete)
  Future<void> deleteConsole(String consoleId) async {
    try {
      await _firestore.collection('consoles').doc(consoleId).delete();
    } catch (e) {
      throw Exception("Gagal menghapus unit: $e");
    }
  }
}