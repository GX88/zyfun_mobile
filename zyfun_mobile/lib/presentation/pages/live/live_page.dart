import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../components/app_bottom_nav_bar.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('直播'),
        actions: <Widget>[
          IconButton(
            tooltip: '设置',
            onPressed: () => context.push('/setting'),
            icon: const Icon(LucideIcons.settings2),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ShadCard(
            title: Text('直播源', style: theme.textTheme.h4),
            description: const Text('直播源管理和频道列表将在这里接入。'),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _LiveInfoTile(
                    icon: LucideIcons.radioTower,
                    title: 'M3U 远程源',
                    subtitle: '后续接入 M3U 解析与频道列表。',
                  ),
                  SizedBox(height: 12),
                  _LiveInfoTile(
                    icon: LucideIcons.tv,
                    title: '节目单 EPG',
                    subtitle: '后续接入节目单展示与回看能力。',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 1),
    );
  }
}

class _LiveInfoTile extends StatelessWidget {
  const _LiveInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: theme.textTheme.large),
              const SizedBox(height: 4),
              Text(subtitle, style: theme.textTheme.muted),
            ],
          ),
        ),
      ],
    );
  }
}
