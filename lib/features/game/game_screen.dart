import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/game_models.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/game_logger.dart';
import '../../core/widgets/confetti_widget.dart';
import 'widgets/coins_widget.dart';
import 'widgets/boosters_bar.dart';
import 'widgets/win_dialog.dart';
import 'widgets/freeze_indicator.dart';
import 'widgets/freeze_overlay.dart';
import 'widgets/rocket_overlay.dart';
import 'widgets/rocket_animation.dart';
import 'widgets/hammer_overlay.dart';
import 'widgets/hammer_animation.dart';
import 'widgets/vacuum_overlay.dart';
import 'widgets/vacuum_animation.dart';

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
  
  // Freeze effect
  bool _isFrozen = false;
  int _freezeRemainingSeconds = 0;
  Timer? _freezeTimer;
  
  // Rocket mode
  bool _isRocketMode = false;
  double _currentCellSize = 0;
  
  // Rocket animation
  bool _isRocketAnimating = false;
  Offset? _rocketStartPos;
  Offset? _rocketEndPos;
  GameBlock? _pendingDestroyBlock;
  Point? _pendingDestroyCell;
  bool _showExplosion = false;
  final GlobalKey _boostersBarKey = GlobalKey();
  final GlobalKey _gameBoardKey = GlobalKey();
  
  // Hammer mode
  bool _isHammerMode = false;
  
  // Hammer animation
  bool _isHammerAnimating = false;
  Offset? _hammerStartPos;
  Offset? _hammerEndPos;
  GameBlock? _pendingHammerDestroyBlock;
  bool _showBigExplosion = false;
  double _bigExplosionSize = 100;
  
  // Vacuum mode
  bool _isVacuumMode = false;
  bool _isVacuumAnimating = false;
  List<GameBlock> _pendingVacuumBlocks = [];
  final VacuumAnimationController _vacuumController = VacuumAnimationController();
  
  // Lives
  int _lives = 5;
  
  // Coins (placeholder - will be from StorageService)
  int _coins = 1480;
  
  // Boosters
  List<BoosterData> _boosters = BoostersBar.defaultBoosters;

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
      // App going to background - pause timers and reset states
      _cancelRocketMode(); // Reset rocket mode
      _cancelHammerMode(); // Reset hammer mode
      _cancelVacuumMode(); // Reset vacuum mode
      if (_timer != null) {
        _pausedAt = DateTime.now();
        _stopTimer();
        _stopFreezeTimer(); // Also stop freeze timer
        GameLogger.info('Timer paused (app backgrounded)', 'TIMER');
      }
    } else if (state == AppLifecycleState.resumed) {
      // App coming back - resume timers
      if (_pausedAt != null && _remainingSeconds > 0) {
        final backgroundDuration = DateTime.now().difference(_pausedAt!).inSeconds;
        
        // Handle freeze timer if it was active
        if (_isFrozen && _freezeRemainingSeconds > 0) {
          _freezeRemainingSeconds = (_freezeRemainingSeconds - backgroundDuration).clamp(0, AppConstants.freezeBoosterDuration);
          if (_freezeRemainingSeconds <= 0) {
            _endFreeze();
          } else {
            _startFreezeTimer();
          }
          // Don't subtract from game timer if we were frozen
        } else {
          // Only subtract from game timer if not frozen
          _remainingSeconds = (_remainingSeconds - backgroundDuration).clamp(0, _level?.duration ?? AppConstants.defaultLevelDuration);
        }
        
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
      
      // Don't count down if frozen
      if (_isFrozen) return;
      
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
  
  void _startFreezeTimer() {
    _stopFreezeTimer();
    _freezeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _stopFreezeTimer();
        return;
      }
      
      setState(() {
        _freezeRemainingSeconds--;
      });
      
      if (_freezeRemainingSeconds <= 0) {
        _stopFreezeTimer();
        _endFreeze();
      }
    });
  }
  
  void _stopFreezeTimer() {
    _freezeTimer?.cancel();
    _freezeTimer = null;
  }
  
  void _activateFreeze() {
    if (_isFrozen) return; // Already frozen
    
    AudioService.playTap(); // Audio feedback for freeze activation
    
    setState(() {
      _isFrozen = true;
      _freezeRemainingSeconds = AppConstants.freezeBoosterDuration;
    });
    
    GameLogger.info('Freeze activated for ${AppConstants.freezeBoosterDuration} seconds', 'BOOSTER');
    _startFreezeTimer();
  }
  
  void _endFreeze() {
    setState(() {
      _isFrozen = false;
      _freezeRemainingSeconds = 0;
    });
    
    GameLogger.info('Freeze ended', 'BOOSTER');
  }
  
  void _onTimeUp() async {
    _stopTimer();
    _stopFreezeTimer(); // Stop freeze timer
    if (_isFrozen) _endFreeze(); // Reset freeze state
    _cancelRocketMode(); // Reset rocket mode
    _cancelHammerMode(); // Reset hammer mode
    _cancelVacuumMode(); // Reset vacuum mode
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
    _cancelRocketMode(); // Reset rocket mode
    _cancelHammerMode(); // Reset hammer mode
    _cancelVacuumMode(); // Reset vacuum mode
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
    _stopFreezeTimer(); // Stop freeze timer
    setState(() {
      _isFrozen = false; // Reset freeze state
      _freezeRemainingSeconds = 0;
      _isRocketMode = false; // Reset rocket mode
      _isRocketAnimating = false;
      _showExplosion = false;
      _rocketStartPos = null;
      _rocketEndPos = null;
      _pendingDestroyBlock = null;
      _pendingDestroyCell = null;
      _isHammerMode = false; // Reset hammer mode
      _isHammerAnimating = false;
      _showBigExplosion = false;
      _hammerStartPos = null;
      _hammerEndPos = null;
      _pendingHammerDestroyBlock = null;
      _isVacuumMode = false; // Reset vacuum mode
      _isVacuumAnimating = false;
      _pendingVacuumBlocks = [];
      _initBlocks();
      _remainingSeconds = _level?.duration ?? AppConstants.defaultLevelDuration;
    });
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Clean up observer
    _stopTimer();
    _stopFreezeTimer();
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
      body: FreezeOverlay(
        isActive: _isFrozen,
        child: Container(
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
            child: Stack(
              children: [
                Column(
                  children: [
                    // Top bar
                    _buildTopBar(),
                    
                    // Freeze indicator (shown when frozen)
                    FreezeIndicator(
                      remainingSeconds: _freezeRemainingSeconds,
                      isVisible: _isFrozen,
                    ),
                    
                    // Game board
                    Expanded(
                      child: Center(
                        child: _buildGameBoard(),
                      ),
                    ),
                    
                    // Bottom boosters bar
                    BoostersBar(
                      key: _boostersBarKey,
                      boosters: _boosters,
                      onBoosterTap: (_isRocketMode || _isHammerMode || _isVacuumMode) ? null : _onBoosterTap,
                      onPauseTap: (_isRocketMode || _isHammerMode || _isVacuumMode) ? null : _onPauseTap,
                    ),
                    
                    // Bottom safe area
                    const SizedBox(height: 8),
                  ],
                ),
                
                // Rocket tooltip (on top of everything when active)
                if (_isRocketMode)
                  RocketOverlay(
                    isActive: _isRocketMode,
                    onCancel: _cancelRocketMode,
                  ),
                
                // Rocket flying animation
                if (_isRocketAnimating && _rocketStartPos != null && _rocketEndPos != null)
                  RocketAnimation(
                    startPosition: _rocketStartPos!,
                    endPosition: _rocketEndPos!,
                    onComplete: _onRocketAnimationComplete,
                  ),
                
                // Explosion animation
                if (_showExplosion && _rocketEndPos != null)
                  ExplosionAnimation(
                    position: _rocketEndPos!,
                    onComplete: _onExplosionComplete,
                  ),
                
                // Hammer tooltip (on top of everything when active)
                if (_isHammerMode)
                  HammerOverlay(
                    isActive: _isHammerMode,
                    onCancel: _cancelHammerMode,
                  ),
                
                // Hammer flying animation
                if (_isHammerAnimating && _hammerStartPos != null && _hammerEndPos != null)
                  HammerAnimation(
                    startPosition: _hammerStartPos!,
                    endPosition: _hammerEndPos!,
                    onComplete: _onHammerAnimationComplete,
                  ),
                
                // Big explosion animation for hammer
                if (_showBigExplosion && _hammerEndPos != null)
                  BigExplosionAnimation(
                    position: _hammerEndPos!,
                    size: _bigExplosionSize,
                    onComplete: _onBigExplosionComplete,
                  ),
                
                // Vacuum tooltip (on top of everything when active)
                if (_isVacuumMode)
                  VacuumOverlay(
                    isActive: _isVacuumMode,
                    onCancel: _cancelVacuumMode,
                  ),
                
                // Vacuum animation overlay (always rendered to keep controller attached)
                VacuumAnimationOverlay(
                  controller: _vacuumController,
                  onComplete: _onVacuumAnimationComplete,
                ),
              ],
            ),
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
          
          const SizedBox(width: 8),
          
          // Coins display
          CoinsWidget(
            coins: _coins,
            onTap: _showShopDialog,
          ),
        ],
      ),
    );
  }
  
  void _showShopDialog() {
    AudioService.playTap();
    // TODO: Implement shop dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shop coming soon!'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  
  void _onBoosterTap(BoosterType type) {
    AudioService.playTap();
    
    switch (type) {
      case BoosterType.freeze:
        _useFreezeBooster();
        break;
      case BoosterType.rocket:
        _useRocketBooster();
        break;
      case BoosterType.hammer:
        _useHammerBooster();
        break;
      case BoosterType.vacuum:
        _useVacuumBooster();
        break;
      case BoosterType.pause:
        // Handled by onPauseTap
        break;
    }
  }
  
  void _useFreezeBooster() {
    final boosterIndex = _boosters.indexWhere((b) => b.type == BoosterType.freeze);
    if (boosterIndex == -1) return;
    
    final booster = _boosters[boosterIndex];
    if (booster.quantity <= 0) {
      _showBoosterNotImplemented('No boosters left!');
      return;
    }
    
    // Decrease booster count
    setState(() {
      _boosters = List.from(_boosters);
      _boosters[boosterIndex] = BoosterData(
        type: BoosterType.freeze,
        quantity: booster.quantity - 1,
      );
    });
    
    // Activate freeze effect
    _activateFreeze();
  }
  
  void _useRocketBooster() {
    final boosterIndex = _boosters.indexWhere((b) => b.type == BoosterType.rocket);
    if (boosterIndex == -1) return;
    
    final booster = _boosters[boosterIndex];
    if (booster.quantity <= 0) {
      _showBoosterNotImplemented('No rocket boosters left!');
      return;
    }
    
    // Enter rocket mode (don't consume booster until used)
    setState(() {
      _isRocketMode = true;
    });
    
    GameLogger.info('Rocket mode activated', 'BOOSTER');
  }
  
  void _onRocketCellTap(GameBlock block, Point cell, Offset tapPosition) {
    if (!_isRocketMode || _isRocketAnimating) return;
    
    // Consume booster first
    final boosterIndex = _boosters.indexWhere((b) => b.type == BoosterType.rocket);
    if (boosterIndex != -1) {
      final booster = _boosters[boosterIndex];
      setState(() {
        _boosters = List.from(_boosters);
        _boosters[boosterIndex] = BoosterData(
          type: BoosterType.rocket,
          quantity: booster.quantity - 1,
        );
      });
    }
    
    // Get booster button position (start of animation)
    // BoostersBar layout: 5 buttons (56px each) + 4 spacings (12px each) = 328px total, centered
    // Rocket is button index 1 (second from left)
    final screenWidth = MediaQuery.of(context).size.width;
    final totalBarWidth = 56.0 * 5 + 12.0 * 4; // 328px
    final barStartX = (screenWidth - totalBarWidth) / 2;
    final rocketButtonCenterX = barStartX + 56 + 12 + 28; // First button + spacing + half of rocket button
    
    Offset startPos = Offset(rocketButtonCenterX, MediaQuery.of(context).size.height - 60);
    
    // Try to get actual Y position from BoostersBar
    final RenderBox? boostersBox = _boostersBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (boostersBox != null) {
      final boostersPos = boostersBox.localToGlobal(Offset.zero);
      startPos = Offset(rocketButtonCenterX, boostersPos.dy + 28); // Center of button vertically
    }
    
    // Use tap position directly - it's already in global coordinates
    final endPos = tapPosition;
    
    // Store pending destruction info
    _pendingDestroyBlock = block;
    _pendingDestroyCell = cell;
    
    // Exit rocket mode and start animation
    setState(() {
      _isRocketMode = false;
      _isRocketAnimating = true;
      _rocketStartPos = startPos;
      _rocketEndPos = endPos;
    });
    
    GameLogger.info('Rocket animation started to (${cell.row}, ${cell.col})', 'BOOSTER');
  }
  
  void _onRocketAnimationComplete() {
    // Play sound and show explosion
    AudioService.playExit();
    
    setState(() {
      _isRocketAnimating = false;
      _showExplosion = true;
    });
  }
  
  void _onExplosionComplete() {
    setState(() {
      _showExplosion = false;
    });
    
    // Now execute the actual destruction
    _executeRocketDestroy();
  }
  
  void _executeRocketDestroy() {
    if (_pendingDestroyBlock == null || _pendingDestroyCell == null) return;
    
    final block = _pendingDestroyBlock!;
    final cell = _pendingDestroyCell!;
    
    // Clear pending state
    _pendingDestroyBlock = null;
    _pendingDestroyCell = null;
    _rocketStartPos = null;
    _rocketEndPos = null;
    
    // Remove the cell from block
    block.removeUnit(cell);
    
    GameLogger.info('Rocket destroyed cell at (${cell.row}, ${cell.col}) from block ${block.blockType}', 'BOOSTER');
    
    // Check if block has no remaining cells
    if (!block.hasRemainingCells) {
      GameLogger.info('Block ${block.blockType} completely destroyed!', 'BOOSTER');
      setState(() {
        _blocks.remove(block);
        _decreaseIceCountForAll();
      });
      
      // Check win condition
      if (_blocks.isEmpty) {
        AudioService.playWin();
        _showWinDialog();
      }
    } else {
      // Just trigger rebuild to show new shape
      setState(() {});
    }
  }
  
  void _cancelRocketMode() {
    setState(() {
      _isRocketMode = false;
      _isRocketAnimating = false;
      _showExplosion = false;
      _rocketStartPos = null;
      _rocketEndPos = null;
      _pendingDestroyBlock = null;
      _pendingDestroyCell = null;
    });
    GameLogger.info('Rocket mode cancelled', 'BOOSTER');
  }
  
  void _onRocketTap(TapUpDetails details, double cellSize, GameLevel level) {
    final cell = _getCellFromPosition(details.localPosition, cellSize, level);
    if (cell == null) {
      // Tapped outside board - cancel rocket mode
      _cancelRocketMode();
      return;
    }
    
    // Find which block contains this cell
    for (final block in _blocks) {
      if (block.cells.contains(cell)) {
        _onRocketCellTap(block, cell, details.globalPosition);
        return;
      }
    }
    
    // Tapped empty cell - cancel rocket mode
    _cancelRocketMode();
  }
  
  // === Hammer Booster Methods ===
  
  void _useHammerBooster() {
    final boosterIndex = _boosters.indexWhere((b) => b.type == BoosterType.hammer);
    if (boosterIndex == -1) return;
    
    final booster = _boosters[boosterIndex];
    if (booster.quantity <= 0) return;
    
    AudioService.playTap();
    setState(() {
      _isHammerMode = true;
    });
    
    GameLogger.info('Hammer mode activated', 'BOOSTER');
  }
  
  void _onHammerBlockTap(GameBlock block, Offset tapPosition) {
    if (!_isHammerMode || _isHammerAnimating) return;
    
    // Consume booster first
    final boosterIndex = _boosters.indexWhere((b) => b.type == BoosterType.hammer);
    if (boosterIndex != -1) {
      final booster = _boosters[boosterIndex];
      setState(() {
        _boosters = List.from(_boosters);
        _boosters[boosterIndex] = BoosterData(
          type: BoosterType.hammer,
          quantity: booster.quantity - 1,
        );
      });
    }
    
    // Store pending destruction info
    _pendingHammerDestroyBlock = block;
    
    // Calculate explosion size based on block size
    _bigExplosionSize = block.cells.length * 25.0 + 50;
    
    // Exit hammer mode and start strike animation
    // Animation strikes at tap position (center of tapped cell)
    setState(() {
      _isHammerMode = false;
      _isHammerAnimating = true;
      _hammerStartPos = tapPosition; // Not used in new animation, but kept for API
      _hammerEndPos = tapPosition;   // Target position
    });
    
    GameLogger.info('Hammer strike at block (${block.gridRow}, ${block.gridCol})', 'BOOSTER');
  }
  
  void _onHammerAnimationComplete() {
    setState(() {
      _isHammerAnimating = false;
      _showBigExplosion = true;
    });
    
    // Play explosion sound
    AudioService.playTap();
  }
  
  void _onBigExplosionComplete() {
    // Now actually destroy the block
    if (_pendingHammerDestroyBlock != null) {
      setState(() {
        _blocks.remove(_pendingHammerDestroyBlock);
        _showBigExplosion = false;
        _hammerStartPos = null;
        _hammerEndPos = null;
        _pendingHammerDestroyBlock = null;
      });
      
      GameLogger.info('Block destroyed by hammer', 'BOOSTER');
      
      // Check win condition
      if (_blocks.isEmpty) {
        AudioService.playWin();
        _showWinDialog();
      }
    }
  }
  
  void _cancelHammerMode() {
    setState(() {
      _isHammerMode = false;
      _isHammerAnimating = false;
      _showBigExplosion = false;
      _hammerStartPos = null;
      _hammerEndPos = null;
      _pendingHammerDestroyBlock = null;
    });
    GameLogger.info('Hammer mode cancelled', 'BOOSTER');
  }
  
  void _onHammerTap(TapUpDetails details, double cellSize, GameLevel level) {
    final cell = _getCellFromPosition(details.localPosition, cellSize, level);
    if (cell == null) {
      // Tapped outside board - cancel hammer mode
      _cancelHammerMode();
      return;
    }
    
    // Find which block contains this cell
    for (final block in _blocks) {
      if (block.cells.contains(cell)) {
        _onHammerBlockTap(block, details.globalPosition);
        return;
      }
    }
    
    // Tapped empty cell - cancel hammer mode
    _cancelHammerMode();
  }
  
  // === Vacuum Booster Methods ===
  
  void _useVacuumBooster() {
    final boosterIndex = _boosters.indexWhere((b) => b.type == BoosterType.vacuum);
    if (boosterIndex == -1) return;
    
    final booster = _boosters[boosterIndex];
    if (booster.quantity <= 0) return;
    
    AudioService.playTap();
    setState(() {
      _isVacuumMode = true;
    });
    
    GameLogger.info('Vacuum mode activated', 'BOOSTER');
  }
  
  void _onVacuumBlockTap(GameBlock block) {
    if (!_isVacuumMode || _isVacuumAnimating) return;
    
    // Find all blocks of the same color
    final targetColor = block.blockType;
    final blocksToVacuum = _blocks.where((b) => b.blockType == targetColor).toList();
    
    if (blocksToVacuum.isEmpty) return;
    
    // Consume booster
    final boosterIndex = _boosters.indexWhere((b) => b.type == BoosterType.vacuum);
    if (boosterIndex != -1) {
      final booster = _boosters[boosterIndex];
      setState(() {
        _boosters = List.from(_boosters);
        _boosters[boosterIndex] = BoosterData(
          type: BoosterType.vacuum,
          quantity: booster.quantity - 1,
        );
      });
    }
    
    // Store blocks to remove
    _pendingVacuumBlocks = blocksToVacuum;
    
    // Get game board global position for proper coordinate conversion
    final RenderBox? boardBox = _gameBoardKey.currentContext?.findRenderObject() as RenderBox?;
    final boardOffset = boardBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    // Add padding (8px) to account for container padding
    final contentOffset = boardOffset + const Offset(8, 8);
    
    // Calculate block rectangles for animation (in global screen coordinates)
    final blockRects = <Rect>[];
    final blockColors = <Color>[];
    
    for (final b in blocksToVacuum) {
      // Get bounding rect of block cells
      if (b.cells.isNotEmpty) {
        final minRow = b.cells.map((c) => c.row).reduce((a, b) => a < b ? a : b);
        final maxRow = b.cells.map((c) => c.row).reduce((a, b) => a > b ? a : b);
        final minCol = b.cells.map((c) => c.col).reduce((a, b) => a < b ? a : b);
        final maxCol = b.cells.map((c) => c.col).reduce((a, b) => a > b ? a : b);
        
        // Convert to global screen coordinates
        final cellSize = _currentCellSize;
        final left = contentOffset.dx + (minCol + 1) * cellSize;
        final top = contentOffset.dy + (minRow + 1) * cellSize;
        final width = (maxCol - minCol + 1) * cellSize;
        final height = (maxRow - minRow + 1) * cellSize;
        
        blockRects.add(Rect.fromLTWH(left, top, width, height));
        blockColors.add(GameColors.getColor(b.blockType));
      }
    }
    
    // Exit vacuum mode and start animation
    setState(() {
      _isVacuumMode = false;
      _isVacuumAnimating = true;
    });
    
    // Start animation
    _vacuumController.startVacuum(blockRects, blockColors);
    
    GameLogger.info('Vacuum started: ${blocksToVacuum.length} blocks of color $targetColor', 'BOOSTER');
  }
  
  void _onVacuumAnimationComplete() {
    // Play destruction sound
    AudioService.playDrop();
    
    // Remove all vacuumed blocks
    setState(() {
      for (final block in _pendingVacuumBlocks) {
        _blocks.remove(block);
      }
      _isVacuumAnimating = false;
      _pendingVacuumBlocks = [];
    });
    
    GameLogger.info('Vacuum complete: blocks removed', 'BOOSTER');
    
    // Check win condition
    if (_blocks.isEmpty) {
      AudioService.playWin();
      _showWinDialog();
    }
  }
  
  void _cancelVacuumMode() {
    setState(() {
      _isVacuumMode = false;
      _isVacuumAnimating = false;
      _pendingVacuumBlocks = [];
    });
    GameLogger.info('Vacuum mode cancelled', 'BOOSTER');
  }
  
  void _onVacuumTap(TapUpDetails details, double cellSize, GameLevel level) {
    final cell = _getCellFromPosition(details.localPosition, cellSize, level);
    if (cell == null) {
      _cancelVacuumMode();
      return;
    }
    
    // Find which block contains this cell
    for (final block in _blocks) {
      if (block.cells.contains(cell)) {
        _onVacuumBlockTap(block);
        return;
      }
    }
    
    // Tapped empty cell - cancel vacuum mode
    _cancelVacuumMode();
  }
  
  void _onPauseTap() {
    AudioService.playTap();
    _stopTimer();
    _stopFreezeTimer(); // Also stop freeze timer during pause
    _cancelRocketMode(); // Reset rocket mode
    _cancelHammerMode(); // Reset hammer mode
    _cancelVacuumMode(); // Reset vacuum mode
    _showPauseDialog();
  }
  
  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF4DA6FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'PAUSED',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.pause_circle_filled,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'Level ${widget.levelId}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonGreen,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _startTimer();
                // Resume freeze timer if it was active
                if (_isFrozen && _freezeRemainingSeconds > 0) {
                  _startFreezeTimer();
                }
              },
              child: const Text(
                'Resume',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showBoosterNotImplemented(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name booster coming soon!'),
        duration: const Duration(seconds: 1),
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
    // Color changes based on remaining time or freeze state
    Color timerColor;
    Color bgColor;
    IconData timerIcon;
    
    if (_isFrozen) {
      // Frozen state - blue colors
      timerColor = AppColors.freezeBlue;
      bgColor = AppColors.freezeGlow;
      timerIcon = Icons.ac_unit; // Snowflake icon when frozen
    } else if (_remainingSeconds <= AppConstants.timerCriticalThreshold) {
      timerColor = AppColors.timerCritical;
      bgColor = AppColors.timerCritical.withOpacity(0.2);
      timerIcon = Icons.access_time_filled;
    } else if (_remainingSeconds <= AppConstants.timerWarningThreshold) {
      timerColor = AppColors.timerLow;
      bgColor = AppColors.timerLow.withOpacity(0.2);
      timerIcon = Icons.access_time_filled;
    } else {
      timerColor = AppColors.timerNormal;
      bgColor = AppColors.timerNormal.withOpacity(0.15);
      timerIcon = Icons.access_time_filled;
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: timerColor.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: _isFrozen ? [
          BoxShadow(
            color: AppColors.freezeGlow,
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clock/Snowflake icon
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              timerIcon,
              key: ValueKey(timerIcon),
              color: timerColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _isFrozen ? 'FROZEN' : 'Time',
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
        
        // Store for rocket overlay (update after frame to avoid setState during build)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_currentCellSize != cellSize) {
            _currentCellSize = cellSize;
          }
        });

        return Container(
          key: _gameBoardKey,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTapUp: _isRocketMode 
                ? (details) => _onRocketTap(details, cellSize, level)
                : _isHammerMode
                    ? (details) => _onHammerTap(details, cellSize, level)
                    : _isVacuumMode
                        ? (details) => _onVacuumTap(details, cellSize, level)
                        : null,
            onPanStart: (_isRocketMode || _isHammerMode || _isVacuumMode)
                ? null 
                : (details) => _onPanStart(details, cellSize, level),
            onPanUpdate: (_isRocketMode || _isHammerMode || _isVacuumMode)
                ? null 
                : (details) => _onPanUpdate(details, cellSize, level),
            onPanEnd: (_isRocketMode || _isHammerMode || _isVacuumMode) ? null : (_) => _onPanEnd(),
            // RepaintBoundary creates an offscreen buffer for the game board
            // TODO: Split into StaticBoardPainter + BlocksPainter for better perf
            child: RepaintBoundary(
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
                  showTargets: _isRocketMode,
                  hiddenBlocks: _isVacuumAnimating ? _pendingVacuumBlocks : null,
                ),
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
    if (_exitDeltaRow < 0) {
      exitEdge = 'top';
    } else if (_exitDeltaRow > 0) exitEdge = 'bottom';
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
    _stopFreezeTimer(); // Stop freeze timer
    if (_isFrozen) _endFreeze(); // Reset freeze state
    _cancelRocketMode(); // Reset rocket mode
    _cancelHammerMode(); // Reset hammer mode
    _cancelVacuumMode(); // Reset vacuum mode
    GameLogger.levelCompleted(widget.levelId, _remainingSeconds);
    await StorageService.markLevelCompleted(widget.levelId);
    widget.onLevelComplete?.call();
    
    // Calculate stars based on remaining time
    final totalTime = _level?.duration ?? AppConstants.defaultLevelDuration;
    final timeRatio = _remainingSeconds / totalTime;
    int stars = 1;
    if (timeRatio > 0.5) {
      stars = 3;
    } else if (timeRatio > 0.25) stars = 2;
    
    // Calculate coins earned (base + time bonus)
    final coinsEarned = 50 + (_remainingSeconds * 2);
    
    // Add coins to player (placeholder)
    setState(() {
      _coins += coinsEarned;
    });
    
    if (!mounted) return;
    
    AudioService.playDrop(); // Play win sound
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfettiWidget(
        isPlaying: true,
        child: WinDialog(
          levelId: widget.levelId,
          stars: stars,
          coinsEarned: coinsEarned,
          onNextLevel: () {
            AudioService.playTap();
            Navigator.pop(context);
            _goToNextLevel();
          },
          onReplay: () {
            AudioService.playTap();
            Navigator.pop(context);
            _resetLevel();
          },
          onHome: () {
            AudioService.playTap();
            Navigator.pop(context);
            Navigator.pop(context);
          },
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
  final bool showTargets; // For rocket booster mode
  final List<GameBlock>? hiddenBlocks; // Blocks to hide during vacuum animation

  GameBoardPainter({
    required this.level,
    required this.blocks,
    this.selectedBlock,
    required this.cellSize,
    this.exitingBlock,
    this.exitProgress = 0.0,
    this.exitDeltaRow = 0,
    this.exitDeltaCol = 0,
    this.showTargets = false,
    this.hiddenBlocks,
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
      // Skip hidden blocks (being vacuumed)
      if (hiddenBlocks != null && hiddenBlocks!.contains(block)) continue;
      _drawBlock(canvas, block, borderOffset);
    }
    
    canvas.restore();
    
    // Draw rocket targets on top of blocks
    if (showTargets) {
      _drawTargets(canvas, borderOffset);
    }
  }
  
  void _drawTargets(Canvas canvas, double borderOffset) {
    for (final block in blocks) {
      for (final cell in block.cells) {
        final centerX = borderOffset + cell.col * cellSize + cellSize / 2;
        final centerY = borderOffset + cell.row * cellSize + cellSize / 2;
        final center = Offset(centerX, centerY);
        
        final baseRadius = cellSize * 0.3;
        
        // Outer glow (red, semi-transparent)
        final glowPaint = Paint()
          ..color = AppColors.targetRed.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, baseRadius * 1.2, glowPaint);
        
        // Outer circle (red)
        final outerPaint = Paint()
          ..color = AppColors.targetRed
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawCircle(center, baseRadius, outerPaint);
        
        // Inner circle (white filled with opacity)
        final innerFillPaint = Paint()
          ..color = AppColors.targetWhite.withOpacity(0.3);
        canvas.drawCircle(center, baseRadius * 0.5, innerFillPaint);
        
        // Crosshair lines
        final crosshairPaint = Paint()
          ..color = AppColors.targetWhite.withOpacity(0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        
        final lineLength = baseRadius * 0.4;
        
        // Horizontal line
        canvas.drawLine(
          Offset(centerX - lineLength, centerY),
          Offset(centerX + lineLength, centerY),
          crosshairPaint,
        );
        
        // Vertical line
        canvas.drawLine(
          Offset(centerX, centerY - lineLength),
          Offset(centerX, centerY + lineLength),
          crosshairPaint,
        );
        
        // Center dot (red)
        final dotPaint = Paint()
          ..color = AppColors.targetRed
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 3, dotPaint);
      }
    }
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

