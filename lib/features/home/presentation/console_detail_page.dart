import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

import '../../booking/data/booking_repository.dart';
import '../../booking/data/booking_model.dart';
import '../../booking/presentation/booking_cubit.dart';
import '../data/console_model.dart';

class ConsoleDetailPage extends StatelessWidget {
  final ConsoleModel console;
  const ConsoleDetailPage({super.key, required this.console});

  @override
  Widget build(BuildContext context) {
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
          Navigator.pop(context);
          Navigator.pop(context); 
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Pesanan Berhasil Dibuat!"), backgroundColor: Colors.green));
        } else if (state is BookingFailure) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${state.message}"), backgroundColor: Colors.red));
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300, pinned: true, backgroundColor: Colors.blue[800],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.console.name, style: const TextStyle(fontSize: 14, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
                background: Hero(
                  tag: widget.console.id.isEmpty ? widget.console.name : widget.console.id,
                  child: CachedNetworkImage(imageUrl: widget.console.imageUrl, fit: BoxFit.cover, errorWidget: (c, u, e) => const Icon(Icons.error)),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: widget.console.isAvailable ? Colors.green[100] : Colors.red[100], borderRadius: BorderRadius.circular(20)), child: Text(widget.console.isAvailable ? "Unit Tersedia" : "Sedang Disewa", style: TextStyle(fontWeight: FontWeight.bold, color: widget.console.isAvailable ? Colors.green[800] : Colors.red[800]))),
                        Text(widget.console.type, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue[200]!)),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("💰 Daftar Harga Rental", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Divider(),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Main Sini (Per Jam)"), Text("Harga Normal")]),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Bawa Pulang (12 Jam)"), Text("Rp 45.000")]),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Bawa Pulang (24 Jam)"), Text("Rp 80.000")]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Deskripsi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text("Nikmati pengalaman bermain game terbaik. Unit terawat, stik responsif, dan siap dimainkan!", style: TextStyle(color: Colors.black54, height: 1.5)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.all(20),
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Harga Mulai"), Text("${currencyFormatter.format(widget.console.price)} /jam", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue))]),
              const Spacer(),
              ElevatedButton(
                onPressed: widget.console.isAvailable ? () => _showBookingForm(context) : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("SEWA SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FORM BOOKING DENGAN AKSESORIS ---
  void _showBookingForm(BuildContext parentContext) {
    int duration = 1;
    String selectedType = "Main di Tempat"; 
    String selectedPayment = "Tunai / Cash";
    String selectedPackage = "12 Jam";
    
    // LIST AKSESORIS YANG DIPILIH USER
    List<Map<String, dynamic>> selectedAccessories = [];
    int accessoriesTotalCost = 0;

    final bookingCubit = parentContext.read<BookingCubit>();
    final user = FirebaseAuth.instance.currentUser;

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            
            // Hitung Harga Dasar (Console)
            int basePrice = 0;
            int finalDuration = 0;

            if (selectedType == "Main di Tempat") {
              basePrice = duration * widget.console.price;
              finalDuration = duration;
            } else {
              if (selectedPackage == "12 Jam") {
                basePrice = 45000;
                finalDuration = 12;
              } else {
                basePrice = 80000;
                finalDuration = 24;
              }
            }

            // Hitung Total Akhir (Console + Aksesoris)
            int grandTotal = basePrice + accessoriesTotalCost;
            
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
              child: SizedBox(
                height: 600, // Batasi tinggi agar bisa scroll
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 20),
                      const Text("Konfirmasi Pesanan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      // 1. TIPE SEWA
                      const Text("Mau main dimana?", style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Expanded(child: RadioListTile<String>(title: const Text("Main Sini", style: TextStyle(fontSize: 13)), value: "Main di Tempat", groupValue: selectedType, contentPadding: EdgeInsets.zero, onChanged: (val) => setModalState(() => selectedType = val!))),
                          Expanded(child: RadioListTile<String>(title: const Text("Bawa Pulang", style: TextStyle(fontSize: 13)), value: "Bawa Pulang", groupValue: selectedType, contentPadding: EdgeInsets.zero, onChanged: (val) => setModalState(() => selectedType = val!))),
                        ],
                      ),
                      const Divider(),

                      // 2. DURASI / PAKET
                      if (selectedType == "Main di Tempat") ...[
                        const Text("Berapa Jam?", style: TextStyle(color: Colors.grey)),
                        Row(children: [
                          IconButton(onPressed: () => duration > 1 ? setModalState(() => duration--) : null, icon: const Icon(Icons.remove_circle_outline, color: Colors.red)),
                          Text("$duration Jam", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(onPressed: () => setModalState(() => duration++), icon: const Icon(Icons.add_circle_outline, color: Colors.green)),
                        ]),
                      ] else ...[
                        const Text("Pilih Paket Hemat:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(child: ChoiceChip(label: const Text("12 Jam - 45rb"), selected: selectedPackage == "12 Jam", onSelected: (bool selected) => setModalState(() => selectedPackage = "12 Jam"), selectedColor: Colors.blue[100])),
                          const SizedBox(width: 10),
                          Expanded(child: ChoiceChip(label: const Text("24 Jam - 80rb"), selected: selectedPackage == "24 Jam", onSelected: (bool selected) => setModalState(() => selectedPackage = "24 Jam"), selectedColor: Colors.green[100])),
                        ]),
                      ],
                      const SizedBox(height: 10),
                      const Divider(),

                      // 3. PILIH AKSESORIS (DARI FIREBASE) - FITUR BARU
                      const Text("Tambah Aksesoris (Opsional)", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('accessories').where('isAvailable', isEqualTo: true).snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const LinearProgressIndicator();
                          var accessories = snapshot.data!.docs;
                          
                          if (accessories.isEmpty) return const Text("Tidak ada aksesoris tambahan.", style: TextStyle(color: Colors.grey));

                          return Column(
                            children: accessories.map((doc) {
                              var data = doc.data() as Map<String, dynamic>;
                              String name = data['name'];
                              int price = data['price'];
                              bool isSelected = selectedAccessories.any((item) => item['name'] == name);

                              return CheckboxListTile(
                                title: Text(name),
                                subtitle: Text("+ ${currencyFormatter.format(price)}"),
                                value: isSelected,
                                activeColor: Colors.blue[800],
                                onChanged: (bool? value) {
                                  setModalState(() {
                                    if (value == true) {
                                      selectedAccessories.add({'name': name, 'price': price});
                                      accessoriesTotalCost += price;
                                    } else {
                                      selectedAccessories.removeWhere((item) => item['name'] == name);
                                      accessoriesTotalCost -= price;
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const Divider(),

                      // 4. PEMBAYARAN
                      const Text("Metode Pembayaran", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedPayment, isExpanded: true,
                            items: ["Tunai / Cash", "Transfer BCA", "Transfer BRI", "E-Wallet DANA", "E-Wallet GoPay"].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                            onChanged: (newValue) => setModalState(() => selectedPayment = newValue!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 5. TOTAL & TOMBOL
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Sewa Console:"), Text(currencyFormatter.format(basePrice))]),
                            if (accessoriesTotalCost > 0)
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Aksesoris Tambahan:"), Text(currencyFormatter.format(accessoriesTotalCost))]),
                            const Divider(),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total Bayar:", style: TextStyle(fontWeight: FontWeight.bold)), Text(currencyFormatter.format(grandTotal), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900], fontSize: 18))]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final bookingData = BookingModel(
                              consoleId: widget.console.id, 
                              consoleName: widget.console.name, 
                              userName: user?.email ?? "Tamu",
                              bookingDate: DateTime.now(), 
                              durationHours: finalDuration, 
                              totalPrice: grandTotal, // Total sudah termasuk aksesoris
                              rentalType: selectedType, 
                              paymentMethod: selectedPayment, 
                              accessories: selectedAccessories, // SIMPAN AKSESORIS
                            );
                            bookingCubit.submitBooking(bookingData);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: const Text("BUAT PESANAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}