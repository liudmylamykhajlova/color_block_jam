/// Game-specific constants
/// 
/// Contains timing, animation, and gameplay configuration values.
/// UI constants like padding/margins should stay inline or in theme.
class AppConstants {
  AppConstants._();
  
  // === TIMER ===
  
  /// Default level duration in seconds (if not specified in level data)
  static const int defaultLevelDuration = 120;
  
  /// Timer turns orange when this many seconds remain
  static const int timerWarningThreshold = 30;
  
  /// Timer turns red when this many seconds remain
  static const int timerCriticalThreshold = 10;
  
  // === LIVES ===
  
  /// Maximum number of lives player can have
  static const int maxLives = 5;
  
  /// Minutes to wait for one life to refill
  static const int lifeRefillMinutes = 30;
  
  // === ANIMATIONS ===
  
  /// Duration for block exit animation (milliseconds)
  static const int exitAnimationDuration = 300;
  
  /// Duration for dialog appear animation (milliseconds)
  static const int dialogAnimationDuration = 400;
  
  /// Duration for confetti animation (milliseconds)
  static const int confettiDuration = 2000;
  
  // === GAME BOARD ===
  
  /// Border offset around the game board (pixels)
  static const double boardBorderOffset = 40.0;
  
  /// Minimum cell size (pixels)
  static const double minCellSize = 30.0;
  
  /// Maximum cell size (pixels)
  static const double maxCellSize = 60.0;
  
  // === BLOCK RENDERING ===
  
  /// Block corner radius relative to cell size
  static const double blockCornerRadiusFactor = 0.15;
  
  /// Stud (LEGO dot) radius relative to cell size
  static const double studRadiusFactor = 0.15;
  
  /// Block border width (pixels)
  static const double blockBorderWidth = 2.0;
  
  /// Multi-layer block outer border width (pixels)
  static const double multiLayerBorderWidth = 4.0;
  
  // === MOVEMENT ===
  
  /// Minimum drag distance to register a move (pixels)
  static const double minDragDistance = 5.0;
  
  /// Threshold to determine drag direction (ratio)
  static const double dragDirectionThreshold = 0.5;
}


