// Combined wasteData and DetailPage widget
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../utils/session_manager.dart';

final Map<String, dynamic> wasteData = {
  'baju': {
    'name': 'Baju',
    'stars': 2,
    'image': 'baju.png',
    'type': 'Anorganik',
    'impact': 'Limbah tekstil membutuhkan waktu ratusan tahun untuk terurai.',
    'desc':
        'Baju bekas termasuk limbah tekstil yang jika tidak dikelola dengan baik dapat mencemari tanah dan air.',
    'progress': {
      'difficulty': 70, // Dampak Lingkungan (tinggi)
      'progress': 40, // Tingkat Daur Ulang (sedang, sulit)
      'area': 60, // Cakupan Pengaruh
      'quests': 50, // Aksi Pengelolaan
    }
  },
  'baterai': {
    'name': 'Baterai',
    'stars': 3,
    'image': 'baterai.png',
    'type': 'B3 (Berbahaya)',
    'impact': 'Mengandung bahan kimia beracun yang merusak tanah dan air.',
    'desc':
        'Baterai bekas adalah limbah B3 yang harus dibuang melalui tempat khusus karena sangat berbahaya.',
    'progress': {
      'difficulty': 100, // Sangat berbahaya
      'progress': 30, // Sulit didaur ulang
      'area': 90, // Dampaknya luas
      'quests': 90, // Butuh penanganan khusus
    }
  },
  'besi': {
    'name': 'Besi',
    'stars': 3,
    'image': 'besi.png',
    'type': 'Anorganik',
    'impact': 'Tidak bisa terurai secara alami, tapi bisa didaur ulang.',
    'desc':
        'Besi bekas merupakan limbah anorganik yang dapat didaur ulang untuk mengurangi limbah.',
    'progress': {
      'difficulty': 50, // Dampak sedang
      'progress': 80, // Sangat bisa didaur ulang
      'area': 60,
      'quests': 40,
    }
  },
  'kaca_coklat': {
    'name': 'Kaca Coklat',
    'stars': 2,
    'image': 'kaca_coklat.png',
    'type': 'Anorganik',
    'impact': 'Tidak dapat terurai, tetapi bisa didaur ulang jadi barang baru.',
    'desc':
        'Kaca merupakan bahan yang aman selama tidak pecah, dan sangat cocok untuk daur ulang.',
    'progress': {
      'difficulty': 45,
      'progress': 75,
      'area': 50,
      'quests': 35,
    }
  },
  'kaca_hijau': {
    'name': 'Kaca Hijau',
    'stars': 2,
    'image': 'kaca_hijau.png',
    'type': 'Anorganik',
    'impact': 'Tidak dapat terurai tetapi aman dan 100% bisa didaur ulang.',
    'desc':
        'Kaca hijau memiliki kekuatan tinggi dan sering digunakan kembali melalui proses daur ulang.',
    'progress': {
      'difficulty': 40,
      'progress': 85,
      'area': 55,
      'quests': 30,
    }
  },
  'kaca_putih': {
    'name': 'Kaca Putih',
    'stars': 1,
    'image': 'kaca_putih.png',
    'type': 'Anorganik',
    'impact': 'Tidak terurai tetapi mudah untuk didaur ulang.',
    'desc':
        'Kaca putih adalah salah satu jenis kaca paling mudah melewati proses daur ulang.',
    'progress': {
      'difficulty': 35,
      'progress': 90,
      'area': 40,
      'quests': 25,
    }
  },
  'kardus': {
    'name': 'Kardus',
    'stars': 1,
    'image': 'kardus.png',
    'type': 'Organik',
    'impact': 'Dapat terurai dan sangat mudah untuk didaur ulang.',
    'desc':
        'Kardus merupakan bahan ramah lingkungan dan sangat sering didaur ulang.',
    'progress': {
      'difficulty': 15, // Dampak kecil
      'progress': 90, // Sangat mudah didaur ulang
      'area': 30,
      'quests': 20,
    }
  },
  'kertas': {
    'name': 'Kertas',
    'stars': 1,
    'image': 'kertas.png',
    'type': 'Organik',
    'impact': 'Mudah terurai dan memiliki nilai daur ulang yang tinggi.',
    'desc': 'Kertas menjadi salah satu bahan yang paling mudah didaur ulang.',
    'progress': {
      'difficulty': 10,
      'progress': 95,
      'area': 25,
      'quests': 15,
    }
  },
  'plastik': {
    'name': 'Plastik',
    'stars': 1,
    'image': 'plastik.png',
    'type': 'Anorganik',
    'impact': 'Sangat sulit terurai, dapat mencemari laut dan tanah.',
    'desc':
        'Plastik membutuhkan waktu sangat lama untuk terurai dan harus didaur ulang.',
    'progress': {
      'difficulty': 85,
      'progress': 50,
      'area': 80,
      'quests': 70,
    }
  },
  'sepatu': {
    'name': 'Sepatu',
    'stars': 3,
    'image': 'sepatu.png',
    'type': 'Anorganik Campuran',
    'impact': 'Sulit didaur ulang karena campuran bahan (karet, kulit, kain).',
    'desc':
        'Sepatu umumnya terdiri dari campuran bahan yang membuatnya sulit untuk dihancurkan.',
    'progress': {
      'difficulty': 75,
      'progress': 30,
      'area': 65,
      'quests': 60,
    }
  },
  'sisa_makanan': {
    'name': 'Sisa Makanan',
    'stars': 1,
    'image': 'sisa_makanan.png',
    'type': 'Organik',
    'impact': 'Menghasilkan gas metana jika menumpuk, tetapi bisa jadi kompos.',
    'desc':
        'Sisa makanan dapat dikomposkan sehingga mengurangi emisi gas rumah kaca.',
    'progress': {
      'difficulty': 25,
      'progress': 85,
      'area': 30,
      'quests': 20,
    }
  },
  'kulit_telur': {
    'name': 'Kulit Telur',
    'stars': 1,
    'image': 'kulit_telur.png',
    'type': 'Organik',
    'impact':
        'Dapat terurai secara alami dan bermanfaat untuk menambah kalsium pada tanah jika dijadikan kompos.',
    'desc':
        'Kulit telur bisa dihancurkan dan dicampurkan ke dalam kompos sebagai sumber kalsium alami untuk tanaman.',
    'progress': {
      'difficulty': 10,
      'progress': 90,
      'area': 20,
      'quests': 15,
    }
  },
  'buah_busuk': {
    'name': 'Buah Busuk',
    'stars': 1,
    'image': 'buah_busuk.png',
    'type': 'Organik',
    'impact':
        'Menghasilkan bau dan gas metana jika dibiarkan, tetapi sangat baik untuk bahan kompos.',
    'desc':
        'Buah busuk mudah terurai dan dapat dimanfaatkan sebagai bahan utama pembuatan pupuk kompos.',
    'progress': {
      'difficulty': 20,
      'progress': 85,
      'area': 25,
      'quests': 20,
    }
  },
};

