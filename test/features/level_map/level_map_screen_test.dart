import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/features/level_map/level_map_screen.dart';
import 'package:color_block_jam/features/level_map/widgets/map_hud.dart';
import 'package:color_block_jam/features/level_map/widgets/level_node.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('LevelMapScreen', () {
    setUp(() async {
      await TestHelpers.initServices();
    });

    testWidgets('renders correctly with loading state', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapScreen(const LevelMapScreen()),
      );
      
      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      tester.resetToDefaultScreenSize();
    });

    testWidgets('renders MapHud after loading', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapScreen(const LevelMapScreen()),
      );
      
      // Wait for levels to load
      await tester.pumpAndSettle();
      
      // Should show MapHud
      expect(find.byType(MapHud), findsOneWidget);
      
      tester.resetToDefaultScreenSize();
    });

    testWidgets('renders level nodes after loading', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapScreen(const LevelMapScreen()),
      );
      
      await tester.pumpAndSettle();
      
      // Should show at least one LevelNode
      expect(find.byType(LevelNode), findsWidgets);
      
      tester.resetToDefaultScreenSize();
    });

    testWidgets('has bottom navigation bar', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapScreen(const LevelMapScreen()),
      );
      
      await tester.pumpAndSettle();
      
      // Should have Home, Shop labels
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Lvl 50'), findsOneWidget);
      
      tester.resetToDefaultScreenSize();
    });

    testWidgets('settings button navigates to settings', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapScreen(const LevelMapScreen()),
      );
      
      await tester.pumpAndSettle();
      
      // Find and tap settings icon
      final settingsButton = find.byIcon(Icons.settings);
      expect(settingsButton, findsOneWidget);
      
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();
      
      // Should navigate to settings (check for settings-specific widget)
      expect(find.text('SETTINGS'), findsOneWidget);
      
      tester.resetToDefaultScreenSize();
    });
  });

  group('MapHud', () {
    setUp(() async {
      await TestHelpers.initServices();
    });

    testWidgets('displays lives count', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapWidget(
          const MapHud(lives: 3, coins: 1000),
        ),
      );
      
      // Should show lives
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      
      tester.resetToDefaultScreenSize();
    });

    testWidgets('displays Full when lives are 5', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapWidget(
          const MapHud(lives: 5, coins: 1000),
        ),
      );
      
      expect(find.text('Full'), findsOneWidget);
      
      tester.resetToDefaultScreenSize();
    });

    testWidgets('displays formatted coins', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapWidget(
          const MapHud(lives: 5, coins: 1480),
        ),
      );
      
      expect(find.text('1.48k'), findsOneWidget);
      
      tester.resetToDefaultScreenSize();
    });

    testWidgets('has settings button', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapWidget(
          const MapHud(lives: 5, coins: 1000),
        ),
      );
      
      expect(find.byIcon(Icons.settings), findsOneWidget);
      
      tester.resetToDefaultScreenSize();
    });

    testWidgets('calls onSettingsTap when settings tapped', (tester) async {
      tester.setLargeScreenSize();
      
      bool tapped = false;
      
      await tester.pumpWidget(
        TestHelpers.wrapWidget(
          MapHud(
            lives: 5,
            coins: 1000,
            onSettingsTap: () => tapped = true,
          ),
        ),
      );
      
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();
      
      expect(tapped, isTrue);
      
      tester.resetToDefaultScreenSize();
    });
  });

  group('LevelNode', () {
    testWidgets('displays level number', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapWidget(
          const LevelNode(
            levelId: 5,
            isUnlocked: true,
          ),
        ),
      );
      
      expect(find.text('5'), findsOneWidget);
      
      tester.resetToDefaultScreenSize();
    });

    testWidgets('shows lock badge when locked', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapWidget(
          const LevelNode(
            levelId: 5,
            isUnlocked: false,
          ),
        ),
      );
      
      expect(find.byIcon(Icons.lock), findsOneWidget);
      
      tester.resetToDefaultScreenSize();
    });

    testWidgets('current level shows Level N button', (tester) async {
      tester.setLargeScreenSize();
      
      await tester.pumpWidget(
        TestHelpers.wrapWidget(
          const LevelNode(
            levelId: 3,
            isUnlocked: true,
            isCurrent: true,
          ),
        ),
      );
      
      expect(find.text('Level 3'), findsOneWidget);
      
      tester.resetToDefaultScreenSize();
    });

    testWidgets('calls onTap when unlocked and tapped', (tester) async {
      tester.setLargeScreenSize();
      
      bool tapped = false;
      
      await tester.pumpWidget(
        TestHelpers.wrapWidget(
          LevelNode(
            levelId: 5,
            isUnlocked: true,
            onTap: () => tapped = true,
          ),
        ),
      );
      
      await tester.tap(find.text('5'));
      await tester.pump();
      
      expect(tapped, isTrue);
      
      tester.resetToDefaultScreenSize();
    });

    testWidgets('does not call onTap when locked', (tester) async {
      tester.setLargeScreenSize();
      
      bool tapped = false;
      
      await tester.pumpWidget(
        TestHelpers.wrapWidget(
          LevelNode(
            levelId: 5,
            isUnlocked: false,
            onTap: () => tapped = true,
          ),
        ),
      );
      
      await tester.tap(find.text('5'));
      await tester.pump();
      
      expect(tapped, isFalse);
      
      tester.resetToDefaultScreenSize();
    });
  });
}

