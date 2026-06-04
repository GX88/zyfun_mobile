import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/constants/constants.dart';

export 'danmaku_switch.dart';
export 'navigation_menu_card.dart';
export 'player_control_bar.dart';
export 'search_bar.dart';
export 'video_card.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const items = <({IconData icon, String label, String route})>[
      (icon: LucideIcons.clapperboard, label: '影视', route: '/film'),
      (icon: LucideIcons.compass, label: '探索', route: '/search'),
      (icon: LucideIcons.tv, label: '直播', route: '/live'),
      (icon: LucideIcons.userRound, label: '我的', route: '/setting'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 83,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          boxShadow: isDark ? AppShadows.darkCard : AppShadows.sm,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Row(
          children: List<Widget>.generate(items.length, (index) {
            final item = items[index];
            final selected = selectedIndex == index;
            final color = selected
                ? AppColors.primary
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);
            return Expanded(
              child: InkWell(
                borderRadius: AppRadius.card,
                onTap: () => context.go(item.route),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                        height: 2,
                        width: 20,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : Colors.transparent,
                          borderRadius: AppRadius.chip,
                        ),
                      ),
                      Icon(item.icon, size: AppIconSize.lg, color: color),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        item.label,
                        style: AppTypography.caption.copyWith(
                          color: color,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
