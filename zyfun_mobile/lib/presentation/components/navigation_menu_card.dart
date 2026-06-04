import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/constants.dart';
import 'buttons/app_buttons.dart';
import 'texts.dart';

class NavigationMenuItem {
  const NavigationMenuItem({
    required this.label,
    required this.route,
    required this.icon,
  });

  final String label;
  final String route;
  final IconData icon;
}

class NavigationMenuCard extends StatelessWidget {
  const NavigationMenuCard({
    super.key,
    required this.title,
    required this.description,
    required this.items,
  });

  final String title;
  final String description;
  final List<NavigationMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: isDark ? AppShadows.darkCard : AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          PrimaryText(title, style: AppTypography.h3),
          const SizedBox(height: AppSpacing.xs),
          SecondaryText(description),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: items
                .map(
                  (item) => OutlineActionButton(
                    onPressed: () => context.push(item.route),
                    label: item.label,
                    leading: Icon(item.icon, size: AppIconSize.sm),
                    size: AppButtonSize.small,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
