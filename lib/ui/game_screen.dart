import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:letrarium/manager/game_progress_manager.dart';
import 'package:letrarium/manager/game_services_manager.dart';
import 'package:letrarium/model/letter_tile.dart';
import 'package:letrarium/model/letter_tile_widget.dart';
import 'package:letrarium/model/word_level.dart';
import 'package:letrarium/painters/dashed-border-painter.dart';
import 'package:letrarium/services/firebase_service.dart';
import 'package:letrarium/services/level_service.dart';
import 'package:letrarium/ui/start_screen.dart';
import 'package:letrarium/ui/unlock_levels_screen.dart';

class GameScreen extends StatefulWidget {
  final int level;
  final int score;

  const GameScreen({
    Key? key,
    required this.level,
    this.score = 0,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Níveis do jogo
  late List<WordLevel> levels = [];
  WordLevel? currentLevel;

  // Letras e estado do jogo
  List<LetterTile> fallingLetters = [];
  List<LetterTile> placedLetters = [];
  late int score;
  bool showHint = false;
  bool wordCompleted = false;
  bool gameOver = false;

  // Controladores e temporizadores
  Timer? gameTimer;
  late AnimationController mascotAnimationController;

  // Players de áudio
  final AudioPlayer correctSoundPlayer = AudioPlayer();
  final AudioPlayer errorSoundPlayer = AudioPlayer();

  final FirebaseService _firebaseService = FirebaseService();
  final LevelService _levelService = LevelService();
  final GameServicesManager _gameServices = GameServicesManager();

  final GameProgressManager _gameProgressManager = GameProgressManager();

  bool isLoading = true;

  // Gerador de números aleatórios
  final random = Random();

  @override
  void initState() {
    super.initState();

    // Validar o nível recebido
    int safeLevel = widget.level > 0 ? widget.level : 1;
    score = widget.score >= 0 ? widget.score : 0;

    mascotAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    // Carrega níveis primeiro, não salve o estado ainda
    _loadWordsFromFirebase(safeLevel);

    // Inicializa serviços de jogos para iOS
    if (Platform.isIOS) {
      _gameServices.initialize();
    }
  }

  Future<void> _handleBackNavigation() async {
    try {
      // Verifica se pode salvar o estado
      if (!isLoading && currentLevel != null) {
        await _saveCurrentState();
      }

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => StartScreen()),
              (Route<dynamic> route) => route.isFirst
      );
    } catch (e) {
      print('Erro ao salvar estado ao voltar: $e');
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveCurrentState() async {
    if (currentLevel == null) return; // Não salvar se ainda não carregou o nível

    try {
      // Converter placedLetters para lista de strings
      final placedLettersList = placedLetters.map((lt) => lt.letter).toList();

      // Usar o GameProgressManager para salvar
      await _gameProgressManager.saveGameProgress(
        level: widget.level,
        score: score,
        wordPosition: placedLetters.length,
        placedLetters: placedLettersList,
      );

      print('DEBUG: Estado salvo via GameProgressManager: Nível ${widget.level}, Posição ${placedLetters.length}');
    } catch (e) {
      print('ERRO ao salvar estado: $e');
    }
  }

  // Método para salvar o estado do próximo nível (após completar o nível atual)
  Future<void> _saveNextLevelState() async {
    try {
      final nextLevel = widget.level + 1;

      // Salvar progresso do próximo nível com GameProgressManager
      await _gameProgressManager.saveGameProgress(
        level: nextLevel,
        score: score,
        wordPosition: 0, // Novo nível começa do zero
        placedLetters: [], // Sem letras colocadas ainda
      );

      print('DEBUG: Progresso para nível $nextLevel salvo via GameProgressManager');
    } catch (e) {
      print('ERRO ao salvar progresso do próximo nível: $e');
    }
  }

  Future<void> _loadWordsFromFirebase(int startLevel) async {
    try {
      setState(() {
        isLoading = true;
      });

      levels = await _firebaseService.getWordLevels();

      // Verifica se temos níveis antes de continuar
      if (levels.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum nível encontrado!')),
          );
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      // Ajustar o índice do nível para garantir que esteja dentro dos limites
      int levelIndex = min(max(0, startLevel - 1), levels.length - 1);

      // Define o nível atual
      currentLevel = levels[levelIndex];

      // Marca como carregado
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      // Agora que os níveis foram carregados, inicia o jogo
      if (mounted && currentLevel != null) {
        setupGame();

        // Salva o estado inicial
        _saveCurrentState();
      }
    } catch (e) {
      print('Erro ao carregar palavras: $e');

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar palavras: $e')),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Inicializa o jogo após o widget estar completamente montado
    if (!isLoading && fallingLetters.isEmpty && currentLevel != null) {
      setupGame();
    }
  }

  // Configura o jogo
  void setupGame() {
    if (isLoading || currentLevel == null) return; // Não continuar se ainda estiver carregando
    createFallingLetters();
    startGameLoop();
  }

  // Cria as letras caindo
  void createFallingLetters() {
    if (currentLevel == null) return;

    // Limpa a lista existente
    fallingLetters.clear();

    // Obtém as letras da palavra atual
    List<String> wordLetters = currentLevel!.word.split('');

    // Adiciona algumas letras extras para dificultar
    if (widget.level > 1) {
      List<String> extraLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
      extraLetters.shuffle();

      // Remove as letras que já estão na palavra
      for (String letter in wordLetters) {
        extraLetters.remove(letter);
      }

      // Adiciona letras extras baseadas no nível
      int extras = min(widget.level, 5);
      wordLetters.addAll(extraLetters.take(extras));
    }

    // Embaralha todas as letras
    wordLetters.shuffle();

    if (!mounted) return;

    // Obtém o tamanho da tela
    final screenWidth = MediaQuery.of(context).size.width;

    // Cria as letras em posições aleatórias
    for (int i = 0; i < wordLetters.length; i++) {
      // Posição X aleatória dentro da tela
      double xPos = random.nextDouble() * (screenWidth - 60) + 30;

      // Posição Y negativa para iniciar acima da tela
      // Distribuídas para não caírem todas ao mesmo tempo
      double yPos = -100.0 - (i * 70);

      // Cor aleatória
      Color color = Color.fromARGB(
        255,
        150 + random.nextInt(100),
        150 + random.nextInt(100),
        150 + random.nextInt(100),
      );

      // Adiciona a letra à lista
      fallingLetters.add(LetterTile(
        letter: wordLetters[i],
        x: xPos,
        y: yPos,
        color: color,
      ));
    }
  }

  // Inicia o loop do jogo
  void startGameLoop() {
    // Cancela o timer existente, se houver
    gameTimer?.cancel();

    // Cria um novo timer
    gameTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) return;

      // Pula a atualização se o jogo terminou
      if (wordCompleted || gameOver) return;

      setState(() {
        updateFallingLetters();
      });
    });
  }

