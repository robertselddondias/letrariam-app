// services/game_services_manager.dart
import 'dart:io';

import 'package:games_services/games_services.dart';

class GameServicesManager {
  static final GameServicesManager _instance = GameServicesManager._internal();
  factory GameServicesManager() => _instance;
  GameServicesManager._internal();

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  // Inicializar serviços de jogos
  Future<void> initialize() async {
    if (!Platform.isIOS && !Platform.isAndroid) return;

    try {
      await GamesServices.signIn();
      _isSignedIn = true;
      print('Login nos serviços de jogos realizado');
    } catch (e) {
      print('Erro ao fazer login nos serviços de jogos: $e');
      _isSignedIn = false;
    }
  }

  // Enviar pontuação para leaderboard
  Future<void> submitScore({required int score}) async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    if (!_isSignedIn) await initialize();

    try {
      await GamesServices.submitScore(
        score: Score(
          androidLeaderboardID: 'letrario_high_scores',
          iOSLeaderboardID: 'letrario_high_scores',
          value: score,
        ),
      );

      print('Pontuação $score enviada com sucesso');
    } catch (e) {
      print('Erro ao enviar pontuação: $e');
    }
  }

  // Mostrar leaderboard
  Future<void> showLeaderboard() async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    if (!_isSignedIn) await initialize();

    try {
      await GamesServices.showLeaderboards(
        androidLeaderboardID: 'letrario_high_scores',
        iOSLeaderboardID: 'letrario_high_scores',
      );

      print('Leaderboard exibido com sucesso');
    } catch (e) {
      print('Erro ao mostrar leaderboard: $e');
    }
  }

  // Desbloquear conquista
  Future<void> unlockAchievement({required String achievementID}) async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    if (!_isSignedIn) await initialize();

    try {
      await GamesServices.unlock(
        achievement: Achievement(
          androidID: achievementID,
          iOSID: achievementID,
          percentComplete: 100,
        ),
      );

      print('Conquista $achievementID desbloqueada com sucesso');
    } catch (e) {
      print('Erro ao desbloquear conquista: $e');
    }
  }

  // Mostrar conquistas
  Future<void> showAchievements() async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    if (!_isSignedIn) await initialize();

    try {
      await GamesServices.showAchievements();

      print('Tela de conquistas exibida com sucesso');
    } catch (e) {
      print('Erro ao mostrar conquistas: $e');
    }
  }
}
