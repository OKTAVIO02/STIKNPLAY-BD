import 'dart:async'; // Import async untuk Timer
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../data/booking_repository.dart';
import '../data/booking_model.dart';
import 'history_cubit.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryCubit(BookingRepository())..loadHistory(),
      child: const HistoryView(),
    );
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // HEADER
          Stack(
            children: [
              Container(
                height: 180,
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[900]!, Colors.blue[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Riwayat Sewa", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("Pantau sisa waktu mainmu disini", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                    Icon(Icons.history_edu_rounded, color: Colors.white, size: 40),
                  ],
                ),
              ),
            ],
          ),

          // LIST RIWAYAT
          Expanded(
            child: BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                if (state is HistoryLoading) return const Center(child: CircularProgressIndicator());
                if (state is HistoryError) return Center(child: Text("Error: ${state.message}"));
                if (state is HistoryLoaded) {
                  if (state.bookings.isEmpty) {
                    return const Center(child: Text("Belum ada riwayat sewa."));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: state.bookings.length,
                    itemBuilder: (context, index) {
                      return _buildHistoryCard(context, state.bookings[index]);
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, BookingModel booking) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormatter = DateFormat('dd MMM, HH:mm');
    
    bool isActive = booking.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: isActive ? Border.all(color: Colors.blue, width: 1.5) : Border.all(color: Colors.transparent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Nama & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(booking.consoleName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.orange[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isActive ? "SEDANG MAIN" : "SELESAI",
                    style: TextStyle(color: isActive ? Colors.orange[800] : Colors.green[800], fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ],
            ),
            
            const Divider(height: 20),
            
            // WAKTU BERJALAN (Countdown)
            // Hanya muncul jika status masih Pending (Aktif)
            if (isActive) 
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _RentalTimerWidget(
                  bookingDate: booking.bookingDate, 
                  durationHours: booking.durationHours
                ),
              ),

            Row(
              children: [
                _buildInfoColumn(Icons.calendar_today, "Mulai", dateFormatter.format(booking.bookingDate)),
                const SizedBox(width: 20),
                _buildInfoColumn(Icons.monetization_on, "Total", currencyFormatter.format(booking.totalPrice)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

// --- WIDGET TIMER PINTAR ---
// Widget ini akan update otomatis setiap detik tanpa refresh halaman
class _RentalTimerWidget extends StatelessWidget {
  final DateTime bookingDate;
  final int durationHours;

  const _RentalTimerWidget({required this.bookingDate, required this.durationHours});

  @override
  Widget build(BuildContext context) {
    // Hitung kapan harus selesai
    final DateTime endTime = bookingDate.add(Duration(hours: durationHours));

    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1), (i) => i), // Update tiap detik
      builder: (context, snapshot) {
        final now = DateTime.now();
        final difference = endTime.difference(now);
        
        final isOverdue = difference.isNegative;
        final durationShow = isOverdue ? difference.abs() : difference;

        // Format HH:MM:SS
        String twoDigits(int n) => n.toString().padLeft(2, '0');
        final hours = twoDigits(durationShow.inHours);
        final minutes = twoDigits(durationShow.inMinutes.remainder(60));
        final seconds = twoDigits(durationShow.inSeconds.remainder(60));

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isOverdue ? Colors.red[50] : Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isOverdue ? Colors.red : Colors.blue),
          ),
          child: Column(
            children: [
              Text(
                isOverdue ? "WAKTU SUDAH HABIS!" : "SISA WAKTU MAIN",
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.bold, 
                  color: isOverdue ? Colors.red : Colors.blue
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${isOverdue ? '+' : ''}$hours : $minutes : $seconds",
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.w900, 
                  color: isOverdue ? Colors.red[900] : Colors.blue[900],
                  letterSpacing: 2
                ),
              ),
              if (isOverdue)
                const Text("(Segera kembalikan unit)", style: TextStyle(fontSize: 10, color: Colors.red)),
            ],
          ),
        );
      },
    );
  }
}