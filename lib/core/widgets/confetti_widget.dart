import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiWidget extends StatefulWidget {
  final Widget child;
  final bool isPlaying;

  const ConfettiWidget({
    super.key,
    required this.child,
    this.isPlaying = false,
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Confetti> _confetti = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _controller.addListener(() {
      setState(() {
        for (final c in _confetti) {
          c.update(_controller.value);
        }
      });
    });

    if (widget.isPlaying) {
      _startConfetti();
    }
  }

  @override
  void didUpdateWidget(ConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startConfetti();
    }
  }

  void _startConfetti() {
    _confetti.clear();
    for (int i = 0; i < 50; i++) {
      _confetti.add(_Confetti(
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.3,
        color: _colors[_random.nextInt(_colors.length)],
        size: 6 + _random.nextDouble() * 6,
        speedY: 0.3 + _random.nextDouble() * 0.4,
        speedX: (_random.nextDouble() - 0.5) * 0.3,
        rotation: _random.nextDouble() * 360,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
      ));
    }
    _controller.forward(from: 0);
  }

  static const _colors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFF95E1D3),
    Color(0xFFF38181),
    Color(0xFFAA96DA),
    Color(0xFFFCBF49),
    Color(0xFF2EC4B6),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isPlaying)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(_confetti),
              ),
            ),
          ),
      ],
    );
  }
}

class _Confetti {
  double x;
  double y;
  final Color color;
  final double size;
  final double speedY;
  final double speedX;
  double rotation;
  final double rotationSpeed;

  _Confetti({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.rotation,
    required this.rotationSpeed,
  });

  void update(double progress) {
    y += speedY * 0.02;
    x += speedX * 0.01;
    rotation += rotationSpeed;
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetti> confetti;

  _ConfettiPainter(this.confetti);

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in confetti) {
      if (c.y > 1.2) continue;

      final paint = Paint()..color = c.color;
      final x = c.x * size.width;
      final y = c.y * size.height;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(c.rotation * pi / 180);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: c.size, height: c.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

