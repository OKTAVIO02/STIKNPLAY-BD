import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String? id;
  final String consoleId;
  final String consoleName;
  final String userName;
  final DateTime bookingDate;
  final int durationHours;
  final int totalPrice;
  final String status;
  final String rentalType;
  final String paymentMethod;
  final int fine;
  final List<Map<String, dynamic>> accessories; // <--- FIELD BARU: LIST AKSESORIS

  BookingModel({
    this.id,
    required this.consoleId,
    required this.consoleName,
    required this.userName,
    required this.bookingDate,
    required this.durationHours,
    required this.totalPrice,
    this.status = 'pending',
    this.rentalType = 'Main di Tempat',
    this.paymentMethod = 'Tunai / Cash',
    this.fine = 0,
    this.accessories = const [], // Default kosong
  });

  Map<String, dynamic> toMap() {
    return {
      'consoleId': consoleId,
      'consoleName': consoleName,
      'userName': userName,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'durationHours': durationHours,
      'totalPrice': totalPrice,
      'status': status,
      'rentalType': rentalType,
      'paymentMethod': paymentMethod,
      'fine': fine,
      'accessories': accessories, // Simpan List Aksesoris
    };
  }

  factory BookingModel.fromMap(String id, Map<String, dynamic> map) {
    return BookingModel(
      id: id,
      consoleId: map['consoleId'] ?? '',
      consoleName: map['consoleName'] ?? '',
      userName: map['userName'] ?? '',
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
      durationHours: map['durationHours'] ?? 0,
      totalPrice: map['totalPrice'] ?? 0,
      status: map['status'] ?? 'pending',
      rentalType: map['rentalType'] ?? 'Main di Tempat',
      paymentMethod: map['paymentMethod'] ?? 'Tunai / Cash',
      fine: map['fine'] ?? 0,
      // Ambil List Aksesoris (pastikan di-cast ke List<Map>)
      accessories: List<Map<String, dynamic>>.from(map['accessories'] ?? []),
    );
  }
}