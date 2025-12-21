import 'package:flutter/material.dart';

class KoleksiPage extends StatelessWidget {
  const KoleksiPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 📦 Data koleksi (sementara hardcode, bisa dari API nanti)
    final List<Map<String, dynamic>> koleksi = [
      {
        'kategori': 'Rare',
        'warna': const Color(0xFFFFFF00),
        'bintang': 3,
        'icon': 'assets/images/botol.png',
        'dampak': 8908
      },
      {
        'kategori': 'Rare',
        'warna': const Color(0xFFFFFF00),
        'bintang': 3,
        'icon': 'assets/images/botol.png',
        'dampak': 8908
      },
      {
        'kategori': 'Normal',
        'warna': const Color(0xFFDEE8B0),
        'bintang': 2,
        'icon': 'assets/images/botol.png',
        'dampak': 8908
      },
      {
        'kategori': 'Common',
        'warna': const Color(0xFFEAEAEA),
        'bintang': 1,
        'icon': 'assets/images/botol.png',
        'dampak': 8908
      },
      {
        'kategori': 'Common',
        'warna': const Color(0xFFEAEAEA),
        'bintang': 1,
        'icon': 'assets/images/botol.png',
        'dampak': 8908
      },
    ];

    return Scaffold(
      backgroundColor: Colors.yellow[50],

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: koleksi.length,
          itemBuilder: (context, index) {
            final item = koleksi[index];
            return GestureDetector(
              onTap: () {
                // 👉 Ketika diklik, langsung pindah ke halaman detail
                Navigator.pushNamed(context, '/detail');
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item['warna'],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    // 🗑️ Gambar tempat sampah
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Image.asset(
                        item['icon'],
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 🌟 Info botol
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bintang sesuai jumlah
                          Row(
                            children: List.generate(
                              3,
                              (starIndex) => Icon(
                                Icons.star,
                                color: starIndex < item['bintang']
                                    ? Colors.amber
                                    : Colors.grey[300],
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Botol Plastik!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          const Text(
                            'Dampak pada Lingkungan',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${item['dampak']}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      // 🧭 Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFD72E),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        currentIndex: 1, // index 1 karena ini halaman Koleksi
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            // tetap di halaman ini
          } else if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Equipment belum tersedia')),
            );
          } else if (index == 3) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Shop belum tersedia')),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark_rounded),
            label: 'Koleksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_rounded),
            label: 'Equipment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_rounded),
            label: 'Shop',
          ),
        ],
      ),
    );
  }
}
