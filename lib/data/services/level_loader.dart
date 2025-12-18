import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/models/level.dart';

/// Сервіс для завантаження рівнів з JSON
class LevelLoader {
  LevelLoader._();
  static final instance = LevelLoader._();

  List<GameLevel>? _cachedLevels;

  /// Завантажити всі рівні
  Future<List<GameLevel>> loadLevels() async {
    if (_cachedLevels != null) {
      return _cachedLevels!;
    }

    final jsonString = await rootBundle.loadString('assets/levels/levels_27.json');
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final levelsJson = jsonData['levels'] as List<dynamic>;

    _cachedLevels = levelsJson
        .map((l) => GameLevel.fromJson(l as Map<String, dynamic>))
        .toList();

    return _cachedLevels!;
  }

  /// Завантажити конкретний рівень за індексом (0-based)
  Future<GameLevel> loadLevel(int index) async {
    final levels = await loadLevels();
    if (index < 0 || index >= levels.length) {
      throw RangeError('Level index $index is out of range (0-${levels.length - 1})');
    }
    return levels[index];
  }

  /// Отримати кількість рівнів
  Future<int> getLevelCount() async {
    final levels = await loadLevels();
    return levels.length;
  }

  /// Очистити кеш
  void clearCache() {
    _cachedLevels = null;
  }
}

