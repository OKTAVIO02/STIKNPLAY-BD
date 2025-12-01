import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

// --- IMPORT LOGIC ---
import '../../booking/data/booking_repository.dart';
import '../../booking/data/booking_model.dart';
import '../../booking/presentation/history_cubit.dart';

import '../data/home_repository.dart';
import '../data/console_model.dart';
import 'home_cubit.dart';

// --- IMPORT HALAMAN LAIN ---
import '../../auth/presentation/login_page.dart';
import 'add_console_page.dart';
import 'console_detail_page.dart';
import 'edit_console_page.dart'; 
import 'admin_sub_pages.dart'; // Halaman Manajemen User, Info, Config
import 'admin_send_notif_page.dart'; // Halaman Kirim Notifikasi

// IMPORT LOADING WIDGET
import '../../../../core/presentation/ps_loading_widget.dart';

// ============================================================================
// 1. MAIN DASHBOARD ADMIN (NAVIGASI UTAMA)
// ============================================================================
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0; 

  // Daftar Tab Halaman Admin
  final List<Widget> _pages = [
    const AdminBookingTab(),   // Tab Pesanan
    const AdminInventoryTab(), // Tab Kelola Unit
    const AdminAccountTab(),   // Tab Akun & Menu Lain
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027), // Background Gelap Utama
      
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F2027),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF0F2027), // Gelap
          selectedItemColor: const Color(0xFF00C6FF), // Electric Blue
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
// 2. TAB PESANAN (DARK GLASS CARD + LOGIKA DENDA TETAP ADA)
// ============================================================================
class AdminBookingTab extends StatelessWidget {
  const AdminBookingTab({super.key});

