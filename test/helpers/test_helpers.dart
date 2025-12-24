import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:color_block_jam/core/services/storage_service.dart';
import 'package:color_block_jam/core/services/audio_service.dart';

/// Test helpers to reduce code duplication across tests
class TestHelpers {
  TestHelpers._();
  
  /// Initialize mock services for testing
  static Future<void> initServices() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    AudioService.init();
  }
  
  /// Wrap a widget in MaterialApp and Scaffold for testing
  static Widget wrapWidget(Widget widget) {
    return MaterialApp(
      home: Scaffold(
        body: widget,
      ),
    );
  }
  
  /// Wrap a widget in MaterialApp only (for full-screen widgets)
  static Widget wrapScreen(Widget widget) {
    return MaterialApp(
      home: widget,
    );
  }
  
  /// Pump widget with services initialized
  static Future<void> pumpWidgetWithServices(
    WidgetTester tester,
    Widget widget,
  ) async {
    await initServices();
    await tester.pumpWidget(wrapWidget(widget));
  }
  
  /// Pump screen with services initialized  
  static Future<void> pumpScreenWithServices(
    WidgetTester tester,
    Widget widget,
  ) async {
    await initServices();
    await tester.pumpWidget(wrapScreen(widget));
  }
  
  /// Set screen size for testing (useful for overflow issues)
  static void setScreenSize(WidgetTester tester, {
    double width = 800,
    double height = 1200,
  }) {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
  }
  
  /// Reset screen size after test
  static void resetScreenSize(WidgetTester tester) {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }
  
  /// Pump and allow animations to complete
  static Future<void> pumpAndSettle(
    WidgetTester tester, {
    Duration? duration,
  }) async {
    if (duration != null) {
      await tester.pump(duration);
    }
    await tester.pumpAndSettle();
  }
}

/// Extension on WidgetTester for common operations
extension WidgetTesterExtensions on WidgetTester {
  /// Tap and pump until settled
  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }
  
  /// Enter text and pump until settled
  Future<void> enterTextAndSettle(Finder finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }
  
  /// Set large screen size for testing
  void setLargeScreenSize() {
    view.physicalSize = const Size(800, 1200);
    view.devicePixelRatio = 1.0;
  }
  
  /// Reset screen size to default
  void resetToDefaultScreenSize() {
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  }
}

