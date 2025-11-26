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
import 'admin_sub_pages.dart'; 
import 'admin_send_notif_page.dart'; // <--- IMPORT HALAMAN KIRIM NOTIFIKASI

// IMPORT LOADING WIDGET
import '../../../../core/presentation/ps_loading_widget.dart';

// ============================================================================
// 1. CLASS UTAMA DASHBOARD ADMIN
// ============================================================================
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});
  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0; 
  final List<Widget> _pages = [const AdminBookingTab(), const AdminInventoryTab(), const AdminAccountTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
        child: BottomNavigationBar(
          currentIndex: _currentIndex, onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed, backgroundColor: Theme.of(context).cardColor, selectedItemColor: Colors.blue[800], unselectedItemColor: Colors.grey[400],
          items: const [BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: "Pesanan"), BottomNavigationBarItem(icon: Icon(Icons.videogame_asset_rounded), label: "Inventory"), BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Admin")],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. TAB PESANAN
// ============================================================================
class AdminBookingTab extends StatelessWidget {
  const AdminBookingTab({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryCubit(BookingRepository()), 
      child: Scaffold(
        appBar: AppBar(title: const Text("Pesanan Masuk", style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
        body: StreamBuilder<List<BookingModel>>(
          stream: BookingRepository().getAllActiveBookings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const PsLoadingWidget(size: 100);
            final bookings = snapshot.data ?? [];
            if (bookings.isEmpty) return const Center(child: Text("Tidak ada pesanan aktif."));

            return ListView.builder(
              padding: const EdgeInsets.all(16), itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final isTakeAway = booking.rentalType == 'Bawa Pulang';
                final labelColor = isTakeAway ? Colors.purple : Colors.blue;
                final labelBg = isTakeAway ? Colors.purple[50] : Colors.blue[50];

                return Card(
                  color: Theme.of(context).cardColor, elevation: 2, margin: const EdgeInsets.only(bottom: 12), 
                  child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(booking.consoleName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: labelBg, borderRadius: BorderRadius.circular(6)), child: Text(booking.rentalType, style: TextStyle(color: labelColor, fontWeight: FontWeight.bold, fontSize: 10)))]),
                    const Divider(),
                    Center(child: _RentalTimerWidget(bookingDate: booking.bookingDate, durationHours: booking.durationHours)),
                    const SizedBox(height: 10),
                    Text("Penyewa: ${booking.userName}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Metode: ${booking.paymentMethod}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 10),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: (){ showDialog(context: context, builder: (d) => AlertDialog(title: const Text("Selesai?"), actions: [TextButton(onPressed: ()=>Navigator.pop(d), child: const Text("Batal")), ElevatedButton(onPressed: (){Navigator.pop(d); context.read<HistoryCubit>().returnUnit(booking.id!, booking.consoleId);}, child: const Text("Ya"))])); }, icon: const Icon(Icons.check_circle), label: const Text("SELESAI"), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white)))
                  ])),
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
// 3. TAB INVENTORY
// ============================================================================
class AdminInventoryTab extends StatelessWidget {
  const AdminInventoryTab({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(HomeRepository())..loadConsoles(), 
      child: Scaffold(
        appBar: AppBar(title: const Text("Kelola Unit"), centerTitle: true),
        floatingActionButton: FloatingActionButton(onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => const AddConsolePage())); }, backgroundColor: Colors.blue[800], child: const Icon(Icons.add, color: Colors.white)),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoaded) {
              return ListView.builder(padding: const EdgeInsets.all(16), itemCount: state.consoles.length, itemBuilder: (context, index) {
                final console = state.consoles[index];
                return Card(child: ListTile(
                  leading: CachedNetworkImage(imageUrl: console.imageUrl, width: 50, height: 50, fit: BoxFit.cover, errorWidget: (c,o,e)=>const Icon(Icons.error)),
                  title: Text(console.name), subtitle: Text(console.type),
                  trailing: IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditConsolePage(console: console)))),
                ));
              });
            }
            return const PsLoadingWidget(size: 100);
          },
        ),
      ),
    );
  }
}

// ============================================================================
// 4. TAB ADMIN ACCOUNT (MENU LENGKAP DENGAN KIRIM NOTIF)
// ============================================================================
class AdminAccountTab extends StatelessWidget {
  const AdminAccountTab({super.key});
  void _handleLogout(BuildContext context) async { await FirebaseAuth.instance.signOut(); if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false); }
  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? "Admin";
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 200, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue[900]!, Colors.blue[600]!]), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30))), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.admin_panel_settings, size: 30, color: Colors.blue)), const SizedBox(height: 10), Text(userEmail, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]))),
            Padding(padding: const EdgeInsets.all(20), child: Column(children: [
              
              // --- MENU BARU: KIRIM NOTIFIKASI ---
              _buildAdminMenuTile(context, icon: Icons.notifications_active_rounded, title: "Kirim Notifikasi ke User", subtitle: "Broadcast info promo", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminSendNotifPage()))),
              const SizedBox(height: 10),
              
              _buildAdminMenuTile(context, icon: Icons.storefront_rounded, title: "Informasi Rental", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminRentalInfoPage()))),
              const SizedBox(height: 10),
              _buildAdminMenuTile(context, icon: Icons.people_outline_rounded, title: "Manajemen User", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminUserManagementPage()))),
              const SizedBox(height: 30),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => _handleLogout(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)), icon: const Icon(Icons.logout), label: const Text("Keluar Akun")))
            ])),
          ],
        ),
      ),
    );
  }
  Widget _buildAdminMenuTile(BuildContext context, {required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) { return ListTile(onTap: onTap, leading: Icon(icon, color: Colors.blue), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: subtitle!=null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null, trailing: const Icon(Icons.arrow_forward_ios, size: 16)); }
}

class _RentalTimerWidget extends StatelessWidget {
  final DateTime bookingDate; final int durationHours;
  const _RentalTimerWidget({required this.bookingDate, required this.durationHours});
  @override
  Widget build(BuildContext context) {
    final DateTime endTime = bookingDate.add(Duration(hours: durationHours));
    return StreamBuilder(stream: Stream.periodic(const Duration(seconds: 1), (i) => i), builder: (context, snapshot) {
      final now = DateTime.now(); final difference = endTime.difference(now); final isOverdue = difference.isNegative; 
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final hours = twoDigits(difference.abs().inHours); final minutes = twoDigits(difference.abs().inMinutes.remainder(60)); final seconds = twoDigits(difference.abs().inSeconds.remainder(60));
      return Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isOverdue ? Colors.red[50] : Colors.blue[50], borderRadius: BorderRadius.circular(8)), child: Text("${isOverdue ? 'Terlambat: ' : 'Sisa: '}$hours:$minutes:$seconds", style: TextStyle(fontWeight: FontWeight.bold, color: isOverdue ? Colors.red : Colors.blue)));
    });
  }
}