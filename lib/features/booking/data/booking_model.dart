import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String? id;
  final String consoleId;
  final String consoleName;
  final String userName;
  final DateTime bookingDate;
  final int durationHours;
  final int totalPrice;
  final String status; // pending, success

  BookingModel({
    this.id,
    required this.consoleId,
    required this.consoleName,
    required this.userName,
    required this.bookingDate,
    required this.durationHours,
    required this.totalPrice,
    this.status = 'pending',
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
    };
  }
}