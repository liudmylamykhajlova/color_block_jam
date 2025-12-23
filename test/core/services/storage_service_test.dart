import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:color_block_jam/core/services/storage_service.dart';
import 'package:color_block_jam/core/constants/app_constants.dart';

void main() {
  group('StorageService', () {
    setUp(() async {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      await StorageService.init();
    });
    
    group('initialization', () {
      test('isInitialized returns true after init', () {
        expect(StorageService.isInitialized, true);
      });
    });
    
    group('level progress', () {
      test('getCompletedLevels returns empty set initially', () {
        final completed = StorageService.getCompletedLevels();
        expect(completed, isEmpty);
      });
      
      test('markLevelCompleted adds level to completed set', () async {
        await StorageService.markLevelCompleted(1);
        await StorageService.markLevelCompleted(2);
        
        final completed = StorageService.getCompletedLevels();
        expect(completed, contains(1));
        expect(completed, contains(2));
        expect(completed.length, 2);
      });
      
      test('getCurrentLevel returns 1 initially', () {
        expect(StorageService.getCurrentLevel(), 1);
      });
      
      test('setCurrentLevel updates current level', () async {
        await StorageService.setCurrentLevel(5);
        expect(StorageService.getCurrentLevel(), 5);
      });
      
      test('isLevelUnlocked returns true for level 1', () {
        expect(StorageService.isLevelUnlocked(1), true);
      });
      
      test('isLevelUnlocked returns false for level 2 initially', () {
        expect(StorageService.isLevelUnlocked(2), false);
      });
      
      test('isLevelUnlocked returns true after completing previous', () async {
        await StorageService.markLevelCompleted(1);
        expect(StorageService.isLevelUnlocked(2), true);
      });
      
      test('getMaxUnlockedLevel returns 1 initially', () {
        expect(StorageService.getMaxUnlockedLevel(), 1);
      });
      
      test('getMaxUnlockedLevel increases after completion', () async {
        await StorageService.markLevelCompleted(1);
        await StorageService.markLevelCompleted(2);
        expect(StorageService.getMaxUnlockedLevel(), 3);
      });
    });
    
    group('settings', () {
      test('sound is enabled by default', () {
        expect(StorageService.getSoundEnabled(), true);
      });
      
      test('setSoundEnabled persists value', () async {
        await StorageService.setSoundEnabled(false);
        expect(StorageService.getSoundEnabled(), false);
        
        await StorageService.setSoundEnabled(true);
        expect(StorageService.getSoundEnabled(), true);
      });
      
      test('music is enabled by default', () {
        expect(StorageService.getMusicEnabled(), true);
      });
      
      test('setMusicEnabled persists value', () async {
        await StorageService.setMusicEnabled(false);
        expect(StorageService.getMusicEnabled(), false);
      });
      
      test('haptic is disabled by default', () {
        expect(StorageService.getHapticEnabled(), false);
      });
      
      test('setHapticEnabled persists value', () async {
        await StorageService.setHapticEnabled(true);
        expect(StorageService.getHapticEnabled(), true);
      });
    });
    
    group('lives system', () {
      test('getLives returns maxLives initially', () {
        expect(StorageService.getLives(), AppConstants.maxLives);
      });
      
      test('loseLife decrements lives', () async {
        await StorageService.loseLife();
        expect(StorageService.getLives(), AppConstants.maxLives - 1);
      });
      
      test('addLife increments lives', () async {
        await StorageService.loseLife();
        await StorageService.loseLife();
        await StorageService.addLife();
        expect(StorageService.getLives(), AppConstants.maxLives - 1);
      });
      
      test('lives cannot exceed maxLives', () async {
        await StorageService.addLife(10);
        expect(StorageService.getLives(), AppConstants.maxLives);
      });
      
      test('lives cannot go below 0', () async {
        for (int i = 0; i < 10; i++) {
          await StorageService.loseLife();
        }
        expect(StorageService.getLives(), greaterThanOrEqualTo(0));
      });
      
      test('hasLives returns true when lives > 0', () {
        expect(StorageService.hasLives(), true);
      });
      
      test('refillLives restores to max', () async {
        await StorageService.loseLife();
        await StorageService.loseLife();
        await StorageService.refillLives();
        expect(StorageService.getLives(), AppConstants.maxLives);
      });
      
      test('getTimeUntilNextLife returns Full when at max', () {
        expect(StorageService.getTimeUntilNextLife(), 'Full');
      });
    });
    
    group('reset', () {
      test('resetProgress clears all data', () async {
        await StorageService.markLevelCompleted(1);
        await StorageService.markLevelCompleted(2);
        await StorageService.setCurrentLevel(5);
        await StorageService.loseLife();
        
        await StorageService.resetProgress();
        
        expect(StorageService.getCompletedLevels(), isEmpty);
        expect(StorageService.getCurrentLevel(), 1);
        expect(StorageService.getLives(), AppConstants.maxLives);
      });
    });
  });
}


