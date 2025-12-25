import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/models/game_models.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/audio_service.dart';
import '../game/game_screen.dart';
import '../game/widgets/level_start_dialog.dart';
import '../settings/settings_screen.dart';
import '../shop/shop_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/map_hud.dart';
import 'widgets/level_node.dart';

/// Level map screen with vertical scrolling path
class LevelMapScreen extends StatefulWidget {
  const LevelMapScreen({super.key});

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  List<GameLevel>? _levels;
  Set<int> _completedLevels = {};
  int _lives = 5;
  final int _coins = 1480;
  bool _isLoading = true;
  
  late ScrollController _scrollController;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadData();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    final levels = await LevelLoader.loadLevels();
    if (mounted) {
      setState(() {
        _levels = levels;
        _completedLevels = StorageService.getCompletedLevels();
        _lives = StorageService.getLives();
        _isLoading = false;
      });
      
      // Scroll to current level
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentLevel();
      });
    }
  }
  
  void _scrollToCurrentLevel() {
    if (_levels == null || _levels!.isEmpty) return;
    
    // Find the last unlocked level (current level to play)
    // This is the first level that is NOT completed but IS unlocked
    int currentLevelId = 1;
    
    if (_completedLevels.isNotEmpty) {
      // Get the highest completed level ID
      final maxCompleted = _completedLevels.reduce((a, b) => a > b ? a : b);
      // Current level is the next one (if exists)
      currentLevelId = (maxCompleted + 1).clamp(1, _levels!.length);
    }
    
    final index = _levels!.indexWhere((l) => l.id == currentLevelId);
    if (index == -1) return;
    
    // Calculate scroll position (from bottom, reversed list)
    if (_scrollController.hasClients) {
      final itemHeight = 140.0; // Approximate height per level node
      final targetScroll = (_levels!.length - index - 1) * itemHeight;
      
      _scrollController.animateTo(
        targetScroll.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }
  
  void _openLevel(int levelId) {
    AudioService.playTap();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => LevelStartDialog(
        levelId: levelId,
        milestoneText: 'Unlock Level 70',
        milestoneProgress: _completedLevels.length % 3,
        milestoneTotal: 3,
        onPlay: () {
          Navigator.pop(context);
          _startLevel(levelId);
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }
  
  void _startLevel(int levelId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          levelId: levelId,
          onLevelComplete: () {
            setState(() {
              _completedLevels = StorageService.getCompletedLevels();
              _lives = StorageService.getLives();
            });
          },
        ),
      ),
    );
  }
  
  void _openSettings() {
    AudioService.playTap();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }
  
  void _openShop() {
    AudioService.playTap();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShopScreen()),
    );
  }
  
  void _openProfile() {
    AudioService.playTap();
    showDialog(
      context: context,
      builder: (_) => const ProfileScreen(),
    );
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
              Color(0xFF5B7FC3), // Blue-purple top
              Color(0xFF4A67A8), // Darker middle
              Color(0xFF3D5A94), // Even darker bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top HUD
              MapHud(
                lives: _lives,
                coins: _coins,
                onAvatarTap: _openProfile,
                onLivesTap: () {},
                onCoinsTap: _openShop,
                onSettingsTap: _openSettings,
              ),
              
              // Map content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _buildMap(),
              ),
              
              // Bottom navigation
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMap() {
    if (_levels == null || _levels!.isEmpty) {
      return const Center(
        child: Text('No levels available', style: TextStyle(color: Colors.white)),
      );
    }
    
    return Stack(
      children: [
        // Background pattern
        _buildBackgroundPattern(),
        
        // Levels list (reversed - bottom to top)
        ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          itemCount: _levels!.length,
          itemBuilder: (context, index) {
            final level = _levels![index];
            final isCompleted = _completedLevels.contains(level.id);
            final isUnlocked = level.id == 1 || _completedLevels.contains(level.id - 1);
            final isCurrent = !isCompleted && isUnlocked;
            
            // Determine level type for styling
            LevelNodeType nodeType = LevelNodeType.normal;
            if (level.isHard) nodeType = LevelNodeType.hard;
            if (level.hardness == LevelHardness.veryHard) nodeType = LevelNodeType.boss;
            
            return _buildLevelRow(
              level: level,
              index: index,
              isCompleted: isCompleted,
              isUnlocked: isUnlocked,
              isCurrent: isCurrent,
              nodeType: nodeType,
            );
          },
        ),
        
        // ADS button (right side)
        Positioned(
          right: 16,
          top: MediaQuery.of(context).size.height * 0.3,
          child: _buildAdsButton(),
        ),
      ],
    );
  }
  
  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _BackgroundPatternPainter(),
      ),
    );
  }
  
  Widget _buildLevelRow({
    required GameLevel level,
    required int index,
    required bool isCompleted,
    required bool isUnlocked,
    required bool isCurrent,
    required LevelNodeType nodeType,
  }) {
    // Alternate left/right positioning for visual interest
    final isLeft = index % 2 == 0;
    
    return Container(
      height: 140,
      padding: EdgeInsets.only(
        left: isLeft ? 40 : 100,
        right: isLeft ? 100 : 40,
      ),
      child: Stack(
        children: [
          // Rope line (connecting to next level)
          if (index < (_levels?.length ?? 0) - 1)
            Positioned(
              left: 0,
              right: 0,
              top: 70,
              bottom: -70,
              child: CustomPaint(
                painter: _RopePainter(isLeft: isLeft),
              ),
            ),
          
          // Level node
          Center(
            child: LevelNode(
              levelId: level.id,
              isCompleted: isCompleted,
              isUnlocked: isUnlocked,
              isCurrent: isCurrent,
              type: nodeType,
              onTap: isUnlocked ? () => _openLevel(level.id) : null,
            ),
          ),
          
          // Coin reward badge (between some levels)
          if (index > 0 && index % 5 == 0)
            Positioned(
              left: isLeft ? null : 20,
              right: isLeft ? 20 : null,
              top: 60,
              child: _buildCoinBadge(),
            ),
        ],
      ),
    );
  }
  
  Widget _buildCoinBadge() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.gold,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.orange.shade700, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.5),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Icon(
        Icons.attach_money,
        color: Colors.white,
        size: 18,
      ),
    );
  }
  
  Widget _buildAdsButton() {
    return GestureDetector(
      onTap: () {
        AudioService.playTap();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Remove Ads coming soon!')),
        );
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text(
              'ADS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Cross line
            Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 40,
                height: 3,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _BottomNavItem(
            icon: Icons.card_giftcard,
            label: 'Shop',
            onTap: _openShop,
          ),
          _BottomNavItem(
            icon: Icons.view_in_ar,
            label: 'Home',
            isSelected: true,
            onTap: () {},
          ),
          _BottomNavItem(
            icon: Icons.lock,
            label: 'Lvl 50',
            isLocked: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback? onTap;
  
  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.isLocked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(
                  icon,
                  color: isLocked 
                      ? Colors.white.withOpacity(0.5)
                      : Colors.white,
                  size: 28,
                ),
                if (isLocked)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isLocked 
                    ? Colors.white.withOpacity(0.5)
                    : Colors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Background pattern painter
class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    
    // Draw subtle LEGO block shapes in background
    final blockSize = 60.0;
    for (double y = 0; y < size.height; y += blockSize * 2) {
      for (double x = 0; x < size.width; x += blockSize * 2) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, blockSize, blockSize * 0.6),
          const Radius.circular(4),
        );
        canvas.drawRRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Rope line painter connecting levels
class _RopePainter extends CustomPainter {
  final bool isLeft;
  
  _RopePainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B4513) // Brown rope color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    
    // Draw curved line connecting levels
    final startX = size.width / 2;
    final startY = 0.0;
    final endX = size.width / 2;
    final endY = size.height;
    
    path.moveTo(startX, startY);
    path.lineTo(endX, endY);
    
    canvas.drawPath(path, paint);
    
    // Draw rope texture
    final texturePaint = Paint()
      ..color = const Color(0xFFA0522D)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    for (double y = 0; y < size.height; y += 10) {
      canvas.drawLine(
        Offset(startX - 2, y),
        Offset(startX + 2, y + 5),
        texturePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

