import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class WasteClassifier {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isModelLoaded = false;

  bool get isModelLoaded => _isModelLoaded;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/modelmulungasikbanget_int8.tflite',
      options: InterpreterOptions()..threads = 4,
    );

    final labelsData = await rootBundle.loadString('assets/labels.txt');
    _labels = labelsData
        .split('\n')
        .where((e) => e.trim().isNotEmpty)
        .toList();

    _isModelLoaded = true;
  }

  // ======================= SOFTMAX =======================
  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce((a, b) => a > b ? a : b);
    final exps = logits.map((e) => math.exp(e - maxLogit)).toList();
    final sum = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sum).toList();
  }

  // ======================= CLASSIFY =======================
  Future<Map<String, dynamic>> classifyImage(String imagePath) async {
    final input = await _preprocessImage(imagePath);

    final outputTensor = _interpreter!.getOutputTensor(0);
    final scale = outputTensor.params.scale;
    final zeroPoint = outputTensor.params.zeroPoint;

    var output = List.generate(
      1,
      (i) => List.filled(outputTensor.shape[1], 0),
    );

    _interpreter!.run(input, output);

    // 1. Dequantize INT8 → float
    List<double> dequantized = output[0].map((e) {
      final int v = e as int;
      return (v - zeroPoint) * scale;
    }).toList();

    // 2. Softmax → probabilitas 0.0 – 1.0
    List<double> probabilities = _softmax(dequantized);

    // 3. Ambil confidence terbesar
    double maxConfidence = probabilities[0];
    int maxIndex = 0;

    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxConfidence) {
        maxConfidence = probabilities[i];
        maxIndex = i;
      }
    }

    String label =
        maxIndex < _labels.length ? _labels[maxIndex] : "Unknown";

    print("Probabilities: $probabilities");
    print("Result: $label → $maxConfidence");

    return {
      'label': _formatLabel(label),
      'confidence': maxConfidence, // sudah 0.0 – 1.0
    };
  }

  // ======================= PREPROCESS =======================
  Future<List<List<List<List<int>>>>> _preprocessImage(String imagePath) async {
    final imageFile = File(imagePath);
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes)!;

    final inputShape = _interpreter!.getInputTensor(0).shape;
    final h = inputShape[1];
    final w = inputShape[2];

    final resized = img.copyResize(image, width: w, height: h);

    return [
      List.generate(
        h,
        (y) => List.generate(
          w,
          (x) {
            final p = resized.getPixel(x, y);
            return [p.r.toInt(), p.g.toInt(), p.b.toInt()];
          },
        ),
      )
    ];
  }

  String _formatLabel(String label) {
    String clean = label.trim().toLowerCase();
    switch (clean) {
      case 'kaca_coklat':
        return 'Kaca Coklat';
      case 'kaca_hijau':
        return 'Kaca Hijau';
      case 'kaca_putih':
        return 'Kaca Putih';
      case 'sisa_makanan':
        return 'Sisa Makanan';
      case 'buah_busuk':
        return 'Buah Busuk';
      case 'kulit_telur':
        return 'Kulit Telur';
      default:
        return clean[0].toUpperCase() + clean.substring(1);
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}
