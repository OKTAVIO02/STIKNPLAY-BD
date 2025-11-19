import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- Tambahkan Import Ini
import 'booking_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. BUAT BOOKING BARU (Tetap sama)
  Future<void> createBooking(BookingModel booking) async {
    return _firestore.runTransaction((transaction) async {
      final bookingRef = _firestore.collection('bookings').doc();
      final consoleRef = _firestore.collection('consoles').doc(booking.consoleId);

      transaction.set(bookingRef, booking.toMap());
      transaction.update(consoleRef, {'isAvailable': false});
    });
  }

  // 2. AMBIL DATA HISTORY (PERBAIKAN DISINI)
  Stream<List<BookingModel>> getBookings() {
    // Ambil Email User yang sedang Login saat ini
    final user = FirebaseAuth.instance.currentUser;
    final String myEmail = user?.email ?? ""; 

    return _firestore
        .collection('bookings')
        // --- FILTER PENTING: Hanya ambil data yang userName-nya sama dengan Email Saya ---
        .where('userName', isEqualTo: myEmail) 
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return BookingModel(
          id: doc.id,
          consoleId: data['consoleId'] ?? '',
          consoleName: data['consoleName'],
          userName: data['userName'],
          bookingDate: (data['bookingDate'] as Timestamp).toDate(),
          durationHours: data['durationHours'],
          totalPrice: data['totalPrice'],
          status: data['status'] ?? 'pending',
        );
      }).toList();
    });
  }

  // 3. SELESAIKAN SEWA (Tetap sama)
  Future<void> finishBooking(String bookingId, String consoleId) async {
    return _firestore.runTransaction((transaction) async {
      final bookingRef = _firestore.collection('bookings').doc(bookingId);
      final consoleRef = _firestore.collection('consoles').doc(consoleId);

      transaction.update(bookingRef, {'status': 'success'});
      transaction.update(consoleRef, {'isAvailable': true});
    });
  }

  // 4. KHUSUS ADMIN (Tetap sama)
  Stream<List<BookingModel>> getAllActiveBookings() {
    return _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'pending') 
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return BookingModel(
          id: doc.id,
          consoleId: data['consoleId'] ?? '',
          consoleName: data['consoleName'],
          userName: data['userName'],
          bookingDate: (data['bookingDate'] as Timestamp).toDate(),
          durationHours: data['durationHours'],
          totalPrice: data['totalPrice'],
          status: data['status'] ?? 'pending',
        );
      }).toList();
    });
  }
}