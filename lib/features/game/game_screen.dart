import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/models/game_models.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/widgets/confetti_widget.dart';

class GameScreen extends StatefulWidget {
  final int levelId;
  final VoidCallback? onLevelComplete;
  
  const GameScreen({
    super.key,
    required this.levelId,
    this.onLevelComplete,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  GameLevel? _level;
  List<GameBlock> _blocks = [];
  GameBlock? _selectedBlock;
  Point? _lastCell;
  bool _isLoading = true;
  
  // Auto-exit animation
  GameBlock? _exitingBlock;
  AnimationController? _exitAnimationController;
  int _exitDeltaRow = 0;
  int _exitDeltaCol = 0;
  double _exitProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  Future<void> _loadLevel() async {
    final levels = await LevelLoader.loadLevels();
    final level = levels.firstWhere((l) => l.id == widget.levelId);
    setState(() {
      _level = level;
      _isLoading = false;
      _initBlocks();
    });
  }
  
  void _initBlocks() {
    if (_level == null) return;
    _blocks = _level!.blocks.map((b) {
      final copy = b.copy();
      copy.gridWidth = _level!.gridWidth;
      copy.gridHeight = _level!.gridHeight;
      return copy;
    }).toList();
    _selectedBlock = null;
    _exitingBlock = null;
  }

  void _resetLevel() {
    setState(() {
      _initBlocks();
    });
  }

  @override
  void dispose() {
    _exitAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _level == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1a1a2e),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              _buildTopBar(),
              
              // Game board
              Expanded(
                child: Center(
                  child: _buildGameBoard(),
                ),
              ),
              
              // Bottom space
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Home button
          _TopBarButton(
            icon: Icons.home,
            onTap: () {
              AudioService.playTap();
              Navigator.pop(context);
            },
          ),
          
          // Level indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Level ${widget.levelId}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Restart button
          _TopBarButton(
            icon: Icons.refresh,
            onTap: () {
              AudioService.playTap();
              _resetLevel();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    final level = _level!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth - 48;
        final maxHeight = constraints.maxHeight - 48;
        final cellSize = (maxWidth / (level.gridWidth + 2))
            .clamp(0.0, maxHeight / (level.gridHeight + 2));

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onPanStart: (details) => _onPanStart(details, cellSize, level),
            onPanUpdate: (details) => _onPanUpdate(details, cellSize, level),
            onPanEnd: (_) => _onPanEnd(),
            child: CustomPaint(
              size: Size(
                (level.gridWidth + 2) * cellSize,
                (level.gridHeight + 2) * cellSize,
              ),
              painter: GameBoardPainter(
                level: level,
                blocks: _blocks,
                selectedBlock: _selectedBlock,
                cellSize: cellSize,
                exitingBlock: _exitingBlock,
                exitProgress: _exitProgress,
                exitDeltaRow: _exitDeltaRow,
                exitDeltaCol: _exitDeltaCol,
              ),
            ),
          ),
        );
      },
    );
  }

  Point? _getCellFromPosition(Offset position, double cellSize, GameLevel level,
      {bool allowOutside = false}) {
    final col = (position.dx / cellSize - 1).floor();
    final row = (position.dy / cellSize - 1).floor();

    if (allowOutside) {
      return Point(row, col);
    }

    if (row >= 0 && row < level.gridHeight && col >= 0 && col < level.gridWidth) {
      return Point(row, col);
    }
    return null;
  }

  void _onPanStart(DragStartDetails details, double cellSize, GameLevel level) {
    final cell = _getCellFromPosition(details.localPosition, cellSize, level);
    if (cell == null) return;

    for (final block in _blocks) {
      if (block.cells.contains(cell)) {
        AudioService.playPickup();
        setState(() {
          _selectedBlock = block;
          _lastCell = cell;
        });
        break;
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details, double cellSize, GameLevel level) {
    if (_selectedBlock == null || _lastCell == null) return;

    final currentCell = _getCellFromPosition(
      details.localPosition,
      cellSize,
      level,
      allowOutside: true,
    );
    if (currentCell == null) return;

    final deltaRow = currentCell.row - _lastCell!.row;
    final deltaCol = currentCell.col - _lastCell!.col;

    if (deltaRow == 0 && deltaCol == 0) return;

    int moveRow = deltaRow.clamp(-1, 1);
    int moveCol = deltaCol.clamp(-1, 1);

    if (moveRow != 0 && moveCol != 0) {
      if (deltaRow.abs() > deltaCol.abs()) {
        moveCol = 0;
      } else {
        moveRow = 0;
      }
    }

    if (_canMove(_selectedBlock!, moveRow, moveCol, level)) {
      setState(() {
        _selectedBlock!.gridRow += moveRow;
        _selectedBlock!.gridCol += moveCol;
        _lastCell = Point(_lastCell!.row + moveRow, _lastCell!.col + moveCol);
      });
      _checkDoorExit(level);
    }
  }

  void _onPanEnd() {
    if (_selectedBlock != null) {
      AudioService.playDrop();
    }
    setState(() {
      _selectedBlock = null;
      _lastCell = null;
    });
  }

  bool _canMove(GameBlock block, int deltaRow, int deltaCol, GameLevel level) {
    final newRow = block.gridRow + deltaRow;
    final newCol = block.gridCol + deltaCol;

    final tempBlock = GameBlock(
      blockType: block.blockType,
      blockGroupType: block.blockGroupType,
      gridRow: newRow,
      gridCol: newCol,
      rotationZ: block.rotationZ,
    )..gridWidth = level.gridWidth..gridHeight = level.gridHeight;

    final newCells = tempBlock.cells;
    
    final matchingDoors = level.doors.where((d) => d.blockType == block.blockType).toList();

    for (final cell in newCells) {
      final isOutside = cell.row < 0 || cell.row >= level.gridHeight ||
          cell.col < 0 || cell.col >= level.gridWidth;
      
      if (isOutside) {
        bool canExit = false;
        
        for (final door in matchingDoors) {
          if (door.edge == 'top' && cell.row < 0) {
            if (cell.col >= door.startCol && cell.col < door.startCol + door.partCount) {
              canExit = true;
              break;
            }
          } 
          else if (door.edge == 'bottom' && cell.row >= level.gridHeight) {
            if (cell.col >= door.startCol && cell.col < door.startCol + door.partCount) {
              canExit = true;
              break;
            }
          } 
          else if (door.edge == 'left' && cell.col < 0) {
            if (cell.row >= door.startRow && cell.row < door.startRow + door.partCount) {
              canExit = true;
              break;
            }
          } 
          else if (door.edge == 'right' && cell.col >= level.gridWidth) {
            if (cell.row >= door.startRow && cell.row < door.startRow + door.partCount) {
              canExit = true;
              break;
            }
          }
        }
        
        if (!canExit) return false;
      }

      if (!isOutside) {
        for (final otherBlock in _blocks) {
          if (otherBlock == block) continue;
          if (otherBlock.cells.contains(cell)) {
            return false;
          }
        }

        if (level.hiddenCells.contains(cell)) {
          return false;
        }
      }
    }

    return true;
  }

  void _checkDoorExit(GameLevel level) {
    if (_selectedBlock == null) return;

    final blockCells = _selectedBlock!.cells;
    
    int outsideCount = 0;
    int exitRow = 0;
    int exitCol = 0;
    
    for (final cell in blockCells) {
      if (cell.row < 0) {
        outsideCount++;
        exitRow = -1;
      } else if (cell.row >= level.gridHeight) {
        outsideCount++;
        exitRow = 1;
      } else if (cell.col < 0) {
        outsideCount++;
        exitCol = -1;
      } else if (cell.col >= level.gridWidth) {
        outsideCount++;
        exitCol = 1;
      }
    }

    if (outsideCount >= (blockCells.length + 1) ~/ 2 && outsideCount > 0) {
      _startAutoExit(_selectedBlock!, exitRow, exitCol, level);
    }
  }
  
  void _startAutoExit(GameBlock block, int deltaRow, int deltaCol, GameLevel level) {
    if (_exitingBlock != null) return;
    
    setState(() {
      _exitingBlock = block;
      _exitDeltaRow = deltaRow;
      _exitDeltaCol = deltaCol;
      _selectedBlock = null;
      _lastCell = null;
    });
    
    _exitAnimationController?.dispose();
    _exitAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _exitAnimationController!.addListener(() {
      setState(() {
        _exitProgress = _exitAnimationController!.value;
      });
    });
    
    _exitAnimationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _completeExit(level);
      }
    });
    
    _exitAnimationController!.forward();
  }
  
  void _completeExit(GameLevel level) {
    if (_exitingBlock == null) return;
    
    AudioService.playExit();
    
    setState(() {
      _blocks.remove(_exitingBlock);
      _exitingBlock = null;
      _exitProgress = 0.0;
    });
    
    _exitAnimationController?.dispose();
    _exitAnimationController = null;
    
    if (_blocks.isEmpty) {
      AudioService.playWin();
      _showWinDialog();
    }
  }

  void _showWinDialog() async {
    await StorageService.markLevelCompleted(widget.levelId);
    widget.onLevelComplete?.call();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfettiWidget(
        isPlaying: true,
        child: AlertDialog(
          backgroundColor: const Color(0xFF764ba2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              // Animated trophy
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: const Text('🏆', style: TextStyle(fontSize: 60)),
                  );
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'Level Complete!',
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + i * 150),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.star,
                          color: const Color(0xFFFFD700),
                          size: 36,
                          shadows: const [
                            Shadow(
                              color: Color(0x80FFD700),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
              ),
              const SizedBox(height: 16),
              Text(
                'Great job! 🎉',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      AudioService.playTap();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Home', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      AudioService.playTap();
                      Navigator.pop(context);
                      _goToNextLevel();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Next', style: TextStyle(color: Colors.white, fontSize: 16)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _goToNextLevel() async {
    final levels = await LevelLoader.loadLevels();
    final nextId = widget.levelId + 1;
    
    if (nextId <= levels.length) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(
            levelId: nextId,
            onLevelComplete: widget.onLevelComplete,
          ),
        ),
      );
    } else {
      if (!mounted) return;
      Navigator.pop(context);
    }
  }
}

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  
  const _TopBarButton({required this.icon, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

// ============ GAME BOARD PAINTER ============

class GameBoardPainter extends CustomPainter {
  final GameLevel level;
  final List<GameBlock> blocks;
  final GameBlock? selectedBlock;
  final double cellSize;
  final GameBlock? exitingBlock;
  final double exitProgress;
  final int exitDeltaRow;
  final int exitDeltaCol;

  GameBoardPainter({
    required this.level,
    required this.blocks,
    this.selectedBlock,
    required this.cellSize,
    this.exitingBlock,
    this.exitProgress = 0.0,
    this.exitDeltaRow = 0,
    this.exitDeltaCol = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderOffset = cellSize;
    final frameThickness = cellSize * 0.4;
    
    // Draw outer frame (brown wooden style like original)
    _drawFrame(canvas, borderOffset, frameThickness);
    
    // Draw doors (they sit in the frame gaps)
    _drawDoors(canvas, borderOffset, frameThickness);

    // Draw game field background
    final bgPaint = Paint()..color = const Color(0xFF3d3d3d);
    canvas.drawRect(
      Rect.fromLTWH(
        borderOffset,
        borderOffset,
        level.gridWidth * cellSize,
        level.gridHeight * cellSize,
      ),
      bgPaint,
    );

    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF555555)
      ..strokeWidth = 1;

    for (int row = 0; row <= level.gridHeight; row++) {
      canvas.drawLine(
        Offset(borderOffset, borderOffset + row * cellSize),
        Offset(borderOffset + level.gridWidth * cellSize, borderOffset + row * cellSize),
        gridPaint,
      );
    }
    for (int col = 0; col <= level.gridWidth; col++) {
      canvas.drawLine(
        Offset(borderOffset + col * cellSize, borderOffset),
        Offset(borderOffset + col * cellSize, borderOffset + level.gridHeight * cellSize),
        gridPaint,
      );
    }

    // Draw hidden cells
    final hiddenPaint = Paint()..color = const Color(0xFF1a1a2e);
    for (final cell in level.hiddenCells) {
      canvas.drawRect(
        Rect.fromLTWH(
          borderOffset + cell.col * cellSize,
          borderOffset + cell.row * cellSize,
          cellSize,
          cellSize,
        ),
        hiddenPaint,
      );
    }

    // Clip blocks to game field
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(
      borderOffset,
      borderOffset,
      level.gridWidth * cellSize,
      level.gridHeight * cellSize,
    ));

    for (final block in blocks) {
      _drawBlock(canvas, block, borderOffset);
    }
    
    canvas.restore();
  }
  
  void _drawFrame(Canvas canvas, double borderOffset, double frameThickness) {
    final frameColor = const Color(0xFF8B4513); // Brown wood color
    final frameHighlight = const Color(0xFFCD853F); // Lighter wood
    final frameShadow = const Color(0xFF5D3A1A); // Darker wood
    
    final fieldLeft = borderOffset;
    final fieldTop = borderOffset;
    final fieldRight = borderOffset + level.gridWidth * cellSize;
    final fieldBottom = borderOffset + level.gridHeight * cellSize;
    
    // Main frame paint
    final framePaint = Paint()..color = frameColor;
    final highlightPaint = Paint()..color = frameHighlight;
    final shadowPaint = Paint()..color = frameShadow;
    
    // Top frame
    final topFrame = Rect.fromLTWH(
      fieldLeft - frameThickness,
      fieldTop - frameThickness,
      level.gridWidth * cellSize + frameThickness * 2,
      frameThickness,
    );
    canvas.drawRect(topFrame, framePaint);
    canvas.drawRect(
      Rect.fromLTWH(topFrame.left, topFrame.top, topFrame.width, 3),
      highlightPaint,
    );
    
    // Bottom frame
    final bottomFrame = Rect.fromLTWH(
      fieldLeft - frameThickness,
      fieldBottom,
      level.gridWidth * cellSize + frameThickness * 2,
      frameThickness,
    );
    canvas.drawRect(bottomFrame, framePaint);
    canvas.drawRect(
      Rect.fromLTWH(bottomFrame.left, bottomFrame.bottom - 3, bottomFrame.width, 3),
      shadowPaint,
    );
    
    // Left frame
    final leftFrame = Rect.fromLTWH(
      fieldLeft - frameThickness,
      fieldTop,
      frameThickness,
      level.gridHeight * cellSize,
    );
    canvas.drawRect(leftFrame, framePaint);
    canvas.drawRect(
      Rect.fromLTWH(leftFrame.left, leftFrame.top, 3, leftFrame.height),
      highlightPaint,
    );
    
    // Right frame
    final rightFrame = Rect.fromLTWH(
      fieldRight,
      fieldTop,
      frameThickness,
      level.gridHeight * cellSize,
    );
    canvas.drawRect(rightFrame, framePaint);
    canvas.drawRect(
      Rect.fromLTWH(rightFrame.right - 3, rightFrame.top, 3, rightFrame.height),
      shadowPaint,
    );
    
    // Corner pieces (to make it look nicer)
    final cornerPaint = Paint()..color = frameHighlight;
    // Top-left corner
    canvas.drawCircle(
      Offset(fieldLeft - frameThickness / 2, fieldTop - frameThickness / 2),
      frameThickness / 3,
      cornerPaint,
    );
    // Top-right corner
    canvas.drawCircle(
      Offset(fieldRight + frameThickness / 2, fieldTop - frameThickness / 2),
      frameThickness / 3,
      cornerPaint,
    );
    // Bottom-left corner
    canvas.drawCircle(
      Offset(fieldLeft - frameThickness / 2, fieldBottom + frameThickness / 2),
      frameThickness / 3,
      cornerPaint,
    );
    // Bottom-right corner
    canvas.drawCircle(
      Offset(fieldRight + frameThickness / 2, fieldBottom + frameThickness / 2),
      frameThickness / 3,
      cornerPaint,
    );
  }

  void _drawDoors(Canvas canvas, double borderOffset, double frameThickness) {
    for (final door in level.doors) {
      final color = GameColors.getColor(door.blockType);
      final doorLength = door.partCount * cellSize;
      
      double x, y, w, h;
      
      // Door is drawn as a colored rectangle in the frame gap
      if (door.edge == 'left') {
        x = borderOffset - frameThickness;
        y = borderOffset + door.startRow * cellSize;
        w = frameThickness;
        h = doorLength;
      } else if (door.edge == 'right') {
        x = borderOffset + level.gridWidth * cellSize;
        y = borderOffset + door.startRow * cellSize;
        w = frameThickness;
        h = doorLength;
      } else if (door.edge == 'top') {
        x = borderOffset + door.startCol * cellSize;
        y = borderOffset - frameThickness;
        w = doorLength;
        h = frameThickness;
      } else {
        x = borderOffset + door.startCol * cellSize;
        y = borderOffset + level.gridHeight * cellSize;
        w = doorLength;
        h = frameThickness;
      }

      // Draw door background (darker)
      final bgPaint = Paint()..color = color.withOpacity(0.3);
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), bgPaint);
      
      // Draw door opening (colored bar)
      final doorPaint = Paint()..color = color;
      final padding = 3.0;
      
      if (door.edge == 'left' || door.edge == 'right') {
        // Vertical door - draw as horizontal bar at the edge
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + padding, y + padding, w - padding * 2, h - padding * 2),
            const Radius.circular(4),
          ),
          doorPaint,
        );
        // Arrow indicator
        _drawDoorArrow(canvas, x + w / 2, y + h / 2, door.edge, color);
      } else {
        // Horizontal door - draw as vertical bar at the edge
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + padding, y + padding, w - padding * 2, h - padding * 2),
            const Radius.circular(4),
          ),
          doorPaint,
        );
        // Arrow indicator
        _drawDoorArrow(canvas, x + w / 2, y + h / 2, door.edge, color);
      }
    }
  }
  
  void _drawDoorArrow(Canvas canvas, double cx, double cy, String edge, Color color) {
    final arrowPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    final size = cellSize * 0.08;
    final path = Path();
    
    switch (edge) {
      case 'left':
        path.moveTo(cx + size * 0.5, cy - size);
        path.lineTo(cx - size * 0.5, cy);
        path.lineTo(cx + size * 0.5, cy + size);
        break;
      case 'right':
        path.moveTo(cx - size * 0.5, cy - size);
        path.lineTo(cx + size * 0.5, cy);
        path.lineTo(cx - size * 0.5, cy + size);
        break;
      case 'top':
        path.moveTo(cx - size, cy + size * 0.5);
        path.lineTo(cx, cy - size * 0.5);
        path.lineTo(cx + size, cy + size * 0.5);
        break;
      case 'bottom':
        path.moveTo(cx - size, cy - size * 0.5);
        path.lineTo(cx, cy + size * 0.5);
        path.lineTo(cx + size, cy - size * 0.5);
        break;
    }
    
    canvas.drawPath(path, arrowPaint);
  }

  void _drawBlock(Canvas canvas, GameBlock block, double borderOffset) {
    final color = GameColors.getColor(block.blockType);
    final isSelected = block == selectedBlock;
    final isExiting = block == exitingBlock;
    final cells = block.cells;

    double offsetX = 0;
    double offsetY = 0;
    if (isExiting) {
      offsetX = exitDeltaCol * exitProgress * cellSize * 3;
      offsetY = exitDeltaRow * exitProgress * cellSize * 3;
    }

    // Draw selection glow
    if (isSelected) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      
      final glowPath = Path();
      for (final cell in cells) {
        final x = borderOffset + cell.col * cellSize + offsetX;
        final y = borderOffset + cell.row * cellSize + offsetY;
        glowPath.addRect(Rect.fromLTWH(x - 4, y - 4, cellSize + 8, cellSize + 8));
      }
      canvas.drawPath(glowPath, glowPaint);
    }

    final paint = Paint()..color = isSelected ? color.withOpacity(0.95) : color;
    
    final path = Path();
    for (final cell in cells) {
      final x = borderOffset + cell.col * cellSize + offsetX;
      final y = borderOffset + cell.row * cellSize + offsetY;
      path.addRect(Rect.fromLTWH(x, y, cellSize, cellSize));
    }
    canvas.drawPath(path, paint);

    final studRadius = cellSize * 0.2;
    final studPaintLight = Paint()
      ..color = Color.lerp(color, Colors.white, 0.25)!;
    final studPaintDark = Paint()
      ..color = Color.lerp(color, Colors.black, 0.1)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    for (final cell in cells) {
      final cx = borderOffset + cell.col * cellSize + cellSize / 2 + offsetX;
      final cy = borderOffset + cell.row * cellSize + cellSize / 2 + offsetY;
      
      canvas.drawCircle(Offset(cx, cy), studRadius, studPaintLight);
      canvas.drawCircle(Offset(cx, cy), studRadius, studPaintDark);
    }

    _drawBlockOutline(canvas, cells, borderOffset, color, isSelected, offsetX, offsetY);
  }

  void _drawBlockOutline(Canvas canvas, List<Point> cells, double borderOffset,
      Color color, bool isSelected, [double offsetX = 0, double offsetY = 0]) {
    final outlinePaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cellSet = cells.toSet();

    for (final cell in cells) {
      final x = borderOffset + cell.col * cellSize + offsetX;
      final y = borderOffset + cell.row * cellSize + offsetY;

      if (!cellSet.contains(Point(cell.row - 1, cell.col))) {
        canvas.drawLine(Offset(x, y), Offset(x + cellSize, y), outlinePaint);
        if (isSelected) {
          canvas.drawLine(Offset(x, y), Offset(x + cellSize, y), highlightPaint);
        }
      }
      if (!cellSet.contains(Point(cell.row + 1, cell.col))) {
        canvas.drawLine(
            Offset(x, y + cellSize), Offset(x + cellSize, y + cellSize), outlinePaint);
        if (isSelected) {
          canvas.drawLine(
              Offset(x, y + cellSize), Offset(x + cellSize, y + cellSize), highlightPaint);
        }
      }
      if (!cellSet.contains(Point(cell.row, cell.col - 1))) {
        canvas.drawLine(Offset(x, y), Offset(x, y + cellSize), outlinePaint);
        if (isSelected) {
          canvas.drawLine(Offset(x, y), Offset(x, y + cellSize), highlightPaint);
        }
      }
      if (!cellSet.contains(Point(cell.row, cell.col + 1))) {
        canvas.drawLine(
            Offset(x + cellSize, y), Offset(x + cellSize, y + cellSize), outlinePaint);
        if (isSelected) {
          canvas.drawLine(
              Offset(x + cellSize, y), Offset(x + cellSize, y + cellSize), highlightPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant GameBoardPainter oldDelegate) => true;
}

