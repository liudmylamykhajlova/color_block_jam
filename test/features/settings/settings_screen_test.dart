import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:color_block_jam/core/services/storage_service.dart';
import 'package:color_block_jam/core/services/audio_service.dart';
import 'package:color_block_jam/features/settings/settings_screen.dart';

void main() {
  group('SettingsScreen', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await StorageService.init();
      AudioService.init();
    });
    
    // Helper to pump SettingsScreen with proper size
    Future<void> pumpSettingsScreen(WidgetTester tester) async {
      // Set a larger screen size to avoid overflow
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
    }
    
    testWidgets('renders settings title', (tester) async {
      await pumpSettingsScreen(tester);
      expect(find.text('SETTINGS'), findsOneWidget);
    });
    
    testWidgets('renders vibration toggle', (tester) async {
      await pumpSettingsScreen(tester);
      expect(find.text('Vibration'), findsOneWidget);
      expect(find.byType(Switch), findsWidgets);
    });
    
    testWidgets('renders sound toggle', (tester) async {
      await pumpSettingsScreen(tester);
      expect(find.text('Sound'), findsOneWidget);
    });
    
    testWidgets('renders music toggle', (tester) async {
      await pumpSettingsScreen(tester);
      expect(find.text('Music'), findsOneWidget);
    });
    
    testWidgets('renders reset progress button', (tester) async {
      await pumpSettingsScreen(tester);
      expect(find.text('Reset Progress'), findsOneWidget);
    });
    
    testWidgets('sound toggle changes state', (tester) async {
      await pumpSettingsScreen(tester);
      
      // Find the Sound toggle (second switch)
      final switches = find.byType(Switch);
      expect(switches, findsWidgets);
      
      // Sound is second toggle
      final soundSwitch = switches.at(1);
      
      // Tap to toggle
      await tester.tap(soundSwitch);
      await tester.pumpAndSettle();
      
      // Verify state changed
      expect(StorageService.getSoundEnabled(), false);
    });
    
    testWidgets('vibration toggle changes state', (tester) async {
      await pumpSettingsScreen(tester);
      
      // Find the Vibration toggle (first switch)
      final switches = find.byType(Switch);
      final vibrationSwitch = switches.first;
      
      // Initial state should be OFF (haptic disabled by default)
      expect(StorageService.getHapticEnabled(), false);
      
      // Tap to toggle
      await tester.tap(vibrationSwitch);
      await tester.pumpAndSettle();
      
      // Verify state changed
      expect(StorageService.getHapticEnabled(), true);
    });
    
    testWidgets('reset progress shows confirmation dialog', (tester) async {
      await pumpSettingsScreen(tester);
      
      // Scroll to find reset button if needed
      await tester.dragUntilVisible(
        find.text('Reset Progress'),
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      
      // Find and tap reset button
      final resetButton = find.text('Reset Progress');
      await tester.tap(resetButton);
      await tester.pumpAndSettle();
      
      // Verify dialog appears
      expect(find.text('Reset Progress?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });
    
    testWidgets('cancel button closes reset dialog', (tester) async {
      await pumpSettingsScreen(tester);
      
      // Scroll to find reset button if needed
      await tester.dragUntilVisible(
        find.text('Reset Progress'),
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      
      // Open dialog
      await tester.tap(find.text('Reset Progress'));
      await tester.pumpAndSettle();
      
      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      
      // Dialog should be closed
      expect(find.text('Reset Progress?'), findsNothing);
    });
    
    testWidgets('back button navigates back', (tester) async {
      // Set a larger screen size
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              child: const Text('Open Settings'),
            ),
          ),
        ),
      );
      
      // Navigate to settings
      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();
      
      expect(find.text('SETTINGS'), findsOneWidget);
      
      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();
      
      // Should be back to original screen
      expect(find.text('SETTINGS'), findsNothing);
      expect(find.text('Open Settings'), findsOneWidget);
    });
  });
}
