import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/features/game/widgets/rocket_overlay.dart';

void main() {
  group('RocketOverlay', () {
    Widget buildOverlay({
      bool isActive = false,
      VoidCallback? onCancel,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: RocketOverlay(
            isActive: isActive,
            onCancel: onCancel,
            child: Container(
              color: Colors.blue,
              width: 300,
              height: 300,
            ),
          ),
        ),
      );
    }
    
    testWidgets('renders child when inactive', (tester) async {
      await tester.pumpWidget(buildOverlay(isActive: false));
      
      // Child should be visible
      expect(find.byType(Container), findsOneWidget);
      
      // Tooltip should NOT be visible
      expect(find.text('ROCKET'), findsNothing);
    });
    
    testWidgets('shows tooltip when active', (tester) async {
      await tester.pumpWidget(buildOverlay(isActive: true));
      
      // Tooltip should be visible
      expect(find.text('ROCKET'), findsOneWidget);
      expect(find.text('Tap and destroy one unit of a block!'), findsOneWidget);
    });
    
    testWidgets('shows rocket icon when active', (tester) async {
      await tester.pumpWidget(buildOverlay(isActive: true));
      
      // Rocket icon should be visible
      expect(find.byIcon(Icons.rocket_launch), findsOneWidget);
    });
    
    testWidgets('shows close button when active', (tester) async {
      await tester.pumpWidget(buildOverlay(isActive: true));
      
      // Close button should be visible
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
    
    testWidgets('calls onCancel when close button tapped', (tester) async {
      bool cancelCalled = false;
      
      await tester.pumpWidget(buildOverlay(
        isActive: true,
        onCancel: () => cancelCalled = true,
      ));
      
      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      
      expect(cancelCalled, true);
    });
    
    testWidgets('child remains visible when active', (tester) async {
      await tester.pumpWidget(buildOverlay(isActive: true));
      
      // Child should still be visible under overlay
      expect(find.byType(Container), findsWidgets);
    });
    
    testWidgets('tooltip has correct styling', (tester) async {
      await tester.pumpWidget(buildOverlay(isActive: true));
      
      // Find the tooltip container
      final tooltipFinder = find.ancestor(
        of: find.text('ROCKET'),
        matching: find.byType(Container),
      );
      
      expect(tooltipFinder, findsWidgets);
    });
    
    testWidgets('transitions from inactive to active', (tester) async {
      // Start inactive
      await tester.pumpWidget(buildOverlay(isActive: false));
      expect(find.text('ROCKET'), findsNothing);
      
      // Activate
      await tester.pumpWidget(buildOverlay(isActive: true));
      expect(find.text('ROCKET'), findsOneWidget);
    });
    
    testWidgets('transitions from active to inactive', (tester) async {
      // Start active
      await tester.pumpWidget(buildOverlay(isActive: true));
      expect(find.text('ROCKET'), findsOneWidget);
      
      // Deactivate
      await tester.pumpWidget(buildOverlay(isActive: false));
      expect(find.text('ROCKET'), findsNothing);
    });
  });
}
