import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Tooltip shown when Rocket booster is active
/// Shows instruction banner at top of screen
class RocketOverlay extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onCancel;
  
  const RocketOverlay({
    super.key,
    required this.isActive,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60, // Below the top bar
      left: 0,
      right: 0,
      child: Center(
        child: _buildTooltip(context),
      ),
    );
  }
  
  Widget _buildTooltip(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF5BB8E8), // Sky blue like original
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rocket icon (purple/violet like original)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: Color(0xFFFFD700), // Gold rocket
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              // Text
              const Flexible(
                child: Text(
                  'Tap and destroy one unit of a block!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 24), // Space for close button
            ],
          ),
        ),
        // ROCKET badge on top
        Positioned(
          top: -12,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4DA6FF), Color(0xFF2E86DE)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Text(
                'ROCKET',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
        // Close button in corner
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: onCancel,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.buttonRed,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
