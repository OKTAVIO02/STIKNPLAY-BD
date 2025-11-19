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
import 'home_cubit.dart'; // Kita butuh ini untuk load daftar console

// Import Halaman Lain
import '../../auth/presentation/login_page.dart';
import 'add_console_page.dart';

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
    const AdminInventoryTab(), // Tab 2: Daftar Unit & Tambah
    const AdminAccountTab(),   // Tab 3: Profil & Logout
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gunakan IndexedStack agar halaman tidak reload saat pindah tab
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      // --- BOTTOM NAVIGATION BAR ADMIN ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.red[800], // Warna Merah Khas Admin
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_rounded),
              label: "Pesanan",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.videogame_asset_rounded),
              label: "Unit Console",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
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
    // Inject Cubit History untuk fungsi Return Unit
    return BlocProvider(
      create: (context) => HistoryCubit(BookingRepository()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pesanan Masuk"),
          backgroundColor: Colors.red[800],
          foregroundColor: Colors.white,
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
                    const Text("Semua aman! Tidak ada yang menyewa.", style: TextStyle(fontSize: 16, color: Colors.grey)),
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
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(booking.consoleName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.orange[200]!)),
                  child: const Text("DISEWA", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
              ],
            ),
            const Divider(),
            // Info Penyewa
            Row(
              children: [
                CircleAvatar(radius: 12, backgroundColor: Colors.red[100], child: const Icon(Icons.person, size: 14, color: Colors.red)),
                const SizedBox(width: 8),
                Text(booking.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text("Durasi: ${booking.durationHours} Jam  •  Total: ${currencyFormatter.format(booking.totalPrice)}"),
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
                      title: const Text("Terima Barang?"),
                      content: Text("Pastikan unit ${booking.consoleName} sudah kembali."),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Batal")),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            context.read<HistoryCubit>().returnUnit(booking.id!, booking.consoleId);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Unit berhasil kembali.")));
                          },
                          child: const Text("Konfirmasi", style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800], foregroundColor: Colors.white),
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
// TAB 2: INVENTORY (Daftar Unit & Tambah Unit)
// ============================================================================
class AdminInventoryTab extends StatelessWidget {
  const AdminInventoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan HomeCubit untuk load daftar console
    return BlocProvider(
      create: (context) => HomeCubit(HomeRepository())..loadConsoles(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Kelola Unit"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        // TOMBOL FAB (Hanya muncul di tab ini)
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddConsolePage()));
          },
          backgroundColor: Colors.red[800],
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Tambah Unit", style: TextStyle(color: Colors.white)),
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) return const Center(child: CircularProgressIndicator());
            if (state is HomeError) return Center(child: Text("Error: ${state.message}"));
            if (state is HomeLoaded) {
              if (state.consoles.isEmpty) return const Center(child: Text("Belum ada unit. Tambahkan sekarang!"));

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.consoles.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final console = state.consoles[index];
                  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

                  return ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: console.imageUrl,
                        width: 60, height: 60, fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                    title: Text(console.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(console.type),
                        Text("${currencyFormatter.format(console.price)} /jam", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: console.isAvailable ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        console.isAvailable ? "READY" : "DISEWA",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: console.isAvailable ? Colors.green : Colors.red),
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
// TAB 3: AKUN ADMIN (Logout)
// ============================================================================
class AdminAccountTab extends StatelessWidget {
  const AdminAccountTab({super.key});

  void _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? "Admin";

    return Scaffold(
      appBar: AppBar(title: const Text("Profil Admin"), centerTitle: true, backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0, automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.red[100],
              child: const Icon(Icons.admin_panel_settings, size: 50, color: Colors.red),
            ),
            const SizedBox(height: 16),
            Text(userEmail, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Administrator Mode", style: TextStyle(color: Colors.grey)),
            
            const SizedBox(height: 40),
            
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Pengaturan Toko"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: (){},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Keluar Admin", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () => _handleLogout(context),
            ),
          ],
        ),
      ),
    );
  }
}