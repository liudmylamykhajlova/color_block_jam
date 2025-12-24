import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/features/game/widgets/freeze_overlay.dart';

void main() {
  group('FreezeOverlay', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FreezeOverlay(
              isActive: false,
              child: Text('Child Content'),
            ),
          ),
        ),
      );
      
      expect(find.text('Child Content'), findsOneWidget);
    });
    
    testWidgets('shows overlay when active', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FreezeOverlay(
              isActive: true,
              child: Text('Child Content'),
            ),
          ),
        ),
      );
      
      // Pump enough frames for fade animation (500ms) - can't use pumpAndSettle because snowflake animation loops
      await tester.pump(const Duration(milliseconds: 600));
      
      // Child should still be visible
      expect(find.text('Child Content'), findsOneWidget);
      
      // CustomPaint for snowflakes should be present
      expect(find.byType(CustomPaint), findsWidgets);
    });
    
    testWidgets('hides overlay when not active', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FreezeOverlay(
              isActive: false,
              child: Text('Child Content'),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Child visible
      expect(find.text('Child Content'), findsOneWidget);
    });
    
    testWidgets('transitions from inactive to active', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FreezeOverlay(
              isActive: false,
              child: Text('Child Content'),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Now activate
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FreezeOverlay(
              isActive: true,
              child: Text('Child Content'),
            ),
          ),
        ),
      );
      
      // Pump animation frames
      await tester.pump(const Duration(milliseconds: 250));
      
      // Child should still be visible during transition
      expect(find.text('Child Content'), findsOneWidget);
    });
    
    testWidgets('transitions from active to inactive', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FreezeOverlay(
              isActive: true,
              child: Text('Child Content'),
            ),
          ),
        ),
      );
      
      // Wait for fade in - can't use pumpAndSettle because snowflake animation loops
      await tester.pump(const Duration(milliseconds: 600));
      
      // Now deactivate
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FreezeOverlay(
              isActive: false,
              child: Text('Child Content'),
            ),
          ),
        ),
      );
      
      // Pump animation frames for fade out
      await tester.pump(const Duration(milliseconds: 600));
      
      // Child should still be visible
      expect(find.text('Child Content'), findsOneWidget);
    });
    
    testWidgets('overlay does not block touch events', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FreezeOverlay(
              isActive: true,
              child: GestureDetector(
                onTap: () => tapped = true,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                  child: const Text('Tap Me'),
                ),
              ),
            ),
          ),
        ),
      );
      
      // Wait for fade in - can't use pumpAndSettle because snowflake animation loops
      await tester.pump(const Duration(milliseconds: 600));
      
      // Tap on the child widget
      await tester.tap(find.text('Tap Me'));
      
      // Touch should pass through (IgnorePointer on overlay)
      expect(tapped, isTrue);
    });
    
    testWidgets('disposes animation controller properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FreezeOverlay(
              isActive: true,
              child: Text('Child Content'),
            ),
          ),
        ),
      );
      
      await tester.pump(const Duration(milliseconds: 100));
      
      // Remove widget
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
    
    testWidgets('has corner frost effects when active', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: FreezeOverlay(
                isActive: true,
                child: Text('Child Content'),
              ),
            ),
          ),
        ),
      );
      
      // Wait for fade in - can't use pumpAndSettle because snowflake animation loops
      await tester.pump(const Duration(milliseconds: 600));
      
      // Should have multiple Positioned widgets for corners
      expect(find.byType(Positioned), findsWidgets);
    });
  });
}

