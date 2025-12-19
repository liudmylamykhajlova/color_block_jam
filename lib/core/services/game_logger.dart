import 'package:flutter/foundation.dart';

/// Simple game logger for debugging gameplay events
class GameLogger {
  static const String _tag = '🎮 GAME';
  static bool enabled = kDebugMode;
  
  // Log levels
  static void info(String message, [String? context]) {
    if (!enabled) return;
    final ctx = context != null ? '[$context] ' : '';
    debugPrint('$_tag ℹ️ $ctx$message');
  }
  
  static void action(String message, [String? context]) {
    if (!enabled) return;
    final ctx = context != null ? '[$context] ' : '';
    debugPrint('$_tag 🎯 $ctx$message');
  }
  
  static void success(String message, [String? context]) {
    if (!enabled) return;
    final ctx = context != null ? '[$context] ' : '';
    debugPrint('$_tag ✅ $ctx$message');
  }
  
  static void warning(String message, [String? context]) {
    if (!enabled) return;
    final ctx = context != null ? '[$context] ' : '';
    debugPrint('$_tag ⚠️ $ctx$message');
  }
  
  static void error(String message, [String? context, Object? error]) {
    // Always log errors
    final ctx = context != null ? '[$context] ' : '';
    debugPrint('$_tag ❌ $ctx$message');
    if (error != null) {
      debugPrint('$_tag    Error: $error');
    }
  }
  
  // Game-specific logs
  static void levelLoaded(int levelId, String name, int blocks, int doors, String hardness, int duration) {
    info('Level $levelId loaded: "$name"', 'LEVEL');
    info('  Blocks: $blocks, Doors: $doors', 'LEVEL');
    info('  Hardness: $hardness, Duration: ${duration}s', 'LEVEL');
  }
  
  static void blockSelected(int blockType, int row, int col) {
    action('Block selected: type=$blockType at ($row, $col)', 'INPUT');
  }
  
  static void blockMoved(int blockType, int fromRow, int fromCol, int toRow, int toCol) {
    action('Block moved: type=$blockType ($fromRow,$fromCol) → ($toRow,$toCol)', 'MOVE');
  }
  
  static void blockExited(int blockType, String edge) {
    success('Block exited: type=$blockType via $edge door', 'EXIT');
  }
  
  static void levelCompleted(int levelId, int remainingTime) {
    success('Level $levelId COMPLETED! Time remaining: ${remainingTime}s', 'WIN');
  }
  
  static void timerTick(int remaining) {
    // Only log every 10 seconds to avoid spam
    if (remaining % 10 == 0 || remaining <= 5) {
      info('Timer: ${remaining}s remaining', 'TIMER');
    }
  }
  
  static void timerExpired(int levelId) {
    warning('Timer expired on level $levelId', 'TIMER');
  }
  
  static void levelReset(int levelId) {
    info('Level $levelId reset', 'LEVEL');
  }
}

