import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/features/level_map/widgets/map_hud.dart';

void main() {
  group('MapHud', () {
    testWidgets('displays Full text when lives >= 5', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapHud(lives: 5, coins: 1000),
          ),
        ),
      );
      
      expect(find.text('Full'), findsOneWidget);
    });
    
    testWidgets('displays lives count when < 5', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapHud(lives: 3, coins: 1000),
          ),
        ),
      );
      
      expect(find.text('3'), findsOneWidget);
    });
    
    testWidgets('displays coins count formatted', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapHud(lives: 5, coins: 1500),
          ),
        ),
      );
      
      expect(find.text('1.50k'), findsOneWidget);
    });
    
    testWidgets('displays coins without k for small amounts', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapHud(lives: 5, coins: 500),
          ),
        ),
      );
      
      expect(find.text('500'), findsOneWidget);
    });
    
    testWidgets('has avatar button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapHud(lives: 5, coins: 1000),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
    
    testWidgets('has settings button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapHud(lives: 5, coins: 1000),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
    
    testWidgets('has heart icon for lives', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapHud(lives: 5, coins: 1000),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
    
    testWidgets('calls onAvatarTap when avatar tapped', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapHud(
              lives: 5,
              coins: 1000,
              onAvatarTap: () => tapped = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.byIcon(Icons.person));
      expect(tapped, true);
    });
    
    testWidgets('calls onSettingsTap when settings tapped', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapHud(
              lives: 5,
              coins: 1000,
              onSettingsTap: () => tapped = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.byIcon(Icons.settings));
      expect(tapped, true);
    });
    
    testWidgets('has plus buttons for lives and coins', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapHud(lives: 5, coins: 1000),
          ),
        ),
      );
      
      // Should have 2 plus icons (one for lives, one for coins)
      expect(find.byIcon(Icons.add), findsNWidgets(2));
    });
    
    testWidgets('displays million with M suffix', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapHud(lives: 5, coins: 1500000),
          ),
        ),
      );
      
      expect(find.text('1.50M'), findsOneWidget);
    });
    
    testWidgets('uses default lives of 5', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapHud(coins: 1000),
          ),
        ),
      );
      
      expect(find.text('Full'), findsOneWidget);
    });
    
    testWidgets('uses default coins of 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapHud(lives: 5),
          ),
        ),
      );
      
      expect(find.text('0'), findsOneWidget);
    });
  });
}
