import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // --- LOGIKA FAVORIT (LOVE) ---
  void _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('favorites').doc('${user.uid}_${widget.console.id}');
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.delete();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dihapus dari favorit"), duration: Duration(seconds: 1)));
    } else {
      await docRef.set({
        'userId': user.email ?? user.uid, 
        'consoleId': widget.console.id,
        'consoleName': widget.console.name,
        'consoleImage': widget.console.imageUrl,
        'price': widget.console.price,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ditambahkan ke favorit ❤️"), backgroundColor: Colors.pink));
    }
  }

  // --- LOGIKA TAMBAH ULASAN (REVIEW) ---
  void _showAddReviewDialog() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silakan login untuk memberi ulasan.")));
      return;
    }

    int selectedRating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E272E),
              title: const Text("Tulis Ulasan", style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Beri Rating:", style: TextStyle(color: Colors.white70)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () => setDialogState(() => selectedRating = index + 1),
                      );
                    }),
                  ),
                  TextField(
                    controller: commentController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Ceritakan pengalamanmu...",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C6FF), foregroundColor: Colors.white),
                  onPressed: () async {
                    if (commentController.text.isNotEmpty) {
                      Navigator.pop(ctx);
                      // SIMPAN KE FIREBASE
                      await FirebaseFirestore.instance.collection('reviews').add({
                        'consoleId': widget.console.id,
                        'userId': user.uid,
                        'userName': user.displayName ?? "User",
                        'rating': selectedRating,
                        'comment': commentController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Terima kasih atas ulasannya! ⭐"), backgroundColor: Colors.green));
                    }
                  },
                  child: const Text("Kirim"),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
        backgroundColor: const Color(0xFF0F2027),
        body: CustomScrollView(
          slivers: [
            // APP BAR GAMBAR
            SliverAppBar(
              expandedHeight: 350,
              pinned: true,
              backgroundColor: const Color(0xFF0F2027),
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
              ),
              actions: [
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('favorites').doc('${user?.uid}_${widget.console.id}').snapshots(),
                  builder: (context, snapshot) {
                    bool isFav = snapshot.hasData && snapshot.data!.exists;
                    return Container(
                      margin: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                      child: IconButton(
                        icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.pinkAccent : Colors.white),
                        onPressed: _toggleFavorite,
                      ),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: widget.console.id.isEmpty ? widget.console.name : widget.console.id,
                  child: CachedNetworkImage(imageUrl: widget.console.imageUrl, fit: BoxFit.cover, errorWidget: (c, u, e) => const Icon(Icons.error)),
                ),
              ),
            ),

            // ISI KONTEN
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF0F2027), Color(0xFF203A43)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // INFO JUDUL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(widget.console.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: widget.console.isAvailable ? const Color(0xFF00E676).withOpacity(0.2) : const Color(0xFFFF4757).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: widget.console.isAvailable ? const Color(0xFF00E676) : const Color(0xFFFF4757)),
                            ),
                            child: Text(widget.console.isAvailable ? "Ready" : "Booked", style: TextStyle(fontWeight: FontWeight.bold, color: widget.console.isAvailable ? const Color(0xFF00E676) : const Color(0xFFFF4757))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(widget.console.type, style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6))),
                      
                      const SizedBox(height: 25),

                      // DAFTAR HARGA
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("💰 Daftar Harga Sewa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                            const SizedBox(height: 15),
                            _buildPriceRow("Main di Tempat (Per Jam)", currencyFormatter.format(widget.console.price)),
                            _buildPriceRow("Bawa Pulang (Paket 12 Jam)", "Rp 45.000"),
                            _buildPriceRow("Bawa Pulang (Paket 24 Jam)", "Rp 80.000"),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 25),
                      const Text("Deskripsi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      Text("Nikmati pengalaman bermain game terbaik dengan kualitas 4K HDR. Unit terawat, stik responsif, dan siap dimainkan!", style: TextStyle(color: Colors.white.withOpacity(0.7), height: 1.6)),
                      
                      const SizedBox(height: 30),
                      Divider(color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 10),

                      // --- BAGIAN ULASAN (REVIEWS) ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Ulasan Pengguna ⭐", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          TextButton.icon(
                            onPressed: _showAddReviewDialog,
                            icon: const Icon(Icons.edit, size: 16, color: Color(0xFF00C6FF)),
                            label: const Text("Tulis Ulasan", style: TextStyle(color: Color(0xFF00C6FF))),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),

                      // LIST ULASAN DARI FIREBASE
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('reviews')
                            .where('consoleId', isEqualTo: widget.console.id)
                            // .orderBy('timestamp', descending: true) // Aktifkan jika index sudah dibuat
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text("Belum ada ulasan. Jadilah yang pertama!", style: TextStyle(color: Colors.white.withOpacity(0.5), fontStyle: FontStyle.italic)),
                              ),
                            );
                          }

                          return Column(
                            children: snapshot.data!.docs.map((doc) {
                              var data = doc.data() as Map<String, dynamic>;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.blueGrey,
                                      child: Text(data['userName'] != null ? data['userName'][0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(data['userName'] ?? "User", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                              Row(
                                                children: List.generate(5, (index) => Icon(
                                                  index < (data['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                                  size: 14, color: Colors.amber,
                                                )),
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(data['comment'] ?? "", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      // ------------------------------

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // BOTTOM SHEET
        bottomSheet: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E272E),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Row(
            children: [
              Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Mulai dari", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)), Text("${currencyFormatter.format(widget.console.price)} /jam", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF00C6FF)))]),
              const Spacer(),
              ElevatedButton(
                onPressed: widget.console.isAvailable ? () => _showBookingForm(context) : null,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C6FF), disabledBackgroundColor: Colors.grey[800], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 10),
                child: Text(widget.console.isAvailable ? "SEWA SEKARANG" : "TIDAK TERSEDIA", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String price) {
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8))), Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E676)))]));
  }

  void _showBookingForm(BuildContext parentContext) {
    int duration = 1;
    String selectedType = "Main di Tempat"; 
    String selectedPayment = "Tunai / Cash";
    String selectedPackage = "12 Jam";
    
    List<Map<String, dynamic>> selectedAccessories = [];
    int accessoriesTotalCost = 0;

    final bookingCubit = parentContext.read<BookingCubit>();
    final user = FirebaseAuth.instance.currentUser;

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E272E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            int basePrice = 0;
            int finalDuration = 0;

            if (selectedType == "Main di Tempat") {
              basePrice = duration * widget.console.price;
              finalDuration = duration;
            } else {
              basePrice = (selectedPackage == "12 Jam") ? 45000 : 80000;
              finalDuration = (selectedPackage == "12 Jam") ? 12 : 24;
            }
            int grandTotal = basePrice + accessoriesTotalCost;
            
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
              child: SizedBox(
                height: 600,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 20),
                      const Text("Konfirmasi Pesanan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 20),

                      const Text("Mau main dimana?", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                      Row(children: [
                        Expanded(child: RadioListTile<String>(title: const Text("Main Sini", style: TextStyle(color: Colors.white)), value: "Main di Tempat", groupValue: selectedType, activeColor: const Color(0xFF00C6FF), onChanged: (val) => setModalState(() => selectedType = val!))),
                        Expanded(child: RadioListTile<String>(title: const Text("Bawa Pulang", style: TextStyle(color: Colors.white)), value: "Bawa Pulang", groupValue: selectedType, activeColor: const Color(0xFF00C6FF), onChanged: (val) => setModalState(() => selectedType = val!))),
                      ]),
                      Divider(color: Colors.white.withOpacity(0.1)),

                      if (selectedType == "Main di Tempat") ...[
                        const Text("Berapa Jam?", style: TextStyle(color: Colors.white70)),
                        Row(children: [
                          IconButton(onPressed: () => duration > 1 ? setModalState(() => duration--) : null, icon: const Icon(Icons.remove_circle_outline, color: Colors.red)),
                          Text("$duration Jam", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          IconButton(onPressed: () => setModalState(() => duration++), icon: const Icon(Icons.add_circle_outline, color: Colors.green)),
                        ]),
                      ] else ...[
                        const Text("Pilih Paket Hemat:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C6FF))),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(child: ChoiceChip(label: const Text("12 Jam - 45rb"), selected: selectedPackage == "12 Jam", onSelected: (bool selected) => setModalState(() => selectedPackage = "12 Jam"), selectedColor: const Color(0xFF00C6FF), labelStyle: TextStyle(color: selectedPackage == "12 Jam" ? Colors.white : Colors.black))),
                          const SizedBox(width: 10),
                          Expanded(child: ChoiceChip(label: const Text("24 Jam - 80rb"), selected: selectedPackage == "24 Jam", onSelected: (bool selected) => setModalState(() => selectedPackage = "24 Jam"), selectedColor: const Color(0xFF00E676), labelStyle: TextStyle(color: selectedPackage == "24 Jam" ? Colors.white : Colors.black))),
                        ]),
                      ],
                      const SizedBox(height: 10),
                      Divider(color: Colors.white.withOpacity(0.1)),

                      const Text("Tambah Aksesoris (Opsional)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('accessories').where('isAvailable', isEqualTo: true).snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const LinearProgressIndicator();
                          var accessories = snapshot.data!.docs;
                          if (accessories.isEmpty) return const Text("Tidak ada aksesoris.", style: TextStyle(color: Colors.grey));

                          return Column(children: accessories.map((doc) {
                            var data = doc.data() as Map<String, dynamic>;
                            String name = data['name'];
                            int price = data['price'];
                            bool isSelected = selectedAccessories.any((item) => item['name'] == name);

                            return CheckboxListTile(
                              title: Text(name, style: const TextStyle(color: Colors.white)),
                              subtitle: Text("+ ${currencyFormatter.format(price)}", style: TextStyle(color: Colors.white.withOpacity(0.6))),
                              value: isSelected,
                              activeColor: const Color(0xFF00C6FF),
                              checkColor: Colors.white,
                              onChanged: (bool? value) {
                                setModalState(() {
                                  if (value == true) { selectedAccessories.add({'name': name, 'price': price}); accessoriesTotalCost += price; } 
                                  else { selectedAccessories.removeWhere((item) => item['name'] == name); accessoriesTotalCost -= price; }
                                });
                              },
                            );
                          }).toList());
                        },
                      ),
                      Divider(color: Colors.white.withOpacity(0.1)),

                      const Text("Metode Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade600), borderRadius: BorderRadius.circular(10)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedPayment, isExpanded: true, dropdownColor: const Color(0xFF2C3E50),
                            items: ["Tunai / Cash", "Transfer BCA", "Transfer BRI", "E-Wallet DANA"].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(color: Colors.white)))).toList(),
                            onChanged: (newValue) => setModalState(() => selectedPayment = newValue!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Column(children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Sewa Console:", style: TextStyle(color: Colors.white70)), Text(currencyFormatter.format(basePrice), style: const TextStyle(color: Colors.white))]),
                          if (accessoriesTotalCost > 0) Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Aksesoris:", style: TextStyle(color: Colors.white70)), Text(currencyFormatter.format(accessoriesTotalCost), style: const TextStyle(color: Colors.white))]),
                          Divider(color: Colors.white.withOpacity(0.2)),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total Bayar:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), Text(currencyFormatter.format(grandTotal), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E676), fontSize: 18))]),
                        ]),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { final bookingData = BookingModel(consoleId: widget.console.id, consoleName: widget.console.name, userName: user?.email ?? "Tamu", bookingDate: DateTime.now(), durationHours: finalDuration, totalPrice: grandTotal, rentalType: selectedType, paymentMethod: selectedPayment, accessories: selectedAccessories); bookingCubit.submitBooking(bookingData); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C6FF), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text("BUAT PESANAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))
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