  @override
  Widget build(BuildContext context) {
    const int finePerHour = 20000; 

    return BlocProvider(
      create: (context) => HistoryCubit(BookingRepository()), 
      child: Scaffold(
        backgroundColor: Colors.transparent, // Agar ikut background parent
        appBar: AppBar(
          title: const Text("Pesanan Masuk", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), 
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: StreamBuilder<List<BookingModel>>(
          stream: BookingRepository().getAllActiveBookings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const PsLoadingWidget(size: 100);
            final bookings = snapshot.data ?? [];
            
            if (bookings.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 80, color: Colors.greenAccent),
                    SizedBox(height: 16),
                    Text("Semua aman. Tidak ada pesanan aktif.", style: TextStyle(color: Colors.white70)),
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
                
                final DateTime endTime = booking.bookingDate.add(Duration(hours: booking.durationHours));
                final DateTime now = DateTime.now();
                final int lateMinutes = now.difference(endTime).inMinutes;
                final bool isLate = lateMinutes > 0; 
                int calculatedFine = 0;
                int lateHours = 0;
                if (isLate) {
                  lateHours = (lateMinutes / 60).ceil();
                  if (lateHours < 1) lateHours = 1; 
                  calculatedFine = lateHours * finePerHour;
                }

                final isTakeAway = booking.rentalType == 'Bawa Pulang';
                final labelColor = isTakeAway ? const Color(0xFFD05CE3) : const Color(0xFF29B6F6); // Ungu Muda / Biru Muda
                final labelBg = isTakeAway ? Colors.purple.withOpacity(0.2) : Colors.blue.withOpacity(0.2);

                // --- KARTU PESANAN (GLASS STYLE) ---
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08), // Transparan
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                          children: [
                            Expanded(child: Text(booking.consoleName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), 
                              decoration: BoxDecoration(color: labelBg, borderRadius: BorderRadius.circular(8)), 
                              child: Text(booking.rentalType, style: TextStyle(color: labelColor, fontWeight: FontWeight.bold, fontSize: 10))
                            )
                          ]
                        ),
                        const SizedBox(height: 8), 
                        Divider(color: Colors.white.withOpacity(0.1)),
                        
                        _buildRowInfo(Icons.person, "Penyewa", booking.userName),
                        const SizedBox(height: 6),
                        _buildRowInfo(Icons.payment, "Pembayaran", booking.paymentMethod, isBold: true, color: const Color(0xFFFFAB40)), // Orange Muda
                        const SizedBox(height: 6),
                        _buildRowInfo(Icons.monetization_on, "Total Awal", currencyFormatter.format(booking.totalPrice), color: const Color(0xFF69F0AE)), // Hijau Muda
                        
                        if (booking.accessories.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.yellow.withOpacity(0.1), 
                              border: Border.all(color: Colors.yellow.withOpacity(0.3)), 
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("📦 Include Aksesoris:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFFFD740))),
                                const SizedBox(height: 4),
                                ...booking.accessories.map((item) => 
                                  Text("• ${item['name']}", style: const TextStyle(fontSize: 12, color: Colors.white70))
                                ).toList(),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                        Center(child: _RentalTimerWidget(bookingDate: booking.bookingDate, durationHours: booking.durationHours)),
                        const SizedBox(height: 16),
                        
                        SizedBox(
                          width: double.infinity, 
                          child: ElevatedButton.icon(
                            onPressed: (){ 
                               showDialog(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  backgroundColor: const Color(0xFF1E272E), // Dialog Gelap
                                  title: Text(isLate ? "⚠️ TERLAMBAT $lateHours JAM!" : "✅ Selesaikan Sewa?", style: TextStyle(color: isLate ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold)),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Pastikan unit dan aksesoris sudah kembali.", style: TextStyle(color: Colors.white70)),
                                      const SizedBox(height: 10),
                                      if (isLate) ...[
                                        const Divider(color: Colors.white24),
                                        Text("Denda: ${currencyFormatter.format(calculatedFine)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                        const SizedBox(height: 5),
                                        Text("(Rp ${currencyFormatter.format(finePerHour)} x $lateHours jam)", style: const TextStyle(fontSize: 12, color: Colors.white54)),
                                      ] else 
                                        const Text("Tepat waktu. Aman.", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Batal", style: TextStyle(color: Colors.white54))),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: isLate ? Colors.red : Colors.green, foregroundColor: Colors.white),
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                        context.read<HistoryCubit>().returnUnit(booking.id!, booking.consoleId, calculatedFine);
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isLate ? "Selesai (Denda Lunas)" : "Unit Kembali"), backgroundColor: isLate ? Colors.orange : Colors.green));
                                      },
                                      child: Text(isLate ? "Bayar & Selesai" : "Ya, Selesai"),
                                    )
                                  ],
                                ),
                              );
                            }, 
                            icon: Icon(isLate ? Icons.warning_amber_rounded : Icons.check_circle),
                            label: Text(isLate ? "PROSES DENDA" : "TERIMA PENGEMBALIAN"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLate ? Colors.red.withOpacity(0.2) : const Color(0xFF00C6FF), 
                              foregroundColor: isLate ? Colors.redAccent : Colors.white,
                              side: isLate ? const BorderSide(color: Colors.redAccent) : null,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
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

  Widget _buildRowInfo(IconData icon, String label, String value, {bool isBold = false, Color color = Colors.white}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(fontSize: 12, color: Colors.white54)),
        Expanded(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

// ============================================================================
// 3. TAB INVENTORY (KELOLA UNIT - DARK MODE)
// ============================================================================
class AdminInventoryTab extends StatelessWidget {
  const AdminInventoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(HomeRepository())..loadConsoles(), 
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Kelola Unit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.transparent, elevation: 0),
        floatingActionButton: FloatingActionButton(
          onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => const AddConsolePage())); }, 
          backgroundColor: const Color(0xFF00C6FF),
          child: const Icon(Icons.add, color: Colors.white)
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) return const PsLoadingWidget(size: 100);

            if (state is HomeLoaded) {
              if (state.consoles.isEmpty) return const Center(child: Text("Belum ada unit console.", style: TextStyle(color: Colors.white54)));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.consoles.length,
                itemBuilder: (context, index) {
                  final console = state.consoles[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1))
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(imageUrl: console.imageUrl, width: 50, height: 50, fit: BoxFit.cover, errorWidget: (c,o,s) => const Icon(Icons.error, color: Colors.white)),
                      ),
                      title: Text(console.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      subtitle: Text(console.type, style: const TextStyle(color: Colors.white54)),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        color: const Color(0xFF1E272E), // Menu Gelap
                        itemBuilder: (c) => [
                          PopupMenuItem(child: const Row(children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text("Edit", style: TextStyle(color: Colors.white))]), onTap: () => Future.delayed(Duration.zero, () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditConsolePage(console: console))))),
                          PopupMenuItem(child: const Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text("Hapus", style: TextStyle(color: Colors.white))]), onTap: () => showDialog(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF1E272E), title: const Text("Hapus?", style: TextStyle(color: Colors.white)), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.white54))), TextButton(onPressed: () { Navigator.pop(ctx); HomeRepository().deleteConsole(console.id); context.read<HomeCubit>().loadConsoles(); }, child: const Text("Hapus", style: TextStyle(color: Colors.red)))]))),
                        ]
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
// 4. TAB ADMIN ACCOUNT (MENU LENGKAP - DARK MODE)
// ============================================================================
class AdminAccountTab extends StatelessWidget {
  const AdminAccountTab({super.key});

