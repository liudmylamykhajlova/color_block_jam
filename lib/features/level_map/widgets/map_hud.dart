import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Top HUD for level map screen
class MapHud extends StatelessWidget {
  final int lives;
  final int coins;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onLivesTap;
  final VoidCallback? onCoinsTap;
  final VoidCallback? onSettingsTap;
  
  const MapHud({
    super.key,
    this.lives = 5,
    this.coins = 0,
    this.onAvatarTap,
    this.onLivesTap,
    this.onCoinsTap,
    this.onSettingsTap,
  });

  String get _formattedCoins {
    if (coins >= 1000000) {
      return '${(coins / 1000000).toStringAsFixed(2)}M';
    } else if (coins >= 1000) {
      return '${(coins / 1000).toStringAsFixed(2)}k';
    }
    return coins.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Avatar
          _AvatarButton(onTap: onAvatarTap),
          
          const SizedBox(width: 8),
          
          // Lives
          _LivesDisplay(
            lives: lives,
            onTap: onLivesTap,
          ),
          
          const Spacer(),
          
          // Coins
          _CoinsDisplay(
            coins: _formattedCoins,
            onTap: onCoinsTap,
          ),
          
          const SizedBox(width: 8),
          
          // Settings
          _SettingsButton(onTap: onSettingsTap),
        ],
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  final VoidCallback? onTap;
  
  const _AvatarButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF5BA3D9),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Container(
            color: const Color(0xFF87CEEB),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

class _LivesDisplay extends StatelessWidget {
  final int lives;
  final VoidCallback? onTap;
  
  const _LivesDisplay({
    required this.lives,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFull = lives >= 5;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Plus button
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.buttonGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 6),
            // Full text or count
            Text(
              isFull ? 'Full' : '$lives',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            // Heart icon with count
            Stack(
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 24,
                ),
                Positioned.fill(
                  child: Center(
                    child: Text(
                      '5',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinsDisplay extends StatelessWidget {
  final String coins;
  final VoidCallback? onTap;
  
  const _CoinsDisplay({
    required this.coins,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Plus button
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.buttonGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 6),
            // Coin value
            Text(
              coins,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            // Coin icon
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange.shade700, width: 2),
              ),
              child: Center(
                child: Text(
                  '\$',
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final VoidCallback? onTap;
  
  const _SettingsButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.amber,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.orange.shade700,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.settings,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

