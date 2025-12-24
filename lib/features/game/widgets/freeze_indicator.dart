import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Freeze time indicator shown below the timer
/// Displays snowflake icon and remaining freeze seconds
class FreezeIndicator extends StatefulWidget {
  final int remainingSeconds;
  final bool isVisible;
  
  const FreezeIndicator({
    super.key,
    required this.remainingSeconds,
    this.isVisible = true,
  });

  @override
  State<FreezeIndicator> createState() => _FreezeIndicatorState();
}

class _FreezeIndicatorState extends State<FreezeIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Only start animation if visible
    if (widget.isVisible) {
      _pulseController.repeat(reverse: true);
    }
  }
  
  @override
  void didUpdateWidget(FreezeIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Start/stop animation based on visibility
    if (widget.isVisible && !oldWidget.isVisible) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.freezeBlue,
                  AppColors.freezeLight,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.freezeGlow,
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Snowflake icon
                const Icon(
                  Icons.ac_unit,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                // Remaining seconds
                Text(
                  '${widget.remainingSeconds}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

