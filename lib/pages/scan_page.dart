import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img; // Import untuk pemrosesan gambar
import 'package:path_provider/path_provider.dart'; // Untuk menyimpan file hasil proses
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

  // Variabel untuk fitur Fokus
  Offset? _tapPosition;
  bool _showFocusCircle = false;

  // Variabel untuk fitur Zoom
  double _currentZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;

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
        ResolutionPreset.high, 
        enableAudio: false,
      );
      _initializeControllerFuture = _controller!.initialize().then((_) async {
        // Ambil batas zoom kamera setelah inisialisasi
        if (mounted) {
          _minZoomLevel = await _controller!.getMinZoomLevel();
          _maxZoomLevel = await _controller!.getMaxZoomLevel();
        }
      });
    }
  }

  Future<void> _loadModel() async {
    setState(() => _isModelLoading = true);
    try {
      await _classifier.loadModel();
      if (mounted) {
        setState(() => _isModelLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isModelLoading = false);
    }
  }

  Future<void> _handleTapToFocus(TapDownDetails details, BoxConstraints constraints) async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    setState(() {
      _tapPosition = details.localPosition;
      _showFocusCircle = true;
    });

    try {
      await _controller!.setFocusPoint(offset);
      await _controller!.setExposurePoint(offset);
    } catch (e) {
      debugPrint("Gagal mengatur fokus: $e");
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showFocusCircle = false);
    });
  }

  // Fungsi untuk menangani Zoom
  Future<void> _handleScaleStart(ScaleStartDetails details) async {
    _baseZoomLevel = _currentZoomLevel;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    double newZoom = (_baseZoomLevel * details.scale).clamp(_minZoomLevel, _maxZoomLevel);

    if (newZoom != _currentZoomLevel) {
      setState(() => _currentZoomLevel = newZoom);
      await _controller!.setZoomLevel(newZoom);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _classifier.dispose();
    super.dispose();
  }

  // Fungsi untuk Memotong dan Mencerahkan Gambar
  Future<XFile?> _processImage(XFile capturedFile) async {
    try {
      final bytes = await File(capturedFile.path).readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);

      if (originalImage == null) return null;

      int width = originalImage.width;
      int height = originalImage.height;

      // 1. CROP: Tentukan porsi tengah gambar
      int cropSize = (width < height ? width : height); 
      int size = (cropSize * 0.7).toInt(); 
      int x = (width - size) ~/ 2;
      int y = (height - size) ~/ 2;

      img.Image croppedImage = img.copyCrop(originalImage, x: x, y: y, width: size, height: size);

      // 2. MENCERAHKAN (BRIGHTEN): Tambah kecerahan 20% (brightness = 1.2)
      // Ini akan membuat gambar yang agak gelap jadi lebih mudah dideteksi AI
      img.Image finalImage = img.adjustColor(croppedImage, brightness: 1.2);

      // Simpan hasil ke memori agar bisa dipakai oleh klasifikasi dan UI
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      File(path).writeAsBytesSync(img.encodeJpg(finalImage));

      return XFile(path);
    } catch (e) {
      debugPrint("Error saat memproses gambar: $e");
      return capturedFile; 
    }
  }

  Future<void> _takePicture() async {
    if (kIsWeb) return;
    try {
      setState(() => _isProcessing = true); 
      await _initializeControllerFuture;
      
      final rawImage = await _controller!.takePicture();
      
      // Lakukan pemrosesan (Crop + Pencerahan)
      final processedImg = await _processImage(rawImage);

      setState(() {
        _imageFile = processedImg ?? rawImage;
        _isCameraView = false;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      debugPrint("Error mengambil foto: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _isProcessing = true); // Tampilkan loading
      
      // Kita juga bisa memproses gambar dari galeri (crop & cerahkan)
      final processedImg = await _processImage(pickedFile);
      
      setState(() {
        _imageFile = processedImg ?? pickedFile;
        _isCameraView = false;
        _isProcessing = false;
      });
    }
  }

  Future<void> _classifyAndNavigate() async {
    if (_imageFile == null) return;
    if (!_classifier.isModelLoaded) return;

    setState(() => _isProcessing = true);
    try {
      final result = await _classifier.classifyImage(_imageFile!.path);
      setState(() => _isProcessing = false);

      if (mounted) {
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
      }
    } catch (e) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Pratinjau Kamera / Gambar
          Positioned.fill(
            child: _isCameraView
                ? (!kIsWeb && _controller != null)
                    ? FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            return LayoutBuilder(builder: (context, constraints) {
                              var scale = 1 / (_controller!.value.aspectRatio * MediaQuery.of(context).size.aspectRatio);
                              if (scale < 1) scale = 1 / scale;

                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapDown: (details) => _handleTapToFocus(details, constraints),
                                onScaleStart: _handleScaleStart,
                                onScaleUpdate: _handleScaleUpdate,
                                child: Stack(
                                  children: [
                                    ClipRect(
                                      child: Transform.scale(
                                        scale: scale,
                                        child: Center(
                                          child: CameraPreview(_controller!),
                                        ),
                                      ),
                                    ),

                                    // Indikator Zoom
                                    if (_currentZoomLevel > 1.0)
                                      Positioned(
                                        top: 50,
                                        right: 20,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.black45,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            "${_currentZoomLevel.toStringAsFixed(1)}x",
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),

                                    // 1. Kotak Panduan Statis
                                    Center(
                                      child: Container(
                                        width: 250,
                                        height: 250,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Align(
                                          alignment: Alignment.topCenter,
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 8),
                                            child: Text(
                                              "Posisikan Objek di Sini",
                                              style: TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // 2. Indikator Kotak Fokus
                                    if (_showFocusCircle && _tapPosition != null)
                                      Positioned(
                                        left: _tapPosition!.dx - 35,
                                        top: _tapPosition!.dy - 35,
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.yellow, width: 2),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            });
                          } else {
                            return const Center(child: CircularProgressIndicator());
                          }
                        },
                      )
                    : Image.asset('assets/images/home_bg.png', fit: BoxFit.cover)
                : _imageFile != null
                    ? Center(
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.greenAccent, width: 3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(17),
                            child: kIsWeb
                                ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                                : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                          ),
                        ),
                      )
                    : Image.asset('assets/images/home_bg.png', fit: BoxFit.cover),
          ),

          // Overlay Loading
          if (_isProcessing || _isModelLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      _isModelLoading 
                          ? "Memuat model AI..." 
                          : (_isCameraView ? "Memproses gambar..." : "Menganalisis objek..."),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          // Tombol Kontrol
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  iconPath: 'assets/images/camera2.png',
                  label: _isCameraView ? "Ambil Foto" : "Ulangi",
                  onTap: () {
                    if (_isCameraView) {
                      _takePicture();
                    } else {
                      setState(() {
                        _isCameraView = true;
                        _imageFile = null;
                        _currentZoomLevel = 1.0; 
                      });
                    }
                  },
                ),
                _buildActionButton(
                  iconPath: 'assets/images/galeri.png',
                  label: "Galeri",
                  onTap: _pickFromGallery,
                ),
                if (!_isCameraView && _imageFile != null)
                  _buildActionButton(
                    iconPath: 'assets/images/centang.png',
                    label: "Analisis",
                    onTap: _classifyAndNavigate,
                    color: Colors.greenAccent,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    bool isDisabled = _isProcessing || _isModelLoading;
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(iconPath, width: 65),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color ?? Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}