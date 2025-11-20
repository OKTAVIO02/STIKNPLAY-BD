import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// ============================================================================
// 1. HALAMAN INFORMASI RENTAL (Form Edit Profil Toko)
// ============================================================================
class AdminRentalInfoPage extends StatefulWidget {
  const AdminRentalInfoPage({super.key});

  @override
  State<AdminRentalInfoPage> createState() => _AdminRentalInfoPageState();
}

class _AdminRentalInfoPageState extends State<AdminRentalInfoPage> {
  final _nameController = TextEditingController(text: "PS Rental Pro");
  final _addressController = TextEditingController(text: "Jl. Sudirman No. 45, Jakarta");
  final _phoneController = TextEditingController(text: "0812-3456-7890");

  void _saveInfo() {
    // Simulasi Simpan ke Database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Informasi Toko Berhasil Disimpan!"), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Informasi Rental")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, backgroundColor: Colors.blue, child: Icon(Icons.store, size: 40, color: Colors.white)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nama Toko", border: OutlineInputBorder(), prefixIcon: Icon(Icons.storefront)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: "Alamat", border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Nomor WhatsApp Admin", border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveInfo,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
                child: const Text("SIMPAN PERUBAHAN"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. HALAMAN MANAJEMEN USER (List User dari Booking)
// ============================================================================
class AdminUserManagementPage extends StatelessWidget {
  const AdminUserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manajemen User")),
      body: StreamBuilder<QuerySnapshot>(
        // Mengambil data user dari history booking
        stream: FirebaseFirestore.instance.collection('bookings').orderBy('bookingDate', descending: true).limit(50).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Belum ada data user."));

          final docs = snapshot.data!.docs;
          
          // Menggunakan Set untuk menyaring email duplikat agar list unik
          final uniqueUsers = <String>{};
          final uniqueDocs = docs.where((doc) {
            final email = (doc.data() as Map<String, dynamic>)['userName'];
            return uniqueUsers.add(email);
          }).toList();

          return ListView.builder(
            itemCount: uniqueDocs.length,
            itemBuilder: (context, index) {
              final data = uniqueDocs[index].data() as Map<String, dynamic>;
              final email = data['userName'] ?? 'Unknown';
              final date = (data['bookingDate'] as Timestamp).toDate();
              final formattedDate = DateFormat('dd MMM yyyy').format(date);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(child: Text(email[0].toUpperCase())),
                  title: Text(email, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Terakhir sewa: $formattedDate"),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Detail user: $email")));
                    },
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

// ============================================================================
// 3. HALAMAN KONFIGURASI SISTEM
// ============================================================================
class AdminSystemConfigPage extends StatefulWidget {
  const AdminSystemConfigPage({super.key});

  @override
  State<AdminSystemConfigPage> createState() => _AdminSystemConfigPageState();
}

class _AdminSystemConfigPageState extends State<AdminSystemConfigPage> {
  bool _maintenanceMode = false;
  bool _allowBooking = true;
  bool _autoConfirm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Konfigurasi Sistem")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Mode Maintenance"),
                  subtitle: const Text("Tutup aplikasi sementara"),
                  value: _maintenanceMode,
                  secondary: const Icon(Icons.build_circle, color: Colors.orange),
                  onChanged: (val) => setState(() => _maintenanceMode = val),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text("Izinkan Sewa Baru"),
                  subtitle: const Text("User bisa order"),
                  value: _allowBooking,
                  secondary: const Icon(Icons.shopping_cart, color: Colors.green),
                  onChanged: (val) => setState(() => _allowBooking = val),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text("Auto-Confirm Pesanan"),
                  subtitle: const Text("Tanpa verifikasi manual"),
                  value: _autoConfirm,
                  secondary: const Icon(Icons.verified, color: Colors.blue),
                  onChanged: (val) => setState(() => _autoConfirm = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 4. HALAMAN PUSAT BANTUAN ADMIN
// ============================================================================
class AdminHelpCenterPage extends StatelessWidget {
  const AdminHelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bantuan Admin")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ExpansionTile(
              title: Text("Cara menambah unit?"),
              children: [Padding(padding: EdgeInsets.all(16), child: Text("Pergi ke tab 'Inventory' lalu klik tombol (+) Tambah Unit di pojok kanan bawah."))],
            ),
          ),
          SizedBox(height: 10),
          Card(
            child: ExpansionTile(
              title: Text("Cara menyelesaikan sewa?"),
              children: [Padding(padding: EdgeInsets.all(16), child: Text("Di tab 'Pesanan', cari pesanan yang aktif, lalu klik tombol 'TERIMA PENGEMBALIAN'."))],
            ),
          ),
          SizedBox(height: 10),
          Card(
            child: ExpansionTile(
              title: Text("Cara edit harga?"),
              children: [Padding(padding: EdgeInsets.all(16), child: Text("Di tab 'Inventory', klik icon titik tiga pada kartu unit, lalu pilih 'Edit'."))],
            ),
          ),
        ],
      ),
    );
  }
}