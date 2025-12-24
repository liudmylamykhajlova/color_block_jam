import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Full-screen freeze visual effect overlay
/// Shows animated falling snowflakes and blue tint when freeze is active
class FreezeOverlay extends StatefulWidget {
  final bool isActive;
  final Widget child;
  
  const FreezeOverlay({
    super.key,
    required this.isActive,
    required this.child,
  });

  @override
  State<FreezeOverlay> createState() => _FreezeOverlayState();
}

class _FreezeOverlayState extends State<FreezeOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Snowflake animation controller
  late AnimationController _snowflakeController;
  
  final List<_Snowflake> _snowflakes = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    
    // Fade animation for overlay appearance
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    // Snowflake falling animation (loops every 4 seconds)
    _snowflakeController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    // Generate snowflakes
    _generateSnowflakes();
    
    if (widget.isActive) {
      _fadeController.forward();
      _snowflakeController.repeat();
    }
  }

  void _generateSnowflakes() {
    for (int i = 0; i < 25; i++) {
      _snowflakes.add(_Snowflake(
        initialX: _random.nextDouble(),
        initialY: _random.nextDouble(),
        size: _random.nextDouble() * 10 + 6,
        speed: _random.nextDouble() * 0.3 + 0.15, // Fall speed
        sway: _random.nextDouble() * 0.02 + 0.01, // Horizontal sway amount
        swayOffset: _random.nextDouble() * pi * 2, // Phase offset for sway
        opacity: _random.nextDouble() * 0.4 + 0.4,
      ));
    }
  }

  @override
  void didUpdateWidget(FreezeOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive && !oldWidget.isActive) {
      _fadeController.forward();
      _snowflakeController.repeat();
    } else if (!widget.isActive && oldWidget.isActive) {
      _fadeController.reverse();
      _snowflakeController.stop();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _snowflakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        widget.child,
        
        // Freeze overlay
        AnimatedBuilder(
          animation: Listenable.merge([_fadeAnimation, _snowflakeController]),
          builder: (context, child) {
            if (_fadeAnimation.value == 0) return const SizedBox.shrink();
            
            return Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Stack(
                    children: [
                      // Blue tint overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.5,
                            colors: [
                              AppColors.freezeGlow.withOpacity(0.1),
                              AppColors.freezeGlow.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                      
                      // Border glow effect
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.freezeBlue.withOpacity(0.5),
                            width: 8,
                          ),
                        ),
                      ),
                      
                      // Animated snowflakes
                      CustomPaint(
                        painter: _SnowflakePainter(
                          snowflakes: _snowflakes,
                          fadeProgress: _fadeAnimation.value,
                          animationTime: _snowflakeController.value,
                        ),
                        size: Size.infinite,
                      ),
                      
                      // Corner frost effects
                      ..._buildCornerFrost(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  List<Widget> _buildCornerFrost() {
    return [
      // Top-left frost
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.0,
              colors: [
                AppColors.freezeLight.withOpacity(0.4),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      // Top-right frost
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.0,
              colors: [
                AppColors.freezeLight.withOpacity(0.4),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      // Bottom-left frost
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.bottomLeft,
              radius: 1.0,
              colors: [
                AppColors.freezeLight.withOpacity(0.4),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      // Bottom-right frost
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.bottomRight,
              radius: 1.0,
              colors: [
                AppColors.freezeLight.withOpacity(0.4),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    ];
  }
}

/// Snowflake data with animation parameters
class _Snowflake {
  final double initialX;  // Starting X position (0-1)
  final double initialY;  // Starting Y position (0-1)
  final double size;      // Snowflake size in pixels
  final double speed;     // Fall speed (0-1 per animation cycle)
  final double sway;      // Horizontal sway amount
  final double swayOffset; // Phase offset for sway animation
  final double opacity;   // Snowflake opacity
  
  _Snowflake({
    required this.initialX,
    required this.initialY,
    required this.size,
    required this.speed,
    required this.sway,
    required this.swayOffset,
    required this.opacity,
  });
}

class _SnowflakePainter extends CustomPainter {
  final List<_Snowflake> snowflakes;
  final double fadeProgress;
  final double animationTime;
  
  _SnowflakePainter({
    required this.snowflakes,
    required this.fadeProgress,
    required this.animationTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    
    for (final flake in snowflakes) {
      paint.color = Colors.white.withOpacity(flake.opacity * fadeProgress);
      
      // Calculate animated Y position (falling down, wrapping around)
      final y = ((flake.initialY + animationTime * flake.speed * 2) % 1.0) * size.height;
      
      // Calculate animated X position (swaying left-right)
      final swayX = sin((animationTime * pi * 4) + flake.swayOffset) * flake.sway;
      final x = (flake.initialX + swayX).clamp(0.0, 1.0) * size.width;
      
      // Draw snowflake
      _drawSnowflake(canvas, Offset(x, y), flake.size, paint);
    }
  }
  
  void _drawSnowflake(Canvas canvas, Offset center, double size, Paint paint) {
    final radius = size / 2;
    
    // Draw 6-pointed star with branches
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      final endX = center.dx + cos(angle) * radius;
      final endY = center.dy + sin(angle) * radius;
      
      // Main branch
      canvas.drawLine(
        center,
        Offset(endX, endY),
        paint..strokeWidth = 1.5..style = PaintingStyle.stroke,
      );
      
      // Small side branches (for larger snowflakes)
      if (size > 8) {
        final midX = center.dx + cos(angle) * radius * 0.6;
        final midY = center.dy + sin(angle) * radius * 0.6;
        
        // Left branch
        final branchAngle1 = angle + pi / 6;
        final branch1EndX = midX + cos(branchAngle1) * radius * 0.3;
        final branch1EndY = midY + sin(branchAngle1) * radius * 0.3;
        canvas.drawLine(
          Offset(midX, midY),
          Offset(branch1EndX, branch1EndY),
          paint..strokeWidth = 1.0,
        );
        
        // Right branch
        final branchAngle2 = angle - pi / 6;
        final branch2EndX = midX + cos(branchAngle2) * radius * 0.3;
        final branch2EndY = midY + sin(branchAngle2) * radius * 0.3;
        canvas.drawLine(
          Offset(midX, midY),
          Offset(branch2EndX, branch2EndY),
          paint..strokeWidth = 1.0,
        );
      }
    }
    
    // Center circle
    canvas.drawCircle(center, 2, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant _SnowflakePainter oldDelegate) {
    return oldDelegate.fadeProgress != fadeProgress ||
           oldDelegate.animationTime != animationTime;
  }
}
