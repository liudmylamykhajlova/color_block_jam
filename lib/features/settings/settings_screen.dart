import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _hapticEnabled = false;

  @override
  void initState() {
    super.initState();
    _soundEnabled = AudioService.soundEnabled;
    _musicEnabled = AudioService.musicEnabled;
    _hapticEnabled = AudioService.hapticEnabled;
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
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        AudioService.playTap();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'SETTINGS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Settings cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Vibration toggle (first, per original game order)
                      _SettingsTile(
                        icon: _hapticEnabled ? Icons.vibration : Icons.phonelink_erase,
                        title: 'Vibration',
                        subtitle: _hapticEnabled ? 'On' : 'Off',
                        trailing: Switch(
                          value: _hapticEnabled,
                          onChanged: (value) async {
                            await AudioService.setHapticEnabled(value);
                            setState(() => _hapticEnabled = value);
                            if (value) AudioService.lightTap();
                          },
                          activeThumbColor: const Color(0xFF4CAF50),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Sound toggle
                      _SettingsTile(
                        icon: _soundEnabled ? Icons.volume_up : Icons.volume_off,
                        title: 'Sound',
                        subtitle: _soundEnabled ? 'On' : 'Off',
                        trailing: Switch(
                          value: _soundEnabled,
                          onChanged: (value) async {
                            AudioService.playTap();
                            await AudioService.setSoundEnabled(value);
                            setState(() => _soundEnabled = value);
                          },
                          activeThumbColor: const Color(0xFF4CAF50),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Music toggle
                      _SettingsTile(
                        icon: _musicEnabled ? Icons.music_note : Icons.music_off,
                        title: 'Music',
                        subtitle: _musicEnabled ? 'On' : 'Off',
                        trailing: Switch(
                          value: _musicEnabled,
                          onChanged: (value) async {
                            AudioService.playTap();
                            await AudioService.setMusicEnabled(value);
                            setState(() => _musicEnabled = value);
                          },
                          activeThumbColor: const Color(0xFF4CAF50),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Legal Terms
                      _SettingsButton(
                        label: 'Legal Terms',
                        onTap: () => _showComingSoon('Legal Terms'),
                      ),

                      const SizedBox(height: 12),

                      // Restore Purchases
                      _SettingsButton(
                        label: 'Restore Purchases',
                        onTap: () => _showComingSoon('Restore Purchases'),
                      ),

                      const SizedBox(height: 12),

                      // Support
                      _SettingsButton(
                        label: 'Support',
                        icon: Icons.check_circle,
                        onTap: () => _showComingSoon('Support'),
                      ),

                      const SizedBox(height: 12),

                      // Language
                      _SettingsButton(
                        label: 'Language',
                        onTap: () => _showComingSoon('Language'),
                      ),

                      const SizedBox(height: 24),

                      // Social Links
                      _buildSocialLinks(),

                      const SizedBox(height: 24),

                      // Reset progress
                      _SettingsTile(
                        icon: Icons.restart_alt,
                        title: 'Reset Progress',
                        subtitle: 'Start from Level 1',
                        onTap: () => _showResetDialog(),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white54,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Version info
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            icon: Icons.camera_alt,
            label: 'Like',
            reward: '+100',
            color: const Color(0xFFE1306C),
            onTap: () => _claimSocialReward('Instagram'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SocialButton(
            icon: Icons.facebook,
            label: 'Follow',
            reward: '+100',
            color: const Color(0xFF1877F2),
            onTap: () => _claimSocialReward('Facebook'),
          ),
        ),
      ],
    );
  }
  
  void _showComingSoon(String feature) {
    AudioService.playTap();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _claimSocialReward(String platform) {
    AudioService.playTap();
    // TODO: Actually open social link and verify follow
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.monetization_on, color: Colors.amber),
            const SizedBox(width: 8),
            Text('$platform: +100 coins coming soon!'),
          ],
        ),
        backgroundColor: AppColors.buttonGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showResetDialog() {
    AudioService.playTap();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF764ba2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD700), size: 28),
            SizedBox(width: 12),
            Text(
              'Reset Progress?',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'This will reset all your progress and you\'ll start from Level 1. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AudioService.playTap();
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              AudioService.playTap();
              await StorageService.resetProgress();
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Progress reset successfully'),
                  backgroundColor: const Color(0xFF4CAF50),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  
  const _SettingsButton({
    required this.label,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF5BB8E8),
              const Color(0xFF3D8BC4),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String reward;
  final Color color;
  final VoidCallback? onTap;
  
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.reward,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF5BB8E8),
              const Color(0xFF3D8BC4),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      reward,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

