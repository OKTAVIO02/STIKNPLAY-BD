import 'package:flutter/material.dart';
import '../data/home_repository.dart';
import '../data/console_model.dart';

class EditConsolePage extends StatefulWidget {
  final ConsoleModel console; // Menerima data lama

  const EditConsolePage({super.key, required this.console});

  @override
  State<EditConsolePage> createState() => _EditConsolePageState();
}

class _EditConsolePageState extends State<EditConsolePage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  
  late String _selectedType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Masukkan data lama ke dalam formulir
    _nameController = TextEditingController(text: widget.console.name);
    _priceController = TextEditingController(text: widget.console.price.toString());
    _imageController = TextEditingController(text: widget.console.imageUrl);
    _selectedType = widget.console.type;
  }

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final updatedConsole = ConsoleModel(
          id: widget.console.id, // ID JANGAN BERUBAH
          name: _nameController.text,
          type: _selectedType,
          price: int.parse(_priceController.text),
          isAvailable: widget.console.isAvailable,
          imageUrl: _imageController.text,
        );

        // Panggil fungsi Update
        await HomeRepository().updateConsole(updatedConsole);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Data berhasil diperbarui!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context); // Kembali
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
      appBar: AppBar(
        title: const Text("Edit Data Unit"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nama Unit", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Harga (Rp)", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: "Tipe", border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'PS5', child: Text("PlayStation 5")),
                  DropdownMenuItem(value: 'PS4', child: Text("PlayStation 4")),
                  DropdownMenuItem(value: 'XBOX', child: Text("Xbox Series X")),
                ],
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: "Link Gambar", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SIMPAN PERUBAHAN"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}