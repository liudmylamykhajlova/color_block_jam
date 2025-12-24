import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/features/game/widgets/freeze_indicator.dart';

void main() {
  group('FreezeIndicator', () {
    testWidgets('renders when visible', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FreezeIndicator(
              remainingSeconds: 5,
              isVisible: true,
            ),
          ),
        ),
      );
      
      // Should show snowflake icon
      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
      // Should show remaining seconds
      expect(find.text('5'), findsOneWidget);
    });
    
    testWidgets('does not render when not visible', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FreezeIndicator(
              remainingSeconds: 5,
              isVisible: false,
            ),
          ),
        ),
      );
      
      // Should not show anything
      expect(find.byIcon(Icons.ac_unit), findsNothing);
      expect(find.text('5'), findsNothing);
    });
    
    testWidgets('displays correct remaining seconds', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FreezeIndicator(
              remainingSeconds: 3,
              isVisible: true,
            ),
          ),
        ),
      );
      
      expect(find.text('3'), findsOneWidget);
    });
    
    testWidgets('updates when remainingSeconds changes', (tester) async {
      int seconds = 5;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return FreezeIndicator(
                  remainingSeconds: seconds,
                  isVisible: true,
                );
              },
            ),
          ),
        ),
      );
      
      expect(find.text('5'), findsOneWidget);
      
      // Rebuild with new value
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FreezeIndicator(
              remainingSeconds: 2,
              isVisible: true,
            ),
          ),
        ),
      );
      
      expect(find.text('2'), findsOneWidget);
    });
    
    testWidgets('has pulse animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FreezeIndicator(
              remainingSeconds: 5,
              isVisible: true,
            ),
          ),
        ),
      );
      
      // Animation should be running - pump some frames
      await tester.pump(const Duration(milliseconds: 500));
      
      // Widget should still be there
      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
    });
    
    testWidgets('disposes animation controller properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FreezeIndicator(
              remainingSeconds: 5,
              isVisible: true,
            ),
          ),
        ),
      );
      
      // Pump some animation
      await tester.pump(const Duration(milliseconds: 100));
      
      // Remove widget - should not throw
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );
      
      // No error means dispose worked
      expect(tester.takeException(), isNull);
    });
    
    testWidgets('shows 0 seconds correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FreezeIndicator(
              remainingSeconds: 0,
              isVisible: true,
            ),
          ),
        ),
      );
      
      expect(find.text('0'), findsOneWidget);
    });
  });
}

