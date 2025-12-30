import 'dart:collection';
import '../models/game_models.dart';

/// Напрямок руху для Brute-Force
enum MoveDir { up, down, left, right }

/// Представлення одного ходу
class Move {
  final int blockIndex;
  final MoveDir direction;
  final int distance; // Скільки клітинок рухатись (1 = до краю/блокера)

  const Move(this.blockIndex, this.direction, [this.distance = 1]);

  @override
  String toString() => 'Move(block:$blockIndex, $direction, dist:$distance)';
  
  @override
  bool operator ==(Object other) =>
      other is Move &&
      other.blockIndex == blockIndex &&
      other.direction == direction &&
      other.distance == distance;

  @override
  int get hashCode => Object.hash(blockIndex, direction, distance);
}

/// Стан гри для симуляції (immutable для BFS)
class GameState {
  final List<GameBlock> blocks;
  final List<GameDoor> doors;
  final int gridWidth;
  final int gridHeight;
  final List<Point> hiddenCells;
  
  /// Блоки що вже вийшли
  final Set<int> exitedBlockIndices;
  
  /// Кількість ходів зроблено
  final int moveCount;
  
  /// Шлях ходів до цього стану
  final List<Move> movePath;

  GameState({
    required this.blocks,
    required this.doors,
    required this.gridWidth,
    required this.gridHeight,
    required this.hiddenCells,
    this.exitedBlockIndices = const {},
    this.moveCount = 0,
    this.movePath = const [],
  });

  /// Створити з GameLevel
  factory GameState.fromLevel(GameLevel level) {
    return GameState(
      blocks: level.blocks.map((b) => _cloneBlock(b)).toList(),
      doors: level.doors,
      gridWidth: level.gridWidth,
      gridHeight: level.gridHeight,
      hiddenCells: level.hiddenCells,
    );
  }

  /// Чи виграно (всі блоки вийшли)
  bool get isWin => exitedBlockIndices.length == blocks.length;

  /// Кількість блоків що залишились
  int get remainingBlocks => blocks.length - exitedBlockIndices.length;

  /// Клонувати блок
  static GameBlock _cloneBlock(GameBlock b) {
    final clone = GameBlock(
      blockType: b.blockType,
      blockGroupType: b.blockGroupType,
      gridRow: b.gridRow,
      gridCol: b.gridCol,
      rotationZ: b.rotationZ,
      needsRowOffset: b.needsRowOffset,
      moveDirection: b.moveDirection,
      innerBlockType: b.innerBlockType,
      iceCount: b.iceCount,
    );
    clone.gridWidth = b.gridWidth;
    clone.gridHeight = b.gridHeight;
    clone.outerLayerDestroyed = b.outerLayerDestroyed;
    return clone;
  }

  /// Створити копію стану
  GameState clone() {
    return GameState(
      blocks: blocks.map((b) => _cloneBlock(b)).toList(),
      doors: doors,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      hiddenCells: hiddenCells,
      exitedBlockIndices: Set.from(exitedBlockIndices),
      moveCount: moveCount,
      movePath: List.from(movePath),
    );
  }

  /// Унікальний ключ стану для visited set
  String get stateKey {
    final sb = StringBuffer();
    for (int i = 0; i < blocks.length; i++) {
      if (exitedBlockIndices.contains(i)) {
        sb.write('X');
      } else {
        final b = blocks[i];
        sb.write('${b.gridRow},${b.gridCol};');
      }
    }
    return sb.toString();
  }
}

/// Результат Brute-Force аналізу
class BruteForceResult {
  final int levelId;
  final bool isSolvable;
  final int? minMoves;
  final List<Move>? solution;
  final int statesExplored;
  final Duration searchTime;
  final String? error;

  BruteForceResult({
    required this.levelId,
    required this.isSolvable,
    this.minMoves,
    this.solution,
    required this.statesExplored,
    required this.searchTime,
    this.error,
  });

  @override
  String toString() {
    if (!isSolvable) {
      return 'Level $levelId: UNSOLVABLE (explored $statesExplored states in ${searchTime.inMilliseconds}ms)';
    }
    return 'Level $levelId: SOLVABLE in $minMoves moves (explored $statesExplored states in ${searchTime.inMilliseconds}ms)';
  }
}

