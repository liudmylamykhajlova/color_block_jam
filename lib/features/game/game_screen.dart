import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/game_models.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/game_logger.dart';
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

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
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
  
  // Timer
  int _remainingSeconds = 0;
  Timer? _timer;
  DateTime? _pausedAt; // Track when timer was paused
  
  // Lives
  int _lives = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Listen to app lifecycle
    _lives = StorageService.getLives();
    _loadLevel();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App going to background - pause timer
      if (_timer != null) {
        _pausedAt = DateTime.now();
        _stopTimer();
        GameLogger.info('Timer paused (app backgrounded)', 'TIMER');
      }
    } else if (state == AppLifecycleState.resumed) {
      // App coming back - resume timer
      if (_pausedAt != null && _remainingSeconds > 0) {
        // Calculate time spent in background
        final backgroundDuration = DateTime.now().difference(_pausedAt!).inSeconds;
        _remainingSeconds = (_remainingSeconds - backgroundDuration).clamp(0, _level?.duration ?? AppConstants.defaultLevelDuration);
        _pausedAt = null;
        
        GameLogger.info('Timer resumed, remaining: $_remainingSeconds seconds', 'TIMER');
        
        if (_remainingSeconds <= 0) {
          _onTimeUp();
        } else {
          _startTimer();
        }
      }
    }
  }

  Future<void> _loadLevel() async {
    GameLogger.info('Loading level ${widget.levelId}...', 'INIT');
    
    try {
      final level = await LevelLoader.getLevel(widget.levelId);
      
      if (level == null) {
        GameLogger.info('Level ${widget.levelId} not found!', 'ERROR');
        if (mounted) {
          _showErrorAndGoBack('Level ${widget.levelId} not found');
        }
        return;
      }
      
      setState(() {
        _level = level;
        _remainingSeconds = level.duration;
        _isLoading = false;
        _initBlocks();
      });
      GameLogger.levelLoaded(
        level.id, 
        level.name, 
        level.blocks.length, 
        level.doors.length,
        level.hardnessText.isEmpty ? 'Normal' : level.hardnessText,
        level.duration,
      );
      _startTimer();
    } on LevelLoadException catch (e) {
      GameLogger.info('Failed to load level: $e', 'ERROR');
      if (mounted) {
        _showErrorAndGoBack('Failed to load level');
      }
    } catch (e) {
      GameLogger.info('Unexpected error loading level: $e', 'ERROR');
      if (mounted) {
        _showErrorAndGoBack('Something went wrong');
      }
    }
  }
  
  void _showErrorAndGoBack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.pop(context);
  }
  
  void _startTimer() {
    _stopTimer(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _stopTimer();
        return;
      }
      
      setState(() {
        _remainingSeconds--;
      });
      GameLogger.timerTick(_remainingSeconds);
      
      if (_remainingSeconds <= 0) {
        _stopTimer();
        _onTimeUp();
      }
    });
  }
  
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
  
  void _onTimeUp() async {
    _stopTimer();
    GameLogger.timerExpired(widget.levelId);
    
    // Lose a life
    await StorageService.loseLife();
    setState(() {
      _lives = StorageService.getLives();
    });
    
    // Show fail dialog
    if (mounted) {
      _showFailDialog();
    }
  }
  
  void _showFailDialog() {
    AudioService.playLevelFail(); // Level fail sound
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            // Level number
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'Level ${widget.levelId}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // Broken heart
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text('💔', style: TextStyle(fontSize: 60)),
                      Positioned(
                        bottom: 0,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '-1',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'You will lose 1 life!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lives remaining: $_lives',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              // Close button (X)
              GestureDetector(
                onTap: () {
                  AudioService.playTap();
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to level select
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.buttonRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              // Retry button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: _lives > 0 ? () {
                    AudioService.playTap();
                    Navigator.pop(context);
                    _resetLevel();
                  } : null,
                  child: Text(
                    _lives > 0 ? 'Retry' : 'No Lives',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
    GameLogger.levelReset(widget.levelId);
    _stopTimer();
    setState(() {
      _initBlocks();
      _remainingSeconds = _level?.duration ?? AppConstants.defaultLevelDuration;
    });
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Clean up observer
    _stopTimer();
    _exitAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _level == null) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
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
              AppColors.primaryLight,
              AppColors.primary,
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
    final isHard = _level?.isHard ?? false;
    final hardnessText = _level?.hardnessText ?? '';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Level indicator with difficulty badge
          _buildLevelBadge(isHard, hardnessText),
          
          const SizedBox(width: 12),
          
          // Lives indicator
          _buildLivesIndicator(),
          
          const Spacer(),
          
          // Timer
          _buildTimer(),
          
          const Spacer(),
          
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
  
  Widget _buildLivesIndicator() {
    final isFull = _lives >= StorageService.maxLives;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite,
            color: Colors.red,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            isFull ? 'Full' : '$_lives',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLevelBadge(bool isHard, String hardnessText) {
    final hardness = _level?.hardness ?? LevelHardness.normal;
    
    // Colors based on difficulty (matching original game)
    Color badgeColor;
    Color textColor = Colors.white;
    
    switch (hardness) {
      case LevelHardness.hard:
        badgeColor = AppColors.badgeHard;
        break;
      case LevelHardness.veryHard:
        badgeColor = AppColors.badgeVeryHard;
        break;
      default:
        badgeColor = AppColors.badgeNormal;
    }
    
    return GestureDetector(
      onTap: () {
        AudioService.playTap();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: badgeColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Skull icon for hard levels
            if (isHard) ...[
              const Text('💀', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
            ],
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Level',
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${widget.levelId}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                if (hardnessText.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hardnessText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
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
  
  Widget _buildTimer() {
    // Color changes based on remaining time
    Color timerColor;
    Color bgColor;
    
    if (_remainingSeconds <= AppConstants.timerCriticalThreshold) {
      timerColor = AppColors.timerCritical;
      bgColor = AppColors.timerCritical.withOpacity(0.2);
    } else if (_remainingSeconds <= AppConstants.timerWarningThreshold) {
      timerColor = AppColors.timerLow;
      bgColor = AppColors.timerLow.withOpacity(0.2);
    } else {
      timerColor = AppColors.timerNormal;
      bgColor = AppColors.timerNormal.withOpacity(0.15);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: timerColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clock icon
          Icon(
            Icons.access_time_filled,
            color: timerColor,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            'Time',
            style: TextStyle(
              color: timerColor.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          // Timer value
          Text(
            _formattedTime,
            style: TextStyle(
              color: timerColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
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
        GameLogger.blockSelected(block.blockType, block.gridRow, block.gridCol);
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
      final fromRow = _selectedBlock!.gridRow;
      final fromCol = _selectedBlock!.gridCol;
      setState(() {
        _selectedBlock!.gridRow += moveRow;
        _selectedBlock!.gridCol += moveCol;
        _lastCell = Point(_lastCell!.row + moveRow, _lastCell!.col + moveCol);
      });
      GameLogger.blockMoved(
        _selectedBlock!.blockType, 
        fromRow, fromCol, 
        _selectedBlock!.gridRow, _selectedBlock!.gridCol
      );
      // Спочатку перевіряємо руйнування шару при торканні дверей
      if (!_checkLayerDestruction(_selectedBlock!, level)) {
        // Якщо шар не зруйновано - перевіряємо вихід
        _checkDoorExit(level);
      }
    } else {
      // Рух заблоковано, але перевіряємо чи потрібно руйнувати шар
      // (якщо блок вже на краю і користувач тягне в бік дверей)
      _checkLayerDestructionOnPush(_selectedBlock!, moveRow, moveCol, level);
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
    // Заморожений блок не можна рухати
    if (block.isFrozen) {
      return false;
    }
    
    // Перевірка обмеження напрямку руху
    if (block.moveDirection == MoveDirection.horizontal && deltaRow != 0) {
      return false; // Горизонтальний блок не може рухатись вертикально
    }
    if (block.moveDirection == MoveDirection.vertical && deltaCol != 0) {
      return false; // Вертикальний блок не може рухатись горизонтально
    }
    
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
    
    // Використовуємо activeBlockType для багатошарових блоків
    final matchingDoors = level.doors.where((d) => d.blockType == block.activeBlockType).toList();

    for (final cell in newCells) {
      final isOutside = cell.row < 0 || cell.row >= level.gridHeight ||
          cell.col < 0 || cell.col >= level.gridWidth;
      final isHidden = level.hiddenCells.contains(cell);
      
      // Блок з внутрішнім шаром не може виходити за межі сітки
      // (він може тільки торкатись краю, де шар руйнується)
      if (isOutside && block.innerBlockType >= 0 && !block.outerLayerDestroyed) {
        return false;
      }
      
      // Check if this cell could be an exit position (outside grid OR in hidden area near a door)
      if (isOutside || isHidden) {
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
          else if (door.edge == 'left' && cell.col < door.startCol) {
            // Use door.startCol to support inner boundary doors (e.g. Level 19)
            if (cell.row >= door.startRow && cell.row < door.startRow + door.partCount) {
              canExit = true;
              break;
            }
          } 
          else if (door.edge == 'right' && cell.col > door.startCol) {
            // Use door.startCol to support inner boundary doors (e.g. Level 19)
            if (cell.row >= door.startRow && cell.row < door.startRow + door.partCount) {
              canExit = true;
              break;
            }
          }
        }
        
        if (!canExit) return false;
      }

      if (!isOutside && !isHidden) {
        for (final otherBlock in _blocks) {
          if (otherBlock == block) continue;
          if (otherBlock.cells.contains(cell)) {
            return false;
          }
        }
      }
    }

    return true;
  }

  /// Перевіряє руйнування шару коли блок вже на краю і користувач тягне в бік дверей.
  void _checkLayerDestructionOnPush(GameBlock block, int pushRow, int pushCol, GameLevel level) {
    // Тільки для блоків з внутрішнім шаром, який ще не зруйновано
    if (block.innerBlockType < 0 || block.outerLayerDestroyed) {
      return;
    }
    
    final blockCells = block.cells;
    
    // Знаходимо двері з зовнішнім кольором блоку
    final outerColorDoors = level.doors.where((d) => d.blockType == block.blockType).toList();
    
    // Перевіряємо чи блок на краю і користувач тягне в бік дверей
    for (final cell in blockCells) {
      for (final door in outerColorDoors) {
        bool pushesTowardsDoor = false;
        
        if (door.edge == 'top' && cell.row == 0 && pushRow < 0) {
          // Блок на верхньому краю, тягнуть вгору
          if (cell.col >= door.startCol && cell.col < door.startCol + door.partCount) {
            pushesTowardsDoor = true;
          }
        } else if (door.edge == 'bottom' && cell.row == level.gridHeight - 1 && pushRow > 0) {
          // Блок на нижньому краю, тягнуть вниз
          if (cell.col >= door.startCol && cell.col < door.startCol + door.partCount) {
            pushesTowardsDoor = true;
          }
        } else if (door.edge == 'left' && cell.col == 0 && pushCol < 0) {
          // Блок на лівому краю, тягнуть вліво
          if (cell.row >= door.startRow && cell.row < door.startRow + door.partCount) {
            pushesTowardsDoor = true;
          }
        } else if (door.edge == 'right' && cell.col == level.gridWidth - 1 && pushCol > 0) {
          // Блок на правому краю, тягнуть вправо
          if (cell.row >= door.startRow && cell.row < door.startRow + door.partCount) {
            pushesTowardsDoor = true;
          }
        }
        
        if (pushesTowardsDoor) {
          // Руйнуємо зовнішній шар
          GameLogger.info('Outer layer destroyed (on push) for block ${block.blockType} -> ${block.innerBlockType}', 'GAME');
          AudioService.playExit();
          
          setState(() {
            block.outerLayerDestroyed = true;
          });
          return;
        }
      }
    }
  }

  /// Перевіряє чи блок торкається дверей свого зовнішнього кольору.
  /// Якщо так і є внутрішній шар - руйнує його і повертає true.
  bool _checkLayerDestruction(GameBlock block, GameLevel level) {
    // Тільки для блоків з внутрішнім шаром, який ще не зруйновано
    if (block.innerBlockType < 0 || block.outerLayerDestroyed) {
      return false;
    }
    
    final blockCells = block.cells;
    
    // Знаходимо двері з зовнішнім кольором блоку
    final outerColorDoors = level.doors.where((d) => d.blockType == block.blockType).toList();
    
    // Перевіряємо чи блок торкається краю сітки біля дверей
    for (final cell in blockCells) {
      for (final door in outerColorDoors) {
        bool touchesDoor = false;
        
        if (door.edge == 'top' && cell.row == 0) {
          // Блок на верхньому краю
          if (cell.col >= door.startCol && cell.col < door.startCol + door.partCount) {
            touchesDoor = true;
          }
        } else if (door.edge == 'bottom' && cell.row == level.gridHeight - 1) {
          // Блок на нижньому краю
          if (cell.col >= door.startCol && cell.col < door.startCol + door.partCount) {
            touchesDoor = true;
          }
        } else if (door.edge == 'left' && cell.col == 0) {
          // Блок на лівому краю
          if (cell.row >= door.startRow && cell.row < door.startRow + door.partCount) {
            touchesDoor = true;
          }
        } else if (door.edge == 'right' && cell.col == level.gridWidth - 1) {
          // Блок на правому краю
          if (cell.row >= door.startRow && cell.row < door.startRow + door.partCount) {
            touchesDoor = true;
          }
        }
        
        if (touchesDoor) {
          // Руйнуємо зовнішній шар
          GameLogger.info('Outer layer destroyed for block ${block.blockType} -> ${block.innerBlockType}', 'GAME');
          AudioService.playExit();
          
          setState(() {
            block.outerLayerDestroyed = true;
          });
          return true;
        }
      }
    }
    
    return false;
  }

  void _checkDoorExit(GameLevel level) {
    if (_selectedBlock == null) return;

    final blockCells = _selectedBlock!.cells;
    
    int outsideCount = 0;
    int exitRow = 0;
    int exitCol = 0;
    
    for (final cell in blockCells) {
      final isHidden = level.hiddenCells.contains(cell);
      
      if (cell.row < 0) {
        outsideCount++;
        exitRow = -1;
      } else if (cell.row >= level.gridHeight) {
        outsideCount++;
        exitRow = 1;
      } else if (cell.col < 0 || (isHidden && cell.col == 0)) {
        // Also count hidden cells at col 0 as left exit (for inner boundary doors)
        outsideCount++;
        exitCol = -1;
      } else if (cell.col >= level.gridWidth || (isHidden && cell.col == level.gridWidth - 1)) {
        // Also count hidden cells at rightmost col as right exit (for inner boundary doors)
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
    
    // Determine exit direction
    String exitEdge = 'unknown';
    if (_exitDeltaRow < 0) exitEdge = 'top';
    else if (_exitDeltaRow > 0) exitEdge = 'bottom';
    else if (_exitDeltaCol < 0) exitEdge = 'left';
    else if (_exitDeltaCol > 0) exitEdge = 'right';
    
    // Блок повністю виходить
    GameLogger.blockExited(_exitingBlock!.activeBlockType, exitEdge);
    AudioService.playExit();
    
    setState(() {
      _blocks.remove(_exitingBlock);
      
      // Зменшити iceCount для всіх заморожених блоків
      _decreaseIceCountForAll();
      
      _exitingBlock = null;
      _exitProgress = 0.0;
    });
    
    _exitAnimationController?.dispose();
    _exitAnimationController = null;
    
    GameLogger.info('Blocks remaining: ${_blocks.length}', 'GAME');
    
    if (_blocks.isEmpty) {
      AudioService.playWin();
      _showWinDialog();
    }
  }
  
  /// Зменшити iceCount для всіх заморожених блоків на 1
  void _decreaseIceCountForAll() {
    for (final block in _blocks) {
      if (block.iceCount > 0) {
        block.iceCount--;
        if (block.iceCount == 0) {
          GameLogger.info('Block ${block.blockType} unfrozen!', 'GAME');
        }
      }
    }
  }

  void _showWinDialog() async {
    _stopTimer(); // Stop the timer on win
    GameLogger.levelCompleted(widget.levelId, _remainingSeconds);
    await StorageService.markLevelCompleted(widget.levelId);
    widget.onLevelComplete?.call();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfettiWidget(
        isPlaying: true,
        child: AlertDialog(
          backgroundColor: AppColors.primary,
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
                          color: AppColors.gold,
                          size: 36,
                          shadows: const [
                            Shadow(
                              color: AppColors.goldGlow,
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
                      backgroundColor: AppColors.buttonGreenAlt,
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
    final bgPaint = Paint()..color = AppColors.boardBg;
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
      ..color = AppColors.boardGrid
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
    final hiddenPaint = Paint()..color = AppColors.backgroundDark;
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
    final frameColor = AppColors.boardFrame;
    final frameHighlight = const Color(0xFF4A4A4A); // Lighter gray
    final frameShadow = const Color(0xFF1A1A1A); // Darker gray
    
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
        // Use startCol for inner boundary doors (e.g. Level 19)
        x = borderOffset + door.startCol * cellSize - frameThickness;
        y = borderOffset + door.startRow * cellSize;
        w = frameThickness;
        h = doorLength;
      } else if (door.edge == 'right') {
        // Use startCol for inner boundary doors (e.g. Level 19)
        x = borderOffset + (door.startCol + 1) * cellSize;
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
    final isSelected = block == selectedBlock;
    final isExiting = block == exitingBlock;
    final cells = block.cells;

    double offsetX = 0;
    double offsetY = 0;
    if (isExiting) {
      offsetX = exitDeltaCol * exitProgress * cellSize * 3;
      offsetY = exitDeltaRow * exitProgress * cellSize * 3;
    }
    
    // Визначаємо кольори для блоку
    final Color fillColor;
    final Color borderColor;
    final bool showOuterBorder;
    
    if (block.outerLayerDestroyed) {
      // Зовнішній шар зруйновано - блок тепер повністю кольору inner layer
      fillColor = GameColors.getColor(block.innerBlockType);
      borderColor = fillColor;
      showOuterBorder = false;
    } else if (block.hasInnerLayer) {
      // Inner layer: заливка = innerBlockType, обводка = blockType
      fillColor = GameColors.getColor(block.innerBlockType);
      borderColor = GameColors.getColor(block.blockType);
      showOuterBorder = true;
    } else {
      fillColor = GameColors.getColor(block.blockType);
      borderColor = fillColor;
      showOuterBorder = false;
    }

    // Draw selection glow
    if (isSelected) {
      final glowPaint = Paint()
        ..color = fillColor.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      
      final glowPath = Path();
      for (final cell in cells) {
        final x = borderOffset + cell.col * cellSize + offsetX;
        final y = borderOffset + cell.row * cellSize + offsetY;
        glowPath.addRect(Rect.fromLTWH(x - 4, y - 4, cellSize + 8, cellSize + 8));
      }
      canvas.drawPath(glowPath, glowPaint);
    }
    
    final paint = Paint()..color = isSelected ? fillColor.withOpacity(0.95) : fillColor;
    
    final path = Path();
    for (final cell in cells) {
      final x = borderOffset + cell.col * cellSize + offsetX;
      final y = borderOffset + cell.row * cellSize + offsetY;
      path.addRect(Rect.fromLTWH(x, y, cellSize, cellSize));
    }
    canvas.drawPath(path, paint);

    // Товста обводка для inner layer блоків (якщо зовнішній шар не зруйновано)
    if (showOuterBorder) {
      final borderWidth = cellSize * 0.12;
      final cellSet = cells.toSet();
      
      for (final cell in cells) {
        final x = borderOffset + cell.col * cellSize + offsetX;
        final y = borderOffset + cell.row * cellSize + offsetY;
        
        final borderPaint = Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;
        
        // Малюємо обводку тільки на зовнішніх краях
        if (!cellSet.contains(Point(cell.row - 1, cell.col))) {
          canvas.drawLine(Offset(x, y + borderWidth/2), Offset(x + cellSize, y + borderWidth/2), borderPaint);
        }
        if (!cellSet.contains(Point(cell.row + 1, cell.col))) {
          canvas.drawLine(Offset(x, y + cellSize - borderWidth/2), Offset(x + cellSize, y + cellSize - borderWidth/2), borderPaint);
        }
        if (!cellSet.contains(Point(cell.row, cell.col - 1))) {
          canvas.drawLine(Offset(x + borderWidth/2, y), Offset(x + borderWidth/2, y + cellSize), borderPaint);
        }
        if (!cellSet.contains(Point(cell.row, cell.col + 1))) {
          canvas.drawLine(Offset(x + cellSize - borderWidth/2, y), Offset(x + cellSize - borderWidth/2, y + cellSize), borderPaint);
        }
      }
    }
    
    // LEGO stud (маленький круг по центру)
    final studRadius = cellSize * 0.2;
    final studColor = fillColor;
    
    final studPaintLight = Paint()
      ..color = Color.lerp(studColor, Colors.white, 0.25)!;
    final studPaintDark = Paint()
      ..color = Color.lerp(studColor, Colors.black, 0.1)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    for (final cell in cells) {
      final cx = borderOffset + cell.col * cellSize + cellSize / 2 + offsetX;
      final cy = borderOffset + cell.row * cellSize + cellSize / 2 + offsetY;
      
      canvas.drawCircle(Offset(cx, cy), studRadius, studPaintLight);
      canvas.drawCircle(Offset(cx, cy), studRadius, studPaintDark);
    }

    _drawBlockOutline(canvas, cells, borderOffset, fillColor, isSelected, offsetX, offsetY);
    
    // Малюємо стрілки напрямку руху
    if (block.moveDirection != MoveDirection.both) {
      _drawMoveDirectionArrows(canvas, block, cells, borderOffset, offsetX, offsetY);
    }
    
    // Малюємо шар льоду для заморожених блоків
    if (block.isFrozen) {
      _drawIceOverlay(canvas, block, cells, borderOffset, offsetX, offsetY);
    }
  }
  
  void _drawMoveDirectionArrows(Canvas canvas, GameBlock block, List<Point> cells,
      double borderOffset, double offsetX, double offsetY) {
    // Знаходимо центр для розміщення стрілок
    double centerX, centerY;
    final gt = block.blockGroupType;
    final cellSet = cells.map((c) => '${c.col},${c.row}').toSet();
    
    // Спеціальна обробка для різних типів блоків
    final isLShape = (gt >= 3 && gt <= 4) && cells.length >= 4; // L і ReverseL
    final isShortL = gt == 5 && cells.length >= 3; // ShortL
    final isTShape = gt == 8 && cells.length >= 4; // ShortT
    
    if (isShortL) {
      // Для ShortL: розміщуємо стрілку на частині, що відповідає напрямку руху
      final rows = <int, List<Point>>{};
      final cols = <int, List<Point>>{};
      for (final c in cells) {
        rows.putIfAbsent(c.row, () => []).add(c);
        cols.putIfAbsent(c.col, () => []).add(c);
      }
      
      // Знаходимо найдовші горизонтальні та вертикальні лінії
      List<Point> horizPart = [];
      List<Point> vertPart = [];
      for (final rowCells in rows.values) {
        if (rowCells.length > horizPart.length) horizPart = rowCells;
      }
      for (final colCells in cols.values) {
        if (colCells.length > vertPart.length) vertPart = colCells;
      }
      
      // Обираємо частину на основі moveDirection
      List<Point> targetPart;
      if (block.moveDirection == MoveDirection.vertical) {
        targetPart = vertPart.length >= 2 ? vertPart : cells;
      } else {
        targetPart = horizPart.length >= 2 ? horizPart : cells;
      }
      
      double sumCol = 0, sumRow = 0;
      for (final c in targetPart) {
        sumCol += c.col;
        sumRow += c.row;
      }
      centerX = borderOffset + (sumCol / targetPart.length + 0.5) * cellSize + offsetX;
      centerY = borderOffset + (sumRow / targetPart.length + 0.5) * cellSize + offsetY;
      
    } else if (isLShape || isTShape) {
      // Знаходимо клітинку з найбільшою кількістю сусідів (кут L або центр T)
      Point? pivotCell;
      int maxNeighbors = 0;
      
      for (final cell in cells) {
        final neighbors = [
          '${cell.col - 1},${cell.row}',
          '${cell.col + 1},${cell.row}',
          '${cell.col},${cell.row - 1}',
          '${cell.col},${cell.row + 1}',
        ].where((n) => cellSet.contains(n)).length;
        
        // Для L: кут має 2 сусіди
        // Для T: центр має 3 сусіди
        if (isLShape && neighbors == 2) {
          pivotCell = cell;
        } else if (isTShape && neighbors >= maxNeighbors) {
          maxNeighbors = neighbors;
          pivotCell = cell;
        }
      }
      
      if (pivotCell != null) {
        // Знаходимо довгу частину (3 клітинки в лінію)
        final inRow = cells.where((c) => c.row == pivotCell!.row).toList();
        final inCol = cells.where((c) => c.col == pivotCell!.col).toList();
        
        List<Point> longPart;
        if (inRow.length >= 3) {
          longPart = inRow;
        } else if (inCol.length >= 3) {
          longPart = inCol;
        } else if (inRow.length >= 2) {
          longPart = inRow;
        } else if (inCol.length >= 2) {
          longPart = inCol;
        } else {
          longPart = cells;
        }
        
        double sumCol = 0, sumRow = 0;
        for (final c in longPart) {
          sumCol += c.col;
          sumRow += c.row;
        }
        centerX = borderOffset + (sumCol / longPart.length + 0.5) * cellSize + offsetX;
        centerY = borderOffset + (sumRow / longPart.length + 0.5) * cellSize + offsetY;
      } else {
        // Fallback до центру bounding box
        int minCol = cells.first.col, maxCol = cells.first.col;
        int minRow = cells.first.row, maxRow = cells.first.row;
        for (final c in cells) {
          if (c.col < minCol) minCol = c.col;
          if (c.col > maxCol) maxCol = c.col;
          if (c.row < minRow) minRow = c.row;
          if (c.row > maxRow) maxRow = c.row;
        }
        centerX = borderOffset + (minCol + maxCol + 1) / 2 * cellSize + offsetX;
        centerY = borderOffset + (minRow + maxRow + 1) / 2 * cellSize + offsetY;
      }
    } else {
      // Для інших блоків використовуємо центр bounding box
      int minCol = cells.first.col, maxCol = cells.first.col;
      int minRow = cells.first.row, maxRow = cells.first.row;
      for (final c in cells) {
        if (c.col < minCol) minCol = c.col;
        if (c.col > maxCol) maxCol = c.col;
        if (c.row < minRow) minRow = c.row;
        if (c.row > maxRow) maxRow = c.row;
      }
      centerX = borderOffset + (minCol + maxCol + 1) / 2 * cellSize + offsetX;
      centerY = borderOffset + (minRow + maxRow + 1) / 2 * cellSize + offsetY;
    }
    
    final arrowSize = cellSize * 0.3;
    
    final arrowFillPaint = Paint()
      ..color = Colors.white.withOpacity(0.9);
    final arrowStrokePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    if (block.moveDirection == MoveDirection.horizontal) {
      // HORIZ - малюємо стрілки вліво/вправо
      // Ліва стрілка
      final leftPath = Path();
      leftPath.moveTo(centerX - arrowSize, centerY);
      leftPath.lineTo(centerX - arrowSize * 0.3, centerY - arrowSize * 0.4);
      leftPath.lineTo(centerX - arrowSize * 0.3, centerY + arrowSize * 0.4);
      leftPath.close();
      canvas.drawPath(leftPath, arrowFillPaint);
      
      // Права стрілка
      final rightPath = Path();
      rightPath.moveTo(centerX + arrowSize, centerY);
      rightPath.lineTo(centerX + arrowSize * 0.3, centerY - arrowSize * 0.4);
      rightPath.lineTo(centerX + arrowSize * 0.3, centerY + arrowSize * 0.4);
      rightPath.close();
      canvas.drawPath(rightPath, arrowFillPaint);
      
      // Лінія між стрілками
      canvas.drawLine(
        Offset(centerX - arrowSize * 0.3, centerY),
        Offset(centerX + arrowSize * 0.3, centerY),
        arrowStrokePaint,
      );
    } else if (block.moveDirection == MoveDirection.vertical) {
      // VERT - малюємо стрілки вгору/вниз
      // Верхня стрілка
      final upPath = Path();
      upPath.moveTo(centerX, centerY - arrowSize);
      upPath.lineTo(centerX - arrowSize * 0.4, centerY - arrowSize * 0.3);
      upPath.lineTo(centerX + arrowSize * 0.4, centerY - arrowSize * 0.3);
      upPath.close();
      canvas.drawPath(upPath, arrowFillPaint);
      
      // Нижня стрілка
      final downPath = Path();
      downPath.moveTo(centerX, centerY + arrowSize);
      downPath.lineTo(centerX - arrowSize * 0.4, centerY + arrowSize * 0.3);
      downPath.lineTo(centerX + arrowSize * 0.4, centerY + arrowSize * 0.3);
      downPath.close();
      canvas.drawPath(downPath, arrowFillPaint);
      
      // Лінія між стрілками
      canvas.drawLine(
        Offset(centerX, centerY - arrowSize * 0.3),
        Offset(centerX, centerY + arrowSize * 0.3),
        arrowStrokePaint,
      );
    }
  }
  
  void _drawIceOverlay(Canvas canvas, GameBlock block, List<Point> cells,
      double borderOffset, double offsetX, double offsetY) {
    // Напівпрозорий блакитний шар льоду
    final icePaint = Paint()
      ..color = const Color(0xFF87CEFA).withOpacity(0.5); // Light sky blue
    
    // Кристалічний візерунок (діагональні лінії)
    final patternPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1;
    
    // Малюємо лід на кожній клітинці
    for (final cell in cells) {
      final x = borderOffset + cell.col * cellSize + offsetX;
      final y = borderOffset + cell.row * cellSize + offsetY;
      final cellRect = Rect.fromLTWH(x + 2, y + 2, cellSize - 4, cellSize - 4);
      
      // Обмежуємо малювання межами клітинки
      canvas.save();
      canvas.clipRect(cellRect);
      
      // Шар льоду
      canvas.drawRect(cellRect, icePaint);
      
      // Кристалічний візерунок
      for (double i = -cellSize; i < cellSize * 2; i += 8) {
        canvas.drawLine(
          Offset(x + i, y),
          Offset(x + i + cellSize, y + cellSize),
          patternPaint,
        );
      }
      
      canvas.restore();
    }
    
    // Знаходимо центр блоку для числа
    int minCol = cells.first.col, maxCol = cells.first.col;
    int minRow = cells.first.row, maxRow = cells.first.row;
    for (final c in cells) {
      if (c.col < minCol) minCol = c.col;
      if (c.col > maxCol) maxCol = c.col;
      if (c.row < minRow) minRow = c.row;
      if (c.row > maxRow) maxRow = c.row;
    }
    final iceCenterX = borderOffset + (minCol + maxCol + 1) / 2 * cellSize + offsetX;
    final iceCenterY = borderOffset + (minRow + maxRow + 1) / 2 * cellSize + offsetY;
    
    // Білий круг під числом
    final circleRadius = cellSize * 0.35;
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.9);
    final circleBorderPaint = Paint()
      ..color = const Color(0xFF0096C8).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(Offset(iceCenterX, iceCenterY), circleRadius, circlePaint);
    canvas.drawCircle(Offset(iceCenterX, iceCenterY), circleRadius, circleBorderPaint);
    
    // Число iceCount
    final textPainter = TextPainter(
      text: TextSpan(
        text: block.iceCount.toString(),
        style: TextStyle(
          color: const Color(0xFF0088AA),
          fontSize: cellSize * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(iceCenterX - textPainter.width / 2, iceCenterY - textPainter.height / 2),
    );
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

