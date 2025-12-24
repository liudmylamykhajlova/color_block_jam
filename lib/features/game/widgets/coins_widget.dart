import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

/// Displays coins count with a + button to open shop
class CoinsWidget extends StatelessWidget {
  final int coins;
  final VoidCallback? onTap;
  
  const CoinsWidget({
    super.key,
    required this.coins,
    this.onTap,
  });
  
  String get _formattedCoins {
    if (coins >= 1000000) {
      return '${(coins / 1000000).toStringAsFixed(2)}M';
    } else if (coins >= 1000) {
      return '${(coins / 1000).toStringAsFixed(2)}k';
    }
    return coins.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gold.withOpacity(0.3),
              AppColors.gold.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.gold.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Plus button
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.buttonGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.buttonGreen.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 6),
            // Coins value
            Text(
              _formattedCoins,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            // Coin icon
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange.shade700, width: 2),
              ),
              child: Center(
                child: Text(
                  '\$',
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontSize: 12,
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
}