class DetailPage extends StatelessWidget {
  final String wasteType;
  final double confidence;

  const DetailPage(
      {super.key, required this.wasteType, required this.confidence});

  // ===================== HITUNG EXP =====================
  int _getExpFromStars(int stars) {
    if (stars == 3) return 3000;
    if (stars == 2) return 2000;
    return 1000;
  }

  // ===================== SIMPAN =====================
  Future<void> _handleSave(
    BuildContext context,
    String wasteName,
    int stars,
  ) async {
    final username = await SessionManager.getUsername();
    if (username == null) return;

    final exp = _getExpFromStars(stars);

    // ✅ Tambah EXP
    await DBHelper.addExp(username, exp);

    // ✅ Simpan sampah (nama + stars)
    await DBHelper.saveWaste(
      username: username,
      wasteName: wasteName,
      stars: stars,
    );

    _showSavedDialog(context);
  }

  // ===================== ABAIKAN =====================
  Future<void> _handleIgnore(
    BuildContext context,
    int stars,
  ) async {
    final username = await SessionManager.getUsername();
    if (username == null) return;

    final exp = _getExpFromStars(stars);

    // ❗ HANYA TAMBAH EXP
    await DBHelper.addExp(username, exp);

    Navigator.pushReplacementNamed(context, '/home');
  }

  // ===================== DIALOG DISIMPAN =====================
  void _showSavedDialog(BuildContext context) {
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
                "Hasil Disimpan!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Image.asset('assets/images/tutupbt.png', width: 120),
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

                      // Penjelasan Parameter
                      Image.asset('assets/images/notifparam.png', width: 250),
                      const SizedBox(height: 10),
                      const Text(
                        "Parameter di atas menjelaskan seberapa besar dampak sampah, peluang untuk didaur ulang, serta tindakan yang perlu dilakukan untuk mengelolanya dengan baik.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 25),

                      // Penjelasan Tombol Abaikan
                      Image.asset('assets/images/notifbtsabaikan.png',
                          width: 160),
                      const SizedBox(height: 10),
                      const Text(
                        "Tombol abaikan Berfungsi Untuk Kembali ke menu beranda",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 25),

                      // Penjelasan Tombol Simpan
                      Image.asset('assets/images/notifbtsimpan.png',
                          width: 160),
                      const SizedBox(height: 10),
                      const Text(
                        "Tombol simpan berfungsi untuk menyimpan sampah mu",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
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
    print("🟢 DEBUG — wasteType yang DITERIMA oleh DetailPage: $wasteType");
    final key = wasteType.toLowerCase().replaceAll(' ', '_');
    final data = wasteData[key] ?? wasteData['plastik'];

    String image = data['image'];
    int stars = data['stars'];
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
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Jenis: $type"),
                SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Dampak Lingkungan:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                Text(impact, textAlign: TextAlign.justify),
                SizedBox(height: 10),
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

          // 🔘 Tombol Abaikan dan Simpan (paling depan)
          Positioned(
            bottom: 35,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ================= ABAIKAN =================
                GestureDetector(
                  onTap: () => _handleIgnore(context, stars),
                  child: Image.asset(
                    'assets/images/abaikanbt.png',
                    width: 170,
                  ),
                ),

                const SizedBox(width: 30),

                // ================= SIMPAN =================
                GestureDetector(
                  onTap: () => _handleSave(context, name, stars),
                  child: Image.asset(
                    'assets/images/simpanbt.png',
                    width: 170,
                  ),
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
