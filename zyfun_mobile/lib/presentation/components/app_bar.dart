import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/constants/constants.dart';

class ZySectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ZySectionAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = false,
    this.centerTitle = false,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final isDark = ShadTheme.of(context).brightness == Brightness.dark;

    return AppBar(
      automaticallyImplyLeading: showBack,
      centerTitle: centerTitle,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      surfaceTintColor: Colors.transparent,
      title: Text(
        title,
        style: AppTypography.h3.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      actions: actions,
    );
  }
}

class ZySearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ZySearchAppBar({
    super.key,
    required this.placeholder,
    required this.onTap,
    this.actions,
  });

  final String placeholder;
  final VoidCallback onTap;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final isDark = ShadTheme.of(context).brightness == Brightness.dark;

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 72,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      surfaceTintColor: Colors.transparent,
      titleSpacing: AppSpacing.pagePadding,
      title: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtle,
            borderRadius: AppRadius.input,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                LucideIcons.search,
                size: AppIconSize.md,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  placeholder,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: actions,
    );
  }
}

class ZyTabAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ZyTabAppBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    this.actions,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final isDark = ShadTheme.of(context).brightness == Brightness.dark;

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 72,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      surfaceTintColor: Colors.transparent,
      titleSpacing: AppSpacing.pagePadding,
      title: Row(
        children: List<Widget>.generate(tabs.length, (index) {
          final selected = index == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: index == tabs.length - 1 ? 0 : AppSpacing.md),
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primarySoft
                      : Colors.transparent,
                  borderRadius: AppRadius.button,
                ),
                child: Text(
                  tabs[index],
                  style: AppTypography.body.copyWith(
                    color: selected
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
      actions: actions,
    );
  }
}
