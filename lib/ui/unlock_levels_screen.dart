import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:letrarium/manager/game_progress_manager.dart';
import 'package:letrarium/services/purchase_service.dart';
import 'package:letrarium/ui/game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnlockLevelsScreen extends StatefulWidget {
  final int currentLevel;
  final int score;

  const UnlockLevelsScreen({
    Key? key,
    required this.currentLevel,
    required this.score,
  }) : super(key: key);

  @override
  State<UnlockLevelsScreen> createState() => _UnlockLevelsScreenState();
}

class _UnlockLevelsScreenState extends State<UnlockLevelsScreen> with TickerProviderStateMixin {
  final PurchaseService _purchaseService = PurchaseService();
  bool _isLoading = true;
  bool _purchasing = false;
  bool _levelsUnlocked = false;
  ProductDetails? _unlockProduct;

  // Controllers para animações
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;

  // Controladores para novas animações
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  GameProgressManager _gameProgressManager = new GameProgressManager();

  @override
  void initState() {
    super.initState();

    // Inicializa animações
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut)
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
        CurvedAnimation(parent: _rotateController, curve: Curves.easeInOutBack)
    );

    // Nova animação de pulso para o botão de compra
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
    );

    // Animação de shimmer para elementos destacados
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
        CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut)
    );

    _scaleController.forward();
    _rotateController.repeat();
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();

    _initPurchase();
  }

  Future<void> _initPurchase() async {
    // Primeiro verificamos se os níveis já foram desbloqueados anteriormente
    final prefs = await SharedPreferences.getInstance();
    _levelsUnlocked = prefs.getBool('levels_unlocked') ?? false;

    if (_levelsUnlocked) {
      // Se já desbloqueado, avança automaticamente
      _navigateToNextLevel();
      return;
    }

    // Inicializa o serviço de compras
    await _purchaseService.initialize();

    // Procura pelo produto de desbloqueio de níveis
    _unlockProduct = _purchaseService.products.first;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _purchaseUnlock() async {
    if (_unlockProduct == null) {
      _showErrorMessage('Produto não disponível no momento.');
      return;
    }

    setState(() {
      _purchasing = true;
    });

    try {
      final success = await _purchaseService.buyProduct(_unlockProduct!);

      if (success) {
        // A compra será processada assincronamente pelo listener no PurchaseService
        // Se a compra for bem-sucedida, o método _deliverProduct será chamado
        // Vamos verificar periodicamente se os níveis foram desbloqueados
        _checkPurchaseStatus();
      } else {
        setState(() {
          _purchasing = false;
          _gameProgressManager.clearGameProgress();
        });
        _showErrorMessage('Não foi possível iniciar a compra.');
      }
    } catch (e) {
      setState(() {
        _purchasing = false;
      });
      _showErrorMessage('Erro ao processar a compra: $e');
    }
  }

  // Verifica periodicamente se a compra foi concluída
  Future<void> _checkPurchaseStatus() async {
    // Aguarda 2 segundos para o processamento da compra
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    bool unlocked = prefs.getBool('levels_unlocked') ?? false;

    if (unlocked) {
      setState(() {
        _levelsUnlocked = true;
        _purchasing = false;
      });

      // Aguarda para mostrar o sucesso antes de avançar
      await Future.delayed(const Duration(seconds: 1));
      _navigateToNextLevel();
    } else {
      // Se ainda não estiver desbloqueado, tenta novamente
      setState(() {
        _purchasing = false;
      });

      // Mostre a mensagem de tentar novamente
      _showErrorMessage('A compra não foi concluída. Tente novamente.');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _restorePurchases() async {
    setState(() {
      _purchasing = true;
    });

    await _purchaseService.restorePurchases();

    // Verifica se os níveis foram desbloqueados após a restauração
    final prefs = await SharedPreferences.getInstance();
    bool unlocked = prefs.getBool('levels_unlocked') ?? false;

    setState(() {
      _levelsUnlocked = unlocked;
      _purchasing = false;
    });

    if (unlocked) {
      // Aguarda para mostrar o sucesso antes de avançar
      await Future.delayed(const Duration(seconds: 1));
      _navigateToNextLevel();
    } else {
      _showErrorMessage('Nenhuma compra encontrada para restaurar.');
    }
  }

  void _navigateToNextLevel() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          level: widget.currentLevel + 1,
          score: widget.score,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 350;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A2980),
              Color(0xFF26D0CE),
            ],
          ),
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.overlay,
            ),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: SafeArea(
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : AnimatedBuilder(
                animation: _scaleController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.9),
                            Colors.white.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Ícone de premium com efeito de brilho
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      AnimatedBuilder(
                                        animation: _shimmerController,
                                        builder: (context, child) {
                                          return Container(
                                            width: isSmallScreen ? 50 : 60,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(3),
                                              gradient: LinearGradient(
                                                begin: Alignment(
                                                  _shimmerAnimation.value - 1,
                                                  0,
                                                ),
                                                end: Alignment(
                                                  _shimmerAnimation.value,
                                                  0,
                                                ),
                                                colors: [
                                                  Colors.amber.withOpacity(0.0),
                                                  Colors.amber.withOpacity(0.5),
                                                  Colors.amber.withOpacity(0.0),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFFFFC107),
                                            Color(0xFFFF9800),
                                          ],
                                        ).createShader(bounds),
                                        child: Text(
                                          'PREMIUM',
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 18 : 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 2.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Medalha/Badge animado com efeitos modernos
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Círculos decorativos em volta do prêmio
                                      ...List.generate(3, (index) {
                                        final size = isSmallScreen ? 180.0 - (index * 20) : 200.0 - (index * 20);
                                        return AnimatedBuilder(
                                          animation: _rotateController,
                                          builder: (context, child) {
                                            return Transform.rotate(
                                              angle: _rotateAnimation.value + (index * 0.5),
                                              child: Container(
                                                width: size,
                                                height: size,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.amber.withOpacity(0.3 - (index * 0.1)),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }),

                                      // Principal "troféu" ou imagem destaque
                                      Container(
                                        width: isSmallScreen ? 110 : 130,
                                        height: isSmallScreen ? 110 : 130,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.amber.shade300,
                                              Colors.orange.shade600,
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.amber.withOpacity(0.6),
                                              blurRadius: 15,
                                              spreadRadius: 0,
                                            ),
                                            BoxShadow(
                                              color: Colors.amber.withOpacity(0.4),
                                              blurRadius: 30,
                                              spreadRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.emoji_events,
                                            size: isSmallScreen ? 60 : 70,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),

                                      // Raios/efeitos de luz
                                      AnimatedBuilder(
                                        animation: _rotateController,
                                        builder: (context, child) {
                                          return Transform.rotate(
                                            angle: -_rotateAnimation.value * 0.7,
                                            child: Container(
                                              width: isSmallScreen ? 150 : 170,
                                              height: isSmallScreen ? 150 : 170,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: List.generate(8, (index) {
                                                  final angle = (index / 8) * 2 * 3.14159;
                                                  return Transform.translate(
                                                    offset: Offset(
                                                      cos(angle) * (isSmallScreen ? 70 : 80),
                                                      sin(angle) * (isSmallScreen ? 70 : 80),
                                                    ),
                                                    child: Transform.rotate(
                                                      angle: angle,
                                                      child: Container(
                                                        width: 12,
                                                        height: 3,
                                                        decoration: BoxDecoration(
                                                          color: Colors.amber.withOpacity(0.8),
                                                          borderRadius: BorderRadius.circular(2),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Título com destaque visual
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.blue.shade800,
                                        Colors.blue.shade500,
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      'Níveis Adicionais',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 26 : 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Texto explicativo mais atraente
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.blue.shade100.withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Parabéns por chegar ao nível ${widget.currentLevel}!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 16 : 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 14 : 16,
                                              color: Colors.blue.shade800,
                                            ),
                                            children: [
                                              TextSpan(text: 'Desbloqueie '),
                                              TextSpan(
                                                text: 'mais de 300 níveis',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                              TextSpan(text: ' para continuar sua jornada de aprendizado!'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  if (_levelsUnlocked)
                                  // Se já desbloqueado - botão melhorado
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(0.4),
                                            blurRadius: 10,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.check_circle, size: 22),
                                        label: const Text(
                                          'Níveis Desbloqueados!',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green.shade600,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                        onPressed: _navigateToNextLevel,
                                      ),
                                    )
                                  else if (_purchasing)
                                  // Loading durante a compra
                                    Container(
                                      width: 50,
                                      height: 50,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blue.shade700,
                                        ),
                                        strokeWidth: 3,
                                      ),
                                    )
                                  else
                                  // Botão de compra animado com destaque visual
                                    Column(
                                      children: [
                                        // Benefícios do desbloqueio
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            _benefitItem(
                                              Icons.star,
                                              'Mais Níveis',
                                              isSmallScreen,
                                            ),
                                            _benefitItem(
                                              Icons.whatshot,
                                              'Desafios',
                                              isSmallScreen,
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 16),

                                        // Oferta especial
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 16),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade500,
                                            borderRadius: BorderRadius.circular(30),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.red.withOpacity(0.4),
                                                blurRadius: 8,
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: const Text(
                                            'OFERTA ESPECIAL',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),

                                        // Botão principal de compra com animação de pulso
                                        AnimatedBuilder(
                                          animation: _pulseController,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: _pulseAnimation.value,
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(24),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Colors.blue.shade500,
                                                      Colors.blue.shade800,
                                                    ],
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.blue.shade500.withOpacity(0.5),
                                                      blurRadius: 12,
                                                      spreadRadius: 0,
                                                      offset: const Offset(0, 6),
                                                    ),
                                                  ],
                                                ),
                                                child: ElevatedButton.icon(
                                                  icon: const Icon(
                                                    Icons.lock_open,
                                                    size: 24,
                                                    color: Colors.white,
                                                  ),
                                                  label: Text(
                                                    'Desbloquear Agora por ${_unlockProduct?.price}0',
                                                    style: TextStyle(
                                                      fontSize: isSmallScreen ? 16 : 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.transparent,
                                                    shadowColor: Colors.transparent,
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 18,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(24),
                                                    ),
                                                  ),
                                                  onPressed: _purchaseUnlock,
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                        const SizedBox(height: 12),

                                        // Opção para restaurar compras estilizada
                                        TextButton.icon(
                                          icon: Icon(
                                            Icons.restore,
                                            size: 18,
                                            color: Colors.blue.shade700,
                                          ),
                                          label: Text(
                                            'Já comprou antes? Restaurar Compras',
                                            style: TextStyle(
                                              color: Colors.blue.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          onPressed: _restorePurchases,
                                        ),
                                      ],
                                    ),

                                  const SizedBox(height: 16),

                                  // Botão de voltar estilizado
                                  TextButton.icon(
                                    icon: Icon(
                                      Icons.arrow_back_rounded,
                                      color: Colors.grey.shade700,
                                      size: 18,
                                    ),
                                    label: Text(
                                      'Voltar aos Níveis Gratuitos',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                    onPressed: () {
                                      _gameProgressManager.clearGameProgress();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );

                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget para itens de benefício
  Widget _benefitItem(IconData icon, String text, bool isSmallScreen) {
    return Container(
      width: isSmallScreen ? 90 : 100,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.amber.shade600,
            size: isSmallScreen ? 24 : 28,
          ),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 13,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
