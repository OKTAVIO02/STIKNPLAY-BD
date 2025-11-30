import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../data/console_model.dart';
import 'console_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      // BACKGROUND DARK LUXURY
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("Favorit Saya", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: StreamBuilder<QuerySnapshot>(
            // Filter favorit berdasarkan Email/UID user yang login
            stream: FirebaseFirestore.instance
                .collection('favorites')
                .where('userId', isEqualTo: user?.email ?? user?.uid) 
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 80, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text("Belum ada favorit.", style: TextStyle(color: Colors.white.withOpacity(0.5))),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  var data = doc.data() as Map<String, dynamic>;

                  // Kita buat ConsoleModel dari data favorit agar bisa diklik ke detail
                  ConsoleModel console = ConsoleModel(
                    id: data['consoleId'] ?? '',
                    name: data['consoleName'] ?? 'Unknown',
                    type: "Console", // Default karena di fav tidak simpan tipe
                    price: data['price'] ?? 0,
                    imageUrl: data['consoleImage'] ?? '',
                    isAvailable: true, // Default
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08), // Glass Effect
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: console.imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorWidget: (c, u, e) => const Icon(Icons.error, color: Colors.white),
                        ),
                      ),
                      title: Text(console.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                      subtitle: Text(currencyFormatter.format(console.price), style: const TextStyle(color: Color(0xFF00C6FF), fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () {
                          // Hapus dari favorit
                          FirebaseFirestore.instance.collection('favorites').doc(doc.id).delete();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dihapus dari favorit"), duration: Duration(seconds: 1)));
                        },
                      ),
                      onTap: () {
                        // Buka Detail Page
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ConsoleDetailPage(console: console)));
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}