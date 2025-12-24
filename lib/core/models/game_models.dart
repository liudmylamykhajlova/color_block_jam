import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// ============ DATA MODELS ============

// Difficulty enum
enum LevelHardness { normal, hard, veryHard }

class GameLevel {
  final int id;
  final String name;
  final int gridWidth;
  final int gridHeight;
  final List<GameBlock> blocks;
  final List<GameDoor> doors;
  final List<Point> hiddenCells;
  final int duration; // in seconds
  final LevelHardness hardness;

  GameLevel({
    required this.id,
    required this.name,
    required this.gridWidth,
    required this.gridHeight,
    required this.blocks,
    required this.doors,
    required this.hiddenCells,
    this.duration = 120,
    this.hardness = LevelHardness.normal,
  });

  factory GameLevel.fromJson(Map<String, dynamic> json) {
    LevelHardness hardness = LevelHardness.normal;
    final hardnessValue = json['hardness'] ?? 0;
    if (hardnessValue == 1) {
      hardness = LevelHardness.hard;
    } else if (hardnessValue == 2) hardness = LevelHardness.veryHard;
    
    return GameLevel(
      id: json['id'],
      name: json['name'],
      gridWidth: json['gridWidth'],
      gridHeight: json['gridHeight'],
      blocks: (json['blocks'] as List)
          .map((b) => GameBlock.fromJson(b))
          .toList(),
      doors: (json['doors'] as List)
          .map((d) => GameDoor.fromJson(d))
          .toList(),
      hiddenCells: (json['hiddenCells'] as List?)
              ?.map((h) => Point(h['row'], h['col']))
              .toList() ??
          [],
      duration: json['duration'] ?? 120,
      hardness: hardness,
    );
  }
  
  /// Check if this is a hard level (Hard or VeryHard)
  bool get isHard => hardness != LevelHardness.normal;
  
  /// Get display string for hardness
  String get hardnessText {
    switch (hardness) {
      case LevelHardness.hard: return 'HARD';
      case LevelHardness.veryHard: return 'VERY HARD';
      default: return '';
    }
  }
}

/// Напрямок руху блока
enum MoveDirection {
  horizontal, // 0 - тільки горизонтально
  vertical,   // 1 - тільки вертикально
  both,       // 2 - в обидва напрямки
}

class GameBlock {
  final int blockType;
  final int blockGroupType;
  int gridRow;
  int gridCol;
  final int rotationZ;
  final bool needsRowOffset;
  final MoveDirection moveDirection;
  final int innerBlockType; // -1 = no inner layer, 0-9 = inner color
  
  /// Чи зруйновано зовнішній шар (для багатошарових блоків)
  bool outerLayerDestroyed = false;
  
  /// Кількість блоків до розморозки (0 = не заморожений)
  int iceCount;
  
  /// Список видалених юнітів (cells) з цього блоку (для Rocket бустера)
  /// Зберігаємо відносні позиції (offset від gridRow/gridCol)
  final List<Point> removedUnits = [];
  
  // Grid size for edge detection
  int gridWidth = 6;
  int gridHeight = 6;

  GameBlock({
    required this.blockType,
    required this.blockGroupType,
    required this.gridRow,
    required this.gridCol,
    required this.rotationZ,
    this.needsRowOffset = false,
    this.moveDirection = MoveDirection.both,
    this.innerBlockType = -1,
    this.iceCount = 0,
  });
  
  /// Чи заморожений блок
  bool get isFrozen => iceCount > 0;
  
  /// Чи є внутрішній шар (і він ще не оголений)
  bool get hasInnerLayer => innerBlockType >= 0 && innerBlockType <= 9 && !outerLayerDestroyed;
  
  /// Поточний активний колір блоку (для виходу через двері)
  int get activeBlockType => outerLayerDestroyed ? innerBlockType : blockType;

  factory GameBlock.fromJson(Map<String, dynamic> json) {
    // Parse moveDirection: 0=horiz, 1=vert, 2=both
    final moveDir = json['moveDirection'] ?? 2;
    MoveDirection direction;
    switch (moveDir) {
      case 0:
        direction = MoveDirection.horizontal;
        break;
      case 1:
        direction = MoveDirection.vertical;
        break;
      default:
        direction = MoveDirection.both;
    }
    
    return GameBlock(
      blockType: json['blockType'],
      blockGroupType: json['blockGroupType'],
      gridRow: json['gridRow'],
      gridCol: json['gridCol'],
      rotationZ: json['rotationZ'],
      needsRowOffset: json['needsRowOffset'] ?? false,
      moveDirection: direction,
      innerBlockType: json['innerBlockType'] ?? -1,
      iceCount: json['iceCount'] ?? 0,
    );
  }

