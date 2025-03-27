// models/letter_tile.dart
import 'package:flutter/material.dart';

class LetterTile {
  final String letter;
  final Color color;
  double x;
  double y;

  LetterTile({
    required this.letter,
    required this.x,
    required this.y,
    required this.color,
  });
}
