// Combined wasteData and DetailPage widget
import 'package:flutter/material.dart';

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
      'difficulty': 60,
      'progress': 40,
      'area': 50,
      'quests': 30,
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
      'difficulty': 100,
      'progress': 80,
      'area': 90,
      'quests': 70,
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
      'difficulty': 70,
      'progress': 50,
      'area': 80,
      'quests': 60,
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
      'difficulty': 50,
      'progress': 30,
      'area': 40,
      'quests': 20,
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
      'difficulty': 50,
      'progress': 40,
      'area': 55,
      'quests': 25,
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
      'difficulty': 30,
      'progress': 20,
      'area': 25,
      'quests': 10,
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
      'difficulty': 20,
      'progress': 60,
      'area': 35,
      'quests': 15,
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
      'difficulty': 20,
      'progress': 50,
      'area': 20,
      'quests': 10,
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
      'difficulty': 40,
      'progress': 80,
      'area': 70,
      'quests': 40,
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
      'progress': 60,
      'area': 65,
      'quests': 50,
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
      'difficulty': 10,
      'progress': 30,
      'area': 15,
      'quests': 5,
    }
  },
};

class DetailPage extends StatelessWidget {
  final String wasteType;
  final double confidence;

  const DetailPage(
      {super.key, required this.wasteType, required this.confidence});

  void _showSavedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // supaya harus klik tombol tutup
      builder: (context) => Dialog(
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
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // tutup dialog
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Image.asset(
                  'assets/images/tutupbt.png',
                  width: 120,
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
                Align(
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
                    _buildProgressBar("Difficulty", prog['difficulty']),
                    _buildProgressBar("Progress", prog['progress']),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProgressBar("Area", prog['area']),
                    _buildProgressBar("Quests", prog['quests']),
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
                // Tombol Abaikan
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                  child: Image.asset(
                    'assets/images/abaikanbt.png',
                    width: 170,
                  ),
                ),
                const SizedBox(width: 30),
                // Tombol Simpan
                GestureDetector(
                  onTap: () => _showSavedDialog(context),
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
      children: [
        Text(title),
        SizedBox(height: 5),
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
              width: (value.toDouble() / 100) * 120,
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
