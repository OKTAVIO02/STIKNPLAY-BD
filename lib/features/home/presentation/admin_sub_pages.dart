import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ============================================================================
// 1. HALAMAN MANAJEMEN USER (TETAP AMAN & FILTER DIRI SENDIRI)
// ============================================================================
class AdminUserManagementPage extends StatelessWidget {
  const AdminUserManagementPage({super.key});

  // Fungsi Ganti Role
  void _toggleRole(BuildContext context, String uid, String currentRole) {
    String newRole = currentRole == 'admin' ? 'user' : 'admin';
    FirebaseFirestore.instance.collection('users').doc(uid).update({'role': newRole});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Role diubah menjadi $newRole")));
  }

  // Fungsi Hapus User
  void _deleteUser(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E272E),
        title: const Text("Hapus User?", style: TextStyle(color: Colors.white)),
        content: const Text("Data user akan hilang permanen.", style: TextStyle(color: Colors.white70)),
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
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: const Text("Manajemen User", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0F2027), Color(0xFF203A43)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
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

                // --- FILTER: JANGAN TAMPILKAN DIRI SENDIRI ---
                if (currentUser != null && uid == currentUser.uid) {
                  return const SizedBox.shrink();
                }

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
// 2. HALAMAN INFORMASI RENTAL (EDIT NAMA TOKO & ALAMAT)
// ============================================================================
class AdminRentalInfoPage extends StatefulWidget {
  const AdminRentalInfoPage({super.key});

  @override
  State<AdminRentalInfoPage> createState() => _AdminRentalInfoPageState();
}

class _AdminRentalInfoPageState extends State<AdminRentalInfoPage> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStoreInfo();
  }

  void _loadStoreInfo() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('settings').doc('store_info').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _addressController.text = data['address'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Error loading store info: $e");
    }
  }

  void _saveStoreInfo() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('settings').doc('store_info').set({
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
      }, SetOptions(merge: true));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Info Toko Berhasil Disimpan!"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(title: const Text("Informasi Rental", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: const Icon(Icons.store_rounded, size: 60, color: Colors.white54)),
            const SizedBox(height: 20),
            const Text("Edit Profil Toko", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildDarkTextField(controller: _nameController, label: "Nama Toko (Header)", icon: Icons.branding_watermark),
            const SizedBox(height: 20),
            _buildDarkTextField(controller: _addressController, label: "Alamat Toko", icon: Icons.location_on),
            const SizedBox(height: 40),
            SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _isLoading ? null : _saveStoreInfo, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C6FF), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("SIMPAN PERUBAHAN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkTextField({required TextEditingController controller, required String label, required IconData icon}) {
    return Container(decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.2))), child: TextField(controller: controller, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)), prefixIcon: Icon(icon, color: const Color(0xFF00C6FF)), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16))));
  }
}

// ============================================================================
// 3. HALAMAN KONFIGURASI SISTEM (SUDAH JADI: DENDA & MAINTENANCE)
// ============================================================================
class AdminSystemConfigPage extends StatefulWidget {
  const AdminSystemConfigPage({super.key});

  @override
  State<AdminSystemConfigPage> createState() => _AdminSystemConfigPageState();
}

class _AdminSystemConfigPageState extends State<AdminSystemConfigPage> {
  final _fineController = TextEditingController(); 
  bool _maintenanceMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  // Load Data Config
  void _loadConfig() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('settings').doc('system_config').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _fineController.text = (data['finePerHour'] ?? '20000').toString();
          _maintenanceMode = data['maintenanceMode'] ?? false;
        });
      } else {
        _fineController.text = "20000"; // Default
      }
    } catch (e) {
      debugPrint("Gagal load config: $e");
    }
  }

  // Simpan Data Config
  void _saveConfig() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('settings').doc('system_config').set({
        'finePerHour': int.tryParse(_fineController.text) ?? 20000,
        'maintenanceMode': _maintenanceMode,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Konfigurasi Tersimpan!"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(title: const Text("Konfigurasi Sistem", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.settings_suggest, size: 80, color: Colors.white54),
            const SizedBox(height: 20),
            const Text("Pengaturan Global", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            // FORM DENDA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withOpacity(0.1))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("💰 Nominal Denda (Per Jam)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _fineController,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: "Rp ", prefixStyle: const TextStyle(color: Colors.greenAccent),
                      filled: true, fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text("Denda akan dihitung otomatis saat user terlambat.", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SAKLAR MAINTENANCE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withOpacity(0.1))),
              child: SwitchListTile(
                title: const Text("Mode Maintenance", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text("Aktifkan jika aplikasi sedang perbaikan.", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                value: _maintenanceMode,
                activeColor: Colors.redAccent,
                onChanged: (val) => setState(() => _maintenanceMode = val),
              ),
            ),

            const SizedBox(height: 40),
            
            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveConfig,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C6FF), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("SIMPAN PENGATURAN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 4. HALAMAN USER (SETTINGS, HELP, PRIVACY)
// ============================================================================
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(title: const Text("Pengaturan"), centerTitle: true),
      body: ListView(padding: const EdgeInsets.all(16), children: [_buildSwitchTile("Notifikasi", true), _buildSwitchTile("Mode Gelap", false), const Divider(), ListTile(title: const Text("Versi"), trailing: const Text("1.0.0", style: TextStyle(color: Colors.grey)))]),
    );
  }
  Widget _buildSwitchTile(String title, bool value) { return SwitchListTile(title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), value: value, onChanged: (val) {}, activeColor: Colors.blue); }
}

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(title: const Text("Pusat Bantuan"), centerTitle: true),
      body: ListView(padding: const EdgeInsets.all(16), children: const [ExpansionTile(title: Text("Cara Sewa?"), children: [Padding(padding: EdgeInsets.all(16.0), child: Text("Pilih console -> Klik Sewa."))]), ExpansionTile(title: Text("Denda?"), children: [Padding(padding: EdgeInsets.all(16.0), child: Text("Rp 20.000/jam."))])]),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(title: const Text("Kebijakan Privasi"), centerTitle: true),
      body: const SingleChildScrollView(padding: EdgeInsets.all(20), child: Text("Data Anda aman bersama kami.")),
    );
  }
}