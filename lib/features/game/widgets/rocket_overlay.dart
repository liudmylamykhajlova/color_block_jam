import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Overlay shown when Rocket booster is active
/// Shows tooltip at top only - targets are drawn in GameBoardPainter
class RocketOverlay extends StatelessWidget {
  final bool isActive;
  final Widget child;
  final VoidCallback? onCancel;
  
  const RocketOverlay({
    super.key,
    required this.isActive,
    required this.child,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return child;
    }
    
    return Stack(
      children: [
        child,
        
        // Tooltip at top
        Positioned(
          top: MediaQuery.of(context).padding.top + 70, // Below top bar
          left: 16,
          right: 16,
          child: _buildTooltip(context),
        ),
      ],
    );
  }
  
  Widget _buildTooltip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent,
            AppColors.accent.withBlue(220),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rocket icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.rocketOrange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.rocket_launch,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ROCKET',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Tap and destroy one unit of a block!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Close button
          GestureDetector(
            onTap: onCancel,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.buttonRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
