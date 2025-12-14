import 'grid_position.dart';
import 'block.dart';
import 'door.dart';

/// Рівень гри
class GameLevel {
  GameLevel({
    required this.id,
    required this.name,
    required this.gridSize,
    required this.blocks,
    required this.doors,
    this.hiddenCells = const [],
  });

  final int id; // Номер рівня в грі (1-based)
  final String name; // Назва файлу рівня
  final GridSize gridSize;
  final List<GameBlock> blocks;
  final List<GameDoor> doors;
  final List<GridPosition> hiddenCells; // Заховані клітинки

  /// Створити з JSON
  factory GameLevel.fromJson(Map<String, dynamic> json) {
    final blocksJson = json['blocks'] as List<dynamic>;
    final doorsJson = json['doors'] as List<dynamic>;
    final hiddenJson = json['hiddenCells'] as List<dynamic>? ?? [];

    return GameLevel(
      id: json['id'] as int,
      name: json['name'] as String,
      gridSize: GridSize(
        json['gridWidth'] as int,
        json['gridHeight'] as int,
      ),
      blocks: blocksJson
          .asMap()
          .entries
          .map((e) => GameBlock.fromJson(e.value as Map<String, dynamic>, e.key))
          .toList(),
      doors: doorsJson
          .map((d) => GameDoor.fromJson(d as Map<String, dynamic>))
          .toList(),
      hiddenCells: hiddenJson
          .map((h) => GridPosition.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() =>
      'GameLevel($id: $name, ${gridSize.width}x${gridSize.height}, ${blocks.length} blocks, ${doors.length} doors)';
}

