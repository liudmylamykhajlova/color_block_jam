import 'package:flutter/material.dart';

/// Controller for vacuum animation that can be triggered externally
class VacuumAnimationController {
  _VacuumAnimationOverlayState? _state;
  
  void _attach(_VacuumAnimationOverlayState state) {
    _state = state;
  }
  
  void _detach() {
    _state = null;
  }
  
  /// Start vacuuming blocks at the given positions
  void startVacuum(List<Rect> blockRects, List<Color> blockColors) {
    _state?.startVacuum(blockRects, blockColors);
  }
}

/// Overlay widget that shows vacuum animation for multiple blocks
class VacuumAnimationOverlay extends StatefulWidget {
  final VacuumAnimationController controller;
  final VoidCallback onComplete;
  
  const VacuumAnimationOverlay({
    super.key,
    required this.controller,
    required this.onComplete,
  });
  
  @override
  State<VacuumAnimationOverlay> createState() => _VacuumAnimationOverlayState();
}

class _VacuumAnimationOverlayState extends State<VacuumAnimationOverlay>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  List<Rect> _blockRects = [];
  List<Color> _blockColors = [];
  bool _isAnimating = false;
  
  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
  }
  
  @override
  void dispose() {
    widget.controller._detach();
    _controller?.dispose();
    super.dispose();
  }
  
  void startVacuum(List<Rect> blockRects, List<Color> blockColors) {
    if (_isAnimating) return;
    
    setState(() {
      _blockRects = blockRects;
      _blockColors = blockColors;
      _isAnimating = true;
    });
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _controller!.forward().whenComplete(() {
      if (mounted) {
        setState(() {
          _isAnimating = false;
          _blockRects = [];
          _blockColors = [];
        });
        widget.onComplete();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isAnimating || _controller == null) {
      return const SizedBox.shrink();
    }
    
    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, child) {
        final progress = _controller!.value;
        // Scale down from 1.0 to 0.0
        final scale = 1.0 - progress;
        // Fade out
        final opacity = 1.0 - progress;
        // Slight rotation for effect
        final rotation = progress * 0.5;
        
        return Stack(
          children: [
            for (int i = 0; i < _blockRects.length; i++)
              _buildShrinkingBlock(
                _blockRects[i],
                _blockColors[i],
                scale,
                opacity,
                rotation,
              ),
          ],
        );
      },
    );
  }
  
  Widget _buildShrinkingBlock(
    Rect rect,
    Color color,
    double scale,
    double opacity,
    double rotation,
  ) {
    final centerX = rect.center.dx;
    final centerY = rect.center.dy;
    final scaledWidth = rect.width * scale;
    final scaledHeight = rect.height * scale;
    
    return Positioned(
      left: centerX - scaledWidth / 2,
      top: centerY - scaledHeight / 2,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: rotation,
          child: Container(
            width: scaledWidth,
            height: scaledHeight,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8 * scale),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5 * opacity),
                  blurRadius: 20 * (1 - scale),
                  spreadRadius: 10 * (1 - scale),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


