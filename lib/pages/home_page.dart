import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/session_manager.dart';
import '../utils/exp_helper.dart';
import '../database/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = 'Player';

  File? profileImage;
  Future<void> _loadProfileImage() async {
    final username = await SessionManager.getUsername();
    if (username == null) return;

    final imagePath = await DBHelper.getProfileImage(username);

    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        profileImage = File(imagePath);
      });
    }
  }

  // 🔥 nanti bisa ambil dari DB
  int totalExp = 0;
  Future<void> _loadExp() async {
    final username = await SessionManager.getUsername();
    if (username == null) return;

    final exp = await DBHelper.getExp(username);
    setState(() {
      totalExp = exp;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadProfileImage();
    _loadExp();
  }

  void _loadUsername() async {
    final name = await SessionManager.getUsername();
    setState(() {
      username = name ?? 'Player';
    });
  }

  // ===================== DIALOG BANTUAN (?) =====================
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFFE8D6AB), // Warna krem
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          // Tinggi dialog lebih pendek karena isinya lebih sedikit
          height: MediaQuery.of(context).size.height * 0.50,
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
                     
                      // Penjelasan Kamera (Ramah Anak)
                      Image.asset('assets/images/notifcamera.png', width: 150),
                      const SizedBox(height: 10),
                      const Text(
                        "Tekan tombol kamera ini untuk memotret dan memindai sampahmu. Yuk, cari tahu jenis sampahnya dan kumpulkan poinnya!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
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
    int level = ExpHelper.getLevel(totalExp);
    int currentExp = ExpHelper.getCurrentExp(totalExp);
    double progressValue = ExpHelper.getProgress(totalExp);
    int expNeeded = ExpHelper.expForNextLevel(level);

    return Scaffold(
      backgroundColor: const Color(0xFFFFD72E),
      body: Stack(
        children: [
          // 🌄 Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // 👤 USER + LEVEL
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, $username 👋',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // 🌟 LEVEL BAR
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellow[700],
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 🏅 LEVEL
                      Column(
                        children: [
                          const Text(
                            'LV',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '$level',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 10),

                      // 📊 EXP BAR
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
                              '$currentExp / $expNeeded EXP',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // 🎁 BONUS (FOTO PROFIL)
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/profile').then(
                              (_) => _loadProfileImage()); // 🔥 INI DI SINI
                        },
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.yellow,
                              width: 2,
                            ),
                            image: DecorationImage(
                              image: profileImage != null
                                  ? FileImage(profileImage!)
                                  : const AssetImage('assets/images/trash.png')
                                      as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tombol Tanda Tanya (?) di Bawah Level Bar (Pojok Kanan)
          Positioned(
            top: 20, // Ditaruh sedikit di bawah bar level
            right: 20,
            child: GestureDetector(
              onTap: () => _showHelpDialog(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD72E).withOpacity(0.5),
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

          // 🧍 KARAKTER
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/images/characters.png',
              fit: BoxFit.contain,
            ),
          ),

          // 📸 KAMERA
          Positioned(
            right: -50,
            bottom: -50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(70),
                backgroundColor: const Color(0xFFFFD72E),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/scan');
              },
              child: Image.asset(
                'assets/images/camera1.png',
                width: 66,
              ),
            ),
          ),

          // 🗨️ AJAKAN
          Positioned(
            left: 20,
            bottom: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/scan');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD72E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/trash_small.png',
                      height: 50,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Ayo Kumpulkan Sampah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // 🧭 BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFD72E),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        currentIndex: 0, // ← karena ini halaman Profile
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/koleksi');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections),
            label: 'Koleksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
