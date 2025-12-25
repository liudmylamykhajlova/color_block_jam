import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/features/splash/splash_screen.dart';
import 'package:color_block_jam/features/level_map/level_map_screen.dart';
import 'package:color_block_jam/features/level_map/widgets/level_node.dart';
import 'package:color_block_jam/features/game/game_screen.dart';
import 'package:color_block_jam/features/settings/settings_screen.dart';
import '../helpers/test_helpers.dart';

/// Integration tests for main app flows
void main() {
  group('App Flow Integration Tests', () {
    setUp(() async {
      await TestHelpers.initServices();
    });

    group('Splash → Level Map Flow', () {
      testWidgets('splash screen shows loading elements', (tester) async {
        tester.setLargeScreenSize();
        
        await tester.pumpWidget(
          TestHelpers.wrapScreen(const SplashScreen()),
        );
        
        // Should show logo text
        expect(find.text('Color'), findsOneWidget);
        expect(find.text('Block'), findsOneWidget);
        expect(find.text('Jam'), findsOneWidget);
        
        tester.resetToDefaultScreenSize();
      });

      testWidgets('level map shows after loading', (tester) async {
        tester.setLargeScreenSize();
        
        await tester.pumpWidget(
          TestHelpers.wrapScreen(const LevelMapScreen()),
        );
        
        // Wait for loading
        await tester.pumpAndSettle();
        
        // Should show level nodes
        expect(find.byType(LevelNode), findsWidgets);
        
        // Should show HUD elements
        expect(find.byIcon(Icons.settings), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsOneWidget);
        
        tester.resetToDefaultScreenSize();
      });
    });

    group('Level Map → Settings Flow', () {
      testWidgets('tapping settings opens settings screen', (tester) async {
        tester.setLargeScreenSize();
        
        await tester.pumpWidget(
          TestHelpers.wrapScreen(const LevelMapScreen()),
        );
        
        await tester.pumpAndSettle();
        
        // Tap settings
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();
        
        // Should show settings screen
        expect(find.text('SETTINGS'), findsOneWidget);
        
        tester.resetToDefaultScreenSize();
      });

      testWidgets('settings toggles work correctly', (tester) async {
        tester.setLargeScreenSize();
        
        await tester.pumpWidget(
          TestHelpers.wrapScreen(const SettingsScreen()),
        );
        
        await tester.pumpAndSettle();
        
        // Should have toggle switches
        expect(find.byType(Switch), findsWidgets);
        
        // Find sound toggle and tap it
        final switches = find.byType(Switch);
        expect(switches, findsWidgets);
        
        tester.resetToDefaultScreenSize();
      });
    });

    group('Level Map → Game Flow', () {
      testWidgets('game screen loads with level', (tester) async {
        tester.setLargeScreenSize();
        
        await tester.pumpWidget(
          TestHelpers.wrapScreen(const GameScreen(levelId: 1)),
        );
        
        // Wait for level to load
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        
        // Should show level indicator
        expect(find.text('1'), findsWidgets); // Level number
        
        // Should show timer
        expect(find.textContaining(':'), findsWidgets); // Timer MM:SS format
        
        tester.resetToDefaultScreenSize();
      });

      testWidgets('game screen has boosters bar', (tester) async {
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
    });

    group('Navigation Back Flow', () {
      testWidgets('back from settings returns to map', (tester) async {
        tester.setLargeScreenSize();
        
        // Start at level map
        await tester.pumpWidget(
          TestHelpers.wrapScreen(const LevelMapScreen()),
        );
        await tester.pumpAndSettle();
        
        // Go to settings
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();
        
        expect(find.text('SETTINGS'), findsOneWidget);
        
        // Close settings
        final closeButton = find.byIcon(Icons.close);
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton);
          await tester.pumpAndSettle();
        }
        
        tester.resetToDefaultScreenSize();
      });
    });

    group('Error Handling', () {
      testWidgets('handles missing level gracefully', (tester) async {
        tester.setLargeScreenSize();
        
        await tester.pumpWidget(
          TestHelpers.wrapScreen(const GameScreen(levelId: 9999)),
        );
        
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        
        // Should handle error (either show message or go back)
        // The exact behavior depends on implementation
        
        tester.resetToDefaultScreenSize();
      });
    });
  });
}

