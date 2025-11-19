import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String? id;
  final String consoleId;   // <--- DATA PENTING BARU
  final String consoleName;
  final String userName;
  final DateTime bookingDate;
  final int durationHours;
  final int totalPrice;
  final String status;

  BookingModel({
    this.id,
    required this.consoleId, // <--- Wajib diisi
    required this.consoleName,
    required this.userName,
    required this.bookingDate,
    required this.durationHours,
    required this.totalPrice,
    this.status = 'pending',
  });

  // Mengubah Data Aplikasi -> Data Firebase (JSON)
  Map<String, dynamic> toMap() {
    return {
      'consoleId': consoleId, // <--- Ikut dikirim ke database
      'consoleName': consoleName,
      'userName': userName,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'durationHours': durationHours,
      'totalPrice': totalPrice,
      'status': status,
    };
  }
}