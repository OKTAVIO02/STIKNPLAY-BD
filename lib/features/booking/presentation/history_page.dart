import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'history_cubit.dart';
import '../data/booking_repository.dart';
import '../data/booking_model.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryCubit(BookingRepository())..loadHistory(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Riwayat Sewa"),
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HistoryError) {
              return Center(child: Text(state.message));
            } else if (state is HistoryLoaded) {
              if (state.bookings.isEmpty) {
                return const Center(child: Text("Belum ada riwayat sewa."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.bookings.length,
                itemBuilder: (context, index) {
                  // Kita kirim 'context' ke widget item
                  return _buildHistoryItem(context, state.bookings[index]);
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, BookingModel booking) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM, HH:mm');

    // Logika Tampilan Status
    Color statusColor = Colors.orange;
    String statusText = "SEDANG DISEWA";
    bool isActive = true; // Penanda tombol muncul atau tidak

    if (booking.status == 'success') {
      statusColor = Colors.green;
      statusText = "SELESAI";
      isActive = false;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris 1: Nama & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.consoleName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Baris 2: Info Detail
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tgl: ${dateFormat.format(booking.bookingDate)}", style: const TextStyle(fontSize: 13)),
                Text(
                  currencyFormatter.format(booking.totalPrice),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Penyewa: ${booking.userName} (${booking.durationHours} Jam)",
              style: const TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic),
            ),

            // --- TOMBOL AKSI (Hanya muncul jika sedang sewa) ---
            if (isActive) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Panggil fungsi kembalikan unit
                    if (booking.id != null) {
                      context.read<HistoryCubit>().returnUnit(booking.id!, booking.consoleId);
                    }
                  },
                  icon: const Icon(Icons.check_circle, size: 16),
                  label: const Text("SELESAIKAN SEWA & KEMBALIKAN UNIT"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}