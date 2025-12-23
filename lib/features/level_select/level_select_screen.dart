import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/models/game_models.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/audio_service.dart';
import '../game/game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  List<GameLevel>? _levels;
  Set<int> _completedLevels = {};
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    try {
      final levels = await LevelLoader.loadLevels();
      if (mounted) {
        setState(() {
          _levels = levels;
          _completedLevels = StorageService.getCompletedLevels();
          _isLoading = false;
        });
      }
    } on LevelLoadException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load levels';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryLight,
              AppColors.primary,
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
                      onPressed: () {
                        AudioService.playTap();
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
                    ),
                    Expanded(
                      child: Text(
                        'SELECT LEVEL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
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
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.textPrimary),
            const SizedBox(height: 16),
            Text(
              'Loading levels...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonGreen,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    return Padding(
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
          // TODO: Для тестування всі рівні відкриті
          final isUnlocked = true; // level.id == 1 || _completedLevels.contains(level.id - 1);
          
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
    );
  }
  
  void _openLevel(int levelId) {
    AudioService.playTap();
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
              ? (isCompleted ? AppColors.success : AppColors.textPrimary)
              : AppColors.textMuted,
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
                      ? (isCompleted ? AppColors.textPrimary : AppColors.primary)
                      : AppColors.textMuted,
                ),
              ),
            ),
            
            // Lock icon
            if (!isUnlocked)
              Center(
                child: Icon(
                  Icons.lock,
                  size: 40,
                  color: AppColors.textSecondary,
                ),
              ),
            
            // Completed star
            if (isCompleted)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

