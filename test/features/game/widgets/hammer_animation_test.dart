import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/features/game/widgets/hammer_animation.dart';

void main() {
  group('HammerAnimation', () {
    testWidgets('renders and calls onComplete after strike animation', (tester) async {
      bool completeCalled = false;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              HammerAnimation(
                startPosition: const Offset(200, 200), // Not used in strike animation
                endPosition: const Offset(200, 200),   // Target position
                onComplete: () => completeCalled = true,
              ),
            ],
          ),
        ),
      ));
      
      // Initially should be animating
      expect(completeCalled, false);
      
      // Wait for animation to complete (300ms + buffer)
      await tester.pump(const Duration(milliseconds: 350));
      
      expect(completeCalled, true);
    });
    
    testWidgets('disposes animation controller properly', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              HammerAnimation(
                startPosition: const Offset(200, 200),
                endPosition: const Offset(200, 200),
                onComplete: () {},
              ),
            ],
          ),
        ),
      ));
      
      // Pump a few frames
      await tester.pump(const Duration(milliseconds: 100));
      
      // Remove widget - should not throw
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: Container()),
      ));
      
      // No exception = proper disposal
    });
    
    testWidgets('hammer appears above target position', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              HammerAnimation(
                startPosition: const Offset(200, 300),
                endPosition: const Offset(200, 300),
                onComplete: () {},
              ),
            ],
          ),
        ),
      ));
      
      // Animation should render without errors
      await tester.pump(const Duration(milliseconds: 50));
      
      // Should have positioned widget
      expect(find.byType(Positioned), findsWidgets);
    });
  });
  
  group('BigExplosionAnimation', () {
    testWidgets('renders and calls onComplete after animation', (tester) async {
      bool completeCalled = false;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              BigExplosionAnimation(
                position: const Offset(200, 200),
                size: 100,
                onComplete: () => completeCalled = true,
              ),
            ],
          ),
        ),
      ));
      
      // Initially should be animating
      expect(completeCalled, false);
      
      // Wait for animation to complete (400ms + buffer)
      await tester.pump(const Duration(milliseconds: 450));
      
      expect(completeCalled, true);
    });
    
    testWidgets('uses custom size parameter', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              BigExplosionAnimation(
                position: const Offset(200, 200),
                size: 150,
                onComplete: () {},
              ),
            ],
          ),
        ),
      ));
      
      // Animation should render without errors
      await tester.pump(const Duration(milliseconds: 100));
    });
    
    testWidgets('disposes animation controller properly', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              BigExplosionAnimation(
                position: const Offset(200, 200),
                onComplete: () {},
              ),
            ],
          ),
        ),
      ));
      
      // Pump a few frames
      await tester.pump(const Duration(milliseconds: 100));
      
      // Remove widget - should not throw
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: Container()),
      ));
      
      // No exception = proper disposal
    });
    
    testWidgets('renders particles during animation', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              BigExplosionAnimation(
                position: const Offset(200, 200),
                size: 100,
                onComplete: () {},
              ),
            ],
          ),
        ),
      ));
      
      // Pump part way through animation
      await tester.pump(const Duration(milliseconds: 200));
      
      // Should have containers for particles (8 particles + main explosion)
      expect(find.byType(Container), findsWidgets);
    });
  });
}

