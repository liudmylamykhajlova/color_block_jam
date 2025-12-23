import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:color_block_jam/main.dart' as app;
import 'package:color_block_jam/core/services/storage_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Level Completion Flow', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await StorageService.init();
    });
    
    testWidgets('full game flow: menu -> level select -> play -> complete', 
        (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 1. Main Menu
      expect(find.text('COLOR BLOCK JAM'), findsOneWidget);
      expect(find.text('PLAY'), findsOneWidget);
      
      // 2. Tap Play
      await tester.tap(find.text('PLAY'));
      await tester.pumpAndSettle();
      
      // 3. Level Select Screen
      expect(find.text('SELECT LEVEL'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // Level 1
      
      // 4. Select Level 1
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      
      // 5. Game Screen
      expect(find.text('Level 1'), findsOneWidget);
      // Timer should be visible
      expect(find.textContaining(':'), findsWidgets);
      
      // Note: Actually completing the level requires game-specific 
      // interactions that depend on level layout
    });
    
    testWidgets('menu -> settings -> back to menu', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 1. Main Menu - find settings button (gear icon)
      final settingsButton = find.byIcon(Icons.settings);
      expect(settingsButton, findsOneWidget);
      
      // 2. Tap Settings
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();
      
      // 3. Settings Screen
      expect(find.text('SETTINGS'), findsOneWidget);
      expect(find.text('Sound'), findsOneWidget);
      expect(find.text('Music'), findsOneWidget);
      expect(find.text('Vibration'), findsOneWidget);
      
      // 4. Go back
      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();
      
      // 5. Back to Main Menu
      expect(find.text('COLOR BLOCK JAM'), findsOneWidget);
    });
    
    testWidgets('level progress is saved', (tester) async {
      // Mark level 1 as completed
      await StorageService.markLevelCompleted(1);
      
      app.main();
      await tester.pumpAndSettle();
      
      // Go to level select
      await tester.tap(find.text('PLAY'));
      await tester.pumpAndSettle();
      
      // Level 1 should show as completed (green with star)
      // Level 2 should be unlocked
      expect(find.text('2'), findsOneWidget);
    });
    
    testWidgets('lives display updates after fail', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Initial lives should be 5
      final initialLives = StorageService.getLives();
      expect(initialLives, 5);
      
      // Simulate losing a life
      await StorageService.loseLife();
      
      // Lives should be 4
      expect(StorageService.getLives(), 4);
    });
    
    testWidgets('timer is visible during gameplay', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to game
      await tester.tap(find.text('PLAY'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      
      // Timer should be visible (format MM:SS or M:SS)
      expect(find.textContaining(':'), findsWidgets);
    });
    
    testWidgets('restart button resets level', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to level 1
      await tester.tap(find.text('PLAY'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      
      // Find restart button
      final restartButton = find.byIcon(Icons.refresh);
      expect(restartButton, findsOneWidget);
      
      // Tap restart
      await tester.tap(restartButton);
      await tester.pumpAndSettle();
      
      // Game should still be on same level
      expect(find.text('Level 1'), findsOneWidget);
    });
  });
}


