/// Позиція на сітці (row, col)
class GridPosition {
  const GridPosition(this.row, this.col);

  final int row;
  final int col;

  GridPosition copyWith({int? row, int? col}) {
    return GridPosition(row ?? this.row, col ?? this.col);
  }

  @override
  bool operator ==(Object other) =>
      other is GridPosition && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => 'GridPosition($row, $col)';

  /// Створити з JSON
  factory GridPosition.fromJson(Map<String, dynamic> json) {
    return GridPosition(
      json['row'] as int,
      json['col'] as int,
    );
  }

  /// Конвертувати в JSON
  Map<String, dynamic> toJson() => {
        'row': row,
        'col': col,
      };
}

/// Розмір сітки
class GridSize {
  const GridSize(this.width, this.height);

  final int width; // колонки
  final int height; // рядки

  factory GridSize.fromJson(Map<String, dynamic> json) {
    return GridSize(
      json['width'] as int,
      json['height'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
      };

  @override
  String toString() => 'GridSize($width x $height)';
}

