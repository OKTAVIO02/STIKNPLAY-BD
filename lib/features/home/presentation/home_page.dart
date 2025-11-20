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
import 'admin_dashboard_page.dart';
import 'profile_sub_pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [const HomeTab(), const HistoryPage(), const ProfileTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // DINAMIS
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).cardColor, // DINAMIS
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

// --- TAB 1: HOME ---
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? (user?.email?.split('@')[0] ?? "Gamers");

    return BlocProvider(
      create: (context) => HomeCubit(HomeRepository())..loadConsoles(),
      child: Scaffold(
        // Background otomatis ikut tema (Hitam/Putih)
        body: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.blue[900]!, Colors.blue[600]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Halo, ${userName.toUpperCase()}", style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              const Text("Mau main apa hari ini?", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.notifications_none_rounded, color: Colors.white))
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Transform.translate(offset: const Offset(0, -25), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: _SearchWidget())),
            Expanded(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) return const Center(child: CircularProgressIndicator());
                  if (state is HomeError) return Center(child: Text("Error: ${state.message}"));
                  if (state is HomeLoaded) {
                    if (state.consoles.isEmpty) return const Center(child: Text("Unit tidak ditemukan"));
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 16, mainAxisSpacing: 16),
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

// --- TAB 3: PROFILE ---
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  void _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? "Tamu";
    const String adminEmail = "admin@gmail.com"; 
    final bool isAdmin = userEmail == adminEmail;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 240, margin: const EdgeInsets.only(bottom: 50),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.blue[900]!, Colors.blue[600]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor, // DINAMIS
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: CircleAvatar(radius: 50, backgroundColor: Colors.blue[50], child: Text(userEmail.isNotEmpty ? userEmail[0].toUpperCase() : "G", style: TextStyle(fontSize: 40, color: Colors.blue[800], fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(height: 12),
                    Text(userEmail, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), // Warna teks otomatis
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: isAdmin ? Colors.red[50] : Colors.blue[50], borderRadius: BorderRadius.circular(20)),
                      child: Text(isAdmin ? "Administrator" : "Verified Member", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isAdmin ? Colors.red : Colors.blue[800])),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (isAdmin) Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: _buildProfileCard(context, icon: Icons.admin_panel_settings_rounded, title: "Dashboard Admin", subtitle: "Masuk ke panel pengelola", iconColor: Colors.red, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboardPage())))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileCard(context, icon: Icons.settings_rounded, title: "Pengaturan Aplikasi", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()))),
                  const SizedBox(height: 12),
                  _buildProfileCard(context, icon: Icons.headset_mic_rounded, title: "Pusat Bantuan", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterPage()))),
                  const SizedBox(height: 12),
                  _buildProfileCard(context, icon: Icons.privacy_tip_rounded, title: "Kebijakan Privasi", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()))),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleLogout(context),
                  style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.grey[800] : Colors.white, foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 15)),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text("Keluar Akun", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, {required IconData icon, required String title, String? subtitle, required VoidCallback onTap, Color iconColor = Colors.blue}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // DINAMIS
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent, borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap, borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 22)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)), if (subtitle != null) Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12))])),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- WIDGETS ---
class _SearchWidget extends StatelessWidget {
  const _SearchWidget();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // DINAMIS
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: TextField(
        onChanged: (value) => context.read<HomeCubit>().searchConsole(value),
        decoration: InputDecoration(hintText: "Cari Console...", hintStyle: TextStyle(color: Colors.grey[400]), prefixIcon: Icon(Icons.search_rounded, color: Colors.blue[800]), filled: true, fillColor: Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)),
      ),
    );
  }
}

Widget _buildCard(BuildContext context, ConsoleModel console) {
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ConsoleDetailPage(console: console))),
    child: Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: Stack(children: [ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Hero(tag: console.id.isEmpty ? console.name : console.id, child: CachedNetworkImage(imageUrl: console.imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity, placeholder: (context, url) => Container(color: Colors.grey[200]), errorWidget: (context, url, error) => const Icon(Icons.error)))), Positioned(top: 10, right: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Theme.of(context).cardColor.withOpacity(0.9), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 8, color: console.isAvailable ? Colors.green : Colors.red), const SizedBox(width: 4), Text(console.isAvailable ? "Ready" : "Booked", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: console.isAvailable ? Colors.green : Colors.red))])))])) ,
          Expanded(flex: 2, child: Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(console.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(height: 2), Text(console.type, style: TextStyle(color: Colors.grey[500], fontSize: 11))]), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${currencyFormatter.format(console.price)}", style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w800, fontSize: 14)), const Text("/jam", style: TextStyle(color: Colors.grey, fontSize: 10))])]))),
        ],
      ),
    ),
  );
}