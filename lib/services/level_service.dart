import 'package:shared_preferences/shared_preferences.dart';

class LevelService {
  // Singleton pattern
  static final LevelService _instance = LevelService._internal();
  factory LevelService() => _instance;
  LevelService._internal();

  // Constantes
  static const int freeMaxLevel = 10;

  // Verifica se um nível específico está desbloqueado
  Future<bool> isLevelUnlocked(int level) async {
    // Níveis de 1 até freeMaxLevel estão sempre desbloqueados
    if (level <= freeMaxLevel) {
      return true;
    }

    // Para níveis superiores, verifica se o usuário fez a compra
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('levels_unlocked') ?? false;
  }

  // Desbloqueia todos os níveis (chamado após compra bem-sucedida)
  Future<void> unlockAllLevels() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('levels_unlocked', true);
  }

  // Retorna o número máximo de níveis disponíveis
  Future<int> getMaxAvailableLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final bool unlocked = prefs.getBool('levels_unlocked') ?? false;

    if (unlocked) {
      return 999; // Efetivamente ilimitado
    } else {
      return freeMaxLevel;
    }
  }

  // Verifica se o limite de níveis gratuitos foi atingido
  Future<bool> hasReachedFreeLimit(int currentLevel) async {
    return currentLevel >= freeMaxLevel;
  }
}
