import 'package:cloud_firestore/cloud_firestore.dart';

class ConsoleModel {
  final String id; // Kita butuh ID dokumen untuk nanti booking
  final String name;
  final String type;
  final int price;
  final bool isAvailable;
  final String imageUrl;

  ConsoleModel({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.isAvailable,
    required this.imageUrl,
  });

  // PENTING: Fungsi ini mengubah Data Firebase -> Data Aplikasi
  factory ConsoleModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ConsoleModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      price: data['price'] ?? 0,
      isAvailable: data['isAvailable'] ?? false,
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'price': price,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
    };
  }
}