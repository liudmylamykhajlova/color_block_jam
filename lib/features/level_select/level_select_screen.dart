import 'package:flutter/material.dart';
import '../../core/models/game_models.dart';
import '../../core/services/storage_service.dart';
import '../game/game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  List<GameLevel>? _levels;
  Set<int> _completedLevels = {};
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final levels = await LevelLoader.loadLevels();
    setState(() {
      _levels = levels;
      _completedLevels = StorageService.getCompletedLevels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'SELECT LEVEL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance
                  ],
                ),
              ),
              
              // Levels Grid
              Expanded(
                child: _levels == null
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _levels!.length,
                          itemBuilder: (context, index) {
                            final level = _levels![index];
                            final isCompleted = _completedLevels.contains(level.id);
                            final isUnlocked = level.id == 1 || 
                                _completedLevels.contains(level.id - 1);
                            
                            return _LevelCard(
                              levelId: level.id,
                              isCompleted: isCompleted,
                              isUnlocked: isUnlocked,
                              onTap: isUnlocked
                                  ? () => _openLevel(level.id)
                                  : null,
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _openLevel(int levelId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          levelId: levelId,
          onLevelComplete: () {
            setState(() {
              _completedLevels = StorageService.getCompletedLevels();
            });
          },
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int levelId;
  final bool isCompleted;
  final bool isUnlocked;
  final VoidCallback? onTap;
  
  const _LevelCard({
    required this.levelId,
    required this.isCompleted,
    required this.isUnlocked,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isUnlocked
              ? (isCompleted ? const Color(0xFF4CAF50) : Colors.white)
              : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Level number
            Center(
              child: Text(
                '$levelId',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked
                      ? (isCompleted ? Colors.white : const Color(0xFF764ba2))
                      : Colors.white.withOpacity(0.5),
                ),
              ),
            ),
            
            // Lock icon
            if (!isUnlocked)
              const Center(
                child: Icon(
                  Icons.lock,
                  size: 40,
                  color: Colors.white54,
                ),
              ),
            
            // Completed star
            if (isCompleted)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

