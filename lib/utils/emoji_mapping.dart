import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

class EmojiMapping {
  // Singleton para facilitar o acesso
  static final EmojiMapping _instance = EmojiMapping._internal();
  factory EmojiMapping() => _instance;
  EmojiMapping._internal() {
    _initParser();
  }

  // Inicializa o parser de emoji
  late EmojiParser parser;

  void _initParser() {
    parser = EmojiParser();
  }

  // Mapeamento para termos de pesquisa em inglês para a biblioteca flutter_emoji
  final Map<String, String> wordToEmojiName = {
    // Palavras de 2 letras
    'PÉ': 'foot',
    'SOL': 'sun_with_face',
    'LUA': 'full_moon_with_face',
    'MÃO': 'raised_hand',
    'PÃO': 'bread',

    // Palavras de 3 letras
    'MAR': 'ocean',
    'RIO': 'river',
    'AVE': 'bird',
    'CÃO': 'dog',
    'CHÁ': 'tea',
    'OVO': 'egg',
    'MEL': 'honey_pot',
    'PAI': 'man',
    'MÃE': 'woman',
    'BOI': 'ox',
    'SAL': 'salt',

    // Palavras de 4 letras
    'BOLA': 'soccer',
    'GATO': 'cat',
    'CASA': 'house',
    'AMOR': 'heart',
    'RATO': 'mouse',
    'PATO': 'duck',
    'MAÇÃ': 'apple',
    'LOBO': 'wolf',
    'VASO': 'potted_plant',
    'SAPO': 'frog',
    'BOLO': 'cake',
    'SUCO': 'cup_with_straw',
    'MOTO': 'motorcycle',
    'VACA': 'cow',
    'FOGO': 'fire',
    'LIVRO': 'book',
    'MEIA': 'socks',
    'BEBÊ': 'baby',
    'FADA': 'fairy',
    'GELO': 'ice_cube',
    'NEVE': 'snowflake',
    'CAFÉ': 'coffee',
    'CHAVE': 'key',

    // Palavras de 5 letras
    'BARCO': 'sailboat',
    'COBRA': 'snake',
    'CARRO': 'car',
    'TIGRE': 'tiger',
    'AVIÃO': 'airplane',
    'PEIXE': 'fish',
    'BALÃO': 'balloon',
    'PORCO': 'pig',
    'FOGÃO': 'cooking',
    'PAPEL': 'page_facing_up',
    'PENTE': 'comb',
    'PRAIA': 'beach_with_umbrella',
    'DENTE': 'tooth',
    'CHUVA': 'rain_cloud',
    'LÁPIS': 'pencil',
    'MÚSICA': 'musical_note',
    'PORTA': 'door',
    'MOEDA': 'coin',
    'PEDRA': 'rock',
    'FOLHA': 'leaf',
    'PIZZA': 'pizza',
    'CAMISA': 'shirt',
    'COROA': 'crown',

    // Palavras de 6 letras
    'GIRAFA': 'giraffe_face',
    'BANANA': 'banana',
    'ESCOLA': 'school',
    'SAPATO': 'shoe',
    'CAVALO': 'horse',
    'COELHO': 'rabbit',
    'MACACO': 'monkey',
    'ÁRVORE': 'deciduous_tree',
    'SORVETE': 'ice_cream',
    'ABELHA': 'bee',
    'ELEFANTE': 'elephant',
    'TECLADO': 'musical_keyboard',
    'MARTELO': 'hammer',
  };

  // Mapeamento de palavras para emojis
  final Map<String, String> wordToEmoji = {
    // Palavras de 2 letras
    'PÉ': '🦶',
    'SOL': '🌞',
    'LUA': '🌝',
    'MÃO': '✋',
    'PÃO': '🍞',

    // Palavras de 3 letras
    'MAR': '🌊',
    'RIO': '🏞️',
    'AVE': '🐦',
    'CÃO': '🐕',
    'CHÁ': '🍵',
    'OVO': '🥚',
    'MEL': '🍯',
    'PAI': '👨',
    'MÃE': '👩',
    'BOI': '🐂',
    'SAL': '🧂',

    // Palavras de 4 letras
    'BOLA': '⚽',
    'GATO': '🐱',
    'CASA': '🏠',
    'AMOR': '❤️',
    'RATO': '🐭',
    'PATO': '🦆',
    'MAÇÃ': '🍎',
    'LOBO': '🐺',
    'VASO': '🪴',
    'SAPO': '🐸',
    'BOLO': '🍰',
    'SUCO': '🥤',
    'MOTO': '🏍️',
    'VACA': '🐄',
    'FOGO': '🔥',
    'LIVRO': '📚',
    'MEIA': '🧦',
    'BEBÊ': '👶',
    'FADA': '🧚',
    'GELO': '🧊',
    'NEVE': '❄️',
    'CAFÉ': '☕',
    'CHAVE': '🔑',

    // Palavras de 5 letras
    'BARCO': '⛵',
    'COBRA': '🐍',
    'CARRO': '🚗',
    'TIGRE': '🐯',
    'AVIÃO': '✈️',
    'PEIXE': '🐟',
    'BALÃO': '🎈',
    'PORCO': '🐷',
    'FOGÃO': '🍳',
    'PAPEL': '📄',
    'PENTE': '🪥',
    'PRAIA': '🏖️',
    'DENTE': '🦷',
    'CHUVA': '🌧️',
    'LÁPIS': '✏️',
    'MÚSICA': '🎵',
    'PORTA': '🚪',
    'MOEDA': '🪙',
    'PEDRA': '🪨',
    'FOLHA': '🍃',
    'PIZZA': '🍕',
    'CAMISA': '👕',
    'COROA': '👑',

    // Palavras de 6 letras
    'GIRAFA': '🦒',
    'BANANA': '🍌',
    'ESCOLA': '🏫',
    'SAPATO': '👞',
    'CAVALO': '🐴',
    'COELHO': '🐰',
    'MACACO': '🐒',
    'ÁRVORE': '🌳',
    'SORVETE': '🍨',
    'ABELHA': '🐝',
    'ELEFANTE': '🐘',
    'TECLADO': '🎹',
    'MARTELO': '🔨',
  };

  // Obtém o emoji usando o nome em inglês via flutter_emoji
  String getEmojiByName(String word) {
    String normalizedWord = word.trim().toUpperCase();
    String? emojiName = wordToEmojiName[normalizedWord];

    if (emojiName != null) {
      try {
        return parser.get(emojiName).code;
      } catch (e) {
        print('Erro ao buscar emoji para "$normalizedWord" com nome "$emojiName": $e');
      }
    }

    // Se não encontrar pelo nome, tenta usar o emoji direto
    return getEmojiDirect(word);
  }

  // Obtém o emoji diretamente do mapeamento
  String getEmojiDirect(String word) {
    String normalizedWord = word.trim().toUpperCase();
    String? emoji = wordToEmoji[normalizedWord];

    return emoji ?? '❓';
  }

  // Obtém o emoji pela palavra (tenta ambos os métodos)
  String getEmoji(String word) {
    // Primeiro tenta obter pelo nome em inglês para garantir compatibilidade
    String emoji = getEmojiByName(word);

    // Se retornou um emoji genérico, tenta diretamente do mapeamento
    if (emoji == '❓') {
      emoji = getEmojiDirect(word);
    }

    return emoji;
  }

  // Função para obter um widget de texto com emoji
  Widget getEmojiWidget(String word, {double size = 50.0}) {
    return Text(
      getEmoji(word),
      style: TextStyle(fontSize: size),
    );
  }
}
