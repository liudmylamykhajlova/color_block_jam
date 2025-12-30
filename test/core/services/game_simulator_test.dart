import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/core/services/game_simulator.dart';
import 'package:color_block_jam/core/models/game_models.dart';

void main() {
  group('GameSimulator', () {
    group('Move', () {
      test('should create Move with correct properties', () {
        const move = Move(0, MoveDir.up, 1);
        expect(move.blockIndex, 0);
        expect(move.direction, MoveDir.up);
        expect(move.distance, 1);
      });

      test('should compare Moves correctly', () {
        const move1 = Move(0, MoveDir.up);
        const move2 = Move(0, MoveDir.up);
        const move3 = Move(1, MoveDir.up);
        
        expect(move1, equals(move2));
        expect(move1, isNot(equals(move3)));
      });
    });

    group('GameState', () {
      late GameLevel testLevel;

      setUp(() {
        // Простий рівень 4x4 з одним блоком
        testLevel = GameLevel(
          id: 1,
          name: 'Test Level',
          gridWidth: 4,
          gridHeight: 4,
          duration: 60,
          blocks: [
            GameBlock(
              blockType: 0,
              blockGroupType: 0, // One cell
              gridRow: 2,
              gridCol: 2,
              rotationZ: 0,
            ),
          ],
          doors: [
            GameDoor(
              blockType: 0,
              partCount: 1,
              edge: 'top',
              startRow: -1,
              startCol: 2,
            ),
          ],
          hiddenCells: [],
        );
      });

      test('should create GameState from GameLevel', () {
        final state = GameState.fromLevel(testLevel);
        
        expect(state.blocks.length, 1);
        expect(state.doors.length, 1);
        expect(state.gridWidth, 4);
        expect(state.gridHeight, 4);
        expect(state.isWin, false);
        expect(state.remainingBlocks, 1);
      });

      test('should generate unique state key', () {
        final state1 = GameState.fromLevel(testLevel);
        final state2 = state1.clone();
        
        expect(state1.stateKey, state2.stateKey);
        
        // Змінити позицію блоку
        state2.blocks[0].gridRow = 1;
        expect(state1.stateKey, isNot(equals(state2.stateKey)));
      });

      test('should detect win condition', () {
        final state = GameState.fromLevel(testLevel);
        expect(state.isWin, false);
        
        state.exitedBlockIndices.add(0);
        expect(state.isWin, true);
      });
    });

    group('getPossibleMoves', () {
      test('should return all valid moves for free block', () {
        final level = GameLevel(
          id: 1,
          name: 'Test',
          gridWidth: 5,
          gridHeight: 5,
          duration: 60,
          blocks: [
            GameBlock(
              blockType: 0,
              blockGroupType: 0,
              gridRow: 2,
              gridCol: 2,
              rotationZ: 0,
              moveDirection: MoveDirection.both,
            ),
          ],
          doors: [],
          hiddenCells: [],
        );

        final simulator = GameSimulator(level);
        final state = GameState.fromLevel(level);
        final moves = simulator.getPossibleMoves(state);

        // Блок в центрі може рухатись в усі 4 напрямки
        expect(moves.length, 4);
        expect(moves.any((m) => m.direction == MoveDir.up), true);
        expect(moves.any((m) => m.direction == MoveDir.down), true);
        expect(moves.any((m) => m.direction == MoveDir.left), true);
        expect(moves.any((m) => m.direction == MoveDir.right), true);
      });

      test('should respect horizontal-only movement', () {
        final level = GameLevel(
          id: 1,
          name: 'Test',
          gridWidth: 5,
          gridHeight: 5,
          duration: 60,
          blocks: [
            GameBlock(
              blockType: 0,
              blockGroupType: 0,
              gridRow: 2,
              gridCol: 2,
              rotationZ: 0,
              moveDirection: MoveDirection.horizontal,
            ),
          ],
          doors: [],
          hiddenCells: [],
        );

        final simulator = GameSimulator(level);
        final state = GameState.fromLevel(level);
        final moves = simulator.getPossibleMoves(state);

        // Тільки горизонтальні ходи
        expect(moves.length, 2);
        expect(moves.any((m) => m.direction == MoveDir.left), true);
        expect(moves.any((m) => m.direction == MoveDir.right), true);
        expect(moves.any((m) => m.direction == MoveDir.up), false);
        expect(moves.any((m) => m.direction == MoveDir.down), false);
      });

      test('should not allow moves for frozen blocks', () {
        final level = GameLevel(
          id: 1,
          name: 'Test',
          gridWidth: 5,
          gridHeight: 5,
          duration: 60,
          blocks: [
            GameBlock(
              blockType: 0,
              blockGroupType: 0,
              gridRow: 2,
              gridCol: 2,
              rotationZ: 0,
              iceCount: 3, // Frozen
            ),
          ],
          doors: [],
          hiddenCells: [],
        );

        final simulator = GameSimulator(level);
        final state = GameState.fromLevel(level);
        final moves = simulator.getPossibleMoves(state);

        expect(moves.length, 0);
      });
    });

    group('applyMove', () {
      test('should move block in correct direction', () {
        final level = GameLevel(
          id: 1,
          name: 'Test',
          gridWidth: 5,
          gridHeight: 5,
          duration: 60,
          blocks: [
            GameBlock(
              blockType: 0,
              blockGroupType: 0,
              gridRow: 2,
              gridCol: 2,
              rotationZ: 0,
            ),
          ],
          doors: [],
          hiddenCells: [],
        );

        final simulator = GameSimulator(level);
        final state = GameState.fromLevel(level);
        
        final move = const Move(0, MoveDir.up);
        final newState = simulator.applyMove(state, move);

        expect(newState, isNotNull);
        // Блок має зрушитись до верхнього краю (row 0)
        expect(newState!.blocks[0].gridRow, 0);
        expect(newState.blocks[0].gridCol, 2);
      });

      test('should exit block through matching door', () {
        final level = GameLevel(
          id: 1,
          name: 'Test',
          gridWidth: 4,
          gridHeight: 4,
          duration: 60,
          blocks: [
            GameBlock(
              blockType: 0, // Blue
              blockGroupType: 0,
              gridRow: 0, // На краю
              gridCol: 2,
              rotationZ: 0,
            ),
          ],
          doors: [
            GameDoor(
              blockType: 0, // Blue door
              partCount: 1,
              edge: 'top',
              startRow: -1,
              startCol: 2,
            ),
          ],
          hiddenCells: [],
        );

        final simulator = GameSimulator(level);
        final state = GameState.fromLevel(level);
        
        final move = const Move(0, MoveDir.up);
        final newState = simulator.applyMove(state, move);

        expect(newState, isNotNull);
        expect(newState!.exitedBlockIndices.contains(0), true);
        expect(newState.isWin, true);
      });
    });

    group('solve', () {
      test('should solve simple level', () {
        // Рівень: 1 блок, 1 двері зверху
        final level = GameLevel(
          id: 1,
          name: 'Simple Test',
          gridWidth: 3,
          gridHeight: 3,
          duration: 60,
          blocks: [
            GameBlock(
              blockType: 0,
              blockGroupType: 0,
              gridRow: 1,
              gridCol: 1,
              rotationZ: 0,
            ),
          ],
          doors: [
            GameDoor(
              blockType: 0,
              partCount: 1,
              edge: 'top',
              startRow: -1,
              startCol: 1,
            ),
          ],
          hiddenCells: [],
        );

        final simulator = GameSimulator(level);
        final result = simulator.solve();

        expect(result.isSolvable, true);
        expect(result.minMoves, 1); // Один хід вгору
        expect(result.solution?.length, 1);
        expect(result.solution?[0].direction, MoveDir.up);
      });

      test('should detect unsolvable level', () {
        // Рівень: блок заблокований, не може дістатись до дверей
        final level = GameLevel(
          id: 1,
          name: 'Blocked Test',
          gridWidth: 3,
          gridHeight: 3,
          duration: 60,
          blocks: [
            // Blue block
            GameBlock(
              blockType: 0,
              blockGroupType: 0,
              gridRow: 1,
              gridCol: 1,
              rotationZ: 0,
              moveDirection: MoveDirection.horizontal, // Тільки горизонтально
            ),
          ],
          doors: [
            // Door at top - but block can only move horizontally
            GameDoor(
              blockType: 0,
              partCount: 1,
              edge: 'top',
              startRow: -1,
              startCol: 1,
            ),
          ],
          hiddenCells: [],
        );

        final simulator = GameSimulator(level);
        final result = simulator.solve(maxStates: 1000);

        expect(result.isSolvable, false);
      });
    });
  });

  group('BruteForceResult', () {
    test('should format solvable result correctly', () {
      final result = BruteForceResult(
        levelId: 1,
        isSolvable: true,
        minMoves: 5,
        solution: [],
        statesExplored: 100,
        searchTime: const Duration(milliseconds: 50),
      );

      expect(result.toString(), contains('SOLVABLE'));
      expect(result.toString(), contains('5 moves'));
    });

    test('should format unsolvable result correctly', () {
      final result = BruteForceResult(
        levelId: 1,
        isSolvable: false,
        statesExplored: 1000,
        searchTime: const Duration(milliseconds: 100),
        error: 'No solution found',
      );

      expect(result.toString(), contains('UNSOLVABLE'));
    });
  });
}