/// Симулятор гри для Brute-Force
class GameSimulator {
  final GameLevel level;

  GameSimulator(this.level);

  /// Отримати всі можливі ходи для поточного стану
  List<Move> getPossibleMoves(GameState state) {
    final moves = <Move>[];

    for (int i = 0; i < state.blocks.length; i++) {
      // Пропустити блоки що вже вийшли
      if (state.exitedBlockIndices.contains(i)) continue;

      final block = state.blocks[i];
      
      // Пропустити заморожені блоки
      if (block.isFrozen) continue;

      // Перевірити напрямки руху
      final canHorizontal = block.moveDirection == MoveDirection.horizontal ||
          block.moveDirection == MoveDirection.both;
      final canVertical = block.moveDirection == MoveDirection.vertical ||
          block.moveDirection == MoveDirection.both;

      if (canHorizontal) {
        // Перевірити рух вліво
        if (_canMove(state, i, MoveDir.left)) {
          moves.add(Move(i, MoveDir.left));
        }
        // Перевірити рух вправо
        if (_canMove(state, i, MoveDir.right)) {
          moves.add(Move(i, MoveDir.right));
        }
      }

      if (canVertical) {
        // Перевірити рух вгору
        if (_canMove(state, i, MoveDir.up)) {
          moves.add(Move(i, MoveDir.up));
        }
        // Перевірити рух вниз
        if (_canMove(state, i, MoveDir.down)) {
          moves.add(Move(i, MoveDir.down));
        }
      }
    }

    return moves;
  }

  /// Перевірити чи можна зробити хід
  bool _canMove(GameState state, int blockIndex, MoveDir dir) {
    final block = state.blocks[blockIndex];
    final cells = block.cells;
    
    // Визначити зміщення
    int dRow = 0, dCol = 0;
    switch (dir) {
      case MoveDir.up:
        dRow = -1;
        break;
      case MoveDir.down:
        dRow = 1;
        break;
      case MoveDir.left:
        dCol = -1;
        break;
      case MoveDir.right:
        dCol = 1;
        break;
    }

    // Перевірити кожну клітинку блоку
    for (final cell in cells) {
      final newRow = cell.row + dRow;
      final newCol = cell.col + dCol;

      // Перевірити межі (враховуючи двері)
      if (!_isValidPosition(state, newRow, newCol, block.activeBlockType, dir)) {
        // Можливо це двері?
        if (!_isDoorExit(state, newRow, newCol, block.activeBlockType, dir)) {
          return false;
        }
      }

      // Перевірити колізію з іншими блоками
      if (_hasCollision(state, blockIndex, newRow, newCol)) {
        return false;
      }

      // Перевірити hidden cells
      if (_isHiddenCell(state, newRow, newCol)) {
        return false;
      }
    }

    return true;
  }

  /// Перевірити чи позиція валідна (в межах сітки)
  bool _isValidPosition(GameState state, int row, int col, int blockType, MoveDir dir) {
    // Перевірити чи є двері на цій позиції
    if (row < 0 || row >= state.gridHeight || col < 0 || col >= state.gridWidth) {
      return false;
    }
    return true;
  }

  /// Перевірити чи це вихід через двері
  bool _isDoorExit(GameState state, int row, int col, int blockType, MoveDir dir) {
    for (final door in state.doors) {
      // Перевірити колір
      if (door.blockType != blockType) continue;

      // Перевірити позицію дверей
      final doorCells = door.cells;
      for (final doorCell in doorCells) {
        // Двері на краю: row може бути -1 (top) або gridHeight (bottom)
        // col може бути -1 (left) або gridWidth (right)
        if (doorCell.row == row && doorCell.col == col) {
          // Перевірити напрямок
          if (door.edge == 'top' && dir == MoveDir.up) return true;
          if (door.edge == 'bottom' && dir == MoveDir.down) return true;
          if (door.edge == 'left' && dir == MoveDir.left) return true;
          if (door.edge == 'right' && dir == MoveDir.right) return true;
        }
      }
    }
    return false;
  }

