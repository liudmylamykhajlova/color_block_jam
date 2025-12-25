import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Booster types available in game
enum BoosterType {
  freeze,    // Freeze time (clock with snowflake)
  destroy,   // Destroy block (hammer)
  drill,     // Drill through ice (drill)
  shop,      // Buy more boosters
  pause,     // Pause game
}

/// Data class for booster state
class BoosterData {
  final BoosterType type;
  final int quantity;
  final bool isEnabled;
  
  const BoosterData({
    required this.type,
    this.quantity = 0,
    this.isEnabled = true,
  });
}

/// Bottom boosters bar with 5 slots
class BoostersBar extends StatelessWidget {
  final List<BoosterData> boosters;
  final Function(BoosterType)? onBoosterTap;
  final VoidCallback? onPauseTap;
  
  const BoostersBar({
    super.key,
    required this.boosters,
    this.onBoosterTap,
    this.onPauseTap,
  });
  
  static List<BoosterData> get defaultBoosters => const [
    BoosterData(type: BoosterType.freeze, quantity: 1),
    BoosterData(type: BoosterType.destroy, quantity: 1),
    BoosterData(type: BoosterType.drill, quantity: 1),
    BoosterData(type: BoosterType.shop, quantity: 0),
    BoosterData(type: BoosterType.pause, quantity: 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < boosters.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            _BoosterButton(
              data: boosters[i],
              onTap: () {
                if (boosters[i].type == BoosterType.pause) {
                  onPauseTap?.call();
                } else {
                  onBoosterTap?.call(boosters[i].type);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _BoosterButton extends StatelessWidget {
  final BoosterData data;
  final VoidCallback? onTap;
  
  const _BoosterButton({
    required this.data,
    this.onTap,
  });
  
  IconData get _icon {
    switch (data.type) {
      case BoosterType.freeze:
        return Icons.ac_unit; // Snowflake icon
      case BoosterType.destroy:
        return Icons.rocket_launch; // Rocket icon
      case BoosterType.drill:
        return Icons.build;
      case BoosterType.shop:
        return Icons.add_circle_outline;
      case BoosterType.pause:
        return Icons.pause;
    }
  }
  
  Color get _iconColor {
    switch (data.type) {
      case BoosterType.freeze:
        return Colors.cyan;
      case BoosterType.destroy:
        return AppColors.rocketOrange; // Orange for rocket
      case BoosterType.drill:
        return Colors.orange;
      case BoosterType.shop:
        return AppColors.buttonGreen;
      case BoosterType.pause:
        return Colors.white;
    }
  }
  
  bool get _showBadge {
    return data.type != BoosterType.pause && data.type != BoosterType.shop;
  }
  
  bool get _showPlusBadge {
    return data.type == BoosterType.shop;
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = data.isEnabled && (data.quantity > 0 || !_showBadge);
    
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isEnabled
                    ? [
                        const Color(0xFF5BA3D9),
                        const Color(0xFF3D7AB3),
                      ]
                    : [
                        Colors.grey.shade600,
                        Colors.grey.shade700,
                      ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isEnabled 
                    ? const Color(0xFF7CC4F0)
                    : Colors.grey.shade500,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _icon,
              color: isEnabled ? _iconColor : Colors.grey.shade400,
              size: 28,
            ),
          ),
          
          // Quantity badge
          if (_showBadge && data.quantity > 0)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF3D7AB3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${data.quantity}',
                    style: const TextStyle(
                      color: Color(0xFF3D7AB3),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          
          // Plus badge for shop
          if (_showPlusBadge)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.buttonGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

