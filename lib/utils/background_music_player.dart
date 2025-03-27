// services/background_music_player.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackgroundMusicPlayer {
  static final BackgroundMusicPlayer _instance = BackgroundMusicPlayer._internal();
  final AudioPlayer _player = AudioPlayer();
  bool _isMusicAvailable = false;
  bool _isMusicPlaying = false;

  // Construtor singleton
  factory BackgroundMusicPlayer() {
    return _instance;
  }

  BackgroundMusicPlayer._internal();

  // Inicializa a música
  Future<void> initialize() async {
    try {
      // Verifica se o arquivo existe
      await rootBundle.load('assets/sounds/background_music.mp3');
      _isMusicAvailable = true;

      // Configura o player
      await _player.setReleaseMode(ReleaseMode.loop);

      // Pré-carrega o arquivo, mas não inicia a reprodução ainda
      await _player.setSource(AssetSource('sounds/background_music.mp3'));

    } catch (e) {
      _isMusicAvailable = false;
      debugPrint('Arquivo de música não encontrado: $e');
    }
  }

  // Inicia a reprodução
  Future<void> play() async {
    if (_isMusicAvailable) {
      try {
        // Em audioplayers, podemos usar o resume() se já carregamos a fonte
        // ou play() para iniciar uma nova reprodução
        if (_player.state == PlayerState.paused) {
          await _player.resume();
        } else {
          await _player.play(AssetSource('sounds/background_music.mp3'));
        }
        _isMusicPlaying = true;
      } catch (e) {
        debugPrint('Erro ao reproduzir música: $e');
      }
    }
  }

  // Pausa a reprodução
  Future<void> pause() async {
    if (_isMusicAvailable) {
      try {
        await _player.pause();
        _isMusicPlaying = false;
      } catch (e) {
        debugPrint('Erro ao pausar música: $e');
      }
    }
  }

  // Alterna entre play e pause
  Future<void> togglePlay() async {
    if (_isMusicPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  // Verifica se a música está disponível
  bool get isMusicAvailable => _isMusicAvailable;

  // Verifica se a música está tocando
  bool get isMusicPlaying => _player.state == PlayerState.playing;

  // Ajusta o volume
  Future<void> setVolume(double volume) async {
    if (_isMusicAvailable) {
      try {
        await _player.setVolume(volume.clamp(0.0, 1.0));
      } catch (e) {
        debugPrint('Erro ao ajustar volume: $e');
      }
    }
  }

  // Libera recursos
  void dispose() {
    _player.dispose();
  }
}
