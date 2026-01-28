import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'services/audio_service.dart';
// Import semua halaman
import 'pages/welcome_page.dart';
import 'pages/home_page.dart';
import 'pages/scan_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/koleksi.dart';
import 'pages/profile_page.dart';
import 'pages/detail_koleksi_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  await AudioService().playBackgroundMusic();
  runApp(MyApp(cameras: cameras));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
      home: const WelcomePage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/scan': (context) => ScanPage(cameras: cameras),
        '/koleksi': (context) => const KoleksiPage(),
        '/profile': (context) => const ProfilePage(),
        '/detail-koleksi': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return DetailKoleksiPage(
            id: args['id'],
            wasteName: args['name'],
            stars: args['stars'],
          );
        },
      },
    );
  }
}
