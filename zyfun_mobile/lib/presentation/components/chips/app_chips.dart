import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = selected
        ? AppColors.primary
        : (isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtle);
    final foregroundColor = selected
        ? Colors.white
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.chip,
        child: Ink(
          height: 28,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: AppRadius.chip,
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (isDark ? AppColors.borderDark : AppColors.border),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: foregroundColor,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum StatusChipTone { success, warning, danger, info }

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.tone,
  });

  final String label;
  final StatusChipTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground, Color border) = switch (tone) {
      StatusChipTone.success => (
          AppColors.successSoft,
          const Color(0xFF166534),
          const Color(0xFF86EFAC),
        ),
      StatusChipTone.warning => (
          AppColors.warningSoft,
          const Color(0xFF92400E),
          const Color(0xFFFCD34D),
        ),
      StatusChipTone.danger => (
          AppColors.errorSoft,
          const Color(0xFF991B1B),
          const Color(0xFFFCA5A5),
        ),
      StatusChipTone.info => (
          AppColors.infoSoft,
          const Color(0xFF1E40AF),
          const Color(0xFF93C5FD),
        ),
    };

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.chip,
        border: Border.all(color: border),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppChip(label: label, selected: selected, onTap: onTap);
  }
}
