import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'booking_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. CREATE BOOKING (Simpan data pesanan)
  Future<void> createBooking(BookingModel booking) async {
    return _firestore.runTransaction((transaction) async {
      final bookingRef = _firestore.collection('bookings').doc();
      final consoleRef = _firestore.collection('consoles').doc(booking.consoleId);

      transaction.set(bookingRef, booking.toMap());
      // Update status console jadi tidak tersedia
      transaction.update(consoleRef, {'isAvailable': false});
    });
  }

  // 2. GET HISTORY (Khusus User yang login)
  Stream<List<BookingModel>> getBookings() {
    final user = FirebaseAuth.instance.currentUser;
    final String myEmail = user?.email ?? ""; 
    return _firestore.collection('bookings')
        .where('userName', isEqualTo: myEmail)
        .orderBy('bookingDate', descending: true)
        .snapshots().map((snapshot) {
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

  // 3. FINISH BOOKING (Admin menyelesaikan pesanan)
  Future<void> finishBooking(String bookingId, String consoleId) async {
    return _firestore.runTransaction((transaction) async {
      final bookingRef = _firestore.collection('bookings').doc(bookingId);
      final consoleRef = _firestore.collection('consoles').doc(consoleId);
      // Update status booking jadi sukses
      transaction.update(bookingRef, {'status': 'success'});
      // Console jadi tersedia lagi
      transaction.update(consoleRef, {'isAvailable': true});
    });
  }

  // 4. GET ALL ACTIVE (Khusus Admin)
  Stream<List<BookingModel>> getAllActiveBookings() {
    return _firestore.collection('bookings')
        .where('status', isEqualTo: 'pending')
        .orderBy('bookingDate', descending: true)
        .snapshots().map((snapshot) {
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