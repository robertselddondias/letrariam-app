import 'dart:async';

import 'package:flutter/material.dart';
import 'package:letrarium/ui/start_screen.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({
    Key? key
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar animação de fade-in e fade-out
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );

    // Animação para aparecer e depois sumir
    _opacityAnimation = TweenSequence<double>([
      // Fade in: 0% a 15% do tempo (0s a 1.2s)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      // Mantém visível: 15% a 85% do tempo (1.2s a 6.8s)
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 70,
      ),
      // Fade out: 85% a 100% do tempo (6.8s a 8s)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
    ]).animate(_animationController);

    // Iniciar animação
    _animationController.forward();

    // Configurar timer para navegar para a próxima tela após a animação
    Timer(const Duration(seconds: 6), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => StartScreen()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco
      body: Center(
        child: AnimatedBuilder(
          animation: _opacityAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Imagem do logo
                  Image.asset(
                    'assets/images/seld1.png',
                    width: 350, // Ajuste o tamanho conforme necessário
                    height: 350, // Ajuste o tamanho conforme necessário
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