  GameBlock copy() {
    final copy = GameBlock(
      blockType: blockType,
      blockGroupType: blockGroupType,
      gridRow: gridRow,
      gridCol: gridCol,
      rotationZ: rotationZ,
      needsRowOffset: needsRowOffset,
      moveDirection: moveDirection,
      innerBlockType: innerBlockType,
      iceCount: iceCount,
    )..gridWidth = gridWidth..gridHeight = gridHeight..outerLayerDestroyed = outerLayerDestroyed;
    copy.removedUnits.addAll(removedUnits);
    return copy;
  }
  
  /// Видалити один юніт (клітинку) з блоку
  /// Повертає true якщо успішно видалено, false якщо це остання клітинка
  bool removeUnit(Point absoluteCell) {
    // Конвертуємо абсолютну позицію у відносну для зберігання
    removedUnits.add(absoluteCell);
    return cells.isNotEmpty;
  }
  
  /// Перевірити чи блок ще має живі клітинки
  bool get hasRemainingCells => cells.isNotEmpty;
  
  /// Отримати всі клітинки без фільтрації (базова форма)
  List<Point> get _baseCells {
    final Map<int, List<List<int>>> baseShapes = {
      0: [[0, 0]],
      1: [[0, -1], [0, 0]],
      2: [[0, -1], [0, 0], [0, 1]],
      3: [[0, -1], [0, 0], [0, 1], [1, 1]],
      4: [[-1, -1], [0, -1], [-1, 0], [-1, 1]],
      5: [[-1, -1], [0, -1], [0, 0]],
      6: [[0, 0], [-1, 0], [1, 0], [0, -1], [0, 1]],
      7: [[-1, -1], [0, -1], [-1, 0], [0, 0]],
      8: [[-1, 0], [0, 0], [1, 0], [0, 1]],
      9: [[0, 0], [1, 0], [1, 1], [2, 1]],
      10: [[1, 0], [2, 0], [0, 1], [1, 1]],
      11: [[0, 0], [2, 0], [0, 1], [1, 1], [2, 1]],
    };

    List<List<int>> shape = baseShapes[blockGroupType] ?? [[0, 0]];
    int row = gridRow;
    int col = gridCol;
    final rotZ = rotationZ % 4;

    List<List<int>> rotatedShape = shape.map((cell) => [...cell]).toList();
    for (int i = 0; i < rotZ; i++) {
      rotatedShape = rotatedShape.map((cell) => [-cell[1], cell[0]]).toList();
    }

    switch (blockGroupType) {
      case 1:
        if (rotZ == 1) {
          col -= 1;
        } else if (rotZ == 2) row -= 1;
        break;
      case 3:
        if (rotZ == 0) {
          rotatedShape = [[0, -1], [1, -1], [1, 0], [1, 1]];
          col -= 1;
        } else if (rotZ == 2) {
          rotatedShape = [[0, -1], [0, 0], [0, 1], [1, 1]];
          col -= 1;
        }
        break;
      case 4:
        final reverseLShapes = {
          0: [[-1, -1], [0, -1], [-1, 0], [-1, 1]],
          1: [[-1, -1], [-1, 0], [0, 0], [1, 0]],
          2: [[1, -1], [1, 0], [0, 1], [1, 1]],
          3: [[-1, 0], [0, 0], [1, 0], [1, 1]],
        };
        rotatedShape = reverseLShapes[rotZ]?.map((c) => [...c]).toList() ?? rotatedShape;
        if (rotZ == 2) {
          col -= 1;
        } else if (rotZ == 3) row -= 1;
        break;
      case 5:
        if (rotZ == 0) {
          rotatedShape = [[-1, -1], [0, -1], [0, 0]];
        } else if (rotZ == 1) {
          rotatedShape = [[0, 0], [1, 0], [0, 1]];
          row -= 1;
          col -= 1;
        } else if (rotZ == 2) {
          rotatedShape = [[0, 0], [0, 1], [1, 1]];
          col -= 1;
          if (needsRowOffset) {
            row -= 1;
          } else {
            final atTopEdge = row <= 1;
            final atBottomEdge = (row + 1) >= gridHeight;
            if (atTopEdge || atBottomEdge) row -= 1;
          }
        } else if (rotZ == 3) {
          rotatedShape = [[-1, 0], [0, -1], [0, 0]];
        }
        break;
      case 8:
        final shortTShapes = {
          0: [[-1, 0], [0, 0], [1, 0], [0, 1]],
          1: [[0, -1], [0, 0], [1, 0], [0, 1]],
          2: [[0, -1], [-1, 0], [0, 0], [1, 0]],
          3: [[0, -1], [-1, 0], [0, 0], [0, 1]]
        };
        rotatedShape = shortTShapes[rotZ]?.map((c) => [...c]).toList() ?? rotatedShape;
        if (rotZ == 0) {
          row -= 1;
        } else if (rotZ == 1) col -= 1;
        break;
    }

    return rotatedShape.map((offset) => Point(row + offset[1], col + offset[0])).toList();
  }

