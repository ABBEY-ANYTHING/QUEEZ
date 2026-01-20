import 'package:flutter/material.dart';

import '../models/library_item.dart';
import '../../utils/color.dart';
import '../../utils/constants.dart';
import 'item_card_clippers.dart';
import 'item_card_helpers.dart';

/// Thumbnail widget for library item cards
class ItemCardThumbnail extends StatelessWidget {
  final LibraryItem item;

  const ItemCardThumbnail({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.thumbnailWidth,
      height: AppSizes.thumbnailHeight,
      margin: AppPadding.allLg,
      child: ClipPath(
        clipper: ThumbnailShapeClipper(),
        child: Container(
          decoration: BoxDecoration(color: ItemCardColors.getAccentColor(item)),
          child: item.coverImagePath != null
              ? Image.network(
                  item.coverImagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _DefaultThumbnailIcon(item: item),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _DefaultThumbnailIcon(item: item);
                  },
                )
              : _DefaultThumbnailIcon(item: item),
        ),
      ),
    );
  }
}

/// Default thumbnail icon shown when no image is available
class _DefaultThumbnailIcon extends StatelessWidget {
  final LibraryItem item;

  const _DefaultThumbnailIcon({required this.item});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            ItemTypeHelper.getIcon(item),
            size: 42,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 6),
          Text(
            ItemTypeHelper.getLabel(item),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

/// Type badge widget showing the item type (Quiz, Flashcard, etc.)
class ItemTypeBadge extends StatelessWidget {
  final LibraryItem item;

  const ItemTypeBadge({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ItemCardColors.getAccentColor(item),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(4),
        ),
      ),
      child: Text(
        ItemTypeHelper.getLabel(item).toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// Type badge row including marketplace listing tag
class ItemTypeBadgeRow extends StatelessWidget {
  final LibraryItem item;

  const ItemTypeBadgeRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ItemTypeBadge(item: item),
        // Marketplace listing tag for course packs that are public
        if (item.isCoursePack && item.isPublic) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentBright.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.accentBright.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storefront_rounded,
                  size: 12,
                  color: AppColors.accentBright,
                ),
                const SizedBox(width: 4),
                Text(
                  'Listed',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentBright,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Statistics row showing item count, author, and date
class ItemStatsRow extends StatelessWidget {
  final LibraryItem item;

  const ItemStatsRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final textColor = ItemCardColors.getTextColor(item);
    final accentColor = ItemCardColors.getAccentColor(item);

    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: [
        // Item count
        _StatChip(
          icon: ItemTypeHelper.getIcon(item),
          text: ItemTypeHelper.getItemCountText(item),
          textColor: textColor,
          backgroundColor: accentColor,
        ),
        // Author (if available)
        if (item.originalOwnerUsername != null &&
            item.originalOwnerUsername!.isNotEmpty)
          _StatChip(
            icon: Icons.person_outline_rounded,
            text: item.originalOwnerUsername!,
            textColor: textColor,
            backgroundColor: accentColor,
          ),
        // Date (if available)
        if (item.createdAt != null)
          _StatChip(
            icon: Icons.access_time_rounded,
            text: formatDateShort(item.createdAt!),
            textColor: textColor,
            backgroundColor: accentColor,
          ),
      ],
    );
  }
}

/// Individual stat chip widget
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color textColor;
  final Color backgroundColor;

  const _StatChip({
    required this.icon,
    required this.text,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
