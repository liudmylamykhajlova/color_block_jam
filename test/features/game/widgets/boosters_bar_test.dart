import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/features/game/widgets/boosters_bar.dart';

void main() {
  group('BoostersBar', () {
    testWidgets('renders all 5 default boosters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BoostersBar(
              boosters: BoostersBar.defaultBoosters,
            ),
          ),
        ),
      );
      
      // Should have 5 booster buttons (inside _BoosterButton widgets)
      expect(find.byType(GestureDetector), findsWidgets);
    });
    
    testWidgets('shows quantity badges on boosters with quantity > 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BoostersBar(
              boosters: BoostersBar.defaultBoosters,
            ),
          ),
        ),
      );
      
      // First 4 default boosters have quantity "1" (freeze, rocket, hammer, vacuum)
      expect(find.text('1'), findsNWidgets(4));
    });
    
    testWidgets('calls onBoosterTap when booster tapped', (tester) async {
      BoosterType? tappedType;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BoostersBar(
              boosters: BoostersBar.defaultBoosters,
              onBoosterTap: (type) => tappedType = type,
            ),
          ),
        ),
      );
      
      // Tap first booster (freeze)
      await tester.tap(find.byIcon(Icons.ac_unit));
      expect(tappedType, BoosterType.freeze);
    });
    
    testWidgets('calls onPauseTap when pause tapped', (tester) async {
      bool pauseTapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BoostersBar(
              boosters: BoostersBar.defaultBoosters,
              onPauseTap: () => pauseTapped = true,
            ),
          ),
        ),
      );
      
      // Tap pause icon
      await tester.tap(find.byIcon(Icons.pause));
      expect(pauseTapped, true);
    });
  });
  
  group('BoosterData', () {
    test('creates with correct type and quantity', () {
      const booster = BoosterData(
        type: BoosterType.freeze,
        quantity: 5,
      );
      
      expect(booster.type, BoosterType.freeze);
      expect(booster.quantity, 5);
      expect(booster.isEnabled, true);
    });
    
    test('can be disabled', () {
      const booster = BoosterData(
        type: BoosterType.rocket,
        quantity: 1,
        isEnabled: false,
      );
      
      expect(booster.isEnabled, false);
    });
    
    test('default quantity is 0', () {
      const booster = BoosterData(type: BoosterType.shop);
      expect(booster.quantity, 0);
    });
  });
  
  group('BoosterType', () {
    test('has all expected types', () {
      expect(BoosterType.values.length, 6);
      expect(BoosterType.values, contains(BoosterType.freeze));
      expect(BoosterType.values, contains(BoosterType.rocket));
      expect(BoosterType.values, contains(BoosterType.hammer));
      expect(BoosterType.values, contains(BoosterType.vacuum));
      expect(BoosterType.values, contains(BoosterType.shop));
      expect(BoosterType.values, contains(BoosterType.pause));
    });
  });
  
  group('BoostersBar.defaultBoosters', () {
    test('has 5 default boosters', () {
      expect(BoostersBar.defaultBoosters.length, 5);
    });
    
    test('first booster is freeze with quantity 1', () {
      final first = BoostersBar.defaultBoosters[0];
      expect(first.type, BoosterType.freeze);
      expect(first.quantity, 1);
    });
    
    test('pause has quantity 0', () {
      final pause = BoostersBar.defaultBoosters.firstWhere(
        (b) => b.type == BoosterType.pause,
      );
      
      expect(pause.quantity, 0);
    });
    
    test('vacuum booster has quantity 1', () {
      final vacuum = BoostersBar.defaultBoosters.firstWhere(
        (b) => b.type == BoosterType.vacuum,
      );
      
      expect(vacuum.quantity, 1);
    });
  });
}
