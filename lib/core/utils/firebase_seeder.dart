import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/home/data/console_model.dart';

class FirebaseSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<ConsoleModel> _dummyConsoles = [
    ConsoleModel(
      id: '', // <--- INI YANG TADI KURANG (Cuma dummy, nanti diganti Firebase)
      name: "PlayStation 5 Standard",
      type: "PS5",
      price: 25000,
      isAvailable: true,
      imageUrl: "https://gmedia.playstation.com/is/image/SIEPDC/ps5-product-thumbnail-01-en-14sep21",
    ),
    ConsoleModel(
      id: '', // <--- INI JUGA
      name: "PlayStation 4 Pro",
      type: "PS4",
      price: 15000,
      isAvailable: true,
      imageUrl: "https://gmedia.playstation.com/is/image/SIEPDC/ps4-pro-product-thumbnail-01-en-14sep21",
    ),
  ];

  Future<void> seedConsoles() async {
    WriteBatch batch = _firestore.batch();
    
    for (var console in _dummyConsoles) {
      // Kita minta Firebase buatkan ID baru
      DocumentReference docRef = _firestore.collection('consoles').doc(); 
      
      // Kita simpan data tanpa field 'id' (karena id sudah jadi nama dokumen)
      batch.set(docRef, console.toMap());
    }

    await batch.commit();
    print("DATA SEEDER BERHASIL DIUPLOAD!");
  }
}