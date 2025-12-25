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

/// Level map screen with vertical scrolling path (like original game)
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
  int _currentLevelId = 1;
  
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
        _updateCurrentLevel();
      });
      
      // Scroll to current level after layout is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _scrollToCurrentLevel();
        });
      });
    }
  }
  
  void _updateCurrentLevel() {
    if (_levels == null || _levels!.isEmpty) return;
    
    if (_completedLevels.isEmpty) {
      _currentLevelId = 1;
    } else {
      final maxCompleted = _completedLevels.reduce((a, b) => a > b ? a : b);
      _currentLevelId = (maxCompleted + 1).clamp(1, _levels!.length);
    }
  }
  
  void _scrollToCurrentLevel() {
    if (_levels == null || _levels!.isEmpty) return;
    if (!_scrollController.hasClients) return;
    
    final index = _levels!.indexWhere((l) => l.id == _currentLevelId);
    if (index == -1) return;
    
    // With reverse:true, to show item at index N, we scroll to index * itemHeight
    const itemHeight = 120.0;
    final targetScroll = index * itemHeight;
    
    _scrollController.jumpTo(
      targetScroll.clamp(0.0, _scrollController.position.maxScrollExtent),
    );
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
              _updateCurrentLevel();
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
              AppColors.mapBgTop,
              AppColors.mapBgMid,
              AppColors.mapBgBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Map content (full screen behind everything)
              Positioned.fill(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _buildMap(),
              ),
              
              // Top HUD (transparent, overlaid on map)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: MapHud(
                  lives: _lives,
                  coins: _coins,
                  onAvatarTap: _openProfile,
                  onLivesTap: () {},
                  onCoinsTap: _openShop,
                  onSettingsTap: _openSettings,
                ),
              ),
              
              // Bottom navigation (centered, compact)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(child: _buildBottomNav()),
              ),
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
          padding: const EdgeInsets.only(top: 80, bottom: 120), // Space for HUD top and nav bottom
          itemCount: _levels!.length,
          itemBuilder: (context, index) {
            final level = _levels![index];
            final isCompleted = _completedLevels.contains(level.id);
            final isUnlocked = level.id == 1 || _completedLevels.contains(level.id - 1);
            final isCurrent = level.id == _currentLevelId;
            
            // Determine level type for styling
            LevelNodeType nodeType = LevelNodeType.normal;
            if (level.isHard) nodeType = LevelNodeType.hard;
            if (level.hardness == LevelHardness.veryHard) nodeType = LevelNodeType.veryHard;
            
            return _buildLevelItem(
              level: level,
              index: index,
              isCompleted: isCompleted,
              isUnlocked: isUnlocked,
              isCurrent: isCurrent,
              nodeType: nodeType,
              isLast: index == _levels!.length - 1,
            );
          },
        ),
        
        // ADS button (right side)
        Positioned(
          right: 16,
          top: MediaQuery.of(context).size.height * 0.25,
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
  
  /// Connection line between levels - thick with dark outline like original
  Widget _buildConnectionLine() {
    return Stack(
      children: [
        // Dark outline (behind)
        Container(
          width: 14,
          decoration: BoxDecoration(
            color: AppColors.mapDarkBrown,
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        // Inner golden line
        Center(
          child: Container(
            width: 10,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.mapGoldenBorder, AppColors.mapGoldenDark],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLevelItem({
    required GameLevel level,
    required int index,
    required bool isCompleted,
    required bool isUnlocked,
    required bool isCurrent,
    required LevelNodeType nodeType,
    required bool isLast,
  }) {
    // Current level needs more height for square + button
    final itemHeight = isCurrent ? 160.0 : 120.0;
    final lineBottom = isCurrent ? 100.0 : 60.0;
    
    return SizedBox(
      height: itemHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Connecting line to next level (not for last item)
          if (!isLast)
            Positioned(
              top: 0,
              bottom: lineBottom,
              child: _buildConnectionLine(),
            ),
          
          // Connecting line from previous level
          if (index > 0)
            Positioned(
              top: lineBottom,
              bottom: 0,
              child: _buildConnectionLine(),
            ),
          
          // Level node (current level is automatically a wide button)
          LevelNode(
            levelId: level.id,
            isCompleted: isCompleted,
            isUnlocked: isUnlocked,
            isCurrent: isCurrent,
            type: nodeType,
            onTap: isUnlocked ? () => _openLevel(level.id) : null,
          ),
        ],
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
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
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
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Cross line
            Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.mapNavBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Shop - Treasure chest with coins
          _buildNavItemCustom(
            child: _buildTreasureChestIcon(),
            label: '',
            onTap: _openShop,
          ),
          const SizedBox(width: 4),
          // Home - LEGO blocks
          _buildNavItemCustom(
            child: _buildLegoBlocksIcon(),
            label: 'Home',
            isSelected: true,
            onTap: () {},
          ),
          const SizedBox(width: 4),
          // Lvl 50 - Locked LEGO block
          _buildNavItemCustom(
            child: _buildLockedBlockIcon(),
            label: 'Lvl 50',
            isLocked: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavItemCustom({
    required Widget child,
    required String label,
    bool isSelected = false,
    bool isLocked = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: isSelected 
            ? BoxDecoration(
                color: AppColors.mapNavSelected,
                borderRadius: BorderRadius.circular(14),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 48,
              child: child,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(isLocked ? 0.7 : 1.0),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Shop icon - shopping cart with coin badge
  Widget _buildTreasureChestIcon() {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shopping cart icon
          const Icon(
            Icons.shopping_cart_rounded,
            color: Colors.white,
            size: 32,
          ),
          // Small gold coin badge
          Positioned(
            right: 2,
            top: 4,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.goldenLight, AppColors.goldenDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.goldenBorder, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '\$',
                  style: TextStyle(
                    color: AppColors.goldenBorder,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// LEGO blocks icon for Home - 4 colorful blocks like original
  Widget _buildLegoBlocksIcon() {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Yellow block (back left)
          Positioned(
            left: 2,
            top: 8,
            child: _buildMiniLegoBlock(AppColors.legoYellow, 20),
          ),
          // Blue block (back right)  
          Positioned(
            right: 4,
            top: 4,
            child: _buildMiniLegoBlock(AppColors.legoBlue, 22),
          ),
          // Green block (middle)
          Positioned(
            left: 14,
            bottom: 8,
            child: _buildMiniLegoBlock(AppColors.legoGreen, 24),
          ),
          // Pink/Magenta block (front right)
          Positioned(
            right: 2,
            bottom: 0,
            child: _buildMiniLegoBlock(AppColors.legoPink, 26),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMiniLegoBlock(Color color, double size) {
    return Container(
      width: size,
      height: size * 0.85,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Color.lerp(color, Colors.black, 0.2)!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Studs on top
          Positioned(
            top: 2,
            left: size * 0.15,
            child: _buildStud(color, size * 0.25),
          ),
          Positioned(
            top: 2,
            right: size * 0.15,
            child: _buildStud(color, size * 0.25),
          ),
          // Highlight
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size * 0.2,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
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
  
  Widget _buildStud(Color baseColor, double size) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: Color.lerp(baseColor, Colors.black, 0.15)!,
          width: 1,
        ),
      ),
    );
  }
  
  /// Just golden lock icon for Lvl 50 (like original - only lock + text)
  Widget _buildLockedBlockIcon() {
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
        border: Border.all(color: AppColors.goldenBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
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

/// Background pattern painter - puzzle/LEGO shapes like original
class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    
    // Puzzle/LEGO block shapes with step cutouts
    const blockWidth = 100.0;
    const blockHeight = 80.0;
    const stepSize = 20.0;
    const spacing = 80.0;
    
    for (double y = -blockHeight; y < size.height + blockHeight * 2; y += blockHeight + spacing) {
      // Offset every other row
      final rowIndex = ((y + blockHeight) / (blockHeight + spacing)).floor();
      final rowOffset = (rowIndex % 2 == 0) ? 0.0 : blockWidth * 0.7;
      
      for (double x = -blockWidth + rowOffset; x < size.width + blockWidth; x += blockWidth + spacing) {
        _drawPuzzleBlock(canvas, paint, x, y, blockWidth, blockHeight, stepSize);
      }
    }
  }
  
  void _drawPuzzleBlock(Canvas canvas, Paint paint, double x, double y, double w, double h, double step) {
    // Create puzzle shape path with step cutouts (like LEGO/tetris)
    final path = Path();
    
    // Start from top-left
    path.moveTo(x, y + step);
    
    // Top edge with step going up
    path.lineTo(x + w * 0.3, y + step);
    path.lineTo(x + w * 0.3, y);
    path.lineTo(x + w * 0.6, y);
    path.lineTo(x + w * 0.6, y + step);
    path.lineTo(x + w, y + step);
    
    // Right edge
    path.lineTo(x + w, y + h - step);
    
    // Bottom edge with step going down
    path.lineTo(x + w * 0.7, y + h - step);
    path.lineTo(x + w * 0.7, y + h);
    path.lineTo(x + w * 0.4, y + h);
    path.lineTo(x + w * 0.4, y + h - step);
    path.lineTo(x, y + h - step);
    
    // Close path
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
