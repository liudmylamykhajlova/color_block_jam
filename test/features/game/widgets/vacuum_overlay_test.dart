import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:color_block_jam/features/game/widgets/vacuum_overlay.dart';

void main() {
  group('VacuumOverlay', () {
    Widget buildOverlay({
      bool isActive = false,
      VoidCallback? onCancel,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Container(
                color: Colors.blue,
                width: 300,
                height: 300,
              ),
              VacuumOverlay(
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
      
      expect(find.text('VACUUM'), findsNothing);
    });
    
    testWidgets('shows tooltip when active', (tester) async {
      await tester.pumpWidget(buildOverlay(isActive: true));
      
      expect(find.text('VACUUM'), findsOneWidget);
      expect(find.text('Tap and vacuum blocks with the same color!'), findsOneWidget);
    });
    
    testWidgets('shows vacuum icon when active', (tester) async {
      await tester.pumpWidget(buildOverlay(isActive: true));
      
      expect(find.byIcon(Icons.cleaning_services), findsOneWidget);
    });
    
    testWidgets('shows close button when active', (tester) async {
      await tester.pumpWidget(buildOverlay(isActive: true));
      
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
    
    testWidgets('calls onCancel when close button tapped', (tester) async {
      bool cancelCalled = false;
      
      await tester.pumpWidget(buildOverlay(
        isActive: true,
        onCancel: () => cancelCalled = true,
      ));
      
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      
      expect(cancelCalled, true);
    });
    
    testWidgets('transitions from inactive to active', (tester) async {
      await tester.pumpWidget(buildOverlay(isActive: false));
      expect(find.text('VACUUM'), findsNothing);
      
      await tester.pumpWidget(buildOverlay(isActive: true));
      expect(find.text('VACUUM'), findsOneWidget);
    });
    
    testWidgets('transitions from active to inactive', (tester) async {
      await tester.pumpWidget(buildOverlay(isActive: true));
      expect(find.text('VACUUM'), findsOneWidget);
      
      await tester.pumpWidget(buildOverlay(isActive: false));
      expect(find.text('VACUUM'), findsNothing);
    });
  });
}




