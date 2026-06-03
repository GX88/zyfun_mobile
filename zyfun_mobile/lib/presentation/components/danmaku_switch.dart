import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
    final theme = ShadTheme.of(context);

    return ShadCard(
      title: Text('弹幕开关', style: theme.textTheme.large),
      description: Text(
        description ?? '当前为本地演示状态，后续会接入真实弹幕流。',
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(value ? '弹幕已开启' : '弹幕已关闭'),
            ),
            ShadSwitch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
