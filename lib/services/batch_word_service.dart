// lib/services/batch_word_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:letrarium/model/word_level.dart';
import 'package:letrarium/utils/emoji_mapping.dart';

class BatchWordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EmojiMapping _emojiMapping = EmojiMapping();

  // Método para salvar palavras em lotes, ordenadas por tamanho
  Future<void> saveWordsBatchByLength() async {
    try {
      // Agrupa as palavras por número de letras
      final Map<int, List<WordData>> wordsByLength = groupWordsByLength();

      // Obtém os tamanhos de palavras em ordem crescente
      final List<int> sortedLengths = wordsByLength.keys.toList()..sort();

      int orderCounter = 1; // Contador para a ordem global

      // Percorre os tamanhos em ordem crescente
      for (int length in sortedLengths) {
        final List<WordData> words = wordsByLength[length]!;

        // Para cada tamanho, armazena as palavras em batch
        final WriteBatch batch = _firestore.batch();

        for (WordData wordData in words) {
          // Cria uma referência para um novo documento
          final DocumentReference docRef = _firestore.collection('words').doc();

          // Cria o objeto WordLevel
          final WordLevel wordLevel = WordLevel(
            word: wordData.word,
            emoji: _emojiMapping.getEmoji(wordData.word),
            hint: wordData.hint,
            category: wordData.category,
            difficulty: _getDifficultyByLength(length),
            order: orderCounter++,
          );

          // Adiciona ao batch
          batch.set(docRef, wordLevel.toMap());
        }

        // Commit o batch
        await batch.commit();
        debugPrint('Salvo lote de ${words.length} palavras com $length letras');
      }

      debugPrint('Todas as palavras foram salvas com sucesso!');
    } catch (e) {
      debugPrint('Erro ao salvar palavras em lote: $e');
      rethrow;
    }
  }

  // Determina a dificuldade com base no tamanho da palavra
  int _getDifficultyByLength(int length) {
    if (length <= 3) return 1;      // 2-3 letras: dificuldade 1
    else if (length <= 4) return 2; // 4 letras: dificuldade 2
    else if (length <= 5) return 3; // 5 letras: dificuldade 3
    else if (length <= 6) return 4; // 6 letras: dificuldade 4
    else return 5;                  // 7+ letras: dificuldade 5
  }

  // Agrupa as palavras por número de letras
  Map<int, List<WordData>> groupWordsByLength() {
    Map<int, List<WordData>> result = {};

    // Adiciona cada palavra à lista correspondente ao seu tamanho
    for (WordData word in getAllWords()) {
      int length = word.word.length;
      result.putIfAbsent(length, () => []);
      result[length]!.add(word);
    }

    return result;
  }

  // Lista com todas as palavras e suas informações
  List<WordData> getAllWords() {
    return [
      // Palavras de 2 letras
      WordData(word: 'AR', hint: 'O que respiramos', category: 'Natureza'),
      WordData(word: 'PÉ', hint: 'Parte do corpo usada para andar', category: 'Corpo'),
      WordData(word: 'LÁ', hint: 'Material usado para fazer roupas quentes', category: 'Materiais'),
      WordData(word: 'CÉU', hint: 'Está acima de nós', category: 'Natureza'),
      WordData(word: 'SOL', hint: 'Estrela que ilumina durante o dia', category: 'Natureza'),
      WordData(word: 'LUZ', hint: 'O oposto de escuro', category: 'Conceitos'),

      // Palavras de 3 letras
      WordData(word: 'ASA', hint: 'Permite que os pássaros voem', category: 'Animais'),
      WordData(word: 'OVO', hint: 'De onde nascem pintinhos', category: 'Alimentos'),
      WordData(word: 'PAI', hint: 'Homem que cuida dos filhos', category: 'Família'),
      WordData(word: 'MÃE', hint: 'Mulher que cuida dos filhos', category: 'Família'),
      WordData(word: 'PÃO', hint: 'Alimento feito de farinha', category: 'Alimentos'),
      WordData(word: 'MAR', hint: 'Grande quantidade de água salgada', category: 'Natureza'),
      WordData(word: 'CÃO', hint: 'Animal de estimação que late', category: 'Animais'),
      WordData(word: 'BOI', hint: 'Animal da fazenda com chifres', category: 'Animais'),
      WordData(word: 'RUA', hint: 'Caminho onde passam carros', category: 'Lugares'),

      // Palavras de 4 letras
      WordData(word: 'BOLA', hint: 'Objeto redondo para brincar', category: 'Brinquedos'),
      WordData(word: 'GATO', hint: 'Animal que mia', category: 'Animais'),
      WordData(word: 'CASA', hint: 'Lugar onde moramos', category: 'Lugares'),
      WordData(word: 'AMOR', hint: 'Sentimento bom pelo outro', category: 'Sentimentos'),
      WordData(word: 'RATO', hint: 'Animal pequeno com rabo comprido', category: 'Animais'),
      WordData(word: 'PATO', hint: 'Ave que nada e faz "quack"', category: 'Animais'),
      WordData(word: 'MAÇÃ', hint: 'Fruta vermelha ou verde', category: 'Frutas'),
      WordData(word: 'LOBO', hint: 'Animal selvagem parecido com cachorro', category: 'Animais'),
      WordData(word: 'VASO', hint: 'Objeto para colocar flores', category: 'Objetos'),
      WordData(word: 'SAPO', hint: 'Animal verde que pula', category: 'Animais'),
      WordData(word: 'BOLO', hint: 'Doce que comemos em aniversários', category: 'Alimentos'),
      WordData(word: 'SUCO', hint: 'Bebida feita de frutas', category: 'Bebidas'),
      WordData(word: 'MOTO', hint: 'Veículo de duas rodas', category: 'Transportes'),
      WordData(word: 'VACA', hint: 'Animal da fazenda que dá leite', category: 'Animais'),
      WordData(word: 'REDE', hint: 'Tecido trançado com buracos', category: 'Objetos'),

      // Palavras de 5 letras
      WordData(word: 'BARCO', hint: 'Veículo que navega na água', category: 'Transportes'),
      WordData(word: 'COBRA', hint: 'Animal que rasteja no chão', category: 'Animais'),
      WordData(word: 'CARRO', hint: 'Veículo com quatro rodas', category: 'Transportes'),
      WordData(word: 'TIGRE', hint: 'Animal selvagem com listras', category: 'Animais'),
      WordData(word: 'AVIÃO', hint: 'Transporte que voa no céu', category: 'Transportes'),
      WordData(word: 'PEIXE', hint: 'Animal que vive na água', category: 'Animais'),
      WordData(word: 'BALÃO', hint: 'Enche com ar e flutua', category: 'Brinquedos'),
      WordData(word: 'PORCO', hint: 'Animal da fazenda que faz "oinc"', category: 'Animais'),
      WordData(word: 'FOGÃO', hint: 'Usamos para cozinhar comida', category: 'Cozinha'),
      WordData(word: 'PAPEL', hint: 'Usamos para desenhar e escrever', category: 'Escola'),
      WordData(word: 'PENTE', hint: 'Objeto para arrumar o cabelo', category: 'Higiene'),
      WordData(word: 'VERDE', hint: 'Cor das folhas das árvores', category: 'Cores'),
      WordData(word: 'PRAIA', hint: 'Lugar com areia e mar', category: 'Lugares'),
      WordData(word: 'DENTE', hint: 'Usamos para mastigar', category: 'Corpo'),
      WordData(word: 'CHUVA', hint: 'Água que cai do céu', category: 'Natureza'),
      WordData(word: 'LIVRO', hint: 'Tem páginas com histórias', category: 'Objetos'),
      WordData(word: 'BEBÊ', hint: 'Pessoa recém-nascida', category: 'Pessoas'),
      WordData(word: 'LÁPIS', hint: 'Usamos para escrever e desenhar', category: 'Escola'),

      // Palavras de 6 letras
      WordData(word: 'GIRAFA', hint: 'Animal com pescoço comprido', category: 'Animais'),
      WordData(word: 'BANANA', hint: 'Fruta amarela comprida', category: 'Frutas'),
      WordData(word: 'ESCOLA', hint: 'Lugar onde aprendemos', category: 'Lugares'),
      WordData(word: 'SAPATO', hint: 'Calçamos nos pés', category: 'Roupas'),
      WordData(word: 'CAVALO', hint: 'Animal que relincha e galopa', category: 'Animais'),
      WordData(word: 'ESTRELA', hint: 'Brilha no céu à noite', category: 'Natureza'),
      WordData(word: 'DINOSSAURO', hint: 'Animal grande que existiu há muito tempo', category: 'Animais'),
      WordData(word: 'ELEFANTE', hint: 'Animal grande com tromba', category: 'Animais'),

      // Adicione mais palavras conforme necessário
    ];
  }

  // Método para limpar a coleção antes de adicionar novas palavras
  Future<void> clearCollection() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('words').get();

      final WriteBatch batch = _firestore.batch();

      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('Coleção de palavras limpa com sucesso.');
    } catch (e) {
      debugPrint('Erro ao limpar coleção: $e');
    }
  }

  // Método principal para reconstruir o banco de dados de palavras
  Future<void> rebuildWordDatabase() async {
    try {
      // Primeiro limpa a coleção existente
      await clearCollection();

      // Depois adiciona as novas palavras ordenadas por tamanho
      await saveWordsBatchByLength();

      debugPrint('Banco de dados de palavras reconstruído com sucesso!');
    } catch (e) {
      debugPrint('Erro ao reconstruir banco de dados: $e');
    }
  }
}

// Classe auxiliar para armazenar dados de palavras
class WordData {
  final String word;
  final String hint;
  final String category;

  WordData({
    required this.word,
    required this.hint,
    required this.category,
  });
}
