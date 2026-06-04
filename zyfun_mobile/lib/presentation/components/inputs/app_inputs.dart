import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/constants/constants.dart';

class _InputShell extends StatelessWidget {
  const _InputShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = ShadTheme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtle,
        borderRadius: AppRadius.input,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: child,
    );
  }
}

class SearchInput extends StatelessWidget {
  const SearchInput({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.onSubmitted,
    this.trailing,
  });

  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String> onSubmitted;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: _InputShell(
        child: ShadInput(
          controller: controller,
          placeholder: Text(placeholder, style: AppTypography.bodySmall),
          leading: const Icon(LucideIcons.search, size: AppIconSize.md),
          trailing: trailing,
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }
}

class TextInput extends StatelessWidget {
  const TextInput({
    super.key,
    required this.controller,
    required this.placeholder,
    this.leading,
    this.trailing,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String placeholder;
  final Widget? leading;
  final Widget? trailing;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return _InputShell(
      child: ShadInput(
        controller: controller,
        placeholder: Text(placeholder, style: AppTypography.bodySmall),
        leading: leading,
        trailing: trailing,
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class PasswordInput extends StatelessWidget {
  const PasswordInput({
    super.key,
    required this.controller,
    required this.placeholder,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return _InputShell(
      child: ShadInput(
        controller: controller,
        obscureText: true,
        placeholder: Text(placeholder, style: AppTypography.bodySmall),
        leading: const Icon(LucideIcons.lock, size: AppIconSize.md),
        onSubmitted: onSubmitted,
      ),
    );
  }
}
