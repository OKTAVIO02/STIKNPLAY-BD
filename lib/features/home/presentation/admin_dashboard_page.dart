import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Import Repository & Model
import '../../booking/data/booking_repository.dart';
import '../../booking/data/booking_model.dart';
import '../../booking/presentation/history_cubit.dart';

import '../data/home_repository.dart';
import '../data/console_model.dart';
import 'home_cubit.dart';

// Import Halaman Lain
import '../../auth/presentation/login_page.dart';
import 'add_console_page.dart';
import 'console_detail_page.dart';
import 'edit_console_page.dart'; 

// ============================================================================
// MAIN WIDGET: ADMIN DASHBOARD (CONTAINER UTAMA)
// ============================================================================
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0; // 0: Pesanan, 1: Unit, 2: Akun

  final List<Widget> _pages = [
    const AdminBookingTab(),   // Tab 1: Pesanan Masuk
    const AdminInventoryTab(), // Tab 2: Kelola Unit
    const AdminAccountTab(),   // Tab 3: Profil Modern
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      // --- BOTTOM NAVIGATION BAR ADMIN (Biru) ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue[800], // Warna Biru Utama
          unselectedItemColor: Colors.grey[400],
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_rounded),
              label: "Pesanan",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.videogame_asset_rounded),
              label: "Inventory",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: "Admin",
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 1: PESANAN (Active Bookings & Return Process)
// ============================================================================
class AdminBookingTab extends StatelessWidget {
  const AdminBookingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryCubit(BookingRepository()), 
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text("Pesanan Masuk", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
          backgroundColor: Colors.blue[800],
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: StreamBuilder<List<BookingModel>>(
          stream: BookingRepository().getAllActiveBookings(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

            final bookings = snapshot.data ?? [];

            if (bookings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 80, color: Colors.green[300]),
                    const SizedBox(height: 16),
                    const Text("Semua aman! Tidak ada pesanan aktif.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                return _buildBookingCard(context, bookings[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM, HH:mm');

    return Card(
      elevation: 3,
      shadowColor: Colors.blue.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(booking.consoleName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.orange[200]!)),
                  child: const Text("DISEWA", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
              ],
            ),
            const Divider(height: 20),
            // Info Penyewa
            Row(
              children: [
                CircleAvatar(radius: 12, backgroundColor: Colors.blue[100], child: Icon(Icons.person, size: 14, color: Colors.blue[800])),
                const SizedBox(width: 8),
                Text(booking.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text("Durasi: ${booking.durationHours} Jam  •  Total: ${currencyFormatter.format(booking.totalPrice)}", style: const TextStyle(color: Colors.black87)),
            Text("Mulai: ${dateFormat.format(booking.bookingDate)}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            
            const SizedBox(height: 16),
            // Tombol Aksi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text("Konfirmasi Pengembalian?"),
                      content: Text("Pastikan unit '${booking.consoleName}' sudah kembali dalam kondisi baik."),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Batal")),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800], 
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            context.read<HistoryCubit>().returnUnit(booking.id!, booking.consoleId);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Unit berhasil dikembalikan ke inventory.")));
                          },
                          child: const Text("Konfirmasi Kembali"),
                        )
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800], 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.assignment_return),
                label: const Text("TERIMA PENGEMBALIAN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 2: INVENTORY (Daftar Unit & Tambah/Edit/Hapus)
// ============================================================================
class AdminInventoryTab extends StatelessWidget {
  const AdminInventoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(HomeRepository())..loadConsoles(), 
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text("Kelola Unit", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
          backgroundColor: Colors.blue[800],
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        // TOMBOL FAB
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddConsolePage()));
          },
          backgroundColor: Colors.blue[800],
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text("Tambah Unit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) return const Center(child: CircularProgressIndicator());
            if (state is HomeError) return Center(child: Text("Error: ${state.message}"));
            if (state is HomeLoaded) {
              if (state.consoles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videogame_asset_off_rounded, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text("Belum ada unit. Tambahkan yang pertama!", style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.consoles.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final console = state.consoles[index];
                  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

                  return Card(
                    elevation: 2,
                    shadowColor: Colors.blue.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ConsoleDetailPage(console: console)));
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: console.imageUrl,
                                width: 70, height: 70, fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: Colors.grey[200]),
                                errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(console.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(console.type, style: const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text("${currencyFormatter.format(console.price)} /jam", style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            
                            // --- POPUP MENU (EDIT/HAPUS) ---
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditConsolePage(console: console)));
                                } else if (value == 'delete') {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Hapus Unit?"),
                                      content: Text("Yakin ingin menghapus ${console.name}?"),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(ctx);
                                            await HomeRepository().deleteConsole(console.id);
                                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unit dihapus.")));
                                          }, 
                                          child: const Text("Hapus", style: TextStyle(color: Colors.red))
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text("Edit")])),
                                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text("Hapus")])),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 3: AKUN ADMIN (MODERN UI)
// ============================================================================
class AdminAccountTab extends StatelessWidget {
  const AdminAccountTab({super.key});

  void _handleLogout(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Keluar Akun Admin?"),
        content: const Text("Sesi Anda akan berakhir."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
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
            child: const Text("Keluar"),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? "Admin";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER GRADIENT ---
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
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Control Panel", style: TextStyle(color: Colors.white70, fontSize: 14)),
                              Text("Dashboard Admin", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          IconButton(
                            onPressed: (){}, 
                            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                            tooltip: "Notifikasi",
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Card Profil Mengambang
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue[800]!, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue[100],
                          child: const Icon(Icons.admin_panel_settings, size: 30, color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userEmail, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.green[200]!)
                              ),
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

            // --- MENU OPTIONS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pengaturan Umum", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  
                  _buildAdminMenuTile(
                    icon: Icons.storefront_rounded,
                    title: "Informasi Rental",
                    subtitle: "Ubah nama toko, alamat & kontak",
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildAdminMenuTile(
                    icon: Icons.people_outline_rounded,
                    title: "Manajemen User",
                    subtitle: "Lihat daftar pengguna terdaftar",
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildAdminMenuTile(
                    icon: Icons.settings_applications_rounded,
                    title: "Konfigurasi Sistem",
                    subtitle: "Backup data & log aktivitas",
                    onTap: () {},
                  ),

                  const SizedBox(height: 30),
                  const Text("Lainnya", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),

                  _buildAdminMenuTile(
                    icon: Icons.help_outline_rounded,
                    title: "Pusat Bantuan Admin",
                    color: Colors.orange,
                    onTap: () {},
                  ),
                  
                  const SizedBox(height: 30),

                  // TOMBOL LOGOUT
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleLogout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.red, width: 1)
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text("Keluar Akun Admin", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  const Center(child: Text("App Version 1.0.0 (Admin)", style: TextStyle(color: Colors.grey, fontSize: 12))),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Menu
  Widget _buildAdminMenuTile({
    required IconData icon, 
    required String title, 
    String? subtitle, 
    required VoidCallback onTap,
    Color color = Colors.blue,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      ),
    );
  }
}