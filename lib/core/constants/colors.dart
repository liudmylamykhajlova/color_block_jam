import 'package:flutter/material.dart';

/// Кольорова палітра гри (відповідає blockType з parsed даних)
class GameColors {
  GameColors._();

  static const List<Color> palette = [
    Color(0xFF03a5ef), // 0 - Blue
    Color(0xFF143cf6), // 1 - Dark Blue
    Color(0xFF48aa1a), // 2 - Green
    Color(0xFFb844c8), // 3 - Pink
    Color(0xFF7343db), // 4 - Purple
    Color(0xFFfbb32d), // 5 - Yellow
    Color(0xFF09521d), // 6 - Dark Green
    Color(0xFFf2772b), // 7 - Orange
    Color(0xFFb8202c), // 8 - Red
    Color(0xFF0facae), // 9 - Cyan
  ];

  static const List<String> names = [
    'Blue',
    'Dark Blue',
    'Green',
    'Pink',
    'Purple',
    'Yellow',
    'Dark Green',
    'Orange',
    'Red',
    'Cyan',
  ];

  static Color getColor(int blockType) {
    if (blockType >= 0 && blockType < palette.length) {
      return palette[blockType];
    }
    return Colors.grey;
  }

  static String getName(int blockType) {
    if (blockType >= 0 && blockType < names.length) {
      return names[blockType];
    }
    return 'Unknown';
  }
}

