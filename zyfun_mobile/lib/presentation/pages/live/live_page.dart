import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../data/models/iptv.dart';
import '../../components/app_bottom_nav_bar.dart';
import '../../providers/iptv_provider.dart';

class LivePage extends ConsumerStatefulWidget {
  const LivePage({super.key});

  @override
  ConsumerState<LivePage> createState() => _LivePageState();
}

class _LivePageState extends ConsumerState<LivePage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(iptvNotifierProvider.notifier).loadIptvs(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(iptvNotifierProvider);
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
      body: RefreshIndicator(
        onRefresh: () => ref.read(iptvNotifierProvider.notifier).loadIptvs(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const NavigationMenuCard(
              title: '快捷入口',
              description: '在直播能力补齐前，先提供常用页面跳转。',
              items: <NavigationMenuItem>[
                NavigationMenuItem(
                  label: '影视首页',
                  route: '/film',
                  icon: LucideIcons.clapperboard,
                ),
                NavigationMenuItem(
                  label: '解析配置',
                  route: '/parse',
                  icon: LucideIcons.sparkles,
                ),
                NavigationMenuItem(
                  label: '应用设置',
                  route: '/setting',
                  icon: LucideIcons.settings2,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ShadCard(
              title: Text('直播源', style: theme.textTheme.h4),
              description: const Text('当前接入 M3U 频道列表与默认直播源选择。'),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (state.isLoading) const LinearProgressIndicator(),
                    if (state.errorMessage != null) ...<Widget>[
                      Text(
                        state.errorMessage!,
                        style: theme.textTheme.small.copyWith(
                          color: theme.colorScheme.destructive,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    ...state.iptvs.map(
                      (iptv) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _IptvTile(
                          iptv: iptv,
                          selected: state.selectedIptv?.id == iptv.id,
                          onTap: () => ref
                              .read(iptvNotifierProvider.notifier)
                              .selectIptv(iptv),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ShadCard(
              title: Text('频道列表', style: theme.textTheme.h4),
              description: Text(
                state.selectedIptv == null
                    ? '请选择直播源后查看频道。'
                    : '当前源：${state.selectedIptv!.name}',
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: state.isChannelLoading
                    ? const LinearProgressIndicator()
                    : state.channels.isEmpty
                        ? Text('暂无频道数据', style: theme.textTheme.muted)
                        : Column(
                            children: state.channels
                                .take(20)
                                .map(
                                  (channel) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _ChannelTile(channel: channel),
                                  ),
                                )
                                .toList(),
                          ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 1),
    );
  }
}

class _IptvTile extends StatelessWidget {
  const _IptvTile({
    required this.iptv,
    required this.selected,
    required this.onTap,
  });

  final Iptv iptv;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(LucideIcons.radioTower, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(iptv.name, style: theme.textTheme.large),
                  const SizedBox(height: 4),
                  Text(
                    iptv.isText ? '文本直播源' : '远程直播源',
                    style: theme.textTheme.muted,
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(LucideIcons.check, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  const _ChannelTile({required this.channel});

  final Channel channel;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(LucideIcons.tv, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(channel.name, style: theme.textTheme.large),
              const SizedBox(height: 4),
              Text(channel.group ?? '未分组', style: theme.textTheme.muted),
            ],
          ),
        ),
      ],
    );
  }
}
