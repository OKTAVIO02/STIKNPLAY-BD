import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// ============================================================================
// 1. HALAMAN INFORMASI RENTAL (TERHUBUNG DATABASE)
// ============================================================================
class AdminRentalInfoPage extends StatefulWidget {
  const AdminRentalInfoPage({super.key});

  @override
  State<AdminRentalInfoPage> createState() => _AdminRentalInfoPageState();
}

class _AdminRentalInfoPageState extends State<AdminRentalInfoPage> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentInfo();
  }

  // Ambil data yang sudah ada di database
  void _loadCurrentInfo() async {
    final doc = await FirebaseFirestore.instance.collection('settings').doc('store_info').get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['name'] ?? "PS Rental Pro";
        _addressController.text = data['address'] ?? "Jakarta, Indonesia";
        _phoneController.text = data['phone'] ?? "";
        _isLoading = false;
      });
    } else {
      setState(() {
        _nameController.text = "PS Rental Pro";
        _addressController.text = "Lokasi Belum Diatur";
        _isLoading = false;
      });
    }
  }

  void _saveInfo() async {
    setState(() => _isLoading = true);
    
    // Simpan ke Collection 'settings', Dokumen 'store_info'
    await FirebaseFirestore.instance.collection('settings').doc('store_info').set({
      'name': _nameController.text,
      'address': _addressController.text,
      'phone': _phoneController.text,
    });

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Informasi Toko Berhasil Disimpan ke Database!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Informasi Rental")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // HEADER PREVIEW
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[800],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.store_mall_directory_rounded, size: 50, color: Colors.white),
                      const SizedBox(height: 10),
                      Text(
                        _nameController.text.isEmpty ? "Nama Toko" : _nameController.text, 
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: Colors.white, size: 16),
                            const SizedBox(width: 5),
                            Flexible(child: Text(_addressController.text.isEmpty ? "Alamat" : _addressController.text, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                const Text("Edit Detail Toko", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 15),

                // FORMULIR
                TextFormField(
                  controller: _nameController,
                  onChanged: (val) => setState(() {}), 
                  decoration: InputDecoration(labelText: "Nama Toko", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.storefront)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(labelText: "Alamat Lengkap", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.map)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: "Nomor WhatsApp Admin", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.phone)),
                ),
                const SizedBox(height: 30),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800], foregroundColor: Colors.white, 
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: const Text("SIMPAN KE DATABASE"),
                  ),
                )
              ],
            ),
          ),
    );
  }
}

// ... (Pastikan class AdminUserManagementPage, AdminSystemConfigPage, AdminHelpCenterPage tetap ada di bawah sini seperti kode sebelumnya) ...
// Agar kode tidak error, biarkan class-class lain tetap ada.
class AdminUserManagementPage extends StatelessWidget { const AdminUserManagementPage({super.key}); @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("Manajemen User")), body: const Center(child: Text("Fitur Manajemen User"))); } }
class AdminSystemConfigPage extends StatelessWidget { const AdminSystemConfigPage({super.key}); @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("Konfigurasi")), body: const Center(child: Text("Fitur Config"))); } }
class AdminHelpCenterPage extends StatelessWidget { const AdminHelpCenterPage({super.key}); @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("Bantuan Admin")), body: const Center(child: Text("Fitur Bantuan"))); } }