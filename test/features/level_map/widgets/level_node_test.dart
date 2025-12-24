import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/features/level_map/widgets/level_node.dart';

void main() {
  group('LevelNode', () {
    testWidgets('displays level number', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LevelNode(levelId: 5),
          ),
        ),
      );
      
      expect(find.text('5'), findsOneWidget);
    });
    
    testWidgets('shows current level label when isCurrent', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LevelNode(
              levelId: 10,
              isCurrent: true,
              isUnlocked: true,
            ),
          ),
        ),
      );
      
      expect(find.text('Level 10'), findsOneWidget);
    });
    
    testWidgets('shows lock badge when locked', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LevelNode(
              levelId: 1,
              isUnlocked: false,
            ),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });
    
    testWidgets('shows star badge when completed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LevelNode(
              levelId: 1,
              isCompleted: true,
              isUnlocked: true,
            ),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
    
    testWidgets('shows dangerous badge for hard levels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LevelNode(
              levelId: 1,
              isUnlocked: true,
              type: LevelNodeType.hard,
            ),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.dangerous), findsOneWidget);
    });
    
    testWidgets('shows dangerous badge for boss levels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LevelNode(
              levelId: 1,
              isUnlocked: true,
              type: LevelNodeType.boss,
            ),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.dangerous), findsOneWidget);
    });
    
    testWidgets('calls onTap when tapped and unlocked', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LevelNode(
              levelId: 1,
              isUnlocked: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.text('1'));
      expect(tapped, true);
    });
    
    testWidgets('does not call onTap when locked', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LevelNode(
              levelId: 1,
              isUnlocked: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.text('1'));
      expect(tapped, false);
    });
    
    testWidgets('does not show skull badge when locked', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LevelNode(
              levelId: 1,
              isUnlocked: false,
              type: LevelNodeType.hard,
            ),
          ),
        ),
      );
      
      // Skull badge should not be visible for locked levels
      expect(find.byIcon(Icons.dangerous), findsNothing);
    });
  });
  
  group('LevelNodeType', () {
    test('has all expected types', () {
      expect(LevelNodeType.values.length, 3);
      expect(LevelNodeType.values, contains(LevelNodeType.normal));
      expect(LevelNodeType.values, contains(LevelNodeType.hard));
      expect(LevelNodeType.values, contains(LevelNodeType.boss));
    });
  });
}
