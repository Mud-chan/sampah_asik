import 'package:flutter/material.dart';
import 'detail.dart';

class HasilPage extends StatelessWidget {
  final String imagePath;
  final String wasteType;
  final double? confidence; // idealnya 0.0 – 1.0

  const HasilPage({
    super.key,
    required this.imagePath,
    required this.wasteType,
    this.confidence,
  });

  // ================================
  // Normalisasi confidence ke 0.0 – 1.0
  // Kalau ternyata dikirim 0–100, kita ubah dulu
  // ================================
  double get normalizedConfidence {
    if (confidence == null) return 0.0;

    double c = confidence!;

    // Kalau lebih dari 1, berarti masih format persen
    if (c > 1.0) {
      c = c / 100.0;
    }

    // Pastikan tetap di 0.0 – 1.0
    return c.clamp(0.0, 1.0);
  }

  // ================================
  // LOGIKA AKURASI (THRESHOLD 50%)
  // ================================
  bool get isLowAccuracy {
    return normalizedConfidence < 0.10;
  }

  String getResponseText() {
    if (isLowAccuracy) {
      return "Objek yang kamu foto belum dapat dikenali sebagai sampah.\n"
          "Coba ambil gambar yang lebih jelas ya!";
    } else {
      return "Objek berhasil dikenali sebagai jenis sampah.\n"
          "Bagus, lanjutkan!";
    }
  }

  // ================================
  // Gambar berdasarkan jenis sampah
  // ================================
  String _getWasteImage(String type) {
    String normalizedType = type.toLowerCase().replaceAll(' ', '_');

    Map<String, String> imageMap = {
      'baju': 'baju.png',
      'baterai': 'baterai.png',
      'besi': 'besi.png',
      'kaca_coklat': 'kaca_coklat.png',
      'kaca_hijau': 'kaca_hijau.png',
      'kaca_putih': 'kaca_putih.png',
      'kardus': 'kardus.png',
      'kertas': 'kertas.png',
      'plastik': 'plastik.png',
      'sepatu': 'sepatu.png',
      'sisa_makanan': 'sisa_makanan.png',
      'buah_busuk': 'buah_busuk.png',
      'kulit_telur': 'kulit_telur.png',
    };

    return imageMap[normalizedType] ?? 'botol.png';
  }

  // ================================
  // Gambar hasil
  // ================================
  String get resultImage {
    if (isLowAccuracy) {
      return 'bukan_sampah.png';
    } else {
      return _getWasteImage(wasteType);
    }
  }

  // ================================
  // Aksi tombol
  // ================================
  void _handleButtonAction(BuildContext context) {
    if (isLowAccuracy) {
      Navigator.pop(context);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPage(
            wasteType: wasteType,
            confidence: normalizedConfidence, // kirim yang sudah benar
          ),
        ),
      );
    }
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      // Penjelasan Bintang
                      Image.asset('assets/images/notifbintang.png', width: 150),
                      const SizedBox(height: 10),
                      const Text(
                        "Jumlah Bintang Menunjukkan kelangkaan dari sampah semakin banyak bintang mana semakin langka",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 25),
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
    final double confidencePercent = normalizedConfidence * 100;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/images/kuningbawah.png',
                fit: BoxFit.cover,
                width: double.infinity,
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
            top: 80,
            child: Image.asset(
              'assets/images/bintang3.png',
              width: 250,
            ),
          ),

          Positioned(
            top: 220,
            child: Column(
              children: [
                const Text(
                  'Terdeteksi',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLowAccuracy ? '"Bukan Sampah"' : '"$wasteType"',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isLowAccuracy
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 340,
            child: Image.asset(
              'assets/images/$resultImage',
              width: 220,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 100,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: 50,
            child: GestureDetector(
              onTap: () => _handleButtonAction(context),
              child: Image.asset(
                isLowAccuracy
                    ? 'assets/images/btkembali.png'
                    : 'assets/images/lanjutbt.png',
                width: 260,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