  void _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? "Admin";

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF000428), Color(0xFF004e92)], begin: Alignment.topLeft, end: Alignment.bottomRight), 
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))
              ),
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.admin_panel_settings, size: 30, color: Colors.blue)), const SizedBox(height: 10), Text(userEmail, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), Container(margin: const EdgeInsets.only(top: 5), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)), child: const Text("Super Admin", style: TextStyle(color: Colors.white, fontSize: 10)))]))
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 1. MENU KIRIM NOTIFIKASI
                  _buildAdminMenuTile(
                    context, 
                    icon: Icons.notifications_active_rounded, 
                    title: "Kirim Notifikasi ke User", 
                    subtitle: "Broadcast info promo", 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminSendNotifPage()))
                  ),
                  const SizedBox(height: 10),
                  
                  // 2. MENU INFORMASI RENTAL
                  _buildAdminMenuTile(
                    context, 
                    icon: Icons.storefront_rounded, 
                    title: "Informasi Rental", 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminRentalInfoPage()))
                  ),
                  const SizedBox(height: 10),
                  
                  // 3. MENU MANAJEMEN USER
                  _buildAdminMenuTile(
                    context, 
                    icon: Icons.people_outline_rounded, 
                    title: "Manajemen User", 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminUserManagementPage()))
                  ),
                  const SizedBox(height: 10),
                  
                  // 4. MENU KONFIGURASI SISTEM
                  _buildAdminMenuTile(
                    context, 
                    icon: Icons.settings_applications_rounded, 
                    title: "Konfigurasi Sistem", 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminSystemConfigPage()))
                  ),
                  
                  const SizedBox(height: 30),
                  
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => _handleLogout(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1), foregroundColor: Colors.redAccent, side: BorderSide(color: Colors.redAccent.withOpacity(0.5)), padding: const EdgeInsets.symmetric(vertical: 12)), icon: const Icon(Icons.logout), label: const Text("Keluar Akun")))
                ]
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMenuTile(BuildContext context, {required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1))
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: const Color(0xFF00C6FF))),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white54)) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
      ),
    );
  }
}

// ============================================================================
// WIDGET TIMER ADMIN (DARK MODE)
// ============================================================================
class _RentalTimerWidget extends StatelessWidget {
  final DateTime bookingDate;
  final int durationHours;

  const _RentalTimerWidget({required this.bookingDate, required this.durationHours});

  @override
  Widget build(BuildContext context) {
    final DateTime endTime = bookingDate.add(Duration(hours: durationHours));

    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final difference = endTime.difference(now);
        final isOverdue = difference.isNegative;
        
        final durationShow = isOverdue ? difference.abs() : difference;
        String twoDigits(int n) => n.toString().padLeft(2, '0');
        final hours = twoDigits(durationShow.inHours);
        final minutes = twoDigits(durationShow.inMinutes.remainder(60));
        final seconds = twoDigits(durationShow.inSeconds.remainder(60));

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isOverdue ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isOverdue ? Colors.redAccent : Colors.blueAccent),
          ),
          child: Column(
            children: [
              Text(
                isOverdue ? "TERLAMBAT (OVERDUE)" : "SISA WAKTU",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isOverdue ? Colors.redAccent : Colors.blueAccent),
              ),
              Text(
                "${isOverdue ? '+' : ''}$hours:$minutes:$seconds",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isOverdue ? Colors.redAccent : Colors.blueAccent),
              ),
            ],
          ),
        );
      },
    );
  }
}