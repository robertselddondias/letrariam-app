// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:letrarium/ui/splash_screen.dart';
import 'package:letrarium/ui/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogo de Letras',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'ComicSans',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      builder: (context, child) {
        // Configuração global de responsividade
        return MediaQuery(
          // Garante que a interface se adapte de acordo com as configurações de fonte do sistema
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
