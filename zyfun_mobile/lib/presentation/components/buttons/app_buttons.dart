import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/constants/constants.dart';

enum AppButtonSize {
  small(height: 36, horizontalPadding: 12, fontSize: 14),
  medium(height: 44, horizontalPadding: 16, fontSize: 15),
  large(height: 52, horizontalPadding: 20, fontSize: 16);

  const AppButtonSize({
    required this.height,
    required this.horizontalPadding,
    required this.fontSize,
  });

  final double height;
  final double horizontalPadding;
  final double fontSize;
}

class _ButtonChild extends StatelessWidget {
  const _ButtonChild({required this.label, required this.size});

  final String label;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.horizontalPadding),
      child: Text(
        label,
        style: AppTypography.body.copyWith(
          fontSize: size.fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height,
      child: ShadButton(
        onPressed: onPressed,
        leading: leading,
        child: _ButtonChild(label: label, size: size),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height,
      child: ShadButton.secondary(
        onPressed: onPressed,
        leading: leading,
        child: _ButtonChild(label: label, size: size),
      ),
    );
  }
}

class OutlineActionButton extends StatelessWidget {
  const OutlineActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height,
      child: ShadButton.outline(
        onPressed: onPressed,
        leading: leading,
        child: _ButtonChild(label: label, size: size),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height,
      child: ShadButton.ghost(
        onPressed: onPressed,
        leading: leading,
        child: _ButtonChild(label: label, size: size),
      ),
    );
  }
}

class DestructiveButton extends StatelessWidget {
  const DestructiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height,
      child: ShadButton.destructive(
        onPressed: onPressed,
        leading: leading,
        child: _ButtonChild(label: label, size: size),
      ),
    );
  }
}

class LinkActionButton extends StatelessWidget {
  const LinkActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height,
      child: ShadButton.link(
        onPressed: onPressed,
        leading: leading,
        child: _ButtonChild(label: label, size: size),
      ),
    );
  }
}
