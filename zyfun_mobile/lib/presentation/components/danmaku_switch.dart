import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'cards/app_cards.dart';

class DanmakuSwitch extends StatelessWidget {
  const DanmakuSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.description,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return FunctionCard(
      title: '弹幕开关',
      description: description ?? '当前为本地演示状态，后续会接入真实弹幕流。',
      icon: LucideIcons.chevronRight,
      onTap: () => onChanged(!value),
    );
  }
}
