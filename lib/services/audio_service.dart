import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  bool _isInitialized = false;
  bool _isPlaying = false;

  Future<void> playBackgroundMusic() async {
    if (_isInitialized) return;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(
      AssetSource('audio/ratdance.mp3'),
      volume: 0.6,
    );

    _isInitialized = true;
    _isPlaying = true;
  }

  void pauseBackgroundMusic() {
    if (_isPlaying) {
      _player.pause();
      _isPlaying = false;
    }
  }

  void resumeBackgroundMusic() {
    if (_isInitialized && !_isPlaying) {
      _player.resume();
      _isPlaying = true;
    }
  }

  void stopBackgroundMusic() {
    _player.stop();
    _isPlaying = false;
    _isInitialized = false;
  }
}
