import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/constants/constants.dart';
import '../texts.dart';

class HeroBannerCard extends StatelessWidget {
  const HeroBannerCard({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    this.badge,
    this.onTap,
  });

  final String title;
  final String description;
  final String? imageUrl;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: AppRadius.largeCard,
          boxShadow: AppShadows.lg,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _CardImage(imageUrl: imageUrl),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0x220F172A), Color(0xD90F172A)],
                ),
              ),
            ),
            Padding(
              padding: AppSpacing.cardInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if (badge != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.92),
                        borderRadius: AppRadius.chip,
                      ),
                      child: Text(
                        badge!,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(
                    title,
                    style: AppTypography.h2.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFFE2E8F0),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FunctionCard extends StatelessWidget {
  const FunctionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = ShadTheme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: onTap,
        child: Ink(
          height: 72,
          padding: AppSpacing.cardInsets,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
            boxShadow: isDark ? AppShadows.darkCard : AppShadows.md,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
                ),
                child: const Icon(
                  LucideIcons.sparkles,
                  size: AppIconSize.md,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    PrimaryText(
                      title,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SecondaryText(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(icon, size: AppIconSize.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.footnote,
  });

  final String label;
  final String value;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final isDark = ShadTheme.of(context).brightness == Brightness.dark;
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: isDark ? AppShadows.darkCard : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CaptionText(label),
          const SizedBox(height: AppSpacing.sm),
          NumericText(value),
          if (footnote != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            SecondaryText(footnote!),
          ],
        ],
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return Container(
        color: AppColors.primary,
        child: const Center(
          child: Icon(
            LucideIcons.clapperboard,
            color: Colors.white,
            size: AppIconSize.xxl,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      errorWidget: (context, _, __) => Container(
        color: AppColors.primary,
        child: const Center(
          child: Icon(
            LucideIcons.imageOff,
            color: Colors.white,
            size: AppIconSize.xxl,
          ),
        ),
      ),
      placeholder: (context, _) => Container(
        color: AppColors.primarySoft,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}
