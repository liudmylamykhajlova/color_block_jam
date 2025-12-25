import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Widget for animating a hammer strike on a block.
/// Hammer appears above the target and strikes down with impact effect.
class HammerAnimation extends StatefulWidget {
  final Offset startPosition; // Not used in new animation
  final Offset endPosition;   // Target position (block center)
  final VoidCallback onComplete;

  const HammerAnimation({
    super.key,
    required this.startPosition,
    required this.endPosition,
    required this.onComplete,
  });

  @override
  State<HammerAnimation> createState() => _HammerAnimationState();
}

class _HammerAnimationState extends State<HammerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _strikeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Strike animation: raise up then slam down
    _strikeAnimation = TweenSequence<double>([
      // Phase 1: Raise hammer (0.0 -> 0.3)
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -60.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      // Phase 2: Strike down fast (0.3 -> 1.0)
      TweenSequenceItem(
        tween: Tween(begin: -60.0, end: 20.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 70,
      ),
    ]).animate(_controller);

    _controller.forward().whenComplete(() {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final yOffset = _strikeAnimation.value;
        
        // Rotation: slight tilt back then forward on strike
        final rotation = progress < 0.3 
            ? -0.3 * (progress / 0.3)  // Tilt back
            : -0.3 + 0.6 * ((progress - 0.3) / 0.7);  // Swing forward
        
        // Scale: grow slightly on impact
        final scale = progress > 0.8 ? 1.0 + 0.2 * ((progress - 0.8) / 0.2) : 1.0;
        
        // Opacity: fade out at end
        final opacity = progress > 0.9 ? 1.0 - ((progress - 0.9) / 0.1) : 1.0;

        return Positioned(
          left: widget.endPosition.dx - 30,
          top: widget.endPosition.dy - 80 + yOffset,
          child: Opacity(
            opacity: opacity,
            child: Transform.rotate(
              angle: rotation,
              alignment: Alignment.bottomCenter,
              child: Transform.scale(
                scale: scale,
                child: _buildHammer(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHammer() {
    return SizedBox(
      width: 60,
      height: 70,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Hammer head (horizontal, at top)
          Positioned(
            top: 0,
            child: Container(
              width: 50,
              height: 22,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.hammerGreen,
                    AppColors.hammerGreen.withGreen(200),
                  ],
                ),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              // Metal shine
              child: Container(
                margin: const EdgeInsets.only(top: 2, left: 4, right: 4),
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          // Hammer handle (vertical, below head)
          Positioned(
            top: 18,
            child: Container(
              width: 12,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.hammerOrange.withRed(200),
                    AppColors.hammerOrange,
                    AppColors.hammerOrange.withRed(200),
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for animating a big explosion effect (for whole block destruction).
class BigExplosionAnimation extends StatefulWidget {
  final Offset position;
  final double size;
  final VoidCallback onComplete;

  const BigExplosionAnimation({
    super.key,
    required this.position,
    this.size = 100,
    required this.onComplete,
  });

  @override
  State<BigExplosionAnimation> createState() => _BigExplosionAnimationState();
}

class _BigExplosionAnimationState extends State<BigExplosionAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward().whenComplete(() {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;
        final radius = widget.size * progress;
        final opacity = 1.0 - progress;

        return Positioned(
          left: widget.position.dx - radius,
          top: widget.position.dy - radius,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.explosionYellow.withOpacity(opacity),
                    AppColors.explosionOrange.withOpacity(opacity * 0.7),
                    AppColors.hammerOrange.withOpacity(opacity * 0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
              child: _buildParticles(progress, opacity),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildParticles(double progress, double opacity) {
    return Stack(
      children: List.generate(8, (index) {
        final angle = index * pi / 4;
        final distance = widget.size * progress * 0.8;
        return Positioned(
          left: widget.size * progress + cos(angle) * distance - 6,
          top: widget.size * progress + sin(angle) * distance - 6,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.explosionYellow,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.explosionOrange.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

