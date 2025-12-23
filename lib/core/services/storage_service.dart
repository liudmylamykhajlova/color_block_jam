import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _completedLevelsKey = 'completed_levels';
  static const String _currentLevelKey = 'current_level';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _hapticEnabledKey = 'haptic_enabled';
  static const String _livesKey = 'lives';
  static const String _lastLifeLostTimeKey = 'last_life_lost_time';
  
  static const int maxLives = 5;
  static const int lifeRefillMinutes = 30;
  
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
  
  // === LIVES SYSTEM ===
  
  static int getLives() {
    final savedLives = _prefs?.getInt(_livesKey) ?? maxLives;
    if (savedLives >= maxLives) return maxLives;
    
    // Check if lives should be refilled based on time
    final lastLostTime = _prefs?.getInt(_lastLifeLostTimeKey) ?? 0;
    if (lastLostTime == 0) return savedLives;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - lastLostTime;
    final minutesPassed = elapsed ~/ (1000 * 60);
    final livesToAdd = minutesPassed ~/ lifeRefillMinutes;
    
    final newLives = (savedLives + livesToAdd).clamp(0, maxLives);
    return newLives;
  }
  
  static Future<void> loseLife() async {
    final currentLives = getLives();
    final newLives = (currentLives - 1).clamp(0, maxLives);
    await _prefs?.setInt(_livesKey, newLives);
    await _prefs?.setInt(_lastLifeLostTimeKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  static Future<void> addLife([int count = 1]) async {
    final currentLives = getLives();
    final newLives = (currentLives + count).clamp(0, maxLives);
    await _prefs?.setInt(_livesKey, newLives);
  }
  
  static Future<void> refillLives() async {
    await _prefs?.setInt(_livesKey, maxLives);
    await _prefs?.remove(_lastLifeLostTimeKey);
  }
  
  static bool hasLives() {
    return getLives() > 0;
  }
  
  static String getTimeUntilNextLife() {
    final currentLives = getLives();
    if (currentLives >= maxLives) return 'Full';
    
    final lastLostTime = _prefs?.getInt(_lastLifeLostTimeKey) ?? 0;
    if (lastLostTime == 0) return 'Full';
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - lastLostTime;
    final minutesPassed = elapsed ~/ (1000 * 60);
    final minutesRemaining = lifeRefillMinutes - (minutesPassed % lifeRefillMinutes);
    
    return '${minutesRemaining}m';
  }
  
  // === RESET PROGRESS ===
  
  static Future<void> resetProgress() async {
    await _prefs?.remove(_completedLevelsKey);
    await _prefs?.remove(_currentLevelKey);
    await _prefs?.remove(_livesKey);
    await _prefs?.remove(_lastLifeLostTimeKey);
  }
}

