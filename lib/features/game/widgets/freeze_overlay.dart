import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Full-screen freeze visual effect overlay
/// Shows animated snowflakes and blue tint when freeze is active
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
  
  final List<_Snowflake> _snowflakes = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    // Generate snowflakes
    _generateSnowflakes();
    
    if (widget.isActive) {
      _fadeController.forward();
    }
  }

  void _generateSnowflakes() {
    for (int i = 0; i < 20; i++) {
      _snowflakes.add(_Snowflake(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 8 + 4,
        speed: _random.nextDouble() * 0.5 + 0.2,
        opacity: _random.nextDouble() * 0.5 + 0.3,
      ));
    }
  }

  @override
  void didUpdateWidget(FreezeOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive && !oldWidget.isActive) {
      _fadeController.forward();
    } else if (!widget.isActive && oldWidget.isActive) {
      _fadeController.reverse();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
          animation: _fadeAnimation,
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
                      
                      // Snowflakes
                      CustomPaint(
                        painter: _SnowflakePainter(
                          snowflakes: _snowflakes,
                          progress: _fadeAnimation.value,
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

class _Snowflake {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  
  _Snowflake({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _SnowflakePainter extends CustomPainter {
  final List<_Snowflake> snowflakes;
  final double progress;
  
  _SnowflakePainter({
    required this.snowflakes,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    
    for (final flake in snowflakes) {
      paint.color = Colors.white.withOpacity(flake.opacity * progress);
      
      final x = flake.x * size.width;
      final y = flake.y * size.height;
      
      // Draw simple snowflake (star shape)
      _drawSnowflake(canvas, Offset(x, y), flake.size, paint);
    }
  }
  
  void _drawSnowflake(Canvas canvas, Offset center, double size, Paint paint) {
    // Draw 6-pointed star
    final radius = size / 2;
    
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      final endX = center.dx + cos(angle) * radius;
      final endY = center.dy + sin(angle) * radius;
      
      canvas.drawLine(
        center,
        Offset(endX, endY),
        paint..strokeWidth = 1.5,
      );
    }
    
    // Center circle
    canvas.drawCircle(center, 2, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant _SnowflakePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

