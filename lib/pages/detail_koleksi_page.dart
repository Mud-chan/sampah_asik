import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../utils/session_manager.dart';
import 'detail.dart'; // ⬅️ ambil wasteData dari sini

class DetailKoleksiPage extends StatelessWidget {
  final int id;
  final String wasteName;
  final int stars;

  const DetailKoleksiPage({
    super.key,
    required this.id,
    required this.wasteName,
    required this.stars,
  });

  // ===================== POPUP BUANG =====================
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.yellowAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/notifpic.png', width: 80),
              const SizedBox(height: 16),
              const Text(
                "Yakin mau dibuang?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ❌ BATAL
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child:
                        Image.asset('assets/images/abaikanbt.png', width: 120),
                  ),

                  const SizedBox(width: 20),

                  // 🗑️ BUANG
                  GestureDetector(
                    onTap: () async {
                      await DBHelper.deleteWaste(id); // 🔥 HAPUS SATU ITEM SAJA

                      Navigator.pop(context); // tutup dialog
                      Navigator.pushReplacementNamed(context, '/koleksi');
                    },
                    child: Image.asset('assets/images/hapusbt.png', width: 120),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== DIALOG BANTUAN (?) =====================
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFFE8D6AB), // Warna krem sesuai gambar
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          // Tinggi dialog dibatasi sekitar 65% layar (separo) agar bisa di-scroll
          height: MediaQuery.of(context).size.height * 0.65, 
          child: Column(
            children: [
              // Tombol silang di kiri atas
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  padding: const EdgeInsets.only(left: 15, top: 15),
                  icon: const Icon(Icons.close, color: Colors.red, size: 35),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Area Scrollable untuk Konten
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      // Penjelasan Bintang
                      Image.asset('assets/images/notifbintang.png', width: 150),
                      const SizedBox(height: 10),
                      const Text(
                        "Jumlah Bintang Menunjukkan kelangkaan dari sampah semakin banyak bintang mana semakin langka",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 25),

                      // Penjelasan Parameter
                      Image.asset('assets/images/notifparam.png', width: 250),
                      const SizedBox(height: 10),
                      const Text(
                        "Parameter di atas menjelaskan seberapa besar dampak sampah, peluang untuk didaur ulang, serta tindakan yang perlu dilakukan untuk mengelolanya dengan baik.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 25),

                      // Penjelasan Tombol Abaikan/Kembali
                      Image.asset('assets/images/notifbtsabaikan.png', width: 160),
                      const SizedBox(height: 10),
                      const Text(
                        "Tombol ini berfungsi untuk kembali ke menu koleksi",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 25),

                      // Penjelasan Tombol Simpan/Buang
                      Image.asset('assets/images/notifbtbuang.png', width: 160),
                      const SizedBox(height: 10),
                      const Text(
                        "Tombol ini berfungsi untuk menghapus sampah dari daftar koleksimu",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final key = wasteName.toLowerCase().replaceAll(' ', '_');
    final data = wasteData[key] ?? wasteData['plastik'];

    String image = data['image'];
    String name = data['name'];
    String type = data['type'];
    String impact = data['impact'];
    String desc = data['desc'];
    Map prog = data['progress'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/images/kuningbawahdetail.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Tombol Tanda Tanya (?) di Pojok Kanan Atas
          Positioned(
            top: 45,
            right: 20,
            child: GestureDetector(
              onTap: () => _showHelpDialog(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Colors.black87,
                  size: 30,
                ),
              ),
            ),
          ),

          Positioned(
            top: 40,
            child: Image.asset('assets/images/bintang$stars.png', width: 200),
          ),

          Positioned(
            top: 180,
            child: Image.asset('assets/images/lingkaranbwah.png', width: 230),
          ),

          Positioned(
            top: 120,
            child: Image.asset('assets/images/$image', width: 150),
          ),

          Positioned(
            top: 300,
            left: 30,
            right: 30,
            child: Column(
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Jenis: $type"),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Dampak Lingkungan:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(impact, textAlign: TextAlign.justify),
                const SizedBox(height: 10),
                Text(desc, textAlign: TextAlign.justify),
              ],
            ),
          ),

          Positioned(
            bottom: 150,
            left: 30,
            right: 30,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProgressBar("Dampak Lingkungan", prog['difficulty']),
                    _buildProgressBar("Tingkat Daur Ulang", prog['progress']),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProgressBar("Cakupan Pengaruh", prog['area']),
                    _buildProgressBar("Aksi Pengelolaan", prog['quests']),
                  ],
                ),
              ],
            ),
          ),

          // 🔘 TOMBOL BAWAH
          Positioned(
            bottom: 35,
            child: Row(
              children: [
                // 🔙 KEMBALI
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset('assets/images/abaikanbt.png', width: 170),
                ),

                const SizedBox(width: 30),

                // 🗑️ BUANG
                GestureDetector(
                  onTap: () => _showDeleteDialog(context),
                  child: Image.asset('assets/images/btbuang.png', width: 170),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String title, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title ($value/100)",
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black87, // sesuaikan dengan background kamu
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 120,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: (value.clamp(0, 100).toDouble() / 100) * 120,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}