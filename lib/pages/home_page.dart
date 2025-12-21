import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    int currentImpact = 5312;
    int maxImpact = 10000;
    double progressValue = currentImpact / maxImpact;

    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: Stack(
        children: [
          // 🌄 Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // 🌟 Level Bar di atas
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.yellow[700],
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Row(
                children: [
                  // 🏅 Level Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'LV',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.0,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${(progressValue * 10).floor()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 10),

                  // 📊 Progress Bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progressValue,
                            minHeight: 10,
                            color: Colors.green,
                            backgroundColor: Colors.yellow[200],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$currentImpact EXP / Next Level $maxImpact',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // 🎁 Ikon bonus
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: Colors.deepPurple,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🗑️ Karakter di tengah bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/images/characters.png',
              fit: BoxFit.contain,
            ),
          ),

          // 📸 Tombol kamera (diletakkan lebih dulu agar berada DI BELAKANG)
          Positioned(
            right: -50,
            bottom: -50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(70),
                backgroundColor: const Color(0xFFFFD72E).withOpacity(0.9),
                shadowColor: Colors.black45,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/scan');
              },
              child: Image.asset(
                "assets/images/camera1.png",
                width: 66,
                height: 66,
                fit: BoxFit.contain,
              ),
            ),
          ),

// 🗨️ Teks ajakan (DILETAKKAN SETELAHNYA -> muncul DI DEPAN tombol kamera)
          Positioned(
            left: 20,
            bottom: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/scan');
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color:  const Color(0xFFFFD72E).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  
                ),
                child: Row(
                  children: [
                    Image.asset('assets/images/trash_small.png', height: 60),
                    const SizedBox(width: 8),
                    const Text(
                      'Ayo Kumpulkan Sampah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // 🧭 Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFD72E),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        currentIndex: 0, // index 0 karena ini Home
        onTap: (index) {
          if (index == 0) {
            // tetap di Home
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/koleksi');
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