  /// Перевірити колізію з іншими блоками
  bool _hasCollision(GameState state, int movingBlockIndex, int row, int col) {
    for (int i = 0; i < state.blocks.length; i++) {
      if (i == movingBlockIndex) continue;
      if (state.exitedBlockIndices.contains(i)) continue;

      final other = state.blocks[i];
      for (final cell in other.cells) {
        if (cell.row == row && cell.col == col) {
          return true;
        }
      }
    }
    return false;
  }

  /// Перевірити чи це hidden cell
  bool _isHiddenCell(GameState state, int row, int col) {
    for (final hidden in state.hiddenCells) {
      if (hidden.row == row && hidden.col == col) {
        return true;
      }
    }
    return false;
  }

  /// Застосувати хід і повернути новий стан
  GameState? applyMove(GameState state, Move move) {
    final newState = state.clone();
    final block = newState.blocks[move.blockIndex];

    // Визначити зміщення
    int dRow = 0, dCol = 0;
    switch (move.direction) {
      case MoveDir.up:
        dRow = -1;
        break;
      case MoveDir.down:
        dRow = 1;
        break;
      case MoveDir.left:
        dCol = -1;
        break;
      case MoveDir.right:
        dCol = 1;
        break;
    }

    // Рухати блок поки не зупиниться
    bool moved = false;
    bool exited = false;

    while (true) {
      // Спробувати зрушити на 1 клітинку
      final cells = block.cells;
      bool canMove = true;
      bool willExit = false;

      for (final cell in cells) {
        final newRow = cell.row + dRow;
        final newCol = cell.col + dCol;

        // Перевірити вихід через двері
        if (_checkDoorExit(newState, newRow, newCol, block.activeBlockType, move.direction)) {
          willExit = true;
          continue;
        }

        // Перевірити межі
        if (newRow < 0 || newRow >= state.gridHeight || 
            newCol < 0 || newCol >= state.gridWidth) {
          canMove = false;
          break;
        }

        // Перевірити колізію
        if (_hasCollision(newState, move.blockIndex, newRow, newCol)) {
          canMove = false;
          break;
        }

        // Перевірити hidden cells
        if (_isHiddenCell(newState, newRow, newCol)) {
          canMove = false;
          break;
        }
      }

      if (willExit) {
        // Блок виходить через двері
        exited = true;
        
        // Обробити multi-layer
        if (block.hasInnerLayer) {
          block.outerLayerDestroyed = true;
          // Блок залишається, але тепер інший колір
        } else {
          // Блок повністю виходить
          newState.exitedBlockIndices.add(move.blockIndex);
          
          // Оновити iceCount інших блоків
          _updateIceCounts(newState);
        }
        break;
      }

      if (!canMove) {
        break;
      }

      // Зрушити блок
      block.gridRow += dRow;
      block.gridCol += dCol;
      moved = true;
    }

    if (!moved && !exited) {
      return null; // Хід неможливий
    }

    // Оновити статистику
    newState.movePath.add(move);

    return newState;
  }

  /// Перевірити вихід через конкретні двері
  bool _checkDoorExit(GameState state, int row, int col, int blockType, MoveDir dir) {
    for (final door in state.doors) {
      if (door.blockType != blockType) continue;

      final doorCells = door.cells;
      for (final doorCell in doorCells) {
        if (doorCell.row == row && doorCell.col == col) {
          if (door.edge == 'top' && dir == MoveDir.up) return true;
          if (door.edge == 'bottom' && dir == MoveDir.down) return true;
          if (door.edge == 'left' && dir == MoveDir.left) return true;
          if (door.edge == 'right' && dir == MoveDir.right) return true;
        }
      }
    }
    return false;
  }

  /// Оновити iceCount після виходу блоку
  void _updateIceCounts(GameState state) {
    for (int i = 0; i < state.blocks.length; i++) {
      if (state.exitedBlockIndices.contains(i)) continue;
      final block = state.blocks[i];
      if (block.isFrozen) {
        block.iceCount--;
      }
    }
  }

