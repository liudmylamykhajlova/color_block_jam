import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/features/game/widgets/level_start_dialog.dart';

void main() {
  group('LevelStartDialog', () {
    testWidgets('displays level number', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LevelStartDialog(levelId: 10),
          ),
        ),
      );
      
      expect(find.text('LEVEL 10'), findsOneWidget);
    });
    
    testWidgets('has Play button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LevelStartDialog(levelId: 1),
          ),
        ),
      );
      
      expect(find.text('Play'), findsOneWidget);
    });
    
    testWidgets('has close button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LevelStartDialog(levelId: 1),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
    
    testWidgets('displays milestone when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LevelStartDialog(
              levelId: 1,
              milestoneText: 'Unlock Level 70',
              milestoneProgress: 1,
              milestoneTotal: 3,
            ),
          ),
        ),
      );
      
      expect(find.text('Unlock Level 70'), findsOneWidget);
      expect(find.text('1/3'), findsOneWidget);
    });
    
    testWidgets('displays booster selection', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LevelStartDialog(levelId: 1),
          ),
        ),
      );
      
      expect(find.text('Select Boosters:'), findsOneWidget);
    });
    
    testWidgets('calls onPlay when Play tapped', (tester) async {
      bool playTapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LevelStartDialog(
              levelId: 1,
              onPlay: () => playTapped = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.text('Play'));
      expect(playTapped, true);
    });
    
    testWidgets('calls onClose when close tapped', (tester) async {
      bool closeTapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LevelStartDialog(
              levelId: 1,
              onClose: () => closeTapped = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.byIcon(Icons.close));
      expect(closeTapped, true);
    });
    
    testWidgets('displays default boosters when none provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LevelStartDialog(levelId: 1),
          ),
        ),
      );
      
      // Check for hourglass and rocket icons
      expect(find.byIcon(Icons.hourglass_bottom), findsOneWidget);
      expect(find.byIcon(Icons.rocket_launch), findsOneWidget);
    });
  });
  
  group('PreGameBooster', () {
    test('creates with correct properties', () {
      const booster = PreGameBooster(
        id: 'test',
        name: 'Test Booster',
        icon: Icons.star,
        color: Colors.blue,
        quantity: 5,
      );
      
      expect(booster.id, 'test');
      expect(booster.name, 'Test Booster');
      expect(booster.quantity, 5);
      expect(booster.isSelected, false);
    });
    
    test('copyWith changes selection', () {
      const booster = PreGameBooster(
        id: 'test',
        name: 'Test',
        icon: Icons.star,
        color: Colors.blue,
      );
      
      final selected = booster.copyWith(isSelected: true);
      
      expect(selected.isSelected, true);
      expect(selected.id, booster.id);
    });
    
    test('default quantity is 0', () {
      const booster = PreGameBooster(
        id: 'test',
        name: 'Test',
        icon: Icons.star,
        color: Colors.blue,
      );
      
      expect(booster.quantity, 0);
    });
  });
  
  group('LevelStartDialog.defaultBoosters', () {
    test('has 2 default boosters', () {
      expect(LevelStartDialog.defaultBoosters.length, 2);
    });
    
    test('default boosters are hourglass and rocket', () {
      final boosters = LevelStartDialog.defaultBoosters;
      expect(boosters[0].id, 'hourglass');
      expect(boosters[1].id, 'rocket');
    });
    
    test('default boosters have quantity 2', () {
      for (final booster in LevelStartDialog.defaultBoosters) {
        expect(booster.quantity, 2);
      }
    });
  });
}
