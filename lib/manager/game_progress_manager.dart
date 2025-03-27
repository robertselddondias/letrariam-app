import 'package:shared_preferences/shared_preferences.dart';

class GameProgressManager {
  // Chaves para salvar dados no SharedPreferences
  static const String _hasGameKey = 'has_saved_game';
  static const String _levelKey = 'saved_level';
  static const String _scoreKey = 'saved_score';
  static const String _wordPositionKey = 'saved_word_position';
  static const String _placedLettersKey = 'saved_placed_letters';

  // Singleton pattern
  static final GameProgressManager _instance = GameProgressManager._internal();
  factory GameProgressManager() => _instance;
  GameProgressManager._internal();

  // Salva o progresso do jogo
  Future<void> saveGameProgress({
    required int level,
    required int score,
    required int wordPosition,
    required List<String> placedLetters,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Garantir que o nível seja sempre positivo
      level = level > 0 ? level : 1;

      // Garantir que a pontuação não seja negativa
      score = score >= 0 ? score : 0;

      // Salva que existe um jogo em andamento
      await prefs.setBool(_hasGameKey, true);
      await prefs.setInt(_levelKey, level);
      await prefs.setInt(_scoreKey, score);
      await prefs.setInt(_wordPositionKey, wordPosition);
      await prefs.setStringList(_placedLettersKey, placedLetters);

      print('Progresso salvo - Nível: $level, Pontuação: $score');
    } catch (e) {
      print('Erro ao salvar progresso: $e');
    }
  }

  // Carrega o progresso do jogo
  Future<Map<String, dynamic>> loadGameProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final hasSavedGame = prefs.getBool(_hasGameKey) ?? false;

      if (!hasSavedGame) {
        return {
          'hasSavedGame': false,
          'level': 1,
          'score': 0,
          'wordPosition': 0,
          'placedLetters': <String>[],
        };
      }

      final level = prefs.getInt(_levelKey) ?? 1;
      final score = prefs.getInt(_scoreKey) ?? 0;
      final wordPosition = prefs.getInt(_wordPositionKey) ?? 0;
      final placedLetters = prefs.getStringList(_placedLettersKey) ?? <String>[];

      return {
        'hasSavedGame': true,
        'level': level > 0 ? level : 1,
        'score': score,
        'wordPosition': wordPosition,
        'placedLetters': placedLetters,
      };
    } catch (e) {
      print('Erro ao carregar progresso: $e');
      return {
        'hasSavedGame': false,
        'level': 1,
        'score': 0,
        'wordPosition': 0,
        'placedLetters': <String>[],
      };
    }
  }

  // Limpa o progresso do jogo
  Future<void> clearGameProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_hasGameKey);
      await prefs.remove(_levelKey);
      await prefs.remove(_scoreKey);
      await prefs.remove(_wordPositionKey);
      await prefs.remove(_placedLettersKey);
    } catch (e) {
      print('Erro ao limpar progresso: $e');
    }
  }
}
