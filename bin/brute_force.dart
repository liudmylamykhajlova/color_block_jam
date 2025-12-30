/// Brute-Force Analyzer CLI
/// 
/// Запуск: dart run bin/brute_force.dart [level_id]
/// 
/// Приклади:
///   dart run bin/brute_force.dart        - аналізувати всі рівні
///   dart run bin/brute_force.dart 15     - аналізувати рівень 15

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:color_block_jam/core/services/game_simulator.dart';
import 'package:color_block_jam/core/models/game_models.dart';

void main(List<String> args) async {
  // Ініціалізувати Flutter bindings для rootBundle
  WidgetsFlutterBinding.ensureInitialized();

  print('');
  print('🎮 Color Block Jam - Brute-Force Analyzer v1.0.0');
  print('');

  if (args.isEmpty) {
    // Аналізувати всі рівні
    await analyzeAllLevels();
  } else {
    // Аналізувати конкретний рівень
    final levelId = int.tryParse(args[0]);
    if (levelId == null) {
      print('❌ Invalid level ID: ${args[0]}');
      exit(1);
    }
    await analyzeSingleLevel(levelId);
  }
}

Future<void> analyzeAllLevels() async {
  print('📊 Analyzing all levels...');
  print('');

  final results = await BruteForceAnalyzer.analyzeAllLevels(
    maxStatesPerLevel: 50000,
    onProgress: (current, total, result) {
      final status = result.isSolvable ? '✅' : '❌';
      final moves = result.isSolvable ? '${result.minMoves} moves' : result.error ?? 'failed';
      print('[$current/$total] Level ${result.levelId}: $status $moves (${result.searchTime.inMilliseconds}ms)');
    },
  );

  BruteForceAnalyzer.printStatistics(results);

  // Зберегти результати у файл
  await saveResults(results);
}

Future<void> analyzeSingleLevel(int levelId) async {
  print('🔍 Analyzing level $levelId...');
  print('');

  final result = await BruteForceAnalyzer.analyzeLevel(levelId, maxStates: 100000);

  if (result.isSolvable) {
    print('✅ Level $levelId is SOLVABLE!');
    print('');
    print('Minimum moves: ${result.minMoves}');
    print('States explored: ${result.statesExplored}');
    print('Search time: ${result.searchTime.inMilliseconds}ms');
    print('');
    
    if (result.solution != null && result.solution!.isNotEmpty) {
      print('📋 Solution:');
      for (int i = 0; i < result.solution!.length; i++) {
        final move = result.solution![i];
        print('  ${i + 1}. Block ${move.blockIndex} → ${move.direction.name}');
      }
    }
  } else {
    print('❌ Level $levelId is UNSOLVABLE!');
    print('');
    print('Error: ${result.error}');
    print('States explored: ${result.statesExplored}');
    print('Search time: ${result.searchTime.inMilliseconds}ms');
  }
}

Future<void> saveResults(List<BruteForceResult> results) async {
  final buffer = StringBuffer();
  buffer.writeln('# Brute-Force Analysis Results');
  buffer.writeln('');
  buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
  buffer.writeln('');
  buffer.writeln('| Level | Solvable | Min Moves | States | Time (ms) | Error |');
  buffer.writeln('|-------|----------|-----------|--------|-----------|-------|');
  
  for (final r in results) {
    final solvable = r.isSolvable ? '✅' : '❌';
    final moves = r.minMoves?.toString() ?? '-';
    final error = r.error ?? '-';
    buffer.writeln('| ${r.levelId} | $solvable | $moves | ${r.statesExplored} | ${r.searchTime.inMilliseconds} | $error |');
  }

  buffer.writeln('');
  
  final solvable = results.where((r) => r.isSolvable).length;
  buffer.writeln('**Summary:** ${solvable}/${results.length} levels solvable');

  final file = File('brute_force_results.md');
  await file.writeAsString(buffer.toString());
  print('');
  print('📄 Results saved to: brute_force_results.md');
}

