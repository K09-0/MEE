import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/experience.dart';

/// Experience Card
/// 
/// Карточка микроопыта для отображения в ленте
/// Показывает превью, цену, таймер FOMO, статистику
class ExperienceCard extends StatelessWidget {
  final Experience experience;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool showFomoTimer;

  const ExperienceCard({
    super.key,
    required this.experience,
    this.onTap,
    this.onLike,
    this.showFomoTimer = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.textTertiaryDark.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/Preview section
            Stack(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Container(
                      color: AppTheme.surfaceDarker,
                      child: experience.thumbnailUrl != null
                          ? Image.network(
                              experience.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),
                  ),
                ),
                
                // Type badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          experience.type.icon,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          experience.type.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // FOMO Timer (if expiring soon)
                if (showFomoTimer && experience.isExpiringSoon)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _FomoTimer(remaining: experience.timeRemaining),
                  ),
                
                // Price badge
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppTheme.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      experience.formattedPrice,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    experience.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Creator info
                  Row(
                    children: [
                      // Avatar placeholder
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '@creator${experience.creatorId.substring(0, 4)}',
                        style: TextStyle(
                          color: AppTheme.textSecondaryDark,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      // Rating
                      if (experience.rating > 0) ...[
                        Icon(
                          Icons.star,
                          size: 16,
                          color: AppTheme.accentOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          experience.rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: AppTheme.textSecondaryDark,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Stats row
                  Row(
                    children: [
                      _StatItem(
                        icon: Icons.remove_red_eye_outlined,
                        value: _formatNumber(experience.viewsCount),
                      ),
                      const SizedBox(width: 16),
                      _StatItem(
                        icon: Icons.favorite_outline,
                        value: _formatNumber(experience.likesCount),
                      ),
                      const SizedBox(width: 16),
                      _StatItem(
                        icon: Icons.shopping_bag_outlined,
                        value: '${experience.salesCount} sold',
                      ),
                      const Spacer(),
                      // Like button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onLike?.call();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceDarker,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.favorite_border,
                            size: 20,
                            color: AppTheme.textTertiaryDark,
                          ),
                        ),
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

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForType(),
            size: 48,
            color: AppTheme.textTertiaryDark,
          ),
          const SizedBox(height: 8),
          Text(
            experience.type.displayName,
            style: TextStyle(
              color: AppTheme.textTertiaryDark,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType() {
    switch (experience.type) {
      case ExperienceType.art:
        return Icons.image;
      case ExperienceType.text:
        return Icons.article;
      case ExperienceType.audio:
        return Icons.music_note;
      case ExperienceType.miniGame:
        return Icons.gamepad;
      default:
        return Icons.extension;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

/// FOMO Timer Widget
class _FomoTimer extends StatelessWidget {
  final Duration remaining;

  const _FomoTimer({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.error.withOpacity(0.4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            hours > 0
                ? '${hours}h ${minutes}m'
                : '${minutes}m ${seconds}s',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat Item Widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const _StatItem({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textTertiaryDark,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textSecondaryDark,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
