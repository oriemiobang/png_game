import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playSubmit() async {
    try {
      await _player.play(AssetSource('audio/submit.mp3'));
    } catch (e) {
      // Ignore if file doesn't exist yet
    }
  }

  Future<void> playCorrect() async {
    try {
      await _player.play(AssetSource('audio/correct.mp3'));
    } catch (e) {
      // Ignore if file doesn't exist yet
    }
  }

  Future<void> playWrong() async {
    try {
      await _player.play(AssetSource('audio/wrong.mp3'));
    } catch (e) {
      // Ignore if file doesn't exist yet
    }
  }

  Future<void> playOpponentGuess() async {
    try {
      await _player.play(AssetSource('audio/opponent_guess.mp3'));
    } catch (e) {
      // Ignore if file doesn't exist yet
    }
  }
}
