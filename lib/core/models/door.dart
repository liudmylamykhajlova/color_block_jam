import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'grid_position.dart';

/// Край дверей
enum DoorEdge { left, right, top, bottom }

/// Двері на краю поля
class GameDoor {
  GameDoor({
    required this.blockType,
    required this.partCount,
    required this.edge,
    required this.startPosition,
  });

  final int blockType; // Колір для матчінгу з блоками
  final int partCount; // Кількість клітинок
  final DoorEdge edge; // Сторона поля
  final GridPosition startPosition; // Початкова позиція

  /// Колір дверей
  Color get color => GameColors.getColor(blockType);

  /// Назва кольору
  String get colorName => GameColors.getName(blockType);

  /// Отримати всі клітинки, які займають двері
  List<GridPosition> get occupiedCells {
    final cells = <GridPosition>[];
    for (int i = 0; i < partCount; i++) {
      switch (edge) {
        case DoorEdge.left:
        case DoorEdge.right:
          cells.add(GridPosition(startPosition.row + i, startPosition.col));
          break;
        case DoorEdge.top:
        case DoorEdge.bottom:
          cells.add(GridPosition(startPosition.row, startPosition.col + i));
          break;
      }
    }
    return cells;
  }

  /// Створити з JSON
  factory GameDoor.fromJson(Map<String, dynamic> json) {
    return GameDoor(
      blockType: json['blockType'] as int,
      partCount: json['partCount'] as int,
      edge: DoorEdge.values.firstWhere(
        (e) => e.name == json['edge'],
        orElse: () => DoorEdge.left,
      ),
      startPosition: GridPosition(
        json['startRow'] as int,
        json['startCol'] as int,
      ),
    );
  }

  @override
  String toString() =>
      'GameDoor($colorName x$partCount on $edge at ${startPosition.row},${startPosition.col})';
}

