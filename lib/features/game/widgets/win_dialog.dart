import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Animation timing constants for WinDialog
class _WinDialogAnimations {
  static const Duration starAnimationDuration = Duration(milliseconds: 400);
  static const Duration starInitialDelay = Duration(milliseconds: 200);
  static const Duration starStaggerDelay = Duration(milliseconds: 200);
}

/// Win dialog shown after completing a level
class WinDialog extends StatefulWidget {
  final int levelId;
  final int coinsEarned;
  final int stars; // 1-3 stars based on performance
  final VoidCallback? onNextLevel;
  final VoidCallback? onReplay;
  final VoidCallback? onHome;
  
  const WinDialog({
    super.key,
    required this.levelId,
    this.coinsEarned = 50,
    this.stars = 3,
    this.onNextLevel,
    this.onReplay,
    this.onHome,
  });

  @override
  State<WinDialog> createState() => _WinDialogState();
}

class _WinDialogState extends State<WinDialog> with TickerProviderStateMixin {
  late List<AnimationController> _starControllers;
  late List<Animation<double>> _starAnimations;
  final List<Timer> _starTimers = [];
  
  @override
  void initState() {
    super.initState();
    
    // Create staggered star animations
    _starControllers = List.generate(3, (i) => AnimationController(
      duration: _WinDialogAnimations.starAnimationDuration,
      vsync: this,
    ));
    
    _starAnimations = _starControllers.map((c) => CurvedAnimation(
      parent: c,
      curve: Curves.elasticOut,
    )).toList();
    
    // Start animations with cancellable timers
    _startStarAnimations();
  }
  
  void _startStarAnimations() {
    for (int i = 0; i < widget.stars && i < 3; i++) {
      final delay = _WinDialogAnimations.starInitialDelay + 
          _WinDialogAnimations.starStaggerDelay * i;
      
      final timer = Timer(delay, () {
        if (mounted) {
          _starControllers[i].forward();
        }
      });
      _starTimers.add(timer);
    }
  }
  
  @override
  void dispose() {
    // Cancel all pending timers to prevent memory leaks
    for (final timer in _starTimers) {
      timer.cancel();
    }
    _starTimers.clear();
    
    // Dispose animation controllers
    for (final controller in _starControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.dialogGradientLight,
              AppColors.dialogGradientDark,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            _buildHeader(),
            
            // Stars
            _buildStars(),
            
            const SizedBox(height: 16),
            
            // Coins earned
            _buildCoinsEarned(),
            
            const SizedBox(height: 24),
            
            // Buttons
            _buildButtons(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Stack(
      children: [
        // Title banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const Text(
                'LEVEL COMPLETE!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Level ${widget.levelId}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        // Close button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: widget.onHome,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.buttonRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStars() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final isEarned = i < widget.stars;
          
          return AnimatedBuilder(
            animation: _starAnimations[i],
            builder: (context, child) {
              return Transform.scale(
                scale: isEarned ? _starAnimations[i].value : 0.8,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: i == 1 ? 0 : 16, // Middle star higher
                  ),
                  child: Icon(
                    Icons.star,
                    size: i == 1 ? 64 : 52, // Middle star bigger
                    color: isEarned 
                        ? AppColors.gold
                        : Colors.white.withOpacity(0.3),
                    shadows: isEarned ? [
                      Shadow(
                        color: AppColors.gold.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ] : null,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
  
  Widget _buildCoinsEarned() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Coin icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.coinBorder, width: 2),
            ),
            child: Center(
              child: Text(
                '\$',
                style: TextStyle(
                  color: AppColors.coinSymbol,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '+${widget.coinsEarned}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Next Level button (primary)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 4,
              ),
              onPressed: widget.onNextLevel,
              child: const Text(
                'Next Level',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Replay button (secondary)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: widget.onReplay,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.replay, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Replay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
