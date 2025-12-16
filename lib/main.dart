import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/services/storage_service.dart';
import 'core/services/audio_service.dart';
import 'features/menu/menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize services
  await StorageService.init();
  AudioService.init();
  
  runApp(const ColorBlockJamApp());
}

class ColorBlockJamApp extends StatelessWidget {
  const ColorBlockJamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Block Jam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF764ba2),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MenuScreen(),
    );
  }
}
