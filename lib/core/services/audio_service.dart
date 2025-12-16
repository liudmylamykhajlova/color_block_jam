import 'package:flutter/services.dart';
import 'storage_service.dart';

/// Service for handling sound effects and haptic feedback
class AudioService {
  static bool _soundEnabled = true;
  static bool _hapticEnabled = true;
  
  static void init() {
    _soundEnabled = StorageService.getSoundEnabled();
    _hapticEnabled = StorageService.getHapticEnabled();
  }
  
  static bool get soundEnabled => _soundEnabled;
  static bool get hapticEnabled => _hapticEnabled;
  
  static Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await StorageService.setSoundEnabled(value);
  }
  
  static Future<void> setHapticEnabled(bool value) async {
    _hapticEnabled = value;
    await StorageService.setHapticEnabled(value);
  }
  
  // === HAPTIC FEEDBACK ===
  
  /// Light tap - for button presses, selections
  static void lightTap() {
    if (!_hapticEnabled) return;
    HapticFeedback.lightImpact();
  }
  
  /// Medium tap - for block pickup
  static void mediumTap() {
    if (!_hapticEnabled) return;
    HapticFeedback.mediumImpact();
  }
  
  /// Heavy tap - for block drop, collision
  static void heavyTap() {
    if (!_hapticEnabled) return;
    HapticFeedback.heavyImpact();
  }
  
  /// Selection changed
  static void selectionClick() {
    if (!_hapticEnabled) return;
    HapticFeedback.selectionClick();
  }
  
  /// Success vibration - for level complete
  static void success() {
    if (!_hapticEnabled) return;
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.mediumImpact();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.lightImpact();
    });
  }
  
  /// Error vibration - for invalid move
  static void error() {
    if (!_hapticEnabled) return;
    HapticFeedback.vibrate();
  }
  
  // === SOUND EFFECTS ===
  // For MVP we use system sounds via haptics
  // Full audio implementation would use audioplayers package
  
  /// Play block pickup sound
  static void playPickup() {
    if (!_soundEnabled) return;
    // SystemSound.play(SystemSoundType.click); // Optional system sound
    mediumTap(); // Haptic feedback as audio substitute
  }
  
  /// Play block drop sound
  static void playDrop() {
    if (!_soundEnabled) return;
    heavyTap();
  }
  
  /// Play block exit sound
  static void playExit() {
    if (!_soundEnabled) return;
    lightTap();
  }
  
  /// Play win sound
  static void playWin() {
    if (!_soundEnabled) return;
    success();
  }
  
  /// Play button tap sound
  static void playTap() {
    if (!_soundEnabled) return;
    lightTap();
  }
}

