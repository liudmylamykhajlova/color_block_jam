import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Service for persistent storage using SharedPreferences.
/// 
/// Must call [init] before using any other methods.
/// Throws [StateError] if accessed before initialization.
class StorageService {
  static const String _completedLevelsKey = 'completed_levels';
  static const String _currentLevelKey = 'current_level';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _musicEnabledKey = 'music_enabled';
  static const String _hapticEnabledKey = 'haptic_enabled';
  static const String _livesKey = 'lives';
  static const String _lastLifeLostTimeKey = 'last_life_lost_time';
  static const String _coinsKey = 'coins';
  
  /// Use constants from AppConstants for consistency
  static int get maxLives => AppConstants.maxLives;
  static int get lifeRefillMinutes => AppConstants.lifeRefillMinutes;
  
  static SharedPreferences? _prefs;
  
  /// Check if service is initialized
  static bool get isInitialized => _prefs != null;
  
  /// Ensure service is initialized, throw if not
  static void _ensureInitialized() {
    if (_prefs == null) {
      throw StateError('StorageService not initialized. Call StorageService.init() in main() before runApp().');
    }
  }
  
  /// Initialize the storage service. Must be called before any other method.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // === LEVEL PROGRESS ===
  
  static Set<int> getCompletedLevels() {
    _ensureInitialized();
    final list = _prefs!.getStringList(_completedLevelsKey) ?? [];
    return list.map((s) => int.parse(s)).toSet();
  }
  
  static Future<void> markLevelCompleted(int levelId) async {
    _ensureInitialized();
    final completed = getCompletedLevels();
    completed.add(levelId);
    await _prefs!.setStringList(
      _completedLevelsKey, 
      completed.map((i) => i.toString()).toList(),
    );
  }
  
  static int getCurrentLevel() {
    _ensureInitialized();
    return _prefs!.getInt(_currentLevelKey) ?? 1;
  }
  
  static Future<void> setCurrentLevel(int levelId) async {
    _ensureInitialized();
    await _prefs!.setInt(_currentLevelKey, levelId);
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
    _ensureInitialized();
    return _prefs!.getBool(_soundEnabledKey) ?? true;
  }
  
  static Future<void> setSoundEnabled(bool value) async {
    _ensureInitialized();
    await _prefs!.setBool(_soundEnabledKey, value);
  }
  
  // === MUSIC SETTINGS ===
  
  static bool getMusicEnabled() {
    _ensureInitialized();
    return _prefs!.getBool(_musicEnabledKey) ?? true; // Default ON
  }
  
  static Future<void> setMusicEnabled(bool value) async {
    _ensureInitialized();
    await _prefs!.setBool(_musicEnabledKey, value);
  }
  
  // === HAPTIC SETTINGS ===
  
  static bool getHapticEnabled() {
    _ensureInitialized();
    return _prefs!.getBool(_hapticEnabledKey) ?? false; // Default OFF per original game
  }
  
  static Future<void> setHapticEnabled(bool value) async {
    _ensureInitialized();
    await _prefs!.setBool(_hapticEnabledKey, value);
  }
  
  // === LIVES SYSTEM ===
  
  static int getLives() {
    _ensureInitialized();
    
    final savedLives = _prefs!.getInt(_livesKey) ?? maxLives;
    if (savedLives >= maxLives) return maxLives;
    
    // Check if lives should be refilled based on time
    final lastLostTime = _prefs!.getInt(_lastLifeLostTimeKey) ?? 0;
    if (lastLostTime == 0) return savedLives;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - lastLostTime;
    final minutesPassed = elapsed ~/ (1000 * 60);
    final livesToAdd = minutesPassed ~/ lifeRefillMinutes;
    
    if (livesToAdd > 0) {
      final newLives = (savedLives + livesToAdd).clamp(0, maxLives);
      // Persist the calculated lives so we don't lose progress
      _persistLivesUpdate(newLives, lastLostTime, minutesPassed);
      return newLives;
    }
    
    return savedLives;
  }
  
  /// Persist the calculated lives update (called internally from getLives)
  static void _persistLivesUpdate(int newLives, int originalLostTime, int minutesPassed) {
    // No need to check - called only from getLives which already checked
    _prefs!.setInt(_livesKey, newLives);
    
    if (newLives >= maxLives) {
      // Lives fully restored, clear the timer
      _prefs!.remove(_lastLifeLostTimeKey);
    } else {
      // Update the lost time to account for partial refills
      // Keep the remaining minutes for the next life
      final newLostTime = originalLostTime + (minutesPassed * 60 * 1000);
      _prefs!.setInt(_lastLifeLostTimeKey, newLostTime);
    }
  }
  
  static Future<void> loseLife() async {
    _ensureInitialized();
    final currentLives = getLives();
    final newLives = (currentLives - 1).clamp(0, maxLives);
    await _prefs!.setInt(_livesKey, newLives);
    await _prefs!.setInt(_lastLifeLostTimeKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  static Future<void> addLife([int count = 1]) async {
    _ensureInitialized();
    final currentLives = getLives();
    final newLives = (currentLives + count).clamp(0, maxLives);
    await _prefs!.setInt(_livesKey, newLives);
  }
  
  static Future<void> refillLives() async {
    _ensureInitialized();
    await _prefs!.setInt(_livesKey, maxLives);
    await _prefs!.remove(_lastLifeLostTimeKey);
  }
  
  static bool hasLives() {
    return getLives() > 0;
  }
  
  static String getTimeUntilNextLife() {
    _ensureInitialized();
    final currentLives = getLives();
    if (currentLives >= maxLives) return 'Full';
    
    final lastLostTime = _prefs!.getInt(_lastLifeLostTimeKey) ?? 0;
    if (lastLostTime == 0) return 'Full';
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - lastLostTime;
    final minutesPassed = elapsed ~/ (1000 * 60);
    final minutesRemaining = lifeRefillMinutes - (minutesPassed % lifeRefillMinutes);
    
    return '${minutesRemaining}m';
  }
  
  // === COINS SYSTEM ===
  
  static const int _defaultCoins = 100; // Starting coins for new players
  
  static int getCoins() {
    _ensureInitialized();
    return _prefs!.getInt(_coinsKey) ?? _defaultCoins;
  }
  
  static Future<void> setCoins(int coins) async {
    _ensureInitialized();
    await _prefs!.setInt(_coinsKey, coins.clamp(0, 9999999));
  }
  
  static Future<void> addCoins(int amount) async {
    _ensureInitialized();
    final current = getCoins();
    await setCoins(current + amount);
  }
  
  static Future<bool> spendCoins(int amount) async {
    _ensureInitialized();
    final current = getCoins();
    if (current < amount) return false;
    await setCoins(current - amount);
    return true;
  }
  
  static bool hasEnoughCoins(int amount) {
    return getCoins() >= amount;
  }
  
  // === RESET PROGRESS ===
  
  static Future<void> resetProgress() async {
    _ensureInitialized();
    await _prefs!.remove(_completedLevelsKey);
    await _prefs!.remove(_currentLevelKey);
    await _prefs!.remove(_livesKey);
    await _prefs!.remove(_lastLifeLostTimeKey);
    await _prefs!.remove(_coinsKey);
  }
}

