import 'dart:io';
import 'dart:ui' as ui; // Import untuk capture layar
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // Import untuk RenderRepaintBoundary
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

  // Variabel untuk fitur Fokus Kamera
  Offset? _tapPosition;
  bool _showFocusCircle = false;

  // Variabel untuk fitur Zoom Kamera
  double _currentZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;

  // Key untuk capture area gambar yang di-crop
  final GlobalKey _cropKey = GlobalKey();

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

  // FUNGSI BARU: Mengambil screenshot dari area gambar yang digeser/dizoom, lalu dicrop & dicerahkan
  Future<XFile?> _captureAndProcess() async {
    try {
      if (_cropKey.currentContext == null) return null;

      // 1. Capture layar dari gambar yang sudah diposisikan pengguna
      RenderRepaintBoundary boundary = _cropKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      double pixelRatio = 2.0; // Agar resolusi lebih tajam
      ui.Image capturedUiImage = await boundary.toImage(pixelRatio: pixelRatio);
      ByteData? byteData = await capturedUiImage.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 2. Decode gambar hasil capture
      img.Image? decodedImage = img.decodeImage(pngBytes);
      if (decodedImage == null) return null;

      // 3. Potong (Crop) TEPAT di area tengah 250x250 sesuai panduan UI
      int cropSize = (250 * pixelRatio).toInt();
      int x = (decodedImage.width - cropSize) ~/ 2;
      int y = (decodedImage.height - cropSize) ~/ 2;

      img.Image croppedImage = img.copyCrop(decodedImage, x: x, y: y, width: cropSize, height: cropSize);

      // 4. Mencerahkan gambar (Brightness +20%)
      img.Image finalImage = img.adjustColor(croppedImage, brightness: 1.2);

      // 5. Simpan file hasil proses
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      File(path).writeAsBytesSync(img.encodeJpg(finalImage));

      return XFile(path);
    } catch (e) {
      debugPrint("Error saat memproses capture gambar: $e");
      return null;
    }
  }

  Future<void> _takePicture() async {
    if (kIsWeb) return;
    try {
      await _initializeControllerFuture;
      final rawImage = await _controller!.takePicture();
      
      setState(() {
        _imageFile = rawImage;
        _isCameraView = false;
      });
    } catch (e) {
      debugPrint("Error mengambil foto: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _isCameraView = false;
      });
    }
  }

  Future<void> _classifyAndNavigate() async {
    if (_imageFile == null) return;
    if (!_classifier.isModelLoaded) return;

    setState(() => _isProcessing = true);
    try {
      // PROSES GAMBAR KETIKA TOMBOL ANALISIS DITEKAN
      final processedFile = await _captureAndProcess();
      final fileToAnalyze = processedFile ?? _imageFile!;

      final result = await _classifier.classifyImage(fileToAnalyze.path);
      setState(() => _isProcessing = false);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HasilPage(
              imagePath: fileToAnalyze.path, // Tampilkan hasil gambar yang sudah di-crop
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
          // KONTEN UTAMA
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

                                    // Indikator Zoom Kamera
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

                                    // Kotak Panduan Kamera
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

                                    // Indikator Titik Fokus
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
                    // UI PREVIEW GAMBAR INTERAKTIF (CROPPER)
                    ? Stack(
                        children: [
                          // 1. Gambar yang bisa digeser dan dizoom (dibungkus RepaintBoundary)
                          Positioned.fill(
                            child: RepaintBoundary(
                              key: _cropKey,
                              child: Container(
                                color: Colors.black, // Background belakang gambar
                                child: InteractiveViewer(
                                  minScale: 0.1,
                                  maxScale: 5.0,
                                  boundaryMargin: const EdgeInsets.all(double.infinity),
                                  child: Center(
                                    child: kIsWeb
                                        ? Image.network(_imageFile!.path)
                                        : Image.file(File(_imageFile!.path)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // 2. Overlay Gelap Berlubang (Hole Punch)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Colors.black54,
                                  BlendMode.srcOut,
                                ),
                                child: Container(
                                  color: Colors.transparent,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 250,
                                      height: 250,
                                      decoration: BoxDecoration(
                                        color: Colors.black, // Bagian ini akan menjadi bolong transparan
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // 3. Garis Kotak Panduan Crop
                          Center(
                            child: IgnorePointer(
                              child: Container(
                                width: 250,
                                height: 250,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.greenAccent, width: 2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      "Geser & Zoom Pas di Sini",
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
                          : "Menganalisis objek...",
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