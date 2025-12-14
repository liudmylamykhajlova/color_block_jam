import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/block_shapes.dart';
import 'grid_position.dart';

/// Ігровий блок
class GameBlock {
  GameBlock({
    required this.id,
    required this.blockType,
    required this.blockGroupType,
    required this.position,
    this.rotationZ = 0,
  });

  final int id;
  final int blockType; // Колір (0-9)
  final int blockGroupType; // Форма (0-11)
  final GridPosition position; // Позиція на сітці
  final int rotationZ; // Ротація (0, 1, 2, 3 = 0°, 90°, 180°, 270°)

  /// Колір блоку
  Color get color => GameColors.getColor(blockType);

  /// Назва кольору
  String get colorName => GameColors.getName(blockType);

  /// Назва форми
  String get shapeName => BlockShapes.getName(blockGroupType);

  /// Отримати всі клітинки, які займає блок
  List<GridPosition> get occupiedCells {
    final shape = _getTransformedShape();
    return shape.map((offset) {
      return GridPosition(
        position.row + offset[1],
        position.col + offset[0],
      );
    }).toList();
  }

  /// Отримати трансформовану форму з урахуванням ротації та спеціальних правил
  List<List<int>> _getTransformedShape() {
    // Спеціальна обробка для L блоків
    if (blockGroupType == 3) {
      return BlockShapes.getLShapeForRotation(rotationZ);
    }

    // Спеціальна обробка для ShortL блоків
    if (blockGroupType == 5) {
      return BlockShapes.getShortLShapeForRotation(rotationZ);
    }

    // Для інших блоків - стандартна ротація
    final baseShape = BlockShapes.getShape(blockGroupType);
    return BlockShapes.rotateShape(baseShape, rotationZ);
  }

  /// Копія з новою позицією
  GameBlock copyWith({GridPosition? position}) {
    return GameBlock(
      id: id,
      blockType: blockType,
      blockGroupType: blockGroupType,
      position: position ?? this.position,
      rotationZ: rotationZ,
    );
  }

  /// Створити з JSON
  factory GameBlock.fromJson(Map<String, dynamic> json, int id) {
    return GameBlock(
      id: id,
      blockType: json['blockType'] as int,
      blockGroupType: json['blockGroupType'] as int,
      position: GridPosition(
        json['gridRow'] as int,
        json['gridCol'] as int,
      ),
      rotationZ: json['rotationZ'] as int? ?? 0,
    );
  }

  @override
  String toString() =>
      'GameBlock($id: $colorName $shapeName at ${position.row},${position.col})';
}