  /// BFS пошук рішення
  BruteForceResult solve({int maxStates = 100000}) {
    final stopwatch = Stopwatch()..start();
    
    final initialState = GameState.fromLevel(level);
    
    // Черга для BFS
    final queue = Queue<GameState>();
    queue.add(initialState);
    
    // Відвідані стани
    final visited = <String>{};
    visited.add(initialState.stateKey);
    
    int statesExplored = 0;

    while (queue.isNotEmpty && statesExplored < maxStates) {
      final state = queue.removeFirst();
      statesExplored++;

      // Перевірити виграш
      if (state.isWin) {
        stopwatch.stop();
        return BruteForceResult(
          levelId: level.id,
          isSolvable: true,
          minMoves: state.movePath.length,
          solution: state.movePath,
          statesExplored: statesExplored,
          searchTime: stopwatch.elapsed,
        );
      }

      // Отримати можливі ходи
      final moves = getPossibleMoves(state);

      for (final move in moves) {
        final newState = applyMove(state, move);
        if (newState == null) continue;

        final key = newState.stateKey;
        if (!visited.contains(key)) {
          visited.add(key);
          queue.add(newState);
        }
      }
    }

    stopwatch.stop();
    return BruteForceResult(
      levelId: level.id,
      isSolvable: false,
      statesExplored: statesExplored,
      searchTime: stopwatch.elapsed,
      error: statesExplored >= maxStates ? 'Max states reached' : 'No solution found',
    );
  }
}

/// Brute-Force аналізатор для всіх рівнів
class BruteForceAnalyzer {
  /// Проаналізувати всі рівні
  static Future<List<BruteForceResult>> analyzeAllLevels({
    int maxStatesPerLevel = 100000,
    void Function(int current, int total, BruteForceResult result)? onProgress,
  }) async {
    final levels = await LevelLoader.loadLevels();
    final results = <BruteForceResult>[];

    for (int i = 0; i < levels.length; i++) {
      final level = levels[i];
      final simulator = GameSimulator(level);
      final result = simulator.solve(maxStates: maxStatesPerLevel);
      results.add(result);
      
      onProgress?.call(i + 1, levels.length, result);
    }

    return results;
  }

  /// Проаналізувати один рівень
  static Future<BruteForceResult> analyzeLevel(int levelId, {int maxStates = 100000}) async {
    final level = await LevelLoader.getLevel(levelId);
    if (level == null) {
      return BruteForceResult(
        levelId: levelId,
        isSolvable: false,
        statesExplored: 0,
        searchTime: Duration.zero,
        error: 'Level not found',
      );
    }

    final simulator = GameSimulator(level);
    return simulator.solve(maxStates: maxStates);
  }

  /// Вивести статистику
  static void printStatistics(List<BruteForceResult> results) {
    final solvable = results.where((r) => r.isSolvable).length;
    final unsolvable = results.where((r) => !r.isSolvable).length;
    final totalMoves = results
        .where((r) => r.isSolvable && r.minMoves != null)
        .fold<int>(0, (sum, r) => sum + r.minMoves!);
    final avgMoves = solvable > 0 ? totalMoves / solvable : 0;
    final totalTime = results.fold<int>(0, (sum, r) => sum + r.searchTime.inMilliseconds);

    print('');
    print('═══════════════════════════════════════════');
    print('        BRUTE-FORCE ANALYSIS RESULTS        ');
    print('═══════════════════════════════════════════');
    print('');
    print('Total levels:    ${results.length}');
    print('Solvable:        $solvable ✅');
    print('Unsolvable:      $unsolvable ❌');
    print('');
    print('Average moves:   ${avgMoves.toStringAsFixed(1)}');
    print('Total time:      ${totalTime}ms');
    print('');
    
    // Показати проблемні рівні
    final problemLevels = results.where((r) => !r.isSolvable).toList();
    if (problemLevels.isNotEmpty) {
      print('⚠️  Problem levels:');
      for (final r in problemLevels) {
        print('   Level ${r.levelId}: ${r.error}');
      }
    }
    
    print('═══════════════════════════════════════════');
  }
}

