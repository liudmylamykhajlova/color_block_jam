import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/models/game_models.dart';
import '../menu/menu_screen.dart';

/// Splash screen with animated LEGO blocks and loading progress
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _logoController;
  late Animation<double> _logoGlow;
  
  final List<_FallingBlock> _blocks = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _generateBlocks();
    _startLoading();
  }

  void _initAnimations() {
    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Logo glow animation only (subtle pulsing, no size changes)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoGlow = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _logoController.repeat(reverse: true);
  }

  void _generateBlocks() {
    // Generate 15-20 falling blocks
    final count = 15 + _random.nextInt(6);
    for (int i = 0; i < count; i++) {
      _blocks.add(_FallingBlock(
        color: GameColors.palette[_random.nextInt(GameColors.palette.length)],
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.5 - 0.1,
        size: 30 + _random.nextDouble() * 40,
        speed: 0.3 + _random.nextDouble() * 0.5,
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 2,
      ));
    }
  }

  Future<void> _startLoading() async {
    // Start progress animation (no setState - AnimatedBuilder handles it)
    _progressController.forward();

    // Actually load data in background
    await Future.wait([
      LevelLoader.loadLevels(),
      Future.delayed(const Duration(milliseconds: 2500)),
    ]);

    // Small delay before transition
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MenuScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4DA6FF), // Sky blue top
              Color(0xFF2E86DE), // Darker blue bottom
            ],
          ),
        ),
        child: Stack(
          children: [
            // Falling blocks background
            ..._blocks.map((block) => _AnimatedBlock(block: block)),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // Logo with glow
                  _buildLogo(),
                  
                  const Spacer(flex: 2),
                  
                  // Progress bar
                  _buildProgressBar(),
                  
                  const SizedBox(height: 40),
                  
                  // Publisher logo placeholder
                  _buildPublisher(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        // No Transform.scale - logo is always full size
        return Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect (subtle pulsing)
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3 * _logoGlow.value),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.2 * _logoGlow.value),
                    blurRadius: 80,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
            
            // Neon circle (fixed size)
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.5 * _logoGlow.value),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            
            // Logo text (fixed size)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogoText('Color', Colors.white),
                _buildLogoText('Block', Colors.white),
                _buildLogoText('Jam', Colors.white),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogoText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: color,
        height: 0.9,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
          Shadow(
            color: Colors.cyan.withOpacity(0.5),
            blurRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        final progress = _progressController.value;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Column(
            children: [
              // Progress bar container (fixed size)
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      // Progress fill (only this animates)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.cyan.shade300,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Shine effect (static)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Percentage text
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPublisher() {
    return Opacity(
      opacity: 0.6,
      child: Text(
        'Playcus Games',
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// Data class for falling block animation
class _FallingBlock {
  Color color;
  double x; // 0-1 horizontal position
  double y; // 0-1 vertical position (can be negative for off-screen)
  double size;
  double speed;
  double rotation;
  double rotationSpeed;

  _FallingBlock({
    required this.color,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
  });
}

/// Animated falling block widget
class _AnimatedBlock extends StatefulWidget {
  final _FallingBlock block;

  const _AnimatedBlock({required this.block});

  @override
  State<_AnimatedBlock> createState() => _AnimatedBlockState();
}

class _AnimatedBlockState extends State<_AnimatedBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _controller.addListener(() {
      setState(() {
        widget.block.y += widget.block.speed * 0.01;
        widget.block.rotation += widget.block.rotationSpeed * 0.02;

        // Reset when off screen
        if (widget.block.y > 1.2) {
          widget.block.y = -0.2;
          widget.block.x = Random().nextDouble();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      left: widget.block.x * screenWidth - widget.block.size / 2,
      top: widget.block.y * screenHeight,
      child: Transform.rotate(
        angle: widget.block.rotation,
        child: _LegoBlock(
          color: widget.block.color,
          size: widget.block.size,
        ),
      ),
    );
  }
}

/// Simple LEGO block representation
class _LegoBlock extends StatelessWidget {
  final Color color;
  final double size;

  const _LegoBlock({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Studs
          Positioned(
            top: 2,
            left: size * 0.15,
            child: _Stud(color: color, size: size * 0.25),
          ),
          Positioned(
            top: 2,
            right: size * 0.15,
            child: _Stud(color: color, size: size * 0.25),
          ),
          
          // Highlight
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size * 0.15,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// LEGO stud (round bump on top)
class _Stud extends StatelessWidget {
  final Color color;
  final double size;

  const _Stud({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: Colors.black.withOpacity(0.2),
          width: 1,
        ),
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            Colors.white.withOpacity(0.4),
            color,
          ],
        ),
      ),
    );
  }
}

