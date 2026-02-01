import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'services/audio_service.dart';

// Pages
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

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatefulWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // ▶️ Play musik saat app pertama dibuka
    _audioService.playBackgroundMusic();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioService.stopBackgroundMusic();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden: // ✅ TAMBAH INI
        // ⏸️ App ke background / home / lock / tidak terlihat
        _audioService.pauseBackgroundMusic();
        break;

      case AppLifecycleState.resumed:
        // ▶️ App balik ke foreground
        _audioService.resumeBackgroundMusic();
        break;
    }
  }

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
        '/scan': (context) => ScanPage(cameras: widget.cameras),
        '/koleksi': (context) => const KoleksiPage(),
        '/profile': (context) => const ProfilePage(),
        '/detail-koleksi': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;

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
