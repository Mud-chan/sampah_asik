import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../utils/session_manager.dart';

class KoleksiPage extends StatefulWidget {
  const KoleksiPage({super.key});

  @override
  State<KoleksiPage> createState() => _KoleksiPageState();
}

class _KoleksiPageState extends State<KoleksiPage> {
  List<Map<String, dynamic>> allData = [];
  int currentPage = 0;
  static const int itemsPerPage = 6;

  @override
  void initState() {
    super.initState();
    _loadKoleksi();
  }

  Future<void> _loadKoleksi() async {
    final username = await SessionManager.getUsername();
    if (username == null) return;

    final data = await DBHelper.getSavedWaste(username);
    setState(() {
      allData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔢 Pagination logic
    final start = currentPage * itemsPerPage;
    final end = (start + itemsPerPage) > allData.length
        ? allData.length
        : start + itemsPerPage;

    final pageData = allData.sublist(start, end);

    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 📦 LIST KOLEKSI
            Expanded(
              child: ListView.builder(
                itemCount: pageData.length,
                itemBuilder: (context, index) {
                  final item = pageData[index];
                  final int stars = item['stars'];

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/detail-koleksi',
                        arguments: {
                          'id': item['id'],
                          'name': item['waste_name'],
                          'stars': stars,
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: warnaDariStar(stars),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          // 🗑️ ICON
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black12,
                                width: 2,
                              ),
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/images/${imageNameFromWaste(item['waste_name'])}.png',
                                ),
                                fit: BoxFit.cover, // 🔥 INI KUNCI
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // 📊 INFO
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ⭐ STAR
                                Row(
                                  children: List.generate(
                                    3,
                                    (i) => Icon(
                                      Icons.star,
                                      color: i < stars
                                          ? Colors.amber
                                          : Colors.grey[300],
                                      size: 26,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // 🧾 NAMA
                                Text(
                                  item['waste_name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                // 🌍 DAMPAK LABEL
                                const Text(
                                  'Dampak Pada Lingkungan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),

                                // 🔢 DAMPAK VALUE
                                Text(
                                  dampakDariStar(stars).toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
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

            // 🔢 PAGINATION
            if (allData.length > itemsPerPage)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: currentPage > 0
                        ? () => setState(() => currentPage--)
                        : null,
                  ),
                  Text(
                    'Page ${currentPage + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: (currentPage + 1) * itemsPerPage < allData.length
                        ? () => setState(() => currentPage++)
                        : null,
                  ),
                ],
              ),
          ],
        ),
      ),

      // 🧭 BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFD72E),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        currentIndex: 1,
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

/* ===================== HELPER ===================== */
String imageNameFromWaste(String name) {
  return name
      .toLowerCase()
      .trim()
      .replaceAll(' ', '_');
}

String kategoriDariStar(int stars) {
  if (stars >= 3) return 'Rare';
  if (stars == 2) return 'Normal';
  return 'Common';
}

Color warnaDariStar(int stars) {
  if (stars >= 3) return const Color(0xFFFFFF00);
  if (stars == 2) return const Color(0xFFDEE8B0);
  return const Color(0xFFEAEAEA);
}

int dampakDariStar(int stars) {
  if (stars >= 3) return 2817;
  if (stars == 2) return 1782;
  return 1090;
}
