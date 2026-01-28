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
                  child: Image.asset('assets/images/simpanbt.png', width: 170),
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
