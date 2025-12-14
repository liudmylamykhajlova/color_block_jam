/// Форми блоків (blockGroupType)
/// Координати: (dx, dy) де dx=зміщення по колонці, dy=зміщення по рядку
/// dy: +1 = вниз, -1 = вгору
/// dx: +1 = вправо, -1 = вліво
class BlockShapes {
  BlockShapes._();

  static const Map<int, String> names = {
    0: 'Single',
    1: 'Double',
    2: 'Triple',
    3: 'L',
    4: 'ReverseL',
    5: 'ShortL',
    6: 'Plus',
    7: 'TwoSquare',
    8: 'ShortT',
    9: 'Z',
    10: 'ReverseZ',
    11: 'U',
  };

  /// Базові форми блоків (до ротації)
  static const Map<int, List<List<int>>> baseShapes = {
    0: [[0, 0]], // Single - одна клітинка
    1: [[0, -1], [0, 0]], // Double - вертикальна 1x2
    2: [[0, -1], [0, 0], [0, 1]], // Triple - вертикальна 1x3
    3: [[0, -1], [0, 0], [0, 1], [1, 1]], // L
    4: [[-1, -1], [0, -1], [-1, 0], [-1, 1]], // ReverseL
    5: [[-1, -1], [0, -1], [0, 0]], // ShortL
    6: [[0, 0], [-1, 0], [1, 0], [0, -1], [0, 1]], // Plus
    7: [[-1, -1], [0, -1], [-1, 0], [0, 0]], // TwoSquare (2x2)
    8: [[-1, 0], [0, 0], [1, 0], [0, 1]], // ShortT
    9: [[0, 0], [1, 0], [1, 1], [2, 1]], // Z
    10: [[1, 0], [2, 0], [0, 1], [1, 1]], // ReverseZ
    11: [[0, 0], [2, 0], [0, 1], [1, 1], [2, 1]], // U
  };

  /// Отримати форму блоку
  static List<List<int>> getShape(int blockGroupType) {
    return baseShapes[blockGroupType] ?? [[0, 0]];
  }

  /// Отримати назву форми
  static String getName(int blockGroupType) {
    return names[blockGroupType] ?? 'Unknown';
  }

  /// Застосувати ротацію до форми (rotZ: 0, 1, 2, 3 = 0°, 90°, 180°, 270°)
  static List<List<int>> rotateShape(List<List<int>> shape, int rotZ) {
    final rotations = rotZ % 4;
    List<List<int>> rotated = shape.map((cell) => [...cell]).toList();

    for (int i = 0; i < rotations; i++) {
      rotated = rotated.map((cell) => [-cell[1], cell[0]]).toList();
    }

    return rotated;
  }

  /// Спеціальні трансформації для L блоків
  static List<List<int>> getLShapeForRotation(int rotZ) {
    switch (rotZ % 4) {
      case 0:
        // rotZ=0: дзеркальна форма X X / _X / _X
        return [[0, -1], [1, -1], [1, 0], [1, 1]];
      case 2:
        // rotZ=2: оригінальна L форма X / X / X X
        return [[0, -1], [0, 0], [0, 1], [1, 1]];
      default:
        // Для інших ротацій використовуємо стандартну ротацію
        return rotateShape(baseShapes[3]!, rotZ);
    }
  }

  /// Спеціальні трансформації для ShortL блоків
  static List<List<int>> getShortLShapeForRotation(int rotZ) {
    switch (rotZ % 4) {
      case 0:
        return [[-1, -1], [0, -1], [0, 0]]; // X X / __X
      case 1:
        return [[0, 0], [1, 0], [0, 1]]; // X X / X__
      case 2:
        return [[0, 0], [0, 1], [1, 1]]; // X__ / X X
      case 3:
        return [[-1, 0], [0, -1], [0, 0]]; // __X / X X
      default:
        return baseShapes[5]!;
    }
  }
}