  /// Get all cells occupied by this block (filtered by removed units)
  List<Point> get cells {
    final baseCells = _baseCells;
    if (removedUnits.isEmpty) return baseCells;
    
    // Filter out removed cells
    return baseCells.where((cell) => !removedUnits.contains(cell)).toList();
  }
}

class GameDoor {
  final int blockType;
  final int partCount;
  final String edge;
  final int startRow;
  final int startCol;

  GameDoor({
    required this.blockType,
    required this.partCount,
    required this.edge,
    required this.startRow,
    required this.startCol,
  });

  factory GameDoor.fromJson(Map<String, dynamic> json) {
    return GameDoor(
      blockType: json['blockType'],
      partCount: json['partCount'],
      edge: json['edge'],
      startRow: json['startRow'],
      startCol: json['startCol'],
    );
  }

  List<Point> get cells {
    List<Point> result = [];
    for (int i = 0; i < partCount; i++) {
      if (edge == 'left' || edge == 'right') {
        result.add(Point(startRow + i, startCol));
      } else {
        result.add(Point(startRow, startCol + i));
      }
    }
    return result;
  }
}

class Point {
  final int row;
  final int col;
  const Point(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is Point && other.row == row && other.col == col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'Point($row, $col)';
}

// ============ LEVEL LOADER ============

class LevelLoader {
  static List<GameLevel>? _cachedLevels;
  
  /// Load all levels from JSON asset
  /// Throws [LevelLoadException] if loading fails
  static Future<List<GameLevel>> loadLevels() async {
    if (_cachedLevels != null) {
      if (kDebugMode) debugPrint('🎮 LEVEL ℹ️ Using cached levels (${_cachedLevels!.length})');
      return _cachedLevels!;
    }
    
    try {
      if (kDebugMode) debugPrint('🎮 LEVEL ℹ️ Loading levels from assets...');
      final jsonString = await rootBundle.loadString('assets/levels/levels_27.json');
      
      final dynamic data;
      try {
        data = json.decode(jsonString);
      } catch (e) {
        throw LevelLoadException('Failed to parse levels JSON: $e');
      }
      
      if (data is! Map<String, dynamic>) {
        throw LevelLoadException('Invalid levels format: expected Map, got ${data.runtimeType}');
      }
      
      final levels = data['levels'];
      if (levels is! List) {
        throw LevelLoadException('Invalid levels format: "levels" key missing or not a List');
      }
      
      _cachedLevels = levels
          .map((l) => GameLevel.fromJson(l as Map<String, dynamic>))
          .toList();
      
      if (_cachedLevels!.isEmpty) {
        throw LevelLoadException('No levels found in JSON');
      }
      
      if (kDebugMode) {
        debugPrint('🎮 LEVEL ✅ Loaded ${_cachedLevels!.length} levels');
        final hardLevels = _cachedLevels!.where((l) => l.isHard).length;
        debugPrint('🎮 LEVEL ℹ️ Hard levels: $hardLevels');
      }
      
      return _cachedLevels!;
    } on LevelLoadException {
      rethrow;
    } catch (e) {
      throw LevelLoadException('Failed to load levels: $e');
    }
  }
  
  /// Get a specific level by ID
  /// Returns null if level not found
  static Future<GameLevel?> getLevel(int levelId) async {
    final levels = await loadLevels();
    try {
      return levels.firstWhere((l) => l.id == levelId);
    } catch (_) {
      return null;
    }
  }
  
  /// Clear cached levels (useful for memory management)
  static void clearCache() {
    _cachedLevels = null;
    if (kDebugMode) debugPrint('🎮 LEVEL ℹ️ Cache cleared');
  }
  
  /// Check if levels are cached
  static bool get isCached => _cachedLevels != null;
  
  /// Get cached level count (or 0 if not cached)
  static int get cachedCount => _cachedLevels?.length ?? 0;
}

/// Exception thrown when level loading fails
class LevelLoadException implements Exception {
  final String message;
  LevelLoadException(this.message);
  
  @override
  String toString() => 'LevelLoadException: $message';
}

