import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSendNotifPage extends StatefulWidget {
  const AdminSendNotifPage({super.key});

  @override
  State<AdminSendNotifPage> createState() => _AdminSendNotifPageState();
}

class _AdminSendNotifPageState extends State<AdminSendNotifPage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isLoading = false;

  // Fungsi Kirim Pesan ke Firebase
  void _sendNotification(String userId, String userName) async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Judul dan Pesan tidak boleh kosong!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId, // ID User Tujuan
        'title': _titleController.text,
        'body': _bodyController.text,
        'isRead': false, // Agar muncul titik merah di HP User
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'admin_msg',
      });

      if (mounted) {
        Navigator.pop(context); // Tutup Dialog
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pesan terkirim ke $userName!"), backgroundColor: Colors.green));
        _titleController.clear();
        _bodyController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Dialog Form Input Pesan
  void _showSendDialog(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Kirim ke $userName"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Judul Pesan", hintText: "Contoh: Promo Spesial")),
            const SizedBox(height: 10),
            TextField(controller: _bodyController, maxLines: 3, decoration: const InputDecoration(labelText: "Isi Pesan", hintText: "Tulis pesan Anda...")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () => _sendNotification(userId, userName),
            child: const Text("Kirim"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kirim Notifikasi"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        // Ambil data semua user biasa (bukan admin)
        stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'user').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada user terdaftar."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              String name = data['displayName'] ?? "User";
              String email = data['email'] ?? "-";
              String uid = data['uid'];

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0].toUpperCase() : "?")),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(email),
                  trailing: IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () => _showSendDialog(uid, name),
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