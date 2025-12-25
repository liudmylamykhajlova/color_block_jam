import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/features/game/widgets/hammer_overlay.dart';

void main() {
  group('HammerOverlay', () {
    Widget buildOverlay({
      bool isActive = false,
      VoidCallback? onCancel,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              // Background content
              Container(
                color: Colors.blue,
                width: 300,
                height: 300,
              ),
              // Hammer overlay tooltip
              HammerOverlay(
                isActive: isActive,
                onCancel: onCancel,
              ),
            ],
          ),
        ),
      );
    }
    
    testWidgets('does not render when inactive', (tester) async {
      await tester.pumpWidget(buildOverlay(isActive: false));
      
      // Tooltip should NOT be visible
      expect(find.text('HAMMER'), findsNothing);
    });
    
    testWidgets('shows tooltip when active', (tester) async {
      await tester.pumpWidget(buildOverlay(isActive: true));
      
      // Tooltip should be visible
      expect(find.text('HAMMER'), findsOneWidget);
      expect(find.text('Tap any block to destroy it!'), findsOneWidget);
    });
    
    testWidgets('shows hammer icon when active', (tester) async {
      await tester.pumpWidget(buildOverlay(isActive: true));
      
      // Hammer icon should be visible
      expect(find.byIcon(Icons.gavel), findsOneWidget);
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
    
    testWidgets('tooltip has correct styling', (tester) async {
      await tester.pumpWidget(buildOverlay(isActive: true));
      
      // Find the tooltip container
      final tooltipFinder = find.ancestor(
        of: find.text('HAMMER'),
        matching: find.byType(Container),
      );
      
      expect(tooltipFinder, findsWidgets);
    });
    
    testWidgets('transitions from inactive to active', (tester) async {
      // Start inactive
      await tester.pumpWidget(buildOverlay(isActive: false));
      expect(find.text('HAMMER'), findsNothing);
      
      // Activate
      await tester.pumpWidget(buildOverlay(isActive: true));
      expect(find.text('HAMMER'), findsOneWidget);
    });
    
    testWidgets('transitions from active to inactive', (tester) async {
      // Start active
      await tester.pumpWidget(buildOverlay(isActive: true));
      expect(find.text('HAMMER'), findsOneWidget);
      
      // Deactivate
      await tester.pumpWidget(buildOverlay(isActive: false));
      expect(find.text('HAMMER'), findsNothing);
    });
  });
}

