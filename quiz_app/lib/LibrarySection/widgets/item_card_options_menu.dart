import 'package:flutter/material.dart';

import '../../utils/color.dart';
import '../../utils/constants.dart';

/// Options menu item in the popup bubble
class ItemCardOptionsMenu extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onRemoveFromMarketplace;
  final bool showMarketplaceOption;

  const ItemCardOptionsMenu({
    super.key,
    required this.scaleAnimation,
    required this.fadeAnimation,
    required this.onEdit,
    required this.onDelete,
    this.onRemoveFromMarketplace,
    this.showMarketplaceOption = false,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        alignment: Alignment.topRight,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: AppOpacity.shadow),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _OptionItem(
                icon: Icons.edit_outlined,
                label: 'Edit',
                color: AppColors.primary,
                onTap: onEdit,
              ),
              if (showMarketplaceOption && onRemoveFromMarketplace != null) ...[
                Container(height: 1, color: AppColors.surface),
                _OptionItem(
                  icon: Icons.remove_shopping_cart_outlined,
                  label: 'Remove from Marketplace',
                  color: AppColors.accentBright,
                  onTap: onRemoveFromMarketplace!,
                ),
              ],
              Container(height: 1, color: AppColors.surface),
              _OptionItem(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: AppColors.error,
                onTap: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual option item in the menu
class _OptionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
