import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Animated rocket that flies from start to end position
class RocketAnimation extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final VoidCallback onComplete;
  final Duration duration;
  
  const RocketAnimation({
    super.key,
    required this.startPosition,
    required this.endPosition,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<RocketAnimation> createState() => _RocketAnimationState();
}

class _RocketAnimationState extends State<RocketAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInQuad,
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 1.2),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.3),
        weight: 20,
      ),
    ]).animate(_controller);
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
    
    _controller.forward();
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
        final progress = _progressAnimation.value;
        final scale = _scaleAnimation.value;
        
        // Calculate current position
        final currentX = widget.startPosition.dx + 
            (widget.endPosition.dx - widget.startPosition.dx) * progress;
        final currentY = widget.startPosition.dy + 
            (widget.endPosition.dy - widget.startPosition.dy) * progress;
        
        // Calculate rotation angle (point towards target)
        final angle = atan2(
          widget.endPosition.dy - widget.startPosition.dy,
          widget.endPosition.dx - widget.startPosition.dx,
        );
        
        return Positioned(
          left: currentX - 20 * scale,
          top: currentY - 20 * scale,
          child: Transform.rotate(
            angle: angle + pi / 2, // Adjust for rocket pointing up
            child: Transform.scale(
              scale: scale,
              child: _buildRocket(),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildRocket() {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Trail effect
          Positioned(
            bottom: 0,
            child: Container(
              width: 16,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.rocketOrange.withOpacity(0.8),
                    AppColors.rocketYellow.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
            ),
          ),
          // Rocket body
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.rocketOrange,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: AppColors.rocketOrange.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.rocket_launch,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

/// Explosion effect shown after rocket hits target
class ExplosionAnimation extends StatefulWidget {
  final Offset position;
  final VoidCallback onComplete;
  final Duration duration;
  
  const ExplosionAnimation({
    super.key,
    required this.position,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<ExplosionAnimation> createState() => _ExplosionAnimationState();
}

class _ExplosionAnimationState extends State<ExplosionAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.2, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
    
    _controller.forward();
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
        final scale = _scaleAnimation.value;
        final opacity = _opacityAnimation.value;
        
        return Positioned(
          left: widget.position.dx - 30 * scale,
          top: widget.position.dy - 30 * scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 60 * scale,
              height: 60 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white,
                    AppColors.rocketYellow,
                    AppColors.rocketOrange,
                    AppColors.rocketOrange.withOpacity(0),
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

