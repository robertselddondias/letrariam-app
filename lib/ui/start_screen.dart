import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:letrarium/manager/game_progress_manager.dart';
import 'package:letrarium/manager/game_services_manager.dart';

import 'game_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with SingleTickerProviderStateMixin {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isMusicInitialized = false;

  bool _isMusicPlaying = false;
  bool _isMusicAvailable = false;
  late AnimationController _titleAnimationController;

  final GameProgressManager _gameProgressManager = GameProgressManager();
  final GameServicesManager _gameServices = GameServicesManager();

  bool _hasSavedGame = false;
  int _savedLevel = 1;
  int _savedScore = 0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _titleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _initBackgroundMusic();
    _loadSavedGameData();

    if (Platform.isIOS) {
      _initGameCenter();
    }
  }

  Future<void> _initGameCenter() async {
    await _gameServices.initialize();
  }

  Future<void> _loadSavedGameData() async {
    try {
      final gameProgress = await _gameProgressManager.loadGameProgress();

      // Debug prints para entender o que está sendo carregado
      print('Carregando progresso do jogo:');
      print('Nível: ${gameProgress['level']}');
      print('Pontuação: ${gameProgress['score']}');
      print('Tem jogo salvo: ${gameProgress['hasSavedGame']}');

      setState(() {
        _hasSavedGame = gameProgress['hasSavedGame'] ?? false;
        _savedLevel = gameProgress['level'] ?? 1;
        _savedScore = gameProgress['score'] ?? 0;

        // Garantir que o nível seja sempre positivo
        if (_savedLevel <= 0) {
          _savedLevel = 1;
        }

        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar progresso do jogo: $e');

      setState(() {
        _hasSavedGame = false;
        _savedLevel = 1;
        _savedScore = 0;
        _isLoading = false;
      });
    }
  }

  Future<void> _initBackgroundMusic() async {
    try {
      if (!_isMusicInitialized) {
        await rootBundle.load('assets/sounds/background_music.mp3');

        // Configurar o AudioPlayer para tocar em loop
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);

        // Carregar o arquivo de música
        await _audioPlayer.setSource(AssetSource('sounds/background_music.mp3'));

        _isMusicInitialized = true;
      }

      if (_audioPlayer.state != PlayerState.playing) {
        await _audioPlayer.resume();
      }

      setState(() {
        _isMusicAvailable = true;
        _isMusicPlaying = _audioPlayer.state == PlayerState.playing;
      });
    } catch (e) {
      print('Erro ao inicializar música: $e');
      setState(() {
        _isMusicAvailable = false;
      });
    }
  }

  void _toggleMusic() {
    setState(() {
      _isMusicPlaying = !_isMusicPlaying;
      if (_isMusicPlaying) {
        _audioPlayer.resume();
      } else {
        _audioPlayer.pause();
      }
    });
  }

  void _startNewGame() async {
    try {
      await _gameProgressManager.clearGameProgress();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GameScreen(
            level: 1,
            score: 0,
          ),
        ),
      ).then((_) {
        // Force rebuild of the start screen
        setState(() {
          _loadSavedGameData();
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao iniciar novo jogo: $e')),
      );
    }
  }

  void _continueSavedGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          level: _savedLevel > 0 ? _savedLevel : 1,
          score: _savedScore,
        ),
      ),
    ).then((_) {
      // Force rebuild of the start screen
      setState(() {
        _loadSavedGameData();
      });
    });
  }

  @override
  void dispose() {
    _titleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 350;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/start_background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenSize.height * 0.23),

                  Visibility(
                    visible: _hasSavedGame,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: GestureDetector(
                        onTap: _continueSavedGame,
                        child: Container(
                          width: screenSize.width * 0.7,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _hasSavedGame
                                  ? [Colors.purple.shade400, Colors.purple.shade700]
                                  : [Colors.grey.shade400, Colors.grey.shade600],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                                spreadRadius: 2,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: isSmallScreen ? 30 : 36,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'CONTINUAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 18 : 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: _startNewGame,
                    child: Container(
                      width: screenSize.width * 0.7,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade400, Colors.orange.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.white,
                            size: isSmallScreen ? 30 : 36,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'NOVO JOGO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 18 : 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_isMusicAvailable)
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: _toggleMusic,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isMusicPlaying ? Icons.volume_up : Icons.volume_off,
                      color: Colors.deepPurple,
                      size: 30,
                    ),
                  ),
                ),
              ),

            Positioned(
              bottom: 10,
              right: 10,
              child: Text(
                'v1.0.1',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
