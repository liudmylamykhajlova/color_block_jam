import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:color_block_jam/core/services/storage_service.dart';
import 'package:color_block_jam/core/services/audio_service.dart';
import 'package:color_block_jam/features/shop/shop_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    AudioService.init();
  });
  
  group('ShopScreen', () {
    testWidgets('displays Shop title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ShopScreen(),
        ),
      );
      
      expect(find.text('Shop'), findsOneWidget);
    });
    
    testWidgets('displays Coins section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ShopScreen(),
        ),
      );
      
      expect(find.text('Coins'), findsOneWidget);
    });
    
    testWidgets('displays Bundles section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ShopScreen(),
        ),
      );
      
      expect(find.text('Bundles'), findsOneWidget);
    });
    
    testWidgets('displays 6 coin packs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ShopScreen(),
        ),
      );
      
      // Check for coin amounts (formatted as "X 000")
      expect(find.text('1 000'), findsOneWidget);
      expect(find.text('5 000'), findsOneWidget);
      expect(find.text('10 000'), findsOneWidget);
      expect(find.text('25 000'), findsOneWidget);
      expect(find.text('50 000'), findsOneWidget);
      expect(find.text('100 000'), findsOneWidget);
    });
    
    testWidgets('displays No Ads bundle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ShopScreen(),
        ),
      );
      
      expect(find.textContaining('Remove interstitial'), findsOneWidget);
    });
    
    testWidgets('has back button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ShopScreen(),
        ),
      );
      
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });
  });
  
  group('ShopItem', () {
    test('creates with correct properties', () {
      const item = ShopItem(
        id: 'test',
        coins: 1000,
        price: 99.99,
        currency: 'USD',
      );
      
      expect(item.id, 'test');
      expect(item.coins, 1000);
      expect(item.price, 99.99);
      expect(item.currency, 'USD');
      expect(item.isBestValue, false);
    });
    
    test('can be marked as best value', () {
      const item = ShopItem(
        id: 'test',
        coins: 25000,
        price: 99.99,
        isBestValue: true,
      );
      
      expect(item.isBestValue, true);
    });
    
    test('default currency is UAH', () {
      const item = ShopItem(
        id: 'test',
        coins: 1000,
        price: 79.99,
      );
      
      expect(item.currency, 'UAH');
    });
  });
  
  group('ShopScreen.coinPacks', () {
    test('has 6 coin packs', () {
      expect(ShopScreen.coinPacks.length, 6);
    });
    
    test('coin packs are in ascending order', () {
      final coins = ShopScreen.coinPacks.map((p) => p.coins).toList();
      for (int i = 1; i < coins.length; i++) {
        expect(coins[i], greaterThan(coins[i - 1]));
      }
    });
    
    test('prices are in UAH by default', () {
      for (final pack in ShopScreen.coinPacks) {
        expect(pack.currency, 'UAH');
      }
    });
    
    test('25k pack is marked as best value', () {
      final bestValue = ShopScreen.coinPacks.firstWhere(
        (p) => p.coins == 25000,
      );
      expect(bestValue.isBestValue, true);
    });
  });
  
  group('RemoveAdsDialog', () {
    testWidgets('displays REMOVE ADS title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RemoveAdsDialog(),
          ),
        ),
      );
      
      expect(find.text('REMOVE ADS'), findsOneWidget);
    });
    
    testWidgets('displays 3 benefits', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RemoveAdsDialog(),
          ),
        ),
      );
      
      expect(find.text('Remove obligatory ads'), findsOneWidget);
      expect(find.text('Remove bottom banner ads'), findsOneWidget);
      expect(find.text('Keep optional ads for rewards'), findsOneWidget);
    });
    
    testWidgets('displays price button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RemoveAdsDialog(),
          ),
        ),
      );
      
      expect(find.text('284,99 UAH'), findsOneWidget);
    });
    
    testWidgets('has close button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RemoveAdsDialog(),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
    
    testWidgets('shows TV icon for obligatory ads', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RemoveAdsDialog(),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.tv), findsOneWidget);
    });
    
    testWidgets('shows smartphone icon for banner ads', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RemoveAdsDialog(),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.smartphone), findsOneWidget);
    });
  });
}
