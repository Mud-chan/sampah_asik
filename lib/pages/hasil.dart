// import 'dart:io';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'detail.dart';

class HasilPage extends StatelessWidget {
  final String imagePath;
  final String wasteType;
  final double confidence;

  const HasilPage({
    super.key,
    required this.imagePath,
    required this.wasteType,
    required this.confidence,
  });

  // Function untuk mendapatkan nama file gambar berdasarkan tipe sampah
  String _getWasteImage(String type) {
    // Normalisasi nama untuk matching dengan file
    String normalizedType = type.toLowerCase().replaceAll(' ', '_');

    // Map untuk handle variasi nama
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
    };

    return imageMap[normalizedType] ??
        'botol.png'; // default ke botol.png jika tidak ada
  }

  void _goToDetailPage(BuildContext context) {
    // ================================
    // 🔵 DEBUG — CETAK DI CMD
    // ================================
    print("🔵 HasilPage — wasteType yang DIKIRIM: $wasteType");
    print("🔵 HasilPage — confidence: $confidence");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return DetailPage(
            wasteType: wasteType,
            confidence: confidence,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 💛 Background bawah (paling belakang)
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

          // 🌟 Bintang di atas
          Positioned(
            top: 80,
            child: Image.asset(
              'assets/images/bintang3.png',
              width: 250,
            ),
          ),

          // 🧃 Teks deteksi (DINAMIS sesuai hasil klasifikasi)
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
                  '"$wasteType"', // 👈 DINAMIS dari hasil klasifikasi
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Tampilkan confidence score
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Akurasi: ${(confidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🧴 Gambar jenis sampah (DINAMIS sesuai klasifikasi)
          Positioned(
            top: 340,
            child: Image.asset(
              'assets/images/${_getWasteImage(wasteType)}', // 👈 DINAMIS
              width: 220,
              errorBuilder: (context, error, stackTrace) {
                // Jika gambar tidak ditemukan, tampilkan icon default
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

          // 🔘 Tombol Next
          Positioned(
            bottom: 50,
            child: GestureDetector(
              onTap: () => _goToDetailPage(context),
              child: Image.asset(
                'assets/images/lanjutbt.png',
                width: 260,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
