import 'package:cloud_firestore/cloud_firestore.dart';
import 'console_model.dart';

class HomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. AMBIL DATA CONSOLE (Untuk Halaman Home)
  Stream<List<ConsoleModel>> getConsoles() {
    return _firestore.collection('consoles').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ConsoleModel.fromFirestore(doc);
      }).toList();
    });
  }

  // 2. TAMBAH UNIT BARU (Khusus Admin)
  Future<void> addConsole(ConsoleModel console) async {
    try {
      // Minta Firebase buatkan ID dokumen baru secara otomatis
      final docRef = _firestore.collection('consoles').doc();
      
      // Siapkan data yang mau disimpan
      // Kita paksa ID-nya sesuai dengan ID dokumen yang baru dibuat
      final newConsole = ConsoleModel(
        id: docRef.id, 
        name: console.name,
        type: console.type,
        price: console.price,
        isAvailable: true, // Default unit baru pasti tersedia
        imageUrl: console.imageUrl,
      );

      // Simpan ke Firestore
      await docRef.set(newConsole.toMap());
    } catch (e) {
      throw Exception("Gagal menambah unit: $e");
    }
  }
}