import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import ThemeCubit (Sesuaikan path-nya jika berbeda)
import '../../../../core/presentation/theme_cubit.dart';

// ============================================================================
// 1. HALAMAN PENGATURAN (SETTINGS)
// ============================================================================
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifEnabled = true;
  String _selectedLanguage = "Bahasa Indonesia";

  // Fungsi Ganti Bahasa (Hanya UI simulasi)
  void _changeLanguage() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Pilih Bahasa", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Text("🇮🇩", style: TextStyle(fontSize: 24)),
                title: const Text("Bahasa Indonesia"),
                trailing: _selectedLanguage == "Bahasa Indonesia" ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  setState(() => _selectedLanguage = "Bahasa Indonesia");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text("🇺🇸", style: TextStyle(fontSize: 24)),
                title: const Text("English"),
                trailing: _selectedLanguage == "English" ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  setState(() => _selectedLanguage = "English");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _checkUpdate() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sedang memeriksa pembaruan...")));
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Versi Terbaru"),
            content: const Text("Aplikasi Anda sudah versi terbaru (v1.0.0)."),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // MENDENGARKAN PERUBAHAN TEMA DARI CUBIT
    // true jika Dark, false jika Light
    final isDarkMode = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan Aplikasi")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Preferensi", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          Card(
            elevation: 0,
            // Menggunakan warna card dari tema yang sedang aktif
            color: Theme.of(context).cardColor, 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Notifikasi"),
                  subtitle: Text(_notifEnabled ? "Aktif" : "Nonaktif"),
                  value: _notifEnabled,
                  activeColor: Colors.blue[800],
                  secondary: Icon(Icons.notifications_active_rounded, color: Colors.blue[800]),
                  onChanged: (val) {
                    setState(() => _notifEnabled = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(val ? "Notifikasi Diaktifkan" : "Notifikasi Dimatikan"), duration: const Duration(seconds: 1)),
                    );
                  },
                ),
                const Divider(height: 1),
                
                // --- SWITCH MODE GELAP ---
                SwitchListTile(
                  title: const Text("Mode Gelap"),
                  subtitle: Text(isDarkMode ? "Tema Gelap" : "Tema Terang"),
                  value: isDarkMode,
                  activeColor: Colors.blue[800],
                  secondary: Icon(Icons.dark_mode_rounded, color: Colors.blue[800]),
                  onChanged: (val) {
                    // Panggil fungsi toggleTheme di ThemeCubit
                    context.read<ThemeCubit>().toggleTheme(val);
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text("Umum", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          Card(
             elevation: 0,
             color: Theme.of(context).cardColor,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
             child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.language, color: Colors.blue[800]),
                  title: const Text("Bahasa"),
                  subtitle: Text(_selectedLanguage),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: _changeLanguage,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.info_outline_rounded, color: Colors.blue[800]),
                  title: const Text("Versi Aplikasi"),
                  subtitle: const Text("v1.0.0 (Release)"),
                  trailing: const Icon(Icons.refresh, size: 18),
                  onTap: _checkUpdate,
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
// 2. HALAMAN PUSAT BANTUAN (Sama seperti sebelumnya)
// ============================================================================
class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pusat Bantuan")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.blue[800], borderRadius: BorderRadius.circular(16)),
            child: const Row(
              children: [
                Icon(Icons.support_agent, size: 40, color: Colors.white),
                SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Butuh Bantuan?", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), Text("Temukan jawaban atau hubungi kami.", style: TextStyle(color: Colors.white70, fontSize: 12))])),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text("Pertanyaan Umum (FAQ)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          _buildFAQItem("Bagaimana cara menyewa?", "Pilih console di halaman beranda, klik tombol 'Sewa Sekarang'."),
          _buildFAQItem("Metode pembayaran?", "Tunai di toko atau Transfer Bank."),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String q, String a) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(title: Text(q, style: const TextStyle(fontWeight: FontWeight.bold)), children: [Padding(padding: const EdgeInsets.all(16), child: Text(a))]),
    );
  }
}

// ============================================================================
// 3. HALAMAN KEBIJAKAN PRIVASI (Sama seperti sebelumnya)
// ============================================================================
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kebijakan Privasi")),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ketentuan & Privasi", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text("1. Pengumpulan Data\nKami mengumpulkan data email untuk login.\n\n2. Keamanan\nData aman di Firebase Google.", style: TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }
}