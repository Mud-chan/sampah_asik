import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'hasil.dart';
import 'package:sampah_asik/ml/classifier.dart';

class ScanPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const ScanPage({super.key, required this.cameras});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  XFile? _imageFile;
  bool _isCameraView = true;
  bool _isProcessing = false;
  bool _isModelLoading = true;

  // Classifier instance
  late WasteClassifier _classifier;

  @override
  void initState() {
    super.initState();
    _classifier = WasteClassifier();
    _loadModel();

    if (widget.cameras.isNotEmpty && !kIsWeb) {
      _controller = CameraController(
        widget.cameras.first,
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _controller!.initialize();
    }
  }

  Future<void> _loadModel() async {
    setState(() {
      _isModelLoading = true;
    });

    try {
      await _classifier.loadModel();
      print('✅ Model berhasil dimuat');

      if (mounted) {
        setState(() {
          _isModelLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Model siap digunakan!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error loading model: $e');

      if (mounted) {
        setState(() {
          _isModelLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat model: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _classifier.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fitur kamera belum didukung di Web')),
      );
      return;
    }

    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      setState(() {
        _imageFile = image;
        _isCameraView = false;
      });
    } catch (e) {
      debugPrint("Error mengambil foto: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _isCameraView = false;
      });
    }
  }

  // ✅ Fungsi untuk klasifikasi dan navigasi ke halaman hasil
  Future<void> _classifyAndNavigate() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada gambar yang dipilih')),
      );
      return;
    }

    // ✅ Cek apakah model sudah dimuat
    if (!_classifier.isModelLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Model sedang dimuat, harap tunggu...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      print('🔍 Mulai klasifikasi gambar: ${_imageFile!.path}');

      // Klasifikasi gambar
      final result = await _classifier.classifyImage(_imageFile!.path);

      print(
          '✅ Hasil klasifikasi: ${result['label']} (${result['confidence']})');

      setState(() {
        _isProcessing = false;
      });

      // Navigate ke halaman hasil dengan hasil klasifikasi
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HasilPage(
            imagePath: _imageFile!.path,
            wasteType: result['label'],
            confidence: result['confidence'],
          ),
        ),
      );
    } catch (e) {
      print('❌ Error klasifikasi: $e');

      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error klasifikasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background kamera, hasil foto, atau default image
          Positioned.fill(
            child: _isCameraView
                ? (!kIsWeb && _controller != null)
                    ? FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return CameraPreview(_controller!);
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      )
                    : Image.asset(
                        'assets/images/home_bg.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                : _imageFile != null
                    ? (kIsWeb
                        ? Image.network(
                            _imageFile!.path,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Image.file(
                            File(_imageFile!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ))
                    : Image.asset(
                        'assets/images/home_bg.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
          ),

          // Loading overlay saat processing
          if (_isProcessing || _isModelLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isModelLoading
                          ? "Memuat model AI..."
                          : "Mengklasifikasi gambar...",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Tombol Kamera, Galeri, & Centang
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Tombol Kamera
                  GestureDetector(
                    onTap: (_isProcessing || _isModelLoading)
                        ? null
                        : _takePicture,
                    child: Opacity(
                      opacity: (_isProcessing || _isModelLoading) ? 0.5 : 1.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/images/camera2.png', width: 60),
                          const SizedBox(height: 8),
                          const Text(
                            "Kamera",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tombol Galeri
                  GestureDetector(
                    onTap: (_isProcessing || _isModelLoading)
                        ? null
                        : _pickFromGallery,
                    child: Opacity(
                      opacity: (_isProcessing || _isModelLoading) ? 0.5 : 1.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/images/galeri.png', width: 60),
                          const SizedBox(height: 8),
                          const Text(
                            "Galeri",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tombol Centang (tampil kalau sudah ada gambar)
                  if (_imageFile != null)
                    GestureDetector(
                      onTap: (_isProcessing || _isModelLoading)
                          ? null
                          : _classifyAndNavigate,
                      child: Opacity(
                        opacity: (_isProcessing || _isModelLoading) ? 0.5 : 1.0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/images/centang.png', width: 60),
                            const SizedBox(height: 8),
                            const Text(
                              "Lanjut",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
