import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Pre-game booster that can be selected before starting
class PreGameBooster {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int quantity;
  final bool isSelected;
  
  const PreGameBooster({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.quantity = 0,
    this.isSelected = false,
  });
  
  PreGameBooster copyWith({bool? isSelected}) {
    return PreGameBooster(
      id: id,
      name: name,
      icon: icon,
      color: color,
      quantity: quantity,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// Dialog shown before starting a level
class LevelStartDialog extends StatefulWidget {
  final int levelId;
  final String? milestoneText; // e.g. "Unlock Level 70"
  final int milestoneProgress; // e.g. 0
  final int milestoneTotal; // e.g. 3
  final List<PreGameBooster> boosters;
  final VoidCallback? onPlay;
  final VoidCallback? onClose;
  final Function(List<PreGameBooster>)? onBoostersChanged;
  
  const LevelStartDialog({
    super.key,
    required this.levelId,
    this.milestoneText,
    this.milestoneProgress = 0,
    this.milestoneTotal = 3,
    this.boosters = const [],
    this.onPlay,
    this.onClose,
    this.onBoostersChanged,
  });
  
  static List<PreGameBooster> get defaultBoosters => [
    const PreGameBooster(
      id: 'hourglass',
      name: 'More Time',
      icon: Icons.hourglass_bottom,
      color: Colors.lightBlue,
      quantity: 2,
    ),
    const PreGameBooster(
      id: 'rocket',
      name: 'Boost',
      icon: Icons.rocket_launch,
      color: Colors.orange,
      quantity: 2,
    ),
  ];

  @override
  State<LevelStartDialog> createState() => _LevelStartDialogState();
}

class _LevelStartDialogState extends State<LevelStartDialog> {
  late List<PreGameBooster> _boosters;
  
  @override
  void initState() {
    super.initState();
    _boosters = widget.boosters.isEmpty 
        ? LevelStartDialog.defaultBoosters 
        : widget.boosters;
  }
  
  void _toggleBooster(int index) {
    if (_boosters[index].quantity <= 0) return;
    
    setState(() {
      _boosters = List.from(_boosters);
      _boosters[index] = _boosters[index].copyWith(
        isSelected: !_boosters[index].isSelected,
      );
    });
    
    widget.onBoostersChanged?.call(_boosters);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5BB8E8),
              Color(0xFF3D8BC4),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            
            const SizedBox(height: 16),
            
            // Milestone progress (if any)
            if (widget.milestoneText != null) ...[
              _buildMilestone(),
              const SizedBox(height: 20),
            ],
            
            // Booster selection
            _buildBoosterSelection(),
            
            const SizedBox(height: 20),
            
            // Play button
            _buildPlayButton(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Stack(
      children: [
        // Title banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Text(
            'LEVEL ${widget.levelId}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        
        // Close button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.buttonRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMilestone() {
    final progress = widget.milestoneProgress / widget.milestoneTotal;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Chest icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.card_giftcard,
                color: Colors.amber,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            
            // Progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.milestoneText!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation(AppColors.buttonGreen),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.milestoneProgress}/${widget.milestoneTotal}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.lock,
                        color: Colors.amber,
                        size: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBoosterSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Text(
            'Select Boosters:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_boosters.length, (i) {
              return Padding(
                padding: EdgeInsets.only(left: i > 0 ? 16 : 0),
                child: _BoosterSlot(
                  booster: _boosters[i],
                  onTap: () => _toggleBooster(i),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlayButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonGreen,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 4,
          ),
          onPressed: widget.onPlay,
          child: const Text(
            'Play',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _BoosterSlot extends StatelessWidget {
  final PreGameBooster booster;
  final VoidCallback? onTap;
  
  const _BoosterSlot({
    required this.booster,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = booster.quantity > 0;
    
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isEnabled
                    ? [
                        const Color(0xFF5BA3D9),
                        const Color(0xFF3D7AB3),
                      ]
                    : [
                        Colors.grey.shade600,
                        Colors.grey.shade700,
                      ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: booster.isSelected 
                    ? AppColors.buttonGreen
                    : (isEnabled ? const Color(0xFF7CC4F0) : Colors.grey.shade500),
                width: booster.isSelected ? 4 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
                if (booster.isSelected)
                  BoxShadow(
                    color: AppColors.buttonGreen.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Icon(
              booster.icon,
              color: isEnabled ? booster.color : Colors.grey.shade400,
              size: 32,
            ),
          ),
          
          // Quantity badge
          if (booster.quantity > 0)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.buttonRed,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${booster.quantity}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          
          // Selected checkmark
          if (booster.isSelected)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.buttonGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

