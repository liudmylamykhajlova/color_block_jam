import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/audio_service.dart';

/// Shop item data
class ShopItem {
  final String id;
  final int coins;
  final double price;
  final String currency;
  final bool isBestValue;
  
  const ShopItem({
    required this.id,
    required this.coins,
    required this.price,
    this.currency = 'UAH',
    this.isBestValue = false,
  });
}

/// Shop screen with coins packs and bundles
class ShopScreen extends StatelessWidget {
  final VoidCallback? onClose;
  
  const ShopScreen({
    super.key,
    this.onClose,
  });
  
  static const List<ShopItem> coinPacks = [
    ShopItem(id: 'coins_1k', coins: 1000, price: 79.99),
    ShopItem(id: 'coins_5k', coins: 5000, price: 284.99),
    ShopItem(id: 'coins_10k', coins: 10000, price: 549.99),
    ShopItem(id: 'coins_25k', coins: 25000, price: 1099.99, isBestValue: true),
    ShopItem(id: 'coins_50k', coins: 50000, price: 1949.99),
    ShopItem(id: 'coins_100k', coins: 100000, price: 3649.99),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5B7FC3),
              Color(0xFF4A67A8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Coins section
                      _buildCoinsSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Bundles section
                      _buildBundlesSection(context),
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
  
  Widget _buildHeader(BuildContext context) {
    return Padding(
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
              'Shop',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Coins display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text(
                  '1.48k',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.orange.shade700, width: 2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCoinsSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4DA6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold,
          width: 3,
        ),
      ),
      child: Column(
        children: [
          // Section header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
            ),
            child: const Text(
              'Coins',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Coins grid
          Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
              children: coinPacks.map((item) => _CoinPackCard(item: item)).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBundlesSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4DA6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orange,
          width: 3,
        ),
      ),
      child: Column(
        children: [
          // Section header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.8),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
            ),
            child: const Text(
              'Bundles',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // No Ads bundle
          Padding(
            padding: const EdgeInsets.all(12),
            child: _NoAdsCard(
              onTap: () {
                AudioService.playTap();
                _showRemoveAdsDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  void _showRemoveAdsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const RemoveAdsDialog(),
    );
  }
}

class _CoinPackCard extends StatelessWidget {
  final ShopItem item;
  
  const _CoinPackCard({required this.item});
  
  String get _formattedCoins {
    if (item.coins >= 1000) {
      return '${(item.coins / 1000).toInt()} 000';
    }
    return item.coins.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AudioService.playTap();
        // TODO: Implement purchase
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase ${item.coins} coins - coming soon!')),
        );
      },
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Coins amount
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _formattedCoins,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Coin pile image placeholder
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Multiple coins
                    for (int i = 0; i < (item.coins >= 25000 ? 4 : item.coins >= 5000 ? 3 : 2); i++)
                      Positioned(
                        left: 10 + i * 8.0,
                        top: 5 + i * 4.0,
                        child: _CoinIcon(size: 28 + (item.coins / 20000).clamp(0, 12)),
                      ),
                  ],
                ),
              ),
            ),
            
            // Price button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.buttonGreen,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              child: Text(
                '${item.price.toStringAsFixed(2)} ${item.currency}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinIcon extends StatelessWidget {
  final double size;
  
  const _CoinIcon({this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.gold,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.orange.shade700, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '\$',
          style: TextStyle(
            color: Colors.orange.shade900,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _NoAdsCard extends StatelessWidget {
  final VoidCallback? onTap;
  
  const _NoAdsCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF9C88D9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // ADS icon with cross
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'ADS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
            
            const SizedBox(width: 16),
            
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Remove interstitial',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '& banner ads',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Price
            Column(
              children: [
                const Text(
                  'No Ads',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.buttonGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '284,99 UAH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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
}

/// Remove Ads dialog
class RemoveAdsDialog extends StatelessWidget {
  const RemoveAdsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade900.withOpacity(0.95),
              Colors.purple.shade900.withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.buttonRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
            
            // Title
            const Text(
              'REMOVE ADS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Big ADS icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 20,
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Transform.rotate(
                    angle: 0.5,
                    child: Container(
                      width: 80,
                      height: 6,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Benefits list
            _buildBenefitRow(Icons.tv, 'Remove obligatory ads'),
            const SizedBox(height: 12),
            _buildBenefitRow(Icons.smartphone, 'Remove bottom banner ads'),
            const SizedBox(height: 12),
            _buildBenefitRow(Icons.play_circle_outline, 'Keep optional ads for rewards'),
            
            const SizedBox(height: 24),
            
            // Price button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  AudioService.playTap();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchase coming soon!')),
                  );
                },
                child: const Text(
                  '284,99 UAH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}


