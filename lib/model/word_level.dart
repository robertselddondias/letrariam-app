// models/word_level.dart

class WordLevel {
  final String word;
  final String emoji;
  final String hint;
  final int order;
  final String category;
  final int difficulty;

  WordLevel({
    required this.word,
    required this.emoji,
    required this.hint,
    required this.category,
    required this.difficulty,
    required this.order,
  });

  // Convert WordLevel to Map
  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'emoji': emoji,
      'hint': hint,
      'category': category,
      'difficulty': difficulty,
      'order': order,
    };
  }

  // Create WordLevel from Map
  factory WordLevel.fromMap(Map<String, dynamic> map) {
    return WordLevel(
      word: map['word'] ?? '',
      emoji: map['emoji'] ?? '🎮',
      hint: map['hint'] ?? '',
      category: map['category'] ?? '',
      difficulty: map['difficulty'] ?? 0,
      order: map['order'] ?? 0
    );
  }

  @override
  String toString() {
    return 'WordLevel(word: $word, emoji: $emoji, hint: $hint)';
  }
}
