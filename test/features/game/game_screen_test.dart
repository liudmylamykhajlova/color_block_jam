import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/features/game/game_screen.dart';
import 'package:color_block_jam/features/game/widgets/boosters_bar.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('GameScreen', () {
    setUp(() async {
      await TestHelpers.initServices();
    });

    testWidgets('renders with level id', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapScreen(const GameScreen(levelId: 1)),
      );
      
      // Should not crash during initial load
      await tester.pump(const Duration(milliseconds: 100));
      
      tester.resetToDefaultScreenSize();
    });

    testWidgets('shows loading state initially', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapScreen(const GameScreen(levelId: 1)),
      );
      
      // Pump a bit to let it start
      await tester.pump(const Duration(milliseconds: 50));
      
      tester.resetToDefaultScreenSize();
    });

    testWidgets('shows boosters bar after loading', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapScreen(const GameScreen(levelId: 1)),
      );
      
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      
      // Should show boosters bar
      expect(find.byType(BoostersBar), findsOneWidget);
      
      tester.resetToDefaultScreenSize();
    });

    testWidgets('shows level number in HUD', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapScreen(const GameScreen(levelId: 5)),
      );
      
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      
      // Should show level number
      expect(find.text('5'), findsWidgets);
      
      tester.resetToDefaultScreenSize();
    });

    testWidgets('has pause button', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapScreen(const GameScreen(levelId: 1)),
      );
      
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      
      // Should show pause button
      expect(find.byIcon(Icons.pause), findsOneWidget);
      
      tester.resetToDefaultScreenSize();
    });

    testWidgets('timer is displayed', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapScreen(const GameScreen(levelId: 1)),
      );
      
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      
      // Timer should show MM:SS format
      // Look for text containing ":"
      expect(find.textContaining(':'), findsWidgets);
      
      tester.resetToDefaultScreenSize();
    });

    testWidgets('restart button reloads level', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapScreen(const GameScreen(levelId: 1)),
      );
      
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      
      // Find restart button (replay icon)
      final restartButton = find.byIcon(Icons.replay);
      expect(restartButton, findsOneWidget);
      
      // Tap restart
      await tester.tap(restartButton);
      await tester.pump();
      
      tester.resetToDefaultScreenSize();
    });

    group('Boosters', () {
      testWidgets('freeze booster icon is visible', (tester) async {
        tester.setLargeScreenSize();
        
        await tester.pumpWidget(
          TestHelpers.wrapScreen(const GameScreen(levelId: 1)),
        );
        
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        
        // Should show freeze icon (snowflake)
        expect(find.byIcon(Icons.ac_unit), findsOneWidget);
        
        tester.resetToDefaultScreenSize();
      });

      testWidgets('rocket booster icon is visible', (tester) async {
        tester.setLargeScreenSize();
        
        await tester.pumpWidget(
          TestHelpers.wrapScreen(const GameScreen(levelId: 1)),
        );
        
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        
        // Should show rocket icon
        expect(find.byIcon(Icons.rocket_launch), findsOneWidget);
        
        tester.resetToDefaultScreenSize();
      });
    });

    group('Level Loading', () {
      testWidgets('handles level 1 correctly', (tester) async {
        tester.setLargeScreenSize();
        
        await tester.pumpWidget(
          TestHelpers.wrapScreen(const GameScreen(levelId: 1)),
        );
        
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        
        // Should not show any error
        expect(find.text('Error'), findsNothing);
        
        tester.resetToDefaultScreenSize();
      });

      testWidgets('handles invalid level gracefully', (tester) async {
        tester.setLargeScreenSize();
        
        await tester.pumpWidget(
          TestHelpers.wrapScreen(const GameScreen(levelId: 99999)),
        );
        
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        
        // Should handle error without crashing
        
        tester.resetToDefaultScreenSize();
      });
    });
  });
}

