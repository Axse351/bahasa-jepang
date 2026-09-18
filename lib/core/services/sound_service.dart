import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playCorrect() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/correct.mp3'));
    } catch (_) {
      // Diam-diam diabaikan kalau file gagal dimuat, jangan ganggu kuis
    }
  }

  static Future<void> playWrong() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/wrong.mp3'));
    } catch (_) {
      // Diam-diam diabaikan
    }
  }
}