  // Atualiza a posição das letras caindo
  void updateFallingLetters() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    for (int i = 0; i < fallingLetters.length; i++) {
      LetterTile letter = fallingLetters[i];

      // Calcula a velocidade baseada no nível
      double speed = 2.0 + (widget.level * 0.2);

      // Move a letra para baixo
      letter.y += speed;

      // Se a letra atingir o fundo da tela, reposiciona no topo
      if (letter.y > screenHeight) {
        letter.y = -50.0;
        letter.x = random.nextDouble() * (screenWidth - 60) + 30;
      }
    }
  }

  // Processa o toque em uma letra
  void onLetterTapped(int index) {
    // Ignora se o jogo terminou ou se o currentLevel é nulo
    if (wordCompleted || gameOver || currentLevel == null) return;

    // Obtém a letra tocada
    LetterTile tappedLetter = fallingLetters[index];

    // Verifica se é a próxima letra correta
    int position = placedLetters.length;

    setState(() {
      if (position < currentLevel!.word.length) {
        if (tappedLetter.letter == currentLevel!.word[position]) {
          fallingLetters.removeAt(index);

          // Adiciona à área da palavra
          placedLetters.add(tappedLetter);

          score += 10;

          _saveCurrentState();

          _playCorrectSound();

          // Verifica se completou a palavra
          if (placedLetters.length == currentLevel!.word.length) {
            // Palavra completa!
            wordCompleted = true;
            score += 50 * widget.level; // Bônus

            // Salva o progresso final do nível
            _saveNextLevelState();

            // Mostra o diálogo de sucesso e avança para o próximo nível
            _showSuccessDialog();
          }
        } else {
          // Letra incorreta!
          gameOver = true;

          // Toca som de erro
          _playErrorSound();

          // Mostra o diálogo de erro
          _showGameOverDialog();
        }
      }
    });
  }

  void _showGameOverDialog() {
    // Para o temporizador do jogo
    gameTimer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        final isSmallScreen = screenSize.width < 350;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 500),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: screenSize.width * 0.85,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.orange.shade400, Colors.deepOrange.shade700],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrange.withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Emoji animado
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: 1.0 + 0.2 * sin(value * 3.14159 * 2),
                            child: Text(
                              '🤔',
                              style: TextStyle(fontSize: isSmallScreen ? 40 : 60),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // Texto "Oops!"
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [Colors.yellow.shade300, Colors.white],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds);
                        },
                        child: Text(
                          'OOPS!',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 28 : 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 5,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Texto erro
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'Essa não é a próxima letra',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Explicação para a criança
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Vamos formar a palavra letra por letra',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Botão de tentar novamente
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Fecha o diálogo
                          // Reinicia o nível atual
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameScreen(
                                level: widget.level,
                                score: score,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tentar Novamente',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange.shade700,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.refresh, color: Colors.deepOrange.shade700),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    if (currentLevel == null) return;

    // Para o temporizador do jogo
    gameTimer?.cancel();

    // Armazena o bônus pela conclusão do nível
    int levelBonus = 50 * widget.level;

    // Verifica se o próximo nível irá exceder o limite gratuito
    if (widget.level == LevelService.freeMaxLevel) {
      _showLevelCompletedWithPurchase(levelBonus);
    } else {
      _showNormalSuccessDialog(levelBonus);
    }
  }

  void _showLevelCompletedWithPurchase(int levelBonus) {
    // Implementação para mostrar a tela de compra quando chega ao nível limite
    // Este método seria implementado se você estiver usando o sistema de compras in-app
    _showNormalSuccessDialog(levelBonus); // Fallback se não implementado
  }

  void _showNormalSuccessDialog(int levelBonus) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        final isSmallScreen = screenSize.width < 350;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 500),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: screenSize.width * 0.85,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.green.shade400, Colors.green.shade700],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Emoji animado
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 1000),
                        builder: (context, double value, child) {
                          return Transform.rotate(
                            angle: value * 2 * 3.14159 * 2,
                            child: Text(
                              '🎉',
                              style: TextStyle(fontSize: isSmallScreen ? 40 : 60),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // Texto "Parabéns!"
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [Colors.yellow.shade300, Colors.white],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds);
                        },
                        child: Text(
                          'PARABÉNS!',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 28 : 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 5,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Texto da palavra formada
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'Você formou a palavra:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 20,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // A palavra em si - Corrigido para não usar altura fixa
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: currentLevel!.word.split('').map((letter) {
                              return Container(
                                width: isSmallScreen ? 35 : 45,
                                height: isSmallScreen ? 35 : 45,
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(
                                    255,
                                    150 + random.nextInt(100),
                                    150 + random.nextInt(100),
                                    150 + random.nextInt(100),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 5,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    letter,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isSmallScreen ? 20 : 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Pontos ganhos
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: 1.0 + sin(value * 3.14159 * 4) * 0.2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade400,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.6),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Text(
                                '+$levelBonus PONTOS!',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 18 : 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.brown.shade800,
                                      blurRadius: 2,
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () async {
                          // Primeiro salva o progresso do próximo nível
                          await _saveNextLevelState();

                          Navigator.of(context).pop();

                          // Verifica se o próximo nível está desbloqueado
                          final nextLevel = widget.level + 1;
                          final nextLevelUnlocked = await _levelService.isLevelUnlocked(nextLevel);

                          if (nextLevelUnlocked) {
                            // Avança para o próximo nível
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GameScreen(
                                  level: nextLevel,
                                  score: score,
                                ),
                              ),
                            );
                          } else {
                            // Se o próximo nível não estiver desbloqueado
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UnlockLevelsScreen(
                                  currentLevel: widget.level,
                                  score: score,
                                ),
                              ),
                            );
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Próximo Nível',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.arrow_forward, color: Colors.green.shade700),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Alterna a exibição da dica
  void toggleHint() {
    setState(() {
      showHint = !showHint;
    });
  }

  @override
  void dispose() {
    // Salva o estado atual antes de fechar
    _saveCurrentState();

    gameTimer?.cancel();
    mascotAnimationController.dispose();
    correctSoundPlayer.dispose();
    errorSoundPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 350;

    // Centro de carregamento para exibir quando os dados estiverem sendo carregados
    final loadingCenter = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Carregando palavras...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );

    // Decoração de fundo reutilizável
    final backgroundDecoration = BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/background.png'),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.white.withOpacity(0.75),
          BlendMode.lighten,
        ),
      ),
    );

    // Verifica se currentLevel é nulo (o que pode acontecer durante o carregamento inicial)
    if (isLoading || currentLevel == null) {
      return Scaffold(
        body: Container(
          decoration: backgroundDecoration,
          child: loadingCenter,
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: backgroundDecoration,
        child: Column(
          children: [
            SizedBox(height: 60),
            _buildTopBar(isSmallScreen),

            // Imagem da palavra atual
            _buildWordImage(isSmallScreen),

            // Dica (se ativada)
            if (showHint) _buildHint(isSmallScreen),

            // Área para formar a palavra
            _buildPlacedLettersArea(isSmallScreen),

            // Área principal do jogo
            Expanded(
              child: Stack(
                children: [
                  // Letras caindo
                  ..._buildFallingLetters(),

                  // Mascote animado
                  _buildAnimatedMascot(isSmallScreen),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Barra superior com botão voltar, nível e pontuação
  Widget _buildTopBar(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 6.0 : 12.0),
      child: Row(
        children: [
          // Botão de voltar (fixo)
          GestureDetector(
            onTap: () {
              _handleBackNavigation();
            },
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
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
                Icons.arrow_back_ios_rounded,
                color: Colors.blue.shade700,
                size: isSmallScreen ? 16 : 20,
              ),
            ),
          ),

          SizedBox(width: 8), // Espaçamento

          // Nível atual (fixo)
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 6 : 10,
                vertical: isSmallScreen ? 3 : 5
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Text(
              'Nível: ${widget.level}',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ),

          // Pontuação (flexível - vai se adaptar ao espaço disponível)
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 6 : 10,
                  vertical: isSmallScreen ? 3 : 5
              ),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Text(
                'Pontos: $score',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis, // Trunca o texto se necessário
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
            ),
          ),

          // Botão de dica (fixo)
          Container(
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.lightbulb_outline),
              onPressed: toggleHint,
              color: Colors.amber,
              iconSize: isSmallScreen ? 20 : 26,
              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
              constraints: BoxConstraints(
                minHeight: isSmallScreen ? 36 : 42,
                minWidth: isSmallScreen ? 36 : 42,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Imagem da palavra
  Widget _buildWordImage(bool isSmallScreen) {
    // Garantir que currentLevel não seja null
    if (currentLevel == null) {
      return Container(); // Retorna um container vazio se currentLevel for nulo
    }

    final imageSize = isSmallScreen ? 100.0 : 130.0;

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 10 : 15),
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          currentLevel!.emoji,
          style: TextStyle(fontSize: isSmallScreen ? 50 : 70),
        ),
      ),
    );
  }

  // Dica
  Widget _buildHint(bool isSmallScreen) {
    if (currentLevel == null) return Container();

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 15 : 30),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Text(
        currentLevel!.hint,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isSmallScreen ? 14 : 18,
          color: Colors.brown.shade800,
        ),
      ),
    );
  }

  // Área para formar a palavra
  Widget _buildPlacedLettersArea(bool isSmallScreen) {
    if (currentLevel == null) return Container();

    final tileSize = isSmallScreen ? 40.0 : 50.0;

    return Container(
      margin: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 10 : 15,
          horizontal: isSmallScreen ? 20 : 30
      ),
      height: tileSize + 20,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.blue.shade700,
          width: 3,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          currentLevel!.word.length,
              (index) {
            if (index < placedLetters.length) {
              // Mostra a letra que foi colocada
              return LetterTileWidget(
                letter: placedLetters[index].letter,
                color: placedLetters[index].color,
                onTap: () {},
              );
            } else {
              // Mostra um espaço vazio
              return Container(
                width: tileSize,
                height: tileSize,
                margin: const EdgeInsets.all(5),
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    color: Colors.grey.shade400,
                    strokeWidth: 2,
                    gap: 3.0,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // Letras caindo
  List<Widget> _buildFallingLetters() {
    return fallingLetters.asMap().entries.map((entry) {
      int index = entry.key;
      LetterTile letter = entry.value;
      return Positioned(
        left: letter.x,
        top: letter.y,
        child: LetterTileWidget(
          letter: letter.letter,
          color: letter.color,
          onTap: () => onLetterTapped(index),
        ),
      );
    }).toList();
  }

  // Mascote animado
  Widget _buildAnimatedMascot(bool isSmallScreen) {
    final mascotSize = isSmallScreen ? 60.0 : 80.0;

    return Positioned(
      right: isSmallScreen ? 10 : 20,
      bottom: isSmallScreen ? 10 : 20,
      child: AnimatedBuilder(
        animation: mascotAnimationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 5 * sin(mascotAnimationController.value * pi)),
            child: Container(
              width: mascotSize,
              height: mascotSize,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '🦊',
                  style: TextStyle(fontSize: isSmallScreen ? 30 : 40),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _playCorrectSound() {
    try {
      correctSoundPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      print('Erro ao reproduzir som de acerto: $e');
    }
  }

  // Reproduz o som de erro
  void _playErrorSound() {
    try {
      errorSoundPlayer.play(AssetSource('sounds/error.ogg'));
    } catch (e) {
      print('Erro ao reproduzir som de erro: $e');
    }
  }
}
