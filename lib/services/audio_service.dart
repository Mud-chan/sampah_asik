import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> playBackgroundMusic() async {
    if (_isPlaying) return;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('sounds/ratdance.mp3'));

    _isPlaying = true;
  }

  Future<void> stopMusic() async {
    await _player.stop();
    _isPlaying = false;
  }

  Future<void> pauseMusic() async {
    await _player.pause();
  }

  Future<void> resumeMusic() async {
    if (!_isPlaying) {
      await playBackgroundMusic();
    } else {
      await _player.resume();
    }
  }
}
