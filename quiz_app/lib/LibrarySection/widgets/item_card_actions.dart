import 'package:flutter/material.dart';

import '../../utils/constants.dart';

/// Circular action button used in item cards (favorite, share, more)
class ItemActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final double size;
  final bool isActive;
  final Color? activeColor;

  const ItemActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.iconColor,
    this.size = AppSizes.iconButtonSmall,
    this.isActive = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: AppOpacity.shadow),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? (activeColor ?? Colors.red) : iconColor,
        ),
      ),
    );
  }
}

/// Row of action buttons for item cards
class ItemCardActionButtons extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onShareTap;
  final VoidCallback onMoreTap;
  final Color accentColor;
  final Color textColor;

  const ItemCardActionButtons({
    super.key,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onShareTap,
    required this.onMoreTap,
    required this.accentColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Favorite button
        ItemActionButton(
          icon: isFavorite ? Icons.favorite : Icons.favorite_border,
          onTap: onFavoriteTap,
          iconColor: accentColor,
          isActive: isFavorite,
          activeColor: Colors.red,
        ),
        const SizedBox(width: 8),
        // Share button
        ItemActionButton(
          icon: Icons.share_outlined,
          onTap: onShareTap,
          iconColor: accentColor,
        ),
        const SizedBox(width: 8),
        // More button
        ItemActionButton(
          icon: Icons.more_horiz,
          onTap: onMoreTap,
          iconColor: textColor,
        ),
      ],
    );
  }
}
