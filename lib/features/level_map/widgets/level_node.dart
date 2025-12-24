import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Types of level nodes
enum LevelNodeType {
  normal,   // Green
  hard,     // Red with skull
  boss,     // Purple with skull
}

/// A single level node on the map
class LevelNode extends StatelessWidget {
  final int levelId;
  final bool isCompleted;
  final bool isUnlocked;
  final bool isCurrent;
  final LevelNodeType type;
  final VoidCallback? onTap;
  
  const LevelNode({
    super.key,
    required this.levelId,
    this.isCompleted = false,
    this.isUnlocked = false,
    this.isCurrent = false,
    this.type = LevelNodeType.normal,
    this.onTap,
  });

  Color get _backgroundColor {
    if (!isUnlocked) return AppColors.levelLocked;
    
    switch (type) {
      case LevelNodeType.normal:
        return isCompleted 
            ? AppColors.levelCompleted
            : AppColors.levelUnlocked;
      case LevelNodeType.hard:
        return AppColors.levelHard;
      case LevelNodeType.boss:
        return AppColors.levelBoss;
    }
  }
  
  Color get _borderColor {
    if (!isUnlocked) return AppColors.levelLocked.withOpacity(0.8);
    
    switch (type) {
      case LevelNodeType.normal:
        return AppColors.levelCompleted.withOpacity(0.9);
      case LevelNodeType.hard:
        return AppColors.levelHard.withOpacity(0.9);
      case LevelNodeType.boss:
        return AppColors.levelBoss.withOpacity(0.9);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Skull badge for hard/boss levels
        if ((type == LevelNodeType.hard || type == LevelNodeType.boss) && isUnlocked)
          _buildSkullBadge(),
        
        // Main node
        GestureDetector(
          onTap: isUnlocked ? onTap : null,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Node body
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _borderColor,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    if (isCurrent)
                      BoxShadow(
                        color: AppColors.buttonGreen.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$levelId',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Lock icon for locked levels
              if (!isUnlocked)
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: _buildLockBadge(),
                ),
              
              // Star for completed levels
              if (isCompleted)
                Positioned(
                  right: -4,
                  top: -4,
                  child: _buildStarBadge(),
                ),
            ],
          ),
        ),
        
        // Current level label
        if (isCurrent)
          _buildCurrentLabel(),
      ],
    );
  }
  
  Widget _buildSkullBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: type == LevelNodeType.boss 
            ? Colors.purple.shade700
            : Colors.red.shade700,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.dangerous,
        color: Colors.white,
        size: 16,
      ),
    );
  }
  
  Widget _buildLockBadge() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.amber,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.orange.shade700, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
          ),
        ],
      ),
      child: const Icon(
        Icons.lock,
        color: Colors.white,
        size: 16,
      ),
    );
  }
  
  Widget _buildStarBadge() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.gold,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.orange.shade700, width: 2),
      ),
      child: const Icon(
        Icons.star,
        color: Colors.white,
        size: 14,
      ),
    );
  }
  
  Widget _buildCurrentLabel() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.buttonGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonGreen.withOpacity(0.5),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        'Level $levelId',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

