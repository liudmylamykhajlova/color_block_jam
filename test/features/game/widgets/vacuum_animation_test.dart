import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/features/game/widgets/vacuum_animation.dart';

void main() {
  group('VacuumAnimationController', () {
    test('can be created', () {
      final controller = VacuumAnimationController();
      expect(controller, isNotNull);
    });
  });
  
  group('VacuumAnimationOverlay', () {
    testWidgets('renders nothing when not animating', (tester) async {
      final controller = VacuumAnimationController();
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              VacuumAnimationOverlay(
                controller: controller,
                onComplete: () {},
              ),
            ],
          ),
        ),
      ));
      
      // Should render SizedBox.shrink when not animating
      expect(find.byType(SizedBox), findsOneWidget);
    });
    
    testWidgets('calls onComplete after animation', (tester) async {
      bool completeCalled = false;
      final controller = VacuumAnimationController();
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              VacuumAnimationOverlay(
                controller: controller,
                onComplete: () => completeCalled = true,
              ),
            ],
          ),
        ),
      ));
      
      // Start vacuum animation
      controller.startVacuum(
        [const Rect.fromLTWH(100, 100, 50, 50)],
        [Colors.red],
      );
      
      await tester.pump();
      expect(completeCalled, false);
      
      // Wait for animation to complete (400ms + buffer)
      await tester.pump(const Duration(milliseconds: 450));
      
      expect(completeCalled, true);
    });
    
    testWidgets('can vacuum multiple blocks', (tester) async {
      bool completeCalled = false;
      final controller = VacuumAnimationController();
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              VacuumAnimationOverlay(
                controller: controller,
                onComplete: () => completeCalled = true,
              ),
            ],
          ),
        ),
      ));
      
      // Start vacuum animation with multiple blocks
      controller.startVacuum(
        [
          const Rect.fromLTWH(100, 100, 50, 50),
          const Rect.fromLTWH(200, 100, 50, 50),
          const Rect.fromLTWH(300, 100, 50, 50),
        ],
        [Colors.red, Colors.red, Colors.red],
      );
      
      await tester.pump();
      
      // Animation should be running
      await tester.pump(const Duration(milliseconds: 200));
      
      // Wait for completion
      await tester.pump(const Duration(milliseconds: 300));
      
      expect(completeCalled, true);
    });
    
    testWidgets('disposes properly', (tester) async {
      final controller = VacuumAnimationController();
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              VacuumAnimationOverlay(
                controller: controller,
                onComplete: () {},
              ),
            ],
          ),
        ),
      ));
      
      // Start animation
      controller.startVacuum(
        [const Rect.fromLTWH(100, 100, 50, 50)],
        [Colors.red],
      );
      
      await tester.pump(const Duration(milliseconds: 100));
      
      // Remove widget - should not throw
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: Container()),
      ));
      
      // No exception = proper disposal
    });
  });
  
}

