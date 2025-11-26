import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORT LOGIC & DATA ---
import 'home_cubit.dart';
import '../data/home_repository.dart';
import '../data/console_model.dart';

// --- IMPORT HALAMAN LAIN ---
import 'console_detail_page.dart';
import '../../booking/presentation/history_page.dart';
import '../../auth/presentation/login_page.dart';
import 'admin_dashboard_page.dart';
import 'profile_sub_pages.dart'; 
import 'notification_page.dart'; // <--- SAYA CUMA NAMBAH INI

// --- IMPORT WIDGET LOADING ---
import '../../../../core/presentation/ps_loading_widget.dart';

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
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).cardColor,
          selectedItemColor: Colors.blue[800],
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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

// ============================================================================
// TAB 1: HOME TAB 
// ============================================================================
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? (user?.email?.split('@')[0] ?? "Gamers");

    return BlocProvider(
      create: (context) => HomeCubit(HomeRepository())..loadConsoles(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Stack(
                children: [
                  Container(
                    height: 260,
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.blue[900]!, Colors.blue[600]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
                      boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
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
                                Text("Halo, ${userName.toUpperCase()}", style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1)),
                                const SizedBox(height: 5),
                                const Text("Mau main apa?", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                              ],
                            ),
                            
                            // --- BAGIAN INI SAYA UBAH SEDIKIT AGAR BISA DIKLIK ---
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationPage()));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.3))),
                                child: Stack(
                                  children: [
                                    const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
                                    // Logika Titik Merah (Badge)
                                    Positioned(
                                      right: 0, top: 0,
                                      child: StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance.collection('notifications')
                                            .where('isRead', isEqualTo: false) 
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                            return Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle));
                                          }
                                          return const SizedBox();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            // ----------------------------------------------------
                          ],
                        ),
                        const SizedBox(height: 25),
                        
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance.collection('settings').doc('store_info').snapshots(),
                          builder: (context, snapshot) {
                            String shopName = "PS Rental Pro"; String shopAddress = "Jakarta";
                            if (snapshot.hasData && snapshot.data!.exists) { final data = snapshot.data!.data() as Map<String, dynamic>; shopName = data['name'] ?? shopName; shopAddress = data['address'] ?? shopAddress; }
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(15)),
                              child: Row(children: [const Icon(Icons.location_on, color: Colors.white, size: 18), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(shopName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), Text(shopAddress, style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)]))]),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              Transform.translate(offset: const Offset(0, -25), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: _SearchWidget())),
              
              const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Promo Spesial 🔥", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('banners').where('isActive', isEqualTo: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Container(height: 140, margin: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)), child: const Center(child: Text("Belum ada promo", style: TextStyle(color: Colors.grey))));
                  return SizedBox(height: 160, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 15), itemCount: snapshot.data!.docs.length, itemBuilder: (context, index) { var data = snapshot.data!.docs[index].data() as Map<String, dynamic>; return Container(width: 280, margin: const EdgeInsets.symmetric(horizontal: 5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), image: DecorationImage(image: NetworkImage(data['imageUrl'] ?? ''), fit: BoxFit.cover), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: const Offset(0, 2))])); }));
                },
              ),

              const SizedBox(height: 25),

              const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Pilih Console", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),

              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) return const Padding(padding: EdgeInsets.all(20.0), child: PsLoadingWidget(size: 100)); 
                  if (state is HomeLoaded) {
                    if (state.consoles.isEmpty) return const Center(child: Text("Unit Kosong"));
                    return GridView.builder(padding: const EdgeInsets.symmetric(horizontal: 20), shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 16, mainAxisSpacing: 16), itemCount: state.consoles.length, itemBuilder: (context, index) => _buildCard(context, state.consoles[index]));
                  }
                  return const SizedBox();
                },
              ),

              const SizedBox(height: 25),

              const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Koleksi Game 🎮", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('games').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Padding(padding: EdgeInsets.only(left: 20, bottom: 30), child: Text("Belum ada data game."));
                  return SizedBox(height: 140, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 15), itemCount: snapshot.data!.docs.length, itemBuilder: (context, index) { var data = snapshot.data!.docs[index].data() as Map<String, dynamic>; return Container(width: 100, margin: const EdgeInsets.symmetric(horizontal: 5), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ClipRRect(borderRadius: BorderRadius.circular(10), child: CachedNetworkImage(imageUrl: data['imageUrl'] ?? '', height: 100, width: 100, fit: BoxFit.cover, placeholder: (c, u) => Container(color: Colors.grey[200]), errorWidget: (c, u, e) => const Icon(Icons.error))), const SizedBox(height: 5), Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis), Text(data['genre'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 10))])); }));
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// --- PROFILE TAB (KODE TETAP SAMA 100% SEPERTI YANG ANDA KIRIM) ---
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  void _handleLogout(BuildContext context) async { bool confirm = await showDialog(context: context, builder: (context) => AlertDialog(title: const Text("Keluar Aplikasi?"), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white), onPressed: () async { Navigator.pop(context); await FirebaseAuth.instance.signOut(); if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false); }, child: const Text("Ya, Keluar"))])) ?? false; }
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Silakan Login"));
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        String displayName = user.email?.split('@')[0] ?? "User"; String role = "user"; String displayEmail = user.email ?? "";
        if (snapshot.hasData && snapshot.data!.exists) { final data = snapshot.data!.data() as Map<String, dynamic>; displayName = data['displayName'] ?? displayName; role = data['role'] ?? "user"; }
        final bool isAdmin = role == 'admin';
        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F5),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(width: double.infinity, padding: const EdgeInsets.only(top: 70, bottom: 40), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)), boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))]), child: Column(children: [Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))]), child: CircleAvatar(radius: 55, backgroundColor: const Color(0xFFE3F2FD), child: Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : "U", style: const TextStyle(fontSize: 50, color: Color(0xFF1565C0), fontWeight: FontWeight.w900)))), const SizedBox(height: 16), Text(displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)), Text(displayEmail, style: const TextStyle(fontSize: 14, color: Colors.white70)), const SizedBox(height: 12), Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(isAdmin ? Icons.verified_user : Icons.account_circle, size: 18, color: isAdmin ? Colors.red[700] : Colors.blue[700]), const SizedBox(width: 8), Text(isAdmin ? "ADMINISTRATOR" : "VERIFIED MEMBER", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isAdmin ? Colors.red[700] : Colors.blue[900], letterSpacing: 1))]))])),
                const SizedBox(height: 25),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: [if (isAdmin) Padding(padding: const EdgeInsets.only(bottom: 15), child: _buildProfileCard(context, icon: Icons.admin_panel_settings_rounded, title: "Dashboard Admin", subtitle: "Panel Kontrol", iconColor: Colors.white, iconBgColor: Colors.redAccent, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboardPage())))), _buildProfileCard(context, icon: Icons.settings_rounded, title: "Pengaturan", subtitle: "Tema & Notifikasi", iconColor: Colors.white, iconBgColor: Colors.blueAccent, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()))), const SizedBox(height: 15), _buildProfileCard(context, icon: Icons.headset_mic_rounded, title: "Pusat Bantuan", subtitle: "FAQ", iconColor: Colors.white, iconBgColor: Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterPage()))), const SizedBox(height: 15), _buildProfileCard(context, icon: Icons.verified_user_rounded, title: "Kebijakan Privasi", subtitle: "Ketentuan", iconColor: Colors.white, iconBgColor: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()))), const SizedBox(height: 40), SizedBox(width: double.infinity, height: 55, child: ElevatedButton.icon(onPressed: () => _handleLogout(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white, elevation: 5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), icon: const Icon(Icons.logout_rounded, size: 24), label: const Text("KELUAR AKUN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)))), const SizedBox(height: 40)])),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildProfileCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap, required Color iconColor, required Color iconBgColor}) { return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))]), child: ListTile(onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: iconBgColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]), child: Icon(icon, color: iconColor, size: 24)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)), subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])), trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey))); }
}

class _SearchWidget extends StatelessWidget { const _SearchWidget(); @override Widget build(BuildContext context) { return Container(height: 60, decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]), child: Center(child: TextField(onChanged: (value) => context.read<HomeCubit>().searchConsole(value), decoration: InputDecoration(hintText: "Cari Console...", hintStyle: TextStyle(color: Colors.grey[400]), prefixIcon: Icon(Icons.search_rounded, color: Colors.blue[800], size: 28), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15))))); } }
Widget _buildCard(BuildContext context, ConsoleModel console) { final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0); return GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ConsoleDetailPage(console: console))), child: Container(decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: Stack(children: [ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Hero(tag: console.id.isEmpty ? console.name : console.id, child: CachedNetworkImage(imageUrl: console.imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorWidget: (c, u, e) => const Icon(Icons.error)))), Positioned(top: 12, right: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Theme.of(context).cardColor.withOpacity(0.95), borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]), child: Row(children: [Icon(Icons.circle, size: 10, color: console.isAvailable ? Colors.green : Colors.red), const SizedBox(width: 5), Text(console.isAvailable ? "Ready" : "Booked", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: console.isAvailable ? Colors.green[700] : Colors.red[700]))])))])) , Padding(padding: const EdgeInsets.all(14.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(console.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), Text(console.type, style: TextStyle(color: Colors.grey[500], fontSize: 12)), const SizedBox(height: 8), Text("${currencyFormatter.format(console.price)} /jam", style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w900, fontSize: 15))]))]))); }