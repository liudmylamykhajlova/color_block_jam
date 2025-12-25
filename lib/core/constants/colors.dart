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
  
  // === Freeze Effect ===
  static const Color freezeBlue = Color(0xFF00BFFF);     // Deep sky blue
  static const Color freezeLight = Color(0xFFB0E0E6);    // Powder blue
  static const Color freezeGlow = Color(0x4000BFFF);     // Freeze with opacity
  
  // === Rocket Effect ===
  static const Color rocketOrange = Color(0xFFFF6B35);   // Rocket body
  static const Color rocketYellow = Color(0xFFFFD700);   // Rocket flame
  static const Color targetRed = Color(0xFFFF4444);      // Target crosshair
  static const Color targetWhite = Color(0xFFFFFFFF);    // Target circle
  static const Color explosionOrange = Color(0xFFFF8C00); // Explosion
  static const Color explosionYellow = Color(0xFFFFEB3B); // Explosion highlight
  
  // === Hammer Effect ===
  static const Color hammerGreen = Color(0xFF4CAF50);    // Hammer head (green)
  static const Color hammerOrange = Color(0xFFFF9800);   // Hammer handle (orange)
  static const Color hammerPurple = Color(0xFF9C27B0);   // Hammer icon background
  
  // === Vacuum Effect ===
  static const Color vacuumYellow = Color(0xFFFFD700);   // Vacuum body (gold/yellow)
  static const Color vacuumBlue = Color(0xFF4FC3F7);     // Vacuum accent (light blue)
  static const Color vacuumPurple = Color(0xFF7E57C2);   // Vacuum icon background
  
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
  
  // === Level Map Background ===
  static const Color mapBgTop = Color(0xFF5B8DEF);            // Bright blue top
  static const Color mapBgMid = Color(0xFF4A7DE8);            // Mid blue
  static const Color mapBgBottom = Color(0xFF3D6DD8);         // Saturated blue bottom
  
  // === Level Map UI ===
  static const Color mapDarkBrown = Color(0xFF5A3D10);        // Connection line outline, node outline
  static const Color mapGoldenBorder = Color(0xFFE8A030);     // Node inner border, connection line
  static const Color mapGoldenDark = Color(0xFFCC8020);       // Connection line gradient end
  static const Color mapNavBg = Color(0xFF4A7AC7);            // Bottom nav background
  static const Color mapNavSelected = Color(0xFF6BA8E8);      // Selected nav item
  
  // === Level Node States ===
  static const Color nodeNormal = Color(0xFF5ED85E);          // Bright vivid green
  static const Color nodeHard = Color(0xFF9B78BE);            // Brighter purple
  static const Color nodeVeryHard = Color(0xFFE85A6A);        // Brighter red/pink
  static const Color nodeLocked = Color(0xFF8A9B8A);          // Gray-green
  
  // === Level Node Studs ===
  static const Color studNormal = Color(0xFF3DB83D);          // Green stud
  static const Color studHard = Color(0xFF8A68AE);            // Purple stud
  static const Color studVeryHard = Color(0xFFD85060);        // Red stud
  static const Color studLocked = Color(0xFF7A8B7A);          // Gray stud
  
  // === Current Level Button ===
  static const Color currentLevelLight = Color(0xFF7DD85A);   // Button gradient top
  static const Color currentLevelDark = Color(0xFF5BC83B);    // Button gradient bottom
  static const Color currentLevelBorder = Color(0xFF9AEF70);  // Button border
  static const Color currentLevelShadow = Color(0xFF4AA82A);  // Button shadow
  
  // === Golden Badge/Icon ===
  static const Color goldenLight = Color(0xFFFFD54F);         // Golden gradient top
  static const Color goldenDark = Color(0xFFFFC107);          // Golden gradient bottom
  static const Color goldenBorder = Color(0xFFE65100);        // Orange border
  static const Color goldenBorderAlt = Color(0xFFE6A000);     // Alternative orange border
  static const Color goldenBorderLight = Color(0xFFFF8F00);   // Lighter orange border
  
  // === Map HUD ===
  static const Color avatarFrame = Color(0xFF4DD0E1);         // Cyan/teal frame
  static const Color avatarBgLight = Color(0xFFFFF3E0);       // Avatar placeholder light
  static const Color avatarBgDark = Color(0xFF8D6E63);        // Avatar placeholder dark
  static const Color badgeBorder = Color(0xFFE0E0E0);         // Badge border
  static const Color textDark = Color(0xFF333333);            // Dark text on light bg
  static const Color plusGreenLight = Color(0xFF4CAF50);      // Plus button gradient top
  static const Color plusGreenDark = Color(0xFF388E3C);       // Plus button gradient bottom
  static const Color heartRed = Color(0xFFE53935);            // Heart icon color
  
  // === Settings Icon ===
  static const Color settingsLight = Color(0xFFFFCA28);       // Yellow-orange top
  static const Color settingsDark = Color(0xFFFF9800);        // Orange bottom
  static const Color settingsHighlight = Color(0xFFFFE082);   // Highlight
  
  // === LEGO Block Icons ===
  static const Color legoYellow = Color(0xFFFFEB3B);          // Yellow block
  static const Color legoBlue = Color(0xFF2196F3);            // Blue block
  static const Color legoGreen = Color(0xFF4CAF50);           // Green block
  static const Color legoPink = Color(0xFFE91E63);            // Pink block
  
  // === Game Screen Colors ===
  static const Color gameBackgroundLight = Color(0xFF667eea);  // Top gradient
  static const Color gameBackgroundDark = Color(0xFF764ba2);   // Bottom gradient
  
  // === Block Colors (same as GameColors but for direct access) ===
  static const List<Color> palette = GameColors.palette;
}

