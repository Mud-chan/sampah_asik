import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
// Import semua halaman
import 'pages/welcome_page.dart';
import 'pages/home_page.dart';
import 'pages/scan_page.dart';
// import 'pages/hasil.dart';
// import 'pages/detail.dart';
import 'pages/koleksi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi kamera sebelum aplikasi dijalankan
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sampah Asik',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
      ),
      // Halaman pertama yang muncul
      home: const WelcomePage(),
      // 📍 Daftar route aplikasi
      routes: {
        '/home': (context) => const HomePage(),
        '/scan': (context) => ScanPage(cameras: cameras),
        // '/hasil' dihapus karena butuh parameter dinamis
        // '/detail': (context) => const DetailPage(),
        '/koleksi': (context) => const KoleksiPage(),
      },
    );
  }
}