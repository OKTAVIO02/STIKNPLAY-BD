import 'package:flutter/material.dart';
import '../data/home_repository.dart';
import '../data/console_model.dart';

class AddConsolePage extends StatefulWidget {
  const AddConsolePage({super.key});

  @override
  State<AddConsolePage> createState() => _AddConsolePageState();
}

class _AddConsolePageState extends State<AddConsolePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk menangkap ketikan user
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  
  String _selectedType = 'PS5'; // Default pilihan
  bool _isLoading = false;

  // Fungsi saat tombol SIMPAN ditekan
  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Bungkus data ke dalam Model
        final newConsole = ConsoleModel(
          id: '', // ID dikosongkan karena nanti diisi otomatis di Repository
          name: _nameController.text,
          type: _selectedType,
          price: int.parse(_priceController.text), // Ubah text jadi angka
          isAvailable: true,
          imageUrl: _imageController.text,
        );

        // Kirim ke Firebase lewat Repository
        await HomeRepository().addConsole(newConsole);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Unit berhasil ditambahkan!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context); // Tutup halaman & kembali ke dashboard
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Unit Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. INPUT NAMA
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Unit (Misal: PS5 Digital #3)", 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.videogame_asset),
                ),
                validator: (value) => value!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

              // 2. INPUT HARGA
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number, // Keyboard angka
                decoration: const InputDecoration(
                  labelText: "Harga Sewa per Jam (Rp)", 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monetization_on),
                ),
                validator: (value) => value!.isEmpty ? "Harga wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // 3. PILIHAN TIPE (Dropdown)
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: "Tipe Console", 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'PS5', child: Text("PlayStation 5")),
                  DropdownMenuItem(value: 'PS4', child: Text("PlayStation 4")),
                  DropdownMenuItem(value: 'XBOX', child: Text("Xbox Series X")),
                ],
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),

              // 4. INPUT GAMBAR (Link URL)
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: "Link Gambar (URL)", 
                  border: OutlineInputBorder(),
                  hintText: "https://...",
                  prefixIcon: Icon(Icons.image),
                ),
                validator: (value) => value!.isEmpty ? "Link gambar wajib diisi" : null,
              ),
              const SizedBox(height: 8),
              const Text(
                "*Tips: Cari gambar di Google -> Klik Kanan -> Copy Image Address", 
                style: TextStyle(color: Colors.grey, fontSize: 12)
              ),
              
              const SizedBox(height: 30),

              // 5. TOMBOL SIMPAN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SIMPAN UNIT KE DATABASE"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}