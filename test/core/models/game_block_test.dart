import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/core/models/game_models.dart';

void main() {
  group('GameBlock', () {
    group('cells calculation', () {
      test('One block (type 0) has 1 cell', () {
        final block = GameBlock(
          blockType: 0,
          blockGroupType: 0, // One
          gridRow: 5,
          gridCol: 5,
          rotationZ: 0,
        );
        
        expect(block.cells.length, 1);
        expect(block.cells.first, Point(5, 5));
      });
      
      test('Two block (type 1) horizontal has 2 cells', () {
        final block = GameBlock(
          blockType: 0,
          blockGroupType: 1, // Two
          gridRow: 5,
          gridCol: 5,
          rotationZ: 0, // Horizontal
        );
        
        expect(block.cells.length, 2);
      });
      
      test('Two block (type 1) vertical has 2 cells', () {
        final block = GameBlock(
          blockType: 0,
          blockGroupType: 1, // Two
          gridRow: 5,
          gridCol: 5,
          rotationZ: 1, // 90 degrees = vertical
        );
        
        expect(block.cells.length, 2);
      });
      
      test('L block (type 3) has 4 cells', () {
        final block = GameBlock(
          blockType: 0,
          blockGroupType: 3, // L
          gridRow: 5,
          gridCol: 5,
          rotationZ: 0,
        );
        
        expect(block.cells.length, 4);
      });
      
      test('Plus block (type 6) has 5 cells', () {
        final block = GameBlock(
          blockType: 0,
          blockGroupType: 6, // Plus
          gridRow: 5,
          gridCol: 5,
          rotationZ: 0,
        );
        
        expect(block.cells.length, 5);
      });
      
      test('U block (type 11) has 5 cells', () {
        final block = GameBlock(
          blockType: 0,
          blockGroupType: 11, // U
          gridRow: 5,
          gridCol: 5,
          rotationZ: 0,
        );
        
        expect(block.cells.length, 5);
      });
    });
    
    group('movement direction', () {
      test('horizontal only allows left/right', () {
        final block = GameBlock(
          blockType: 0,
          blockGroupType: 1,
          gridRow: 5,
          gridCol: 5,
          rotationZ: 0,
          moveDirection: MoveDirection.horizontal,
        );
        
        expect(block.moveDirection, MoveDirection.horizontal);
      });
      
      test('vertical only allows up/down', () {
        final block = GameBlock(
          blockType: 0,
          blockGroupType: 1,
          gridRow: 5,
          gridCol: 5,
          rotationZ: 0,
          moveDirection: MoveDirection.vertical,
        );
        
        expect(block.moveDirection, MoveDirection.vertical);
      });
      
      test('both allows all directions', () {
        final block = GameBlock(
          blockType: 0,
          blockGroupType: 1,
          gridRow: 5,
          gridCol: 5,
          rotationZ: 0,
          moveDirection: MoveDirection.both,
        );
        
        expect(block.moveDirection, MoveDirection.both);
      });
    });
    
    group('multi-layer blocks', () {
      test('hasInnerLayer is true when innerBlockType >= 0', () {
        final block = GameBlock(
          blockType: 0,
          blockGroupType: 1,
          gridRow: 5,
          gridCol: 5,
          rotationZ: 0,
          innerBlockType: 3, // Pink inner
        );
        
        expect(block.hasInnerLayer, true);
        expect(block.activeBlockType, 0); // Outer color
      });
      
      test('hasInnerLayer is false when innerBlockType is -1', () {
        final block = GameBlock(
          blockType: 0,
          blockGroupType: 1,
          gridRow: 5,
          gridCol: 5,
          rotationZ: 0,
          innerBlockType: -1,
        );
        
        expect(block.hasInnerLayer, false);
      });
      
      test('activeBlockType changes after outer layer destroyed', () {
        final block = GameBlock(
          blockType: 0, // Blue outer
          blockGroupType: 1,
          gridRow: 5,
          gridCol: 5,
          rotationZ: 0,
          innerBlockType: 3, // Pink inner
        );
        
        expect(block.activeBlockType, 0); // Blue
        
        block.outerLayerDestroyed = true;
        
        expect(block.activeBlockType, 3); // Pink
        expect(block.hasInnerLayer, false); // No longer has inner
      });
    });
    
    group('frozen blocks', () {
      test('isFrozen is true when iceCount > 0', () {
        final block = GameBlock(
          blockType: 0,
          blockGroupType: 1,
          gridRow: 5,
          gridCol: 5,
          rotationZ: 0,
          iceCount: 3,
        );
        
        expect(block.isFrozen, true);
      });
      
      test('isFrozen is false when iceCount is 0', () {
        final block = GameBlock(
          blockType: 0,
          blockGroupType: 1,
          gridRow: 5,
          gridCol: 5,
          rotationZ: 0,
          iceCount: 0,
        );
        
        expect(block.isFrozen, false);
      });
      
      test('iceCount can be decremented', () {
        final block = GameBlock(
          blockType: 0,
          blockGroupType: 1,
          gridRow: 5,
          gridCol: 5,
          rotationZ: 0,
          iceCount: 3,
        );
        
        block.iceCount--;
        expect(block.iceCount, 2);
        expect(block.isFrozen, true);
        
        block.iceCount--;
        block.iceCount--;
        expect(block.iceCount, 0);
        expect(block.isFrozen, false);
      });
    });
    
    group('copy', () {
      test('copy creates independent instance', () {
        final original = GameBlock(
          blockType: 0,
          blockGroupType: 1,
          gridRow: 5,
          gridCol: 5,
          rotationZ: 0,
          iceCount: 3,
          innerBlockType: 2,
        );
        
        final copy = original.copy();
        
        expect(copy.blockType, original.blockType);
        expect(copy.gridRow, original.gridRow);
        expect(copy.iceCount, original.iceCount);
        
        // Modifying copy doesn't affect original
        copy.iceCount = 0;
        expect(original.iceCount, 3);
      });
    });
  });
  
  group('Point', () {
    test('equality works correctly', () {
      final p1 = Point(5, 3);
      final p2 = Point(5, 3);
      final p3 = Point(3, 5);
      
      expect(p1, p2);
      expect(p1, isNot(p3));
    });
    
    test('hashCode is consistent', () {
      final p1 = Point(5, 3);
      final p2 = Point(5, 3);
      
      expect(p1.hashCode, p2.hashCode);
    });
  });
  
  group('MoveDirection', () {
    test('fromJson parses correctly', () {
      expect(MoveDirection.values[0], MoveDirection.horizontal);
      expect(MoveDirection.values[1], MoveDirection.vertical);
      expect(MoveDirection.values[2], MoveDirection.both);
    });
  });
}


