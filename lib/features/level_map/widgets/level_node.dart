import 'package:flutter/material.dart';
import 'package:color_block_jam/core/constants/colors.dart';

/// Types of level nodes
enum LevelNodeType {
  normal,   // Green when unlocked, gray when locked
  hard,     // Purple (always, even when locked)
  veryHard, // Red/Pink (always, even when locked)
}

/// A single level node on the map (matching original game design)
class LevelNode extends StatelessWidget {
  final int levelId;
  final bool isCompleted;
  final bool isUnlocked;
  final bool isCurrent;
  final LevelNodeType type;
  final VoidCallback? onTap;
  
  const LevelNode({
    super.key,
    required this.levelId,
    this.isCompleted = false,
    this.isUnlocked = false,
    this.isCurrent = false,
    this.type = LevelNodeType.normal,
    this.onTap,
  });

  /// Get the main background color based on state and type
  Color get _backgroundColor {
    // Hard levels ALWAYS keep their color (even when locked)
    if (type == LevelNodeType.hard) {
      return AppColors.nodeHard;
    }
    if (type == LevelNodeType.veryHard) {
      return AppColors.nodeVeryHard;
    }
    
    // Normal levels: gray when locked, bright green when unlocked
    if (!isUnlocked) {
      return AppColors.nodeLocked;
    }
    
    return AppColors.nodeNormal;
  }
  
  /// Get stud color (subtle but visible)
  Color get _studColor {
    if (type == LevelNodeType.hard) {
      return AppColors.studHard.withOpacity(0.7);
    }
    if (type == LevelNodeType.veryHard) {
      return AppColors.studVeryHard.withOpacity(0.7);
    }
    if (!isUnlocked) {
      return AppColors.studLocked.withOpacity(0.6);
    }
    return AppColors.studNormal.withOpacity(0.7);
  }

  @override
  Widget build(BuildContext context) {
    // Current level: green square + "Level N" button below (like original)
    if (isCurrent) {
      return _buildCurrentLevelNode();
    }
    
    return _buildNormalNode();
  }
  
  /// Current level: green square + separate "Level N" button below
  Widget _buildCurrentLevelNode() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The square node (same as normal unlocked but green)
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Green square with studs - with dark outline
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.mapDarkBrown,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mapDarkBrown.withOpacity(0.6),
                      blurRadius: 0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppColors.mapGoldenBorder,
                      width: 5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      color: AppColors.nodeNormal,
                      child: Stack(
                        children: [
                          _buildStuds(),
                          Center(
                            child: Text(
                              '$levelId',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 4,
                                    offset: const Offset(1, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Skull badge for hard/veryHard
              if (type == LevelNodeType.hard || type == LevelNodeType.veryHard)
                Positioned(
                  left: 0,
                  right: 0,
                  top: -16,
                  child: Center(child: _buildSkullBadge()),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // "Level N" button below
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 140,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.currentLevelLight, AppColors.currentLevelDark],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.currentLevelBorder, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.currentLevelShadow.withOpacity(0.9),
                  blurRadius: 0,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Level $levelId',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 4,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Normal square node for non-current levels
  Widget _buildNormalNode() {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Node body with dark outline + golden border like original
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.mapDarkBrown,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mapDarkBrown.withOpacity(0.6),
                  blurRadius: 0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.mapGoldenBorder,
                  width: 5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: _backgroundColor,
                  child: Stack(
                    children: [
                      // 4 LEGO studs
                      _buildStuds(),
                      // Level number
                      Center(
                        child: Text(
                          '$levelId',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 4,
                                offset: const Offset(1, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Skull badge overlaid on top (for hard/veryHard levels)
          if (type == LevelNodeType.hard || type == LevelNodeType.veryHard)
            Positioned(
              left: 0,
              right: 0,
              top: -16,
              child: Center(child: _buildSkullBadge()),
            ),
          
          // Lock icon for locked levels (bottom right)
          if (!isUnlocked)
            Positioned(
              right: -8,
              bottom: -8,
              child: _buildLockBadge(),
            ),
        ],
      ),
    );
  }
  
  /// 4 LEGO studs in corners
  Widget _buildStuds() {
    return Stack(
      children: [
        // Top left stud
        Positioned(
          left: 10,
          top: 10,
          child: _buildStud(),
        ),
        // Top right stud
        Positioned(
          right: 10,
          top: 10,
          child: _buildStud(),
        ),
        // Bottom left stud
        Positioned(
          left: 10,
          bottom: 10,
          child: _buildStud(),
        ),
        // Bottom right stud
        Positioned(
          right: 10,
          bottom: 10,
          child: _buildStud(),
        ),
      ],
    );
  }
  
  /// Single LEGO stud - 3D effect with highlight and shadow
  Widget _buildStud() {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            Colors.white.withOpacity(0.4),
            _studColor,
            _studColor.withOpacity(0.8),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border.all(
          color: Colors.black.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }
  
  /// Skull badge for hard levels - black skull on golden circle like original
  Widget _buildSkullBadge() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.goldenLight, AppColors.goldenDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.goldenBorder,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(20, 20),
          painter: _SkullPainter(),
        ),
      ),
    );
  }
  
  /// Lock badge for locked levels
  Widget _buildLockBadge() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.goldenLight, AppColors.goldenDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.goldenBorderAlt, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.lock,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

/// Custom painter for skull icon
class _SkullPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    final w = size.width;
    final h = size.height;
    
    // Skull head (oval)
    canvas.drawOval(
      Rect.fromLTWH(w * 0.1, 0, w * 0.8, h * 0.7),
      paint,
    );
    
    // Jaw
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.25, h * 0.55, w * 0.5, h * 0.35),
        const Radius.circular(4),
      ),
      paint,
    );
    
    // Left eye (yellow)
    final eyePaint = Paint()
      ..color = AppColors.goldenDark
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromLTWH(w * 0.2, h * 0.2, w * 0.22, h * 0.22),
      eyePaint,
    );
    
    // Right eye (yellow)
    canvas.drawOval(
      Rect.fromLTWH(w * 0.58, h * 0.2, w * 0.22, h * 0.22),
      eyePaint,
    );
    
    // Nose (inverted triangle, yellow)
    final nosePath = Path();
    nosePath.moveTo(w * 0.5, h * 0.4);
    nosePath.lineTo(w * 0.38, h * 0.55);
    nosePath.lineTo(w * 0.62, h * 0.55);
    nosePath.close();
    canvas.drawPath(nosePath, eyePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
