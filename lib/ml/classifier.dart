import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class WasteClassifier {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isModelLoaded = false;

  bool get isModelLoaded => _isModelLoaded;

  Future<void> loadModel() async {
    try {
      print('🔄 Memuat model...');

      _interpreter = await Interpreter.fromAsset(
        'assets/models/waste_classifier_int8.tflite',
        options: InterpreterOptions()..threads = 4,
      );

      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData
          .split('\n')
          .where((label) => label.trim().isNotEmpty)
          .toList();

      print('✅ Model loaded successfully');
      print('Input shape: ${_interpreter!.getInputTensor(0).shape}');
      print('Output shape: ${_interpreter!.getOutputTensor(0).shape}');
      print('Labels (${_labels.length}): $_labels');

      _isModelLoaded = true;
    } catch (e) {
      print('❌ Error loading model: $e');
      _isModelLoaded = false;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> classifyImage(String imagePath) async {
    if (!_isModelLoaded || _interpreter == null) {
      throw Exception('Model not loaded');
    }

    try {
      print('🔍 Memproses gambar: $imagePath');

      final input = await _preprocessImage(imagePath);

      final outputShape = _interpreter!.getOutputTensor(0).shape;

      // Karena output INT8 / UINT8 → pakai num lalu convert ke double
      var output = List.generate(
        1,
        (i) => List.filled(outputShape[1], 0),
      );

      _interpreter!.run(input, output);

      // Convert output ke double
      List<double> results =
          output[0].map((e) => (e as num).toDouble()).toList();

      print('Raw output: $results');

      double maxConfidence = results[0];
      int maxIndex = 0;

      for (int i = 1; i < results.length; i++) {
        if (results[i] > maxConfidence) {
          maxConfidence = results[i];
          maxIndex = i;
        }
      }

      String labelName =
          maxIndex < _labels.length ? _labels[maxIndex] : 'Unknown';

      print(
          '✅ Hasil: $labelName (confidence: $maxConfidence, index: $maxIndex)');

      return {
        'label': _formatLabel(labelName),
        'confidence': maxConfidence,
        'rawLabel': labelName,
        'allResults': results,
      };
    } catch (e) {
      print('❌ Error klasifikasi: $e');
      rethrow;
    }
  }

  /// PREPROCESS KHUSUS UINT8 (INT8 MODEL)
  Future<List<List<List<List<int>>>>> _preprocessImage(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      final inputShape = _interpreter!.getInputTensor(0).shape;
      final inputHeight = inputShape[1];
      final inputWidth = inputShape[2];

      final resized = img.copyResize(
        image,
        width: inputWidth,
        height: inputHeight,
      );

      final input = List.generate(
        1,
        (b) => List.generate(
          inputHeight,
          (y) => List.generate(
            inputWidth,
            (x) {
              final pixel = resized.getPixel(x, y);

              return [
                pixel.r.toInt(),
                pixel.g.toInt(),
                pixel.b.toInt(),
              ];
            },
          ),
        ),
      );

      return input;
    } catch (e) {
      print('❌ Error preprocessing: $e');
      rethrow;
    }
  }

  String _formatLabel(String label) {
    String clean = label.trim();

    switch (clean.toLowerCase()) {
      case 'kaca_coklat':
        return 'Kaca Coklat';
      case 'kaca_hijau':
        return 'Kaca Hijau';
      case 'kaca_putih':
        return 'Kaca Putih';
      case 'sisa_makanan':
        return 'Sisa Makanan';
      default:
        if (clean.isEmpty) return 'Unknown';
        return clean[0].toUpperCase() + clean.substring(1);
    }
  }

  void dispose() {
    _interpreter?.close();
    _isModelLoaded = false;
  }
}
