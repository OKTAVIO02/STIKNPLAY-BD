import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "Baru saja";
    DateTime date = timestamp.toDate();
    return DateFormat('dd MMM, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kotak Masuk", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: Colors.grey[50],
      
      // StreamBuilder untuk membaca pesan dari Admin
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user?.uid) // Filter pesan untuk user ini
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("Error: ${snapshot.error}")));
          }

          // Kosong
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("Belum ada pesan dari Admin", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // Daftar Pesan
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (c, i) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              bool isRead = data['isRead'] ?? false;

              return GestureDetector(
                onTap: () {
                  if (!isRead) {
                    FirebaseFirestore.instance.collection('notifications').doc(doc.id).update({'isRead': true});
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isRead ? Colors.white : Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
                    border: isRead ? null : Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: isRead ? Colors.grey[100] : Colors.blue[100], shape: BoxShape.circle),
                        child: Icon(Icons.notifications, color: isRead ? Colors.grey : Colors.blue[800], size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(data['title'] ?? "Info", style: TextStyle(fontWeight: isRead ? FontWeight.w600 : FontWeight.bold, fontSize: 15))),
                                if (!isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(data['body'] ?? "", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            const SizedBox(height: 8),
                            Text(_formatDate(data['timestamp']), style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}