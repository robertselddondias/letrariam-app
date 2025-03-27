// widgets/letter_tile_widget.dart
import 'package:flutter/material.dart';

class LetterTileWidget extends StatelessWidget {
  final String letter;
  final Color color;
  final VoidCallback onTap;

  const LetterTileWidget({
    Key? key,
    required this.letter,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Verifica se a tela é pequena
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 350;
    final tileSize = isSmallScreen ? 40.0 : 50.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: tileSize,
        height: tileSize,
        margin: EdgeInsets.all(isSmallScreen ? 3 : 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 24 : 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
