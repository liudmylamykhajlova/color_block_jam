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

/// UI кольори для всього застосунку
class AppColors {
  AppColors._();
  
  // === Primary Colors ===
  static const Color primary = Color(0xFF764ba2);        // Purple gradient
  static const Color primaryLight = Color(0xFF667eea);   // Light purple/blue
  static const Color accent = Color(0xFF4DA6FF);         // Sky blue (dialogs)
  
  // === Button Colors ===
  static const Color buttonGreen = Color(0xFF7ED321);    // Play, Retry, Next
  static const Color buttonRed = Color(0xFFE74C3C);      // Close, Cancel
  static const Color buttonGreenAlt = Color(0xFF4CAF50); // Alternative green
  
  // === Background Colors ===
  static const Color backgroundDark = Color(0xFF1a1a2e); // Main dark bg
  static const Color surfaceDark = Color(0xFF2D2D2D);    // Cards, badges
  static const Color boardBg = Color(0xFF3d3d3d);        // Game board interior
  static const Color boardFrame = Color(0xFF2D2D2D);     // Board frame (dark gray)
  static const Color boardGrid = Color(0xFF555555);      // Grid lines
  
  // === Timer Colors ===
  static const Color timerNormal = Color(0xFFFFD54F);    // Gold/yellow
  static const Color timerLow = Color(0xFFFFB74D);       // Orange (<30s)
  static const Color timerCritical = Color(0xFFFF5252);  // Red (<10s)
  
  // === Difficulty Badge Colors ===
  static const Color badgeNormal = Color(0xFF5C6BC0);    // Blue
  static const Color badgeHard = Color(0xFF9C27B0);      // Purple
  static const Color badgeVeryHard = Color(0xFF7B1FA2);  // Dark purple
  
  // === Status Colors ===
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Colors.red;
  static const Color warning = Color(0xFFFFB74D);
  
  // === Text Colors ===
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textMuted = Color(0x80FFFFFF);      // 50% white
  
  // === Special ===
  static const Color gold = Color(0xFFFFD700);           // Stars, coins
  static const Color goldGlow = Color(0x80FFD700);       // Gold with opacity
  static const Color ice = Color(0xFF87CEFA);            // Ice overlay
  
  // === Dialog Colors ===
  static const Color dialogGradientLight = Color(0xFF5BB8E8);  // Dialog top
  static const Color dialogGradientDark = Color(0xFF3D8BC4);   // Dialog bottom
  
  // === Coin Colors ===
  static const Color coinBorder = Color(0xFFE65100);     // Orange border
  static const Color coinSymbol = Color(0xFFE65100);     // $ symbol color
  
  // === Level Node Colors ===
  static const Color levelCompleted = Color(0xFF4CAF50);      // Green completed
  static const Color levelUnlocked = Color(0xFF7ED321);       // Bright green unlocked
  static const Color levelHard = Color(0xFFE74C3C);           // Red hard
  static const Color levelBoss = Color(0xFF9C27B0);           // Purple boss
  static const Color levelLocked = Color(0xFF757575);         // Gray locked
  
  // === Game Screen Colors ===
  static const Color gameBackgroundLight = Color(0xFF667eea);  // Top gradient
  static const Color gameBackgroundDark = Color(0xFF764ba2);   // Bottom gradient
  
  // === Block Colors (same as GameColors but for direct access) ===
  static const List<Color> palette = GameColors.palette;
}

