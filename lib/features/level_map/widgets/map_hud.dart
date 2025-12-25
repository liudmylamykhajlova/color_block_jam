import 'package:flutter/material.dart';

/// Top HUD for level map screen (matching original game design)
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
          
          const SizedBox(width: 24),
          
          // Settings
          _SettingsButton(onTap: onSettingsTap),
        ],
      ),
    );
  }
}

/// Avatar button with teal/cyan frame like original
class _AvatarButton extends StatelessWidget {
  final VoidCallback? onTap;
  
  const _AvatarButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF4DD0E1), // Cyan/teal frame
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: const Color(0xFF4DD0E1).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: Colors.white,
            child: Image.network(
              'https://via.placeholder.com/48',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback avatar
                return Container(
                  color: const Color(0xFFFFF3E0),
                  child: const Icon(
                    Icons.face,
                    color: Color(0xFF8D6E63),
                    size: 36,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Lives display - WHITE background like original
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
        height: 36,
        padding: const EdgeInsets.only(left: 2, right: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main content - centered text
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 24),
                child: Text(
                  isFull ? 'Full' : '$lives',
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            // Green plus - bottom left corner, small
            Positioned(
              left: -6,
              bottom: -6,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
            // Red heart - same height as badge, half outside on right
            Positioned(
              right: -18,
              top: 0,
              bottom: 0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Color(0xFFE53935),
                    size: 36,
                  ),
                  Text(
                    '$lives',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Coins display - BLUE background with gold coin
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
        height: 36,
        padding: const EdgeInsets.only(left: 2, right: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main content - centered text
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 24),
                child: Text(
                  coins,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            // Green plus - bottom left corner, small
            Positioned(
              left: -6,
              bottom: -6,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
            // Gold coin - half outside on right
            Positioned(
              right: -18,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD54F), Color(0xFFFFC107)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFF8F00), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '\$',
                      style: TextStyle(
                        color: Color(0xFFE65100),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

/// Settings button - Yellow/Orange gradient like original
class _SettingsButton extends StatelessWidget {
  final VoidCallback? onTap;
  
  const _SettingsButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFCA28), Color(0xFFFF9800)], // Yellow-orange
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFFFE082),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE65100).withOpacity(0.5),
              blurRadius: 0,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.settings,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
