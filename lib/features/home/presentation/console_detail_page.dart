import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- PENTING: Import ini wajib ada!

import '../../booking/data/booking_repository.dart';
import '../../booking/data/booking_model.dart';
import '../../booking/presentation/booking_cubit.dart';
import '../data/console_model.dart';

class ConsoleDetailPage extends StatelessWidget {
  final ConsoleModel console;

  const ConsoleDetailPage({super.key, required this.console});

  @override
  Widget build(BuildContext context) {
    // Membungkus halaman dengan BookingCubit agar siap dipakai
    return BlocProvider(
      create: (context) => BookingCubit(BookingRepository()),
      child: ConsoleDetailView(console: console),
    );
  }
}

class ConsoleDetailView extends StatefulWidget {
  final ConsoleModel console;
  const ConsoleDetailView({super.key, required this.console});

  @override
  State<ConsoleDetailView> createState() => _ConsoleDetailViewState();
}

class _ConsoleDetailViewState extends State<ConsoleDetailView> {
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingSuccess) {
          // Tutup BottomSheet
          Navigator.pop(context);
          // Kembali ke Home
          Navigator.pop(context); 
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Booking Berhasil! Unit sekarang berstatus DISEWA."), 
              backgroundColor: Colors.green
            ),
          );
        } else if (state is BookingFailure) {
          // Tutup BottomSheet dulu biar user lihat errornya di halaman detail
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Gagal: ${state.message}"), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // --- HEADER GAMBAR ---
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.blue[800],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.console.name, style: const TextStyle(fontSize: 14, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
                background: Hero(
                  tag: widget.console.id.isEmpty ? widget.console.name : widget.console.id,
                  child: CachedNetworkImage(
                    imageUrl: widget.console.imageUrl, 
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
            ),

            // --- KONTEN DESKRIPSI ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.console.isAvailable ? Colors.green[100] : Colors.red[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.console.isAvailable ? "Unit Tersedia" : "Sedang Disewa",
                            style: TextStyle(fontWeight: FontWeight.bold, color: widget.console.isAvailable ? Colors.green[800] : Colors.red[800]),
                          ),
                        ),
                        Text(widget.console.type, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text("Deskripsi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      "Nikmati pengalaman bermain game terbaik dengan konsol ini. Sudah termasuk 2 stik original, kabel HDMI, dan akun PS Plus. Kondisi mesin prima.",
                      style: TextStyle(color: Colors.black54, height: 1.5),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),

        // --- TOMBOL SEWA DI BAWAH ---
        bottomSheet: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Harga Sewa", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    "${currencyFormatter.format(widget.console.price)} /jam",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: widget.console.isAvailable
                    ? () => _showBookingForm(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("SEWA SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FORMULIR BOOKING ---
  void _showBookingForm(BuildContext parentContext) {
    int duration = 1;
    
    // 1. AMBIL DATA USER (Pastikan Import firebase_auth ada di atas)
    final user = FirebaseAuth.instance.currentUser;
    final String userEmail = user?.email ?? "Tamu"; 
    
    // 2. TRIK PENTING: Simpan Cubit ke variabel sebelum buka modal
    // Ini mencegah error "ProviderNotFound" saat tombol ditekan
    final bookingCubit = parentContext.read<BookingCubit>(); 

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            int totalPrice = duration * widget.console.price;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20, right: 20, top: 20
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Konfirmasi Sewa", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Info Penyewa
                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Penyewa:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.account_circle, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Text(userEmail, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input Durasi
                  const Text("Mau sewa berapa lama?"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (duration > 1) setModalState(() => duration--);
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text("$duration Jam", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () {
                          setModalState(() => duration++);
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      const Spacer(),
                      Text(
                        currencyFormatter.format(totalPrice),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tombol Bayar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final bookingData = BookingModel(
                          consoleId: widget.console.id,
                          consoleName: widget.console.name,
                          userName: userEmail,
                          bookingDate: DateTime.now(),
                          durationHours: duration,
                          totalPrice: totalPrice,
                        );

                        // Gunakan variabel yang sudah kita simpan tadi (AMAN)
                        bookingCubit.submitBooking(bookingData);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text("BAYAR SEKARANG", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}