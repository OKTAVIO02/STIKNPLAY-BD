import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================================
// 1. HALAMAN MANAJEMEN USER (YANG TADI KOSONG)
// ============================================================================
class AdminUserManagementPage extends StatelessWidget {
  const AdminUserManagementPage({super.key});

  // Fungsi Ganti Role (User <-> Admin)
  void _toggleRole(BuildContext context, String uid, String currentRole) {
    String newRole = currentRole == 'admin' ? 'user' : 'admin';
    FirebaseFirestore.instance.collection('users').doc(uid).update({'role': newRole});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Role diubah menjadi $newRole")));
  }

  // Fungsi Hapus User (Dari Database)
  void _deleteUser(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E272E),
        title: const Text("Hapus User?", style: TextStyle(color: Colors.white)),
        content: const Text("Data user akan hilang dari database.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              FirebaseFirestore.instance.collection('users').doc(uid).delete();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User berhasil dihapus")));
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027), // Dark Luxury
      appBar: AppBar(
        title: const Text("Manajemen User", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Belum ada user terdaftar.", style: TextStyle(color: Colors.white54)));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                String uid = snapshot.data!.docs[index].id;
                String role = data['role'] ?? 'user';
                bool isAdmin = role == 'admin';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isAdmin ? Colors.amber : Colors.blueAccent,
                      child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person, color: Colors.white),
                    ),
                    title: Text(data['displayName'] ?? "No Name", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['email'] ?? "-", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isAdmin ? Colors.amber.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(role.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isAdmin ? Colors.amber : Colors.blueAccent)),
                        )
                      ],
                    ),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      color: const Color(0xFF1E272E),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(children: [
                            Icon(Icons.swap_horiz, color: isAdmin ? Colors.blue : Colors.amber, size: 20),
                            const SizedBox(width: 10),
                            Text(isAdmin ? "Jadikan User" : "Jadikan Admin", style: const TextStyle(color: Colors.white))
                          ]),
                          onTap: () => _toggleRole(context, uid, role),
                        ),
                        PopupMenuItem(
                          child: const Row(children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 10),
                            Text("Hapus User", style: TextStyle(color: Colors.white))
                          ]),
                          onTap: () => Future.delayed(Duration.zero, () => _deleteUser(context, uid)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// 2. HALAMAN INFORMASI RENTAL (Hanya Teks Statis)
// ============================================================================
class AdminRentalInfoPage extends StatelessWidget {
  const AdminRentalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(title: const Text("Informasi Rental", style: TextStyle(color: Colors.white)), centerTitle: true, backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: const Center(child: Text("Halaman Informasi Rental\n(Bisa diisi form edit nama toko dll)", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54))),
    );
  }
}

// ============================================================================
// 3. HALAMAN KONFIGURASI SISTEM (Hanya Teks Statis)
// ============================================================================
class AdminSystemConfigPage extends StatelessWidget {
  const AdminSystemConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(title: const Text("Konfigurasi Sistem", style: TextStyle(color: Colors.white)), centerTitle: true, backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: const Center(child: Text("Halaman Konfigurasi Sistem\n(Bisa diisi setting denda/harga)", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54))),
    );
  }
}

// ============================================================================
// 4. HALAMAN PENGATURAN (USER)
// ============================================================================
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Light Mode untuk User
      appBar: AppBar(title: const Text("Pengaturan"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSwitchTile("Notifikasi", true),
          _buildSwitchTile("Mode Gelap", false),
          _buildSwitchTile("Suara Efek", true),
          const Divider(),
          ListTile(title: const Text("Versi Aplikasi"), trailing: const Text("1.0.0", style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value) {
    return SwitchListTile(title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), value: value, onChanged: (val) {}, activeColor: Colors.blue);
  }
}

// ============================================================================
// 5. HALAMAN PUSAT BANTUAN (USER)
// ============================================================================
class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(title: const Text("Pusat Bantuan"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ExpansionTile(title: Text("Cara Sewa Console?"), children: [Padding(padding: EdgeInsets.all(16.0), child: Text("Pilih console di beranda, klik 'Sewa Sekarang', pilih durasi, dan lakukan pembayaran."))]),
          ExpansionTile(title: Text("Apa Saja Syaratnya?"), children: [Padding(padding: EdgeInsets.all(16.0), child: Text("Cukup tinggalkan KTP/Identitas asli saat pengambilan unit."))]),
          ExpansionTile(title: Text("Bagaimana Jika Telat?"), children: [Padding(padding: EdgeInsets.all(16.0), child: Text("Keterlambatan akan dikenakan denda otomatis Rp 20.000/jam."))]),
        ],
      ),
    );
  }
}

// ============================================================================
// 6. HALAMAN KEBIJAKAN PRIVASI (USER)
// ============================================================================
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(title: const Text("Kebijakan Privasi"), centerTitle: true),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Kebijakan Privasi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Kami menghargai privasi Anda. Data yang Anda berikan (Nama, Email, No HP) hanya digunakan untuk keperluan transaksi sewa-menyewa dan tidak akan disebarluaskan ke pihak ketiga tanpa izin.", style: TextStyle(height: 1.5)),
            SizedBox(height: 20),
            Text("Keamanan Data", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Semua data transaksi disimpan secara aman menggunakan enkripsi standar industri.", style: TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }
}