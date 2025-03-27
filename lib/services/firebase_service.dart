// lib/services/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:letrarium/model/word_level.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para carregar as palavras do Firestore
  Future<List<WordLevel>> getWordLevels() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('words')
          .orderBy('order')
          .get();

      // Mapeia os documentos para objetos WordLevel
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return WordLevel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Erro ao carregar palavras do Firestore: $e');
      return [];
    }
  }

  Future<void> saveWords() async {
    try {
      await _firestore.collection('words').add(WordLevel(
          word: 'CHUVA',
          emoji: '🌧️',
          hint: 'Água que cai do céu',
          order: 37,
          difficulty: 2,
          category: 'Natureza'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'LIVRO',
          emoji: '📚',
          hint: 'Tem páginas com histórias',
          order: 38,
          difficulty: 2,
          category: 'Objetos'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'BEBÊ',
          emoji: '👶',
          hint: 'Pessoa recém-nascida',
          order: 39,
          difficulty: 2,
          category: 'Pessoas'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'LÁPIS',
          emoji: '✏️',
          hint: 'Usamos para escrever e desenhar',
          order: 40,
          difficulty: 2,
          category: 'Escola'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'SUCO',
          emoji: '🧃',
          hint: 'Bebida feita de frutas',
          order: 41,
          difficulty: 2,
          category: 'Bebidas'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'MOTO',
          emoji: '🏍️',
          hint: 'Veículo de duas rodas',
          order: 42,
          difficulty: 2,
          category: 'Transportes'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'BOLO',
          emoji: '🎂',
          hint: 'Doce que comemos em aniversários',
          order: 43,
          difficulty: 2,
          category: 'Alimentos'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'REDE',
          emoji: '🥅',
          hint: 'Tecido trançado com buracos',
          order: 44,
          difficulty: 2,
          category: 'Objetos'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'VACA',
          emoji: '🐄',
          hint: 'Animal da fazenda que dá leite',
          order: 45,
          difficulty: 2,
          category: 'Animais'
      ).toMap());


      await _firestore.collection('words').add(WordLevel(
          word: 'BARCO',
          emoji: '⛵',
          hint: 'Veículo que navega na água',
          order: 46,
          difficulty: 3,
          category: 'Transportes'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'COBRA',
          emoji: '🐍',
          hint: 'Animal que rasteja no chão',
          order: 47,
          difficulty: 3,
          category: 'Animais'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'CARRO',
          emoji: '🚗',
          hint: 'Veículo com quatro rodas',
          order: 48,
          difficulty: 3,
          category: 'Transportes'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'TIGRE',
          emoji: '🐯',
          hint: 'Animal selvagem com listras',
          order: 49,
          difficulty: 3,
          category: 'Animais'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'AVIÃO',
          emoji: '✈️',
          hint: 'Transporte que voa no céu',
          order: 50,
          difficulty: 3,
          category: 'Transportes'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'PEIXE',
          emoji: '🐠',
          hint: 'Animal que vive na água',
          order: 51,
          difficulty: 3,
          category: 'Animais'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'BALÃO',
          emoji: '🎈',
          hint: 'Enche com ar e flutua',
          order: 52,
          difficulty: 3,
          category: 'Brinquedos'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'PORCO',
          emoji: '🐷',
          hint: 'Animal da fazenda que faz "oinc"',
          order: 53,
          difficulty: 3,
          category: 'Animais'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'FOGÃO',
          emoji: '🔥',
          hint: 'Usamos para cozinhar comida',
          order: 54,
          difficulty: 3,
          category: 'Cozinha'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'PAPEL',
          emoji: '📄',
          hint: 'Usamos para desenhar e escrever',
          order: 55,
          difficulty: 3,
          category: 'Escola'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'PENTE',
          emoji: '🪥',
          hint: 'Objeto para arrumar o cabelo',
          order: 56,
          difficulty: 3,
          category: 'Higiene'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'VERDE',
          emoji: '🟢',
          hint: 'Cor das folhas das árvores',
          order: 57,
          difficulty: 3,
          category: 'Cores'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'PRAIA',
          emoji: '🏖️',
          hint: 'Lugar com areia e mar',
          order: 58,
          difficulty: 3,
          category: 'Lugares'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'DENTE',
          emoji: '🦷',
          hint: 'Usamos para mastigar',
          order: 59,
          difficulty: 3,
          category: 'Corpo'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'PLANTA',
          emoji: '🌱',
          hint: 'Ser vivo que cresce na terra',
          order: 60,
          difficulty: 3,
          category: 'Natureza'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'BANCO',
          emoji: '🪑',
          hint: 'Móvel onde sentamos',
          order: 61,
          difficulty: 3,
          category: 'Móveis'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'GIRAFA',
          emoji: '🦒',
          hint: 'Animal com pescoço comprido',
          order: 62,
          difficulty: 3,
          category: 'Animais'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'FLAUTA',
          emoji: '🎵',
          hint: 'Instrumento musical de sopro',
          order: 63,
          difficulty: 3,
          category: 'Música'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'PONTE',
          emoji: '🌉',
          hint: 'Construção que passa por cima da água',
          order: 64,
          difficulty: 3,
          category: 'Construções'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'BRAÇO',
          emoji: '💪',
          hint: 'Parte do corpo entre o ombro e a mão',
          order: 65,
          difficulty: 3,
          category: 'Corpo'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'PASTA',
          emoji: '🗂️',
          hint: 'Guarda papéis e documentos',
          order: 66,
          difficulty: 3,
          category: 'Escola'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'LIMÃO',
          emoji: '🍋',
          hint: 'Fruta amarela e azeda',
          order: 67,
          difficulty: 3,
          category: 'Frutas'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'TRIGO',
          emoji: '🌾',
          hint: 'Planta usada para fazer pão',
          order: 68,
          difficulty: 3,
          category: 'Plantas'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'ÔNIBUS',
          emoji: '🚌',
          hint: 'Transporte coletivo de pessoas',
          order: 69,
          difficulty: 3,
          category: 'Transportes'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'DANÇA',
          emoji: '💃',
          hint: 'Movimento do corpo ao som da música',
          order: 70,
          difficulty: 3,
          category: 'Artes'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'GLOBO',
          emoji: '🌎',
          hint: 'Modelo redondo do planeta Terra',
          order: 71,
          difficulty: 3,
          category: 'Geografia'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'BOMBA',
          emoji: '💣',
          hint: 'Objeto que explode',
          order: 72,
          difficulty: 3,
          category: 'Objetos'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'NARIZ',
          emoji: '👃',
          hint: 'Parte do rosto usada para respirar',
          order: 73,
          difficulty: 3,
          category: 'Corpo'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'NUVEM',
          emoji: '☁️',
          hint: 'Formação branca no céu',
          order: 74,
          difficulty: 3,
          category: 'Natureza'
      ).toMap());

      await _firestore.collection('words').add(WordLevel(
          word: 'TINTA',
          emoji: '🎨',
          hint: 'Líquido colorido para pintar',
          order: 75,
          difficulty: 3,
          category: 'Arte'
      ).toMap());
    } catch (e) {
      debugPrint('Erro ao salvar pontuação: $e');
    }
  }

  // Método para salvar uma pontuação
  Future<void> saveScore(String playerName, int score, int level) async {
    try {
      await _firestore.collection('scores').add({
        'playerName': playerName,
        'score': score,
        'level': level,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Erro ao salvar pontuação: $e');
    }
  }
}
