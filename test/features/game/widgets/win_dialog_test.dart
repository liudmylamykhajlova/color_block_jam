import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/features/game/widgets/win_dialog.dart';

void main() {
  group('WinDialog', () {
    testWidgets('displays level number', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WinDialog(levelId: 5),
          ),
        ),
      );
      
      expect(find.text('Level 5'), findsOneWidget);
    });
    
    testWidgets('displays LEVEL COMPLETE title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WinDialog(levelId: 1),
          ),
        ),
      );
      
      expect(find.text('LEVEL COMPLETE!'), findsOneWidget);
    });
    
    testWidgets('displays coins earned with plus sign', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WinDialog(levelId: 1, coinsEarned: 100),
          ),
        ),
      );
      
      expect(find.text('+100'), findsOneWidget);
    });
    
    testWidgets('displays 3 stars by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WinDialog(levelId: 1, stars: 3),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // 3 star icons
      expect(find.byIcon(Icons.star), findsNWidgets(3));
    });
    
    testWidgets('has Next Level button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WinDialog(levelId: 1),
          ),
        ),
      );
      
      expect(find.text('Next Level'), findsOneWidget);
    });
    
    testWidgets('has Replay button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WinDialog(levelId: 1),
          ),
        ),
      );
      
      expect(find.text('Replay'), findsOneWidget);
    });
    
    testWidgets('calls onNextLevel when Next Level tapped', (tester) async {
      bool nextTapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WinDialog(
              levelId: 1,
              onNextLevel: () => nextTapped = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.text('Next Level'));
      expect(nextTapped, true);
    });
    
    testWidgets('calls onReplay when Replay tapped', (tester) async {
      bool replayTapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WinDialog(
              levelId: 1,
              onReplay: () => replayTapped = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.text('Replay'));
      expect(replayTapped, true);
    });
    
    testWidgets('has close button that calls onHome', (tester) async {
      bool homeTapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WinDialog(
              levelId: 1,
              onHome: () => homeTapped = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.byIcon(Icons.close));
      expect(homeTapped, true);
    });
    
    testWidgets('default coins earned is 50', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WinDialog(levelId: 1),
          ),
        ),
      );
      
      expect(find.text('+50'), findsOneWidget);
    });
  });
}
