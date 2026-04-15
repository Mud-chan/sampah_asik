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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child:
                        Image.asset('assets/images/abaikanbt.png', width: 120),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () async {
                      await DBHelper.deleteWaste(id);
                      Navigator.pop(context);
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
    String starLabel = "";

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFFE8D6AB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  padding: const EdgeInsets.all(15),
                  icon: const Icon(Icons.close, color: Colors.red, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // SEKSI BINTANG
                      Image.asset('assets/images/notifbintang.png', width: 120),
                      const SizedBox(height: 5),

                      const Text(
                        "Semakin banyak bintang, maka sampah tersebut semakin sulit untuk dikoleksi.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                      const Divider(height: 40, color: Colors.black26),

                      // SEKSI PARAMETER 1: DAMPAK
                      _buildHelpParameter(
                        "Dampak Lingkungan",
                        80,
                        "Semakin tinggi angkanya, maka semakin besar kerusakan yang ditimbulkan sampah ini terhadap alam.",
                      ),
                      const SizedBox(height: 20),

                      // SEKSI PARAMETER 2: DAUR ULANG
                      _buildHelpParameter(
                        "Tingkat Daur Ulang",
                        40,
                        "Semakin tinggi angkanya, maka sampah ini semakin mudah untuk diolah kembali menjadi barang berguna.",
                      ),
                      const SizedBox(height: 20),

                      // SEKSI PARAMETER 3: CAKUPAN
                      _buildHelpParameter(
                        "Cakupan Pengaruh",
                        60,
                        "Menunjukkan seberapa luas area yang dapat tercemar jika sampah ini tidak dikelola dengan benar.",
                      ),
                      const SizedBox(height: 20),

                      // SEKSI PARAMETER 4: AKSI
                      _buildHelpParameter(
                        "Aksi Pengelolaan",
                        90,
                        "Semakin tinggi angkanya, semakin banyak tindakan nyata yang perlu kamu lakukan untuk mengatasinya.",
                      ),
                      const SizedBox(height: 30),
                      const Divider(height: 40, color: Colors.black26),

                      // SEKSI TOMBOL (DIKEMBALIKAN)
                      Image.asset('assets/images/notifbtsabaikan.png',
                          width: 160),
                      const SizedBox(height: 10),
                      const Text(
                        "Tombol ini berfungsi untuk kembali ke menu koleksi",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 25),

                      Image.asset('assets/images/notifbtbuang.png', width: 160),
                      const SizedBox(height: 10),
                      const Text(
                        "Tombol ini berfungsi untuk menghapus sampah dari daftar koleksimu",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 30),
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

  Widget _buildHelpParameter(String title, int value, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildProgressBar(title, value),
        const SizedBox(height: 8),
        Text(
          desc,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
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

          // Help Button
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
                child: const Icon(Icons.help_outline,
                    color: Colors.black87, size: 30),
              ),
            ),
          ),

          // Stars & Rare Text
          Positioned(
            top: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/bintang$stars.png', width: 200),
                // Menggunakan Transform.translate untuk menarik teks ke atas agar lebih dekat dengan gambar
                Transform.translate(
                  offset: const Offset(0, -15),
                  child: Text(
                    stars == 3
                        ? "Langka"
                        : (stars == 2 ? "Lumayan Sulit" : "Mudah Ditemukan"),
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w900, // Membuat tulisan jauh lebih bold
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                )
              ],
            ),
          ),

          Positioned(
            top: 210,
            child: Image.asset('assets/images/lingkaranbwah.png', width: 230),
          ),

          Positioned(
            top: 140,
            child: Image.asset('assets/images/$image', width: 150),
          ),

          Positioned(
            top: 315,
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
                Text(
                  desc,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),

          // Progress Bars
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

          // Bottom Buttons
          Positioned(
            bottom: 55,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset('assets/images/abaikanbt.png', width: 170),
                ),
                const SizedBox(width: 30),
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
            color: Colors.black87,
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
