import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/features/game/widgets/win_dialog.dart';

void main() {
  group('WinDialog', () {
    // Helper to pump widget with enough time for animations
    Future<void> pumpWinDialog(WidgetTester tester, {
      int levelId = 1,
      int coinsEarned = 50,
      int stars = 3,
      VoidCallback? onNextLevel,
      VoidCallback? onReplay,
      VoidCallback? onHome,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WinDialog(
              levelId: levelId,
              coinsEarned: coinsEarned,
              stars: stars,
              onNextLevel: onNextLevel,
              onReplay: onReplay,
              onHome: onHome,
            ),
          ),
        ),
      );
      // Allow animations to complete
      await tester.pump(const Duration(seconds: 1));
    }
    
    testWidgets('displays level number', (tester) async {
      await pumpWinDialog(tester, levelId: 5);
      expect(find.text('Level 5'), findsOneWidget);
    });
    
    testWidgets('displays LEVEL COMPLETE title', (tester) async {
      await pumpWinDialog(tester);
      expect(find.text('LEVEL COMPLETE!'), findsOneWidget);
    });
    
    testWidgets('displays coins earned with plus sign', (tester) async {
      await pumpWinDialog(tester, coinsEarned: 100);
      expect(find.text('+100'), findsOneWidget);
    });
    
    testWidgets('displays 3 stars', (tester) async {
      await pumpWinDialog(tester, stars: 3);
      // 3 star icons
      expect(find.byIcon(Icons.star), findsNWidgets(3));
    });
    
    testWidgets('has Next Level button', (tester) async {
      await pumpWinDialog(tester);
      expect(find.text('Next Level'), findsOneWidget);
    });
    
    testWidgets('has Replay button', (tester) async {
      await pumpWinDialog(tester);
      expect(find.text('Replay'), findsOneWidget);
    });
    
    testWidgets('calls onNextLevel when Next Level tapped', (tester) async {
      bool nextTapped = false;
      await pumpWinDialog(tester, onNextLevel: () => nextTapped = true);
      
      await tester.tap(find.text('Next Level'));
      expect(nextTapped, true);
    });
    
    testWidgets('calls onReplay when Replay tapped', (tester) async {
      bool replayTapped = false;
      await pumpWinDialog(tester, onReplay: () => replayTapped = true);
      
      await tester.tap(find.text('Replay'));
      expect(replayTapped, true);
    });
    
    testWidgets('has close button that calls onHome', (tester) async {
      bool homeTapped = false;
      await pumpWinDialog(tester, onHome: () => homeTapped = true);
      
      await tester.tap(find.byIcon(Icons.close));
      expect(homeTapped, true);
    });
    
    testWidgets('default coins earned is 50', (tester) async {
      await pumpWinDialog(tester);
      expect(find.text('+50'), findsOneWidget);
    });
  });
}
