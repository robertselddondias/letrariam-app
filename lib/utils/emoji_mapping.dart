// Crie o arquivo lib/utils/emoji_mapping.dart
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
    'AR': 'wind',
    'LÁ': 'point_right',
    'PÉ': 'foot',
    'NÓ': 'loop',
    'CÉU': 'sky',
    'DIA': 'sunny',
    'SOL': 'sun',
    'LUA': 'crescent_moon',
    'MÃO': 'hand',
    'PÃO': 'bread',

    // Palavras de 3 letras
    'MAR': 'ocean',
    'RIO': 'river',
    'AVE': 'bird',
    'CÃO': 'dog',
    'CHÁ': 'tea',
    'OVO': 'egg',
    'ASA': 'wing',
    'MEL': 'honey_pot',
    'PAI': 'man',
    'MÃE': 'woman',

    // Palavras de 4 letras
    'BOLA': 'soccer',
    'CASA': 'house',
    'GATO': 'cat',
    'SAPO': 'frog',
    'FLOR': 'blossom',
    'PATO': 'duck',
    'PEIXE': 'tropical_fish',
    'MEIA': 'socks',
    'BEBÊ': 'baby',
    'FADA': 'fairy',
    'LEÃO': 'lion',
    'LOBO': 'wolf',
    'RATO': 'mouse',
    'VACA': 'cow',

    // Palavras de 5 letras
    'LIVRO': 'books',
    'ÁGUA': 'droplet',
    'MAÇÃ': 'apple',
    'CHUVA': 'rain',
    'COBRA': 'snake',
    'TERRA': 'earth_africa',
    'PEDRA': 'rock',
    'PIANO': 'musical_keyboard',
    'PORTA': 'door',
    'BARCO': 'sailboat',
    'MOTO': 'motorcycle',
    'AVIÃO': 'airplane',
    'LÁPIS': 'pencil',
    'BOLO': 'cake',
    'DENTE': 'tooth',
    'LEITE': 'milk',
    'CALÇA': 'jeans',
    'CARRO': 'car',
    'PAPEL': 'page_facing_up',
    'FOGÃO': 'fire',
    'BALÃO': 'balloon',
    'PORCO': 'pig',
    'LIMÃO': 'lemon',
    'TINTA': 'art',
    'NARIZ': 'nose',
    'NUVEM': 'cloud',
    'DANÇA': 'dancer',
    'TIGRE': 'tiger',
    'URSO': 'bear',
    'AREIA': 'hourglass',

    // Outras palavras do mapeamento original
    'AMOR': 'heart',
    'ÁRVORE': 'tree',
    'BANANA': 'banana',
    'BONECA': 'girl',
    'BRUXA': 'woman_mage',
    'CABELO': 'woman_blond_hair',
    'CALÇA': 'jeans',
    'CAMISA': 'shirt',
    'CARANGUEIJO': 'crab',
    'CÉREBRO': 'brain',
    'CHAVE': 'key',
    'COELHO': 'rabbit',
    'CORAÇÃO': 'heart',
    'COROA': 'crown',
    'DINHEIRO': 'moneybag',
    'ESCOLA': 'school',
    'ESTRELA': 'star',
    'FADA': 'fairy',
    'FOGO': 'fire',
    'FOLHA': 'leaves',
    'FUTEBOL': 'soccer',
    'GELADO': 'ice_cube',
    'GUITARRA': 'guitar',
    'LIXO': 'wastebasket',
    'LOJA': 'convenience_store',
    'LOUSA': 'clipboard',
    'LUVA': 'gloves',
    'MACACO': 'monkey',
    'MALA': 'briefcase',
    'MARTELO': 'hammer',
    'MÉDICO': 'man_health_worker',
    'MELANCIA': 'watermelon',
    'MESA': 'chair',
    'MILHO': 'corn',
    'MÚSICA': 'musical_note',
    'NEVE': 'snowflake',
    'NOITE': 'crescent_moon',
    'OLHO': 'eye',
    'ORELHA': 'ear',
    'OSSO': 'bone',
    'OURO': 'medal_gold',
    'PALHAÇO': 'clown',
    'PANDA': 'panda_face',
    'PEDRA': 'rock',
    'PIPOCA': 'popcorn',
    'PIRATA': 'pirate_flag',
    'PIZZA': 'pizza',
    'POLÍCIA': 'police_officer',
    'PRESENTE': 'gift',
    'PRINCESA': 'princess',
    'QUEIJO': 'cheese',
    'RÁDIO': 'radio',
    'RELÓGIO': 'alarm_clock',
    'ROBÔ': 'robot',
    'RODA': 'wheel',
    'ROSA': 'rose',
    'SAPATO': 'mans_shoe',
    'SEREIA': 'mermaid',
    'SONO': 'sleeping',
    'SOPA': 'stew',
    'SORVETE': 'ice_cream',
    'TEATRO': 'performing_arts',
    'TEIA': 'spider_web',
    'TESOURA': 'scissors',
    'TIGELA': 'bowl',
    'TOMATE': 'tomato',
    'TREM': 'steam_locomotive',
    'TRONCO': 'wood',
    'UVA': 'grapes',
    'VENTO': 'wind',
    'VIDRO': 'window',
    'ZEBRA': 'zebra',
  };

  // Mapeamento de palavras para emojis
  final Map<String, String> wordToEmoji = {
    // Palavras de 2 letras
    'AR': '💨',
    'LÁ': '👉',
    'PÉ': '🦶',
    'NÓ': '➰',
    'CÉU': '🌤️',
    'DIA': '☀️',
    'SOL': '☀️',
    'LUA': '🌙',
    'MÃO': '✋',
    'PÃO': '🍞',

    // Palavras de 3 letras
    'MAR': '🌊',
    'RIO': '🏞️',
    'AVE': '🐦',
    'CÃO': '🐕',
    'CHÁ': '🍵',
    'OVO': '🥚',
    'ASA': '🪽',
    'MEL': '🍯',
    'PAI': '👨',
    'MÃE': '👩',

    // Palavras de 4 letras
    'BOLA': '⚽',
    'CASA': '🏠',
    'GATO': '🐱',
    'SAPO': '🐸',
    'FLOR': '🌸',
    'PATO': '🦆',
    'PEIXE': '🐠',
    'MEIA': '🧦',
    'BEBÊ': '👶',
    'FADA': '🧚',
    'LEÃO': '🦁',
    'LOBO': '🐺',
    'RATO': '🐭',
    'VACA': '🐄',

    // Palavras de 5 letras
    'LIVRO': '📚',
    'ÁGUA': '💧',
    'MAÇÃ': '🍎',
    'CHUVA': '🌧️',
    'COBRA': '🐍',
    'TERRA': '🌍',
    'PEDRA': '🪨',
    'PIANO': '🎹',
    'PORTA': '🚪',
    'BARCO': '⛵',
    'MOTO': '🏍️',
    'AVIÃO': '✈️',
    'LÁPIS': '✏️',
    'BOLO': '🎂',
    'DENTE': '🦷',
    'LEITE': '🥛',
    'CALÇA': '👖',
    'CARRO': '🚗',
    'PAPEL': '📄',
    'FOGÃO': '🔥',
    'BALÃO': '🎈',
    'PORCO': '🐷',
    'LIMÃO': '🍋',
    'TINTA': '🎨',
    'NARIZ': '👃',
    'NUVEM': '☁️',
    'DANÇA': '💃',
    'TIGRE': '🐯',
    'URSO': '🐻',
    'AREIA': '⏳',

    // Outras palavras do mapeamento original
    'AMOR': '❤️',
    'ÁRVORE': '🌳',
    'BANANA': '🍌',
    'BONECA': '👧',
    'BRUXA': '🧙‍♀️',
    'CABELO': '👱‍♀️',
    'CAMISA': '👕',
    'CARANGUEIJO': '🦀',
    'CASA': '🏠',
    'CÉREBRO': '🧠',
    'CÉU': '🌤️',
    'CHAVE': '🔑',
    'COELHO': '🐰',
    'CORAÇÃO': '❤️',
    'COROA': '👑',
    'DINHEIRO': '💰',
    'ESCOLA': '🏫',
    'ESTRELA': '⭐',
    'FOGO': '🔥',
    'FOLHA': '🍃',
    'FUTEBOL': '⚽',
    'GATO': '🐱',
    'GELADO': '🧊',
    'GUITARRA': '🎸',
    'LEÃO': '🦁',
    'LIXO': '🗑️',
    'LOBO': '🐺',
    'LOJA': '🏪',
    'LOUSA': '📋',
    'LUVA': '🧤',
    'MAÇÃ': '🍎',
    'MACACO': '🐒',
    'MALA': '💼',
    'MARTELO': '🔨',
    'MÉDICO': '👨‍⚕️',
    'MELANCIA': '🍉',
    'MESA': '🪑',
    'MILHO': '🌽',
    'MÚSICA': '🎵',
    'NEVE': '❄️',
    'NOITE': '🌙',
    'OLHO': '👁️',
    'ORELHA': '👂',
    'OSSO': '🦴',
    'OURO': '🥇',
    'OVO': '🥚',
    'PALHAÇO': '🤡',
    'PANDA': '🐼',
    'PATO': '🦆',
    'PEDRA': '🪨',
    'PIANO': '🎹',
    'PIPOCA': '🍿',
    'PIRATA': '🏴‍☠️',
    'PIZZA': '🍕',
    'POLÍCIA': '👮',
    'PORTA': '🚪',
    'PRESENTE': '🎁',
    'PRINCESA': '👸',
    'QUEIJO': '🧀',
    'RÁDIO': '📻',
    'RATO': '🐭',
    'RELÓGIO': '⏰',
    'ROBÔ': '🤖',
    'RODA': '🛞',
    'ROSA': '🌹',
    'SAPO': '🐸',
    'SAPATO': '👞',
    'SEREIA': '🧜‍♀️',
    'SOL': '☀️',
    'SONO': '😴',
    'SOPA': '🍲',
    'SORVETE': '🍦',
    'TEATRO': '🎭',
    'TEIA': '🕸️',
    'TESOURA': '✂️',
    'TIGELA': '🥣',
    'TOMATE': '🍅',
    'TREM': '🚂',
    'TRONCO': '🪵',
    'UVA': '🍇',
    'VENTO': '💨',
    'VIDRO': '🪟',
    'ZEBRA': '🦓',
  };

  // Obtém o emoji usando o nome em inglês via flutter_emoji
  String getEmojiByName(String word) {
    String normalizedWord = word.trim().toUpperCase();
    String? emojiName = wordToEmojiName[normalizedWord];

    if (emojiName != null) {
      try {
        debugPrint(parser.get('heart').code);
        return parser.get('$emojiName').code;
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
