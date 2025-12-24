import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/audio_service.dart';

/// Avatar data
class AvatarData {
  final String id;
  final IconData icon;
  final Color backgroundColor;
  
  const AvatarData({
    required this.id,
    required this.icon,
    required this.backgroundColor,
  });
}

/// Profile screen with avatar selection
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  /// Available avatars
  static const List<AvatarData> avatars = [
    AvatarData(id: 'avatar_1', icon: Icons.person, backgroundColor: Color(0xFF5BA3D9)),
    AvatarData(id: 'avatar_2', icon: Icons.face, backgroundColor: Color(0xFF9C27B0)),
    AvatarData(id: 'avatar_3', icon: Icons.face_2, backgroundColor: Color(0xFF4CAF50)),
    AvatarData(id: 'avatar_4', icon: Icons.face_3, backgroundColor: Color(0xFFFF9800)),
    AvatarData(id: 'avatar_5', icon: Icons.face_4, backgroundColor: Color(0xFF2196F3)),
    AvatarData(id: 'avatar_6', icon: Icons.face_5, backgroundColor: Color(0xFFE91E63)),
    AvatarData(id: 'avatar_7', icon: Icons.face_6, backgroundColor: Color(0xFF795548)),
    AvatarData(id: 'avatar_8', icon: Icons.elderly, backgroundColor: Color(0xFF607D8B)),
    AvatarData(id: 'avatar_9', icon: Icons.child_care, backgroundColor: Color(0xFFFFEB3B)),
    AvatarData(id: 'avatar_10', icon: Icons.person_2, backgroundColor: Color(0xFF00BCD4)),
    AvatarData(id: 'avatar_11', icon: Icons.person_3, backgroundColor: Color(0xFFCDDC39)),
    AvatarData(id: 'avatar_12', icon: Icons.person_4, backgroundColor: Color(0xFFFF5722)),
  ];
  
  /// Available frames
  static const List<Color> frameColors = [
    Color(0xFF5BA3D9),
    Color(0xFF9C27B0),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
  ];

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _playerName = 'Player8659';
  String _selectedAvatarId = 'avatar_1';
  String _selectedFrameId = 'frame_1';
  int _currentTab = 0; // 0 = Avatar, 1 = Frame
  
  final TextEditingController _nameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _nameController.text = _playerName;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  void _saveProfile() {
    // TODO: Save to StorageService when implemented
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340, maxHeight: 520),
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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            
            // Player card
            _buildPlayerCard(),
            
            // Tabs
            _buildTabs(),
            
            // Grid content
            Expanded(
              child: _currentTab == 0 
                  ? _buildAvatarGrid()
                  : _buildFrameGrid(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: const Text(
            'Profile',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Close button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              AudioService.playTap();
              Navigator.pop(context);
            },
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
  
  Widget _buildPlayerCard() {
    final selectedAvatar = ProfileScreen.avatars.firstWhere(
      (a) => a.id == _selectedAvatarId,
      orElse: () => ProfileScreen.avatars.first,
    );
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7), // Cream/beige
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar preview
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: selectedAvatar.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF5BA3D9),
                width: 3,
              ),
            ),
            child: Icon(
              selectedAvatar.icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Name
          Expanded(
            child: Text(
              _playerName,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Edit button
          GestureDetector(
            onTap: _showEditNameDialog,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF5BA3D9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Avatar',
              isSelected: _currentTab == 0,
              onTap: () {
                AudioService.playTap();
                setState(() => _currentTab = 0);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabButton(
              label: 'Frame',
              isSelected: _currentTab == 1,
              onTap: () {
                AudioService.playTap();
                setState(() => _currentTab = 1);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAvatarGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: ProfileScreen.avatars.length,
      itemBuilder: (context, index) {
        final avatar = ProfileScreen.avatars[index];
        final isSelected = avatar.id == _selectedAvatarId;
        
        return _AvatarItem(
          avatar: avatar,
          isSelected: isSelected,
          onTap: () {
            AudioService.playTap();
            setState(() => _selectedAvatarId = avatar.id);
            _saveProfile();
          },
        );
      },
    );
  }
  
  Widget _buildFrameGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: ProfileScreen.frameColors.length,
      itemBuilder: (context, index) {
        final frameId = 'frame_${index + 1}';
        final isSelected = frameId == _selectedFrameId;
        
        return _FrameItem(
          color: ProfileScreen.frameColors[index],
          isSelected: isSelected,
          onTap: () {
            AudioService.playTap();
            setState(() => _selectedFrameId = frameId);
            _saveProfile();
          },
        );
      },
    );
  }
  
  void _showEditNameDialog() {
    _nameController.text = _playerName;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF4DA6FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Edit Name',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter name',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white),
            ),
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonGreen,
            ),
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                setState(() {
                  _playerName = _nameController.text.trim();
                });
                _saveProfile();
              }
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  
  const _TabButton({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF3D7AB3)
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _AvatarItem extends StatelessWidget {
  final AvatarData avatar;
  final bool isSelected;
  final VoidCallback? onTap;
  
  const _AvatarItem({
    required this.avatar,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: avatar.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? AppColors.buttonGreen
                    : Colors.white.withOpacity(0.3),
                width: isSelected ? 4 : 2,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppColors.buttonGreen.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
            child: Center(
              child: Icon(
                avatar.icon,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          
          // Checkmark
          if (isSelected)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.buttonGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FrameItem extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;
  
  const _FrameItem({
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? AppColors.buttonGreen
                    : Colors.white.withOpacity(0.3),
                width: isSelected ? 4 : 2,
              ),
            ),
            child: Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color,
                    width: 4,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  color: color,
                  size: 28,
                ),
              ),
            ),
          ),
          
          // Checkmark
          if (isSelected)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.buttonGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

