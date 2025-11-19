import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_cubit.dart';
import '../data/home_repository.dart';
import '../data/console_model.dart';
import 'console_detail_page.dart';
import '../../booking/presentation/history_page.dart';
import '../../auth/presentation/login_page.dart';

// Note: Tidak perlu import AdminDashboard lagi disini

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; 

  final List<Widget> _pages = [
    const HomeTab(),    
    const HistoryPage(), 
    const ProfileTab(),  
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue[800],
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Beranda"),
            BottomNavigationBarItem(icon: Icon(Icons.history_edu_rounded), label: "Riwayat"),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Akun"),
          ],
        ),
      ),
    );
  }
}

// --- TAB HOME & SEARCH (Tetap Sama) ---
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(HomeRepository())..loadConsoles(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text("Rental PlayStation", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            _SearchWidget(),
            Expanded(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) return const Center(child: CircularProgressIndicator());
                  if (state is HomeError) return Center(child: Text("Error: ${state.message}"));
                  if (state is HomeLoaded) {
                    if (state.consoles.isEmpty) return const Center(child: Text("Unit tidak ditemukan"));
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 16, mainAxisSpacing: 16,
                      ),
                      itemCount: state.consoles.length,
                      itemBuilder: (context, index) => _buildCard(context, state.consoles[index]),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- TAB PROFIL (Bersih dari menu Admin) ---
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  void _handleLogout(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Keluar Aplikasi?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Keluar", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? "Tamu";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Akun Saya"), centerTitle: true, elevation: 0, backgroundColor: Colors.white, automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50, backgroundColor: Colors.blue[100],
                    child: Text(userEmail.isNotEmpty ? userEmail[0].toUpperCase() : "G", style: TextStyle(fontSize: 40, color: Colors.blue[800], fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  Text(userEmail, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text("Member Setia", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Menu User Biasa
            _buildProfileItem(icon: Icons.settings, title: "Pengaturan Aplikasi"),
            _buildProfileItem(icon: Icons.help_outline, title: "Pusat Bantuan"),
            _buildProfileItem(icon: Icons.privacy_tip_outlined, title: "Kebijakan Privasi"),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50], foregroundColor: Colors.red, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Keluar Akun", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({required IconData icon, required String title}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }
}

// --- WIDGET PENDUKUNG (Copy paste saja dari sebelumnya) ---
class _SearchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16), color: Colors.white,
      child: TextField(
        onChanged: (value) => context.read<HomeCubit>().searchConsole(value),
        decoration: InputDecoration(hintText: "Cari PS4, PS5...", prefixIcon: const Icon(Icons.search, color: Colors.grey), filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none)),
      ),
    );
  }
}

Widget _buildCard(BuildContext context, ConsoleModel console) {
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ConsoleDetailPage(console: console))),
    child: Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Hero(tag: console.id.isEmpty ? console.name : console.id, child: CachedNetworkImage(imageUrl: console.imageUrl, fit: BoxFit.cover, width: double.infinity, placeholder: (context, url) => Container(color: Colors.grey[200]), errorWidget: (context, url, error) => const Icon(Icons.error))))),
          Padding(padding: const EdgeInsets.all(10.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(console.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text("${currencyFormatter.format(console.price)} /jam", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)), const SizedBox(height: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: console.isAvailable ? Colors.green[50] : Colors.red[50], borderRadius: BorderRadius.circular(4), border: Border.all(color: console.isAvailable ? Colors.green : Colors.red, width: 0.5)), child: Text(console.isAvailable ? "Tersedia" : "Disewa", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: console.isAvailable ? Colors.green[700] : Colors.red[700])))])),
        ],
      ),
    ),
  );
}