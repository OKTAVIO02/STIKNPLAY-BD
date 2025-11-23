import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../booking/data/booking_repository.dart';
import '../../booking/data/booking_model.dart';
import '../../booking/presentation/history_cubit.dart';

import '../data/home_repository.dart';
import '../data/console_model.dart';
import 'home_cubit.dart';

import '../../auth/presentation/login_page.dart';
import 'add_console_page.dart';
import 'console_detail_page.dart';
import 'edit_console_page.dart'; 
import 'admin_sub_pages.dart'; // Pastikan file admin_sub_pages.dart sudah ada

// ============================================================================
// 1. CLASS UTAMA DASHBOARD
// ============================================================================
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0; 

  // Daftar Halaman Tab
  final List<Widget> _pages = [
    const AdminBookingTab(),   
    const AdminInventoryTab(), 
    const AdminAccountTab(),   
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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
          unselectedItemColor: Colors.grey[400],
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: "Pesanan"),
            BottomNavigationBarItem(icon: Icon(Icons.videogame_asset_rounded), label: "Inventory"),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Admin"),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. TAB PESANAN (BERSIH TANPA GAMBAR)
// ============================================================================
class AdminBookingTab extends StatelessWidget {
  const AdminBookingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryCubit(BookingRepository()), 
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pesanan Masuk", style: TextStyle(fontWeight: FontWeight.bold)), 
          centerTitle: true
        ),
        body: StreamBuilder<List<BookingModel>>(
          stream: BookingRepository().getAllActiveBookings(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

            final bookings = snapshot.data ?? [];

            if (bookings.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("Tidak ada pesanan aktif.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
                final dateFormat = DateFormat('dd MMM, HH:mm');
                
                return Card(
                  color: Theme.of(context).cardColor,
                  elevation: 2, 
                  margin: const EdgeInsets.only(bottom: 12), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                          children: [
                            Text(booking.consoleName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                              decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(6)), 
                              child: const Text("DISEWA", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10))
                            )
                          ]
                        ),
                        const Divider(),
                        Text("Penyewa: ${booking.userName}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("Mulai: ${dateFormat.format(booking.bookingDate)}"),
                        Text("Total: ${currencyFormatter.format(booking.totalPrice)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        const SizedBox(height: 16),
                        
                        // TOMBOL TERIMA PENGEMBALIAN (Tanpa Lihat Bukti)
                        SizedBox(
                          width: double.infinity, 
                          child: ElevatedButton.icon(
                            onPressed: (){ 
                               showDialog(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text("Selesaikan Sewa?"),
                                  content: Text("Pastikan unit '${booking.consoleName}' sudah kembali dan pembayaran lunas."),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Batal")),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                        // Panggil fungsi Return Unit
                                        context.read<HistoryCubit>().returnUnit(booking.id!, booking.consoleId);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Unit dikembalikan ke stok.")));
                                      },
                                      child: const Text("Ya, Selesai"),
                                    )
                                  ],
                                ),
                              );
                            }, 
                            icon: const Icon(Icons.check_circle),
                            label: const Text("TERIMA PENGEMBALIAN"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
                          )
                        )
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
// 3. TAB INVENTORY (KELOLA UNIT)
// ============================================================================
class AdminInventoryTab extends StatelessWidget {
  const AdminInventoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(HomeRepository())..loadConsoles(), 
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Kelola Unit", style: TextStyle(fontWeight: FontWeight.bold)), 
          centerTitle: true
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){ 
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddConsolePage())); 
          }, 
          backgroundColor: Colors.blue[800],
          child: const Icon(Icons.add, color: Colors.white)
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoaded) {
              if (state.consoles.isEmpty) {
                return const Center(child: Text("Belum ada unit console."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.consoles.length,
                itemBuilder: (context, index) {
                  final console = state.consoles[index];
                  return Card(
                    color: Theme.of(context).cardColor,
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          console.imageUrl, 
                          width: 50, 
                          height: 50, 
                          fit: BoxFit.cover, 
                          errorBuilder: (c,o,s) => const Icon(Icons.error)
                        ),
                      ),
                      title: Text(console.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(console.type),
                      trailing: PopupMenuButton(
                        itemBuilder: (c) => [
                          PopupMenuItem(
                            child: const Row(children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text("Edit")]), 
                            onTap: () => Future.delayed(Duration.zero, () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditConsolePage(console: console))))
                          ),
                          PopupMenuItem(
                            child: const Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text("Hapus")]), 
                            onTap: () => showDialog(
                              context: context, 
                              builder: (ctx) => AlertDialog(
                                title: const Text("Hapus?"), 
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")), 
                                  TextButton(
                                    onPressed: () { 
                                      Navigator.pop(ctx); 
                                      // Logic Hapus
                                      HomeRepository().deleteConsole(console.id); 
                                      // Refresh List (Manual trigger)
                                      context.read<HomeCubit>().loadConsoles();
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unit dihapus")));
                                    }, 
                                    child: const Text("Hapus", style: TextStyle(color: Colors.red))
                                  )
                                ]
                              )
                            )
                          ),
                        ]
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

// ============================================================================
// 4. TAB ADMIN ACCOUNT (PROFIL ADMIN)
// ============================================================================
class AdminAccountTab extends StatelessWidget {
  const AdminAccountTab({super.key});

  void _handleLogout(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Keluar?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (context) => const LoginPage()), 
                  (route) => false
                );
              }
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? "Admin";

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 260,
                  margin: const EdgeInsets.only(bottom: 50),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[900]!, Colors.blue[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                  child: const SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Control Panel", style: TextStyle(color: Colors.white70, fontSize: 14)),
                              Text("Dashboard Admin", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Icon(Icons.notifications_none, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
                
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30, 
                        backgroundColor: Colors.blue[100], 
                        child: const Icon(Icons.admin_panel_settings, size: 30, color: Colors.blue)
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userEmail, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(4)),
                              child: Text("Super Admin", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green[700])),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildAdminMenuTile(context, icon: Icons.storefront_rounded, title: "Informasi Rental", subtitle: "Ubah nama & kontak", onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminRentalInfoPage()));
                  }),
                  const SizedBox(height: 12),
                  _buildAdminMenuTile(context, icon: Icons.people_outline_rounded, title: "Manajemen User", subtitle: "Daftar penyewa", onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminUserManagementPage()));
                  }),
                  const SizedBox(height: 12),
                  _buildAdminMenuTile(context, icon: Icons.settings_applications_rounded, title: "Konfigurasi Sistem", subtitle: "Maintenance mode", onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminSystemConfigPage()));
                  }),
                  const SizedBox(height: 30),
                  _buildAdminMenuTile(context, icon: Icons.help_outline_rounded, title: "Pusat Bantuan Admin", color: Colors.orange, onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminHelpCenterPage()));
                  }),
                  
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleLogout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).cardColor,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Colors.red),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text("Keluar Akun Admin"),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMenuTile(BuildContext context, {required IconData icon, required String title, String? subtitle, required VoidCallback onTap, Color color = Colors.blue}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      ),
    );
  }
}