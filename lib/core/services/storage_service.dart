import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _completedLevelsKey = 'completed_levels';
  static const String _currentLevelKey = 'current_level';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _hapticEnabledKey = 'haptic_enabled';
  
  static SharedPreferences? _prefs;
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  static Set<int> getCompletedLevels() {
    final list = _prefs?.getStringList(_completedLevelsKey) ?? [];
    return list.map((s) => int.parse(s)).toSet();
  }
  
  static Future<void> markLevelCompleted(int levelId) async {
    final completed = getCompletedLevels();
    completed.add(levelId);
    await _prefs?.setStringList(
      _completedLevelsKey, 
      completed.map((i) => i.toString()).toList(),
    );
  }
  
  static int getCurrentLevel() {
    return _prefs?.getInt(_currentLevelKey) ?? 1;
  }
  
  static Future<void> setCurrentLevel(int levelId) async {
    await _prefs?.setInt(_currentLevelKey, levelId);
  }
  
  static bool isLevelUnlocked(int levelId) {
    if (levelId == 1) return true;
    return getCompletedLevels().contains(levelId - 1);
  }
  
  static int getMaxUnlockedLevel() {
    final completed = getCompletedLevels();
    if (completed.isEmpty) return 1;
    return completed.reduce((a, b) => a > b ? a : b) + 1;
  }
  
  // === SOUND SETTINGS ===
  
  static bool getSoundEnabled() {
    return _prefs?.getBool(_soundEnabledKey) ?? true;
  }
  
  static Future<void> setSoundEnabled(bool value) async {
    await _prefs?.setBool(_soundEnabledKey, value);
  }
  
  // === HAPTIC SETTINGS ===
  
  static bool getHapticEnabled() {
    return _prefs?.getBool(_hapticEnabledKey) ?? true;
  }
  
  static Future<void> setHapticEnabled(bool value) async {
    await _prefs?.setBool(_hapticEnabledKey, value);
  }
  
  // === RESET PROGRESS ===
  
  static Future<void> resetProgress() async {
    await _prefs?.remove(_completedLevelsKey);
    await _prefs?.remove(_currentLevelKey);
  }
}

