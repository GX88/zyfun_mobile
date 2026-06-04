import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../data/models/history.dart';
import '../../../data/models/iptv.dart';
import '../../components/app_bottom_nav_bar.dart';
import '../../providers/app_providers.dart';
import '../../providers/iptv_provider.dart';

class LivePage extends ConsumerStatefulWidget {
  const LivePage({super.key});

  @override
  ConsumerState<LivePage> createState() => _LivePageState();
}

class _LivePageState extends ConsumerState<LivePage> {
  String? _selectedGroup;

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
    final groupedChannels = _groupChannels(state.channels);
    final availableGroups = groupedChannels.keys.toList()..sort();
    final currentGroup = _resolveCurrentGroup(availableGroups);
    final visibleChannels = groupedChannels[currentGroup] ?? state.channels;
    final currentChannel = state.selectedChannel;

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
              title: Text('当前播放', style: theme.textTheme.h4),
              description: Text(
                currentChannel == null
                    ? '请选择频道开始播放。'
                    : '当前频道：${currentChannel.name}',
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: currentChannel == null
                    ? Text('暂无已选频道', style: theme.textTheme.muted)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _ChannelTile(
                            channel: currentChannel,
                            selected: true,
                            onTap: () => ref
                                .read(iptvNotifierProvider.notifier)
                                .selectChannel(currentChannel),
                            action: ShadButton(
                              onPressed: () => _playChannel(currentChannel),
                              child: const Text('立即播放'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: ShadButton.outline(
                                  onPressed: () => _playChannel(currentChannel),
                                  child: const Text('播放直播'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ShadButton.secondary(
                                  onPressed: () => _watchReplay(currentChannel),
                                  child: const Text('回看入口'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            ShadCard(
              title: Text('节目单', style: theme.textTheme.h4),
              description: Text(
                state.selectedIptv?.epg?.isNotEmpty == true
                    ? '已配置 EPG 地址，当前页面先展示基础节目单视图。'
                    : '当前直播源未配置 EPG，先展示默认节目流。',
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: currentChannel == null
                    ? Text('选择频道后可查看节目安排', style: theme.textTheme.muted)
                    : Column(
                        children: _buildProgramTimeline(currentChannel)
                            .map(
                              (program) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ProgramTile(program: program),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            ShadCard(
              title: Text('频道列表', style: theme.textTheme.h4),
              description: Text(
                state.selectedIptv == null
                    ? '请选择直播源后查看频道。'
                    : '当前源：${state.selectedIptv!.name}，支持频道切换和分组浏览。',
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: state.isChannelLoading
                    ? const LinearProgressIndicator()
                    : state.channels.isEmpty
                        ? Text('暂无频道数据', style: theme.textTheme.muted)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (availableGroups.isNotEmpty) ...<Widget>[
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: availableGroups
                                      .map(
                                        (group) => ShadButton.outline(
                                          onPressed: () => setState(() => _selectedGroup = group),
                                          child: Text(group),
                                        ),
                                      )
                                      .toList(),
                                ),
                                const SizedBox(height: 16),
                              ],
                              ...visibleChannels.take(30).map(
                                (channel) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _ChannelTile(
                                    channel: channel,
                                    selected: currentChannel?.id == channel.id,
                                    onTap: () => ref
                                        .read(iptvNotifierProvider.notifier)
                                        .selectChannel(channel),
                                    action: ShadButton.outline(
                                      onPressed: () => _playChannel(channel),
                                      child: const Text('播放'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 1),
    );
  }

  Map<String, List<Channel>> _groupChannels(List<Channel> channels) {
    final groups = <String, List<Channel>>{};
    for (final channel in channels) {
      final group = channel.group?.trim().isNotEmpty == true ? channel.group!.trim() : '未分组';
      groups.putIfAbsent(group, () => <Channel>[]).add(channel);
    }
    return groups;
  }

  String? _resolveCurrentGroup(List<String> availableGroups) {
    if (availableGroups.isEmpty) {
      return null;
    }
    if (_selectedGroup != null && availableGroups.contains(_selectedGroup)) {
      return _selectedGroup;
    }
    _selectedGroup = availableGroups.first;
    return _selectedGroup;
  }

  List<_ProgramItem> _buildProgramTimeline(Channel channel) {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day, now.hour);
    return <_ProgramItem>[
      _ProgramItem(
        timeLabel: _formatClock(base.subtract(const Duration(hours: 1))),
        title: '${channel.name} 早间节目',
        status: '可回看',
      ),
      _ProgramItem(
        timeLabel: _formatClock(base),
        title: '${channel.name} 正在直播',
        status: '直播中',
      ),
      _ProgramItem(
        timeLabel: _formatClock(base.add(const Duration(hours: 1))),
        title: '${channel.name} 下一档节目',
        status: '即将开始',
      ),
    ];
  }

  String _formatClock(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _playChannel(Channel channel) {
    final uri = Uri(
      path: '/player/${channel.id}',
      queryParameters: <String, String>{
        'title': channel.name,
        'url': channel.url,
        'episode': channel.group ?? '直播',
      },
    );
    context.push(uri.toString());
  }

  Future<void> _watchReplay(Channel channel) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await ref.read(historyRepositoryProvider).addHistory(
          History(
            id: 'live_${channel.id}',
            siteId: stateSiteId,
            videoId: channel.id,
            title: channel.name,
            description: '直播回看入口',
            episodeUrl: channel.url,
            episodeName: '${channel.group ?? '直播'} 回看',
            createdAt: now,
            updatedAt: now,
          ),
        );

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text('${channel.name} 已加入历史，可在历史页继续观看')),
    );
    _playChannel(channel);
  }

  String get stateSiteId => ref.read(iptvNotifierProvider).selectedIptv?.id ?? 'live';
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
  const _ChannelTile({
    required this.channel,
    required this.selected,
    required this.onTap,
    this.action,
  });

  final Channel channel;
  final bool selected;
  final VoidCallback onTap;
  final Widget? action;

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
            color: selected ? theme.colorScheme.primary : theme.colorScheme.border,
          ),
        ),
        child: Row(
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
                  if (channel.url.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      channel.url,
                      style: theme.textTheme.small,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (action != null) ...<Widget>[
              const SizedBox(width: 12),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgramItem {
  const _ProgramItem({
    required this.timeLabel,
    required this.title,
    required this.status,
  });

  final String timeLabel;
  final String title;
  final String status;
}

class _ProgramTile extends StatelessWidget {
  const _ProgramTile({required this.program});

  final _ProgramItem program;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 56,
          child: Text(program.timeLabel, style: theme.textTheme.small),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(program.title, style: theme.textTheme.large),
              const SizedBox(height: 4),
              Text(program.status, style: theme.textTheme.muted),
            ],
          ),
        ),
      ],
    );
  }
}
