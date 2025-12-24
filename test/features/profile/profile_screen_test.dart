import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:color_block_jam/core/services/storage_service.dart';
import 'package:color_block_jam/core/services/audio_service.dart';
import 'package:color_block_jam/features/profile/profile_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    AudioService.init();
  });
  
  group('ProfileScreen', () {
    testWidgets('displays Profile title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileScreen(),
          ),
        ),
      );
      
      expect(find.text('Profile'), findsOneWidget);
    });
    
    testWidgets('displays default player name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileScreen(),
          ),
        ),
      );
      
      expect(find.text('Player8659'), findsOneWidget);
    });
    
    testWidgets('has Avatar and Frame tabs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileScreen(),
          ),
        ),
      );
      
      expect(find.text('Avatar'), findsOneWidget);
      expect(find.text('Frame'), findsOneWidget);
    });
    
    testWidgets('has edit name button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileScreen(),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
    
    testWidgets('has close button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileScreen(),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
    
    testWidgets('can switch to Frame tab', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileScreen(),
          ),
        ),
      );
      
      await tester.tap(find.text('Frame'));
      await tester.pumpAndSettle();
      
      // Frame tab should now be selected
      // Verify frame grid is visible (contains person icons for frames)
      expect(find.byIcon(Icons.person), findsWidgets);
    });
    
    testWidgets('edit button opens name dialog', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileScreen(),
          ),
        ),
      );
      
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      
      expect(find.text('Edit Name'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });
    
    testWidgets('avatar grid is visible by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileScreen(),
          ),
        ),
      );
      
      // Default person icon for first avatar
      expect(find.byIcon(Icons.person), findsWidgets);
    });
  });
  
  group('AvatarData', () {
    test('creates with correct properties', () {
      const avatar = AvatarData(
        id: 'test',
        icon: Icons.person,
        backgroundColor: Colors.blue,
      );
      
      expect(avatar.id, 'test');
      expect(avatar.icon, Icons.person);
      expect(avatar.backgroundColor, Colors.blue);
    });
  });
  
  group('ProfileScreen.avatars', () {
    test('has 12 avatars', () {
      expect(ProfileScreen.avatars.length, 12);
    });
    
    test('all avatars have unique ids', () {
      final ids = ProfileScreen.avatars.map((a) => a.id).toSet();
      expect(ids.length, ProfileScreen.avatars.length);
    });
    
    test('first avatar has id avatar_1', () {
      expect(ProfileScreen.avatars.first.id, 'avatar_1');
    });
  });
}
