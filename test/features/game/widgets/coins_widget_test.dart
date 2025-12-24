import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/features/game/widgets/coins_widget.dart';

void main() {
  group('CoinsWidget', () {
    testWidgets('displays coins count correctly for thousands', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CoinsWidget(coins: 1500),
          ),
        ),
      );
      
      expect(find.text('1.50k'), findsOneWidget);
    });
    
    testWidgets('displays small coin count without k suffix', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CoinsWidget(coins: 500),
          ),
        ),
      );
      
      expect(find.text('500'), findsOneWidget);
    });
    
    testWidgets('displays millions with M suffix', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CoinsWidget(coins: 1500000),
          ),
        ),
      );
      
      expect(find.text('1.50M'), findsOneWidget);
    });
    
    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoinsWidget(
              coins: 1000,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.byType(CoinsWidget));
      expect(tapped, true);
    });
    
    testWidgets('has plus icon for adding coins', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CoinsWidget(coins: 100),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
    
    testWidgets('displays zero coins correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CoinsWidget(coins: 0),
          ),
        ),
      );
      
      expect(find.text('0'), findsOneWidget);
    });
    
    testWidgets('formats edge case 1000 correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CoinsWidget(coins: 1000),
          ),
        ),
      );
      
      expect(find.text('1.00k'), findsOneWidget);
    });
  });
}
