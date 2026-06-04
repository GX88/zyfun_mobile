import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'dart:convert';

import '../../../data/models/history.dart';
import '../../../core/constants/constants.dart';
import '../../../data/models/iptv.dart';
import '../../components/app_bottom_nav_bar.dart';
import '../../components/app_bar.dart';
import '../../components/buttons/app_buttons.dart';
import '../../components/cards/app_cards.dart';
import '../../components/chips/app_chips.dart';
import '../../components/texts.dart';
import '../../providers/app_providers.dart';
import '../../providers/iptv_provider.dart';

class LivePage extends ConsumerStatefulWidget {
  const LivePage({super.key});

  @override
  ConsumerState<LivePage> createState() => _LivePageState();
}

class _LivePageState extends ConsumerState<LivePage> {
  String? _selectedGroup;
  int _selectedTabIndex = 0;

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
    final groupedChannels = _groupChannels(state.channels);
    final availableGroups = groupedChannels.keys.toList()..sort();
    final currentGroup = _resolveCurrentGroup(availableGroups);
    final visibleChannels = groupedChannels[currentGroup] ?? state.channels;
    final currentChannel = state.selectedChannel;

    return Scaffold(
      appBar: ZyTabAppBar(
        tabs: const <String>['频道', '收藏', '最近'],
        selectedIndex: _selectedTabIndex,
        onSelected: (index) => setState(() => _selectedTabIndex = index),
        actions: <Widget>[
          IconButton(
            tooltip: '搜索',
            onPressed: () => context.push('/search'),
            icon: const Icon(LucideIcons.search, size: AppIconSize.md),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(iptvNotifierProvider.notifier).loadIptvs(),
        child: ListView(
          padding: AppSpacing.pageInsets,
          children: <Widget>[
            _LiveSourceHeader(
              iptvs: state.iptvs,
              selectedIptvId: state.selectedIptv?.id,
              isLoading: state.isLoading,
              errorMessage: state.errorMessage,
              onTapIptv: (iptv) => ref.read(iptvNotifierProvider.notifier).selectIptv(iptv),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 560,
              child: Row(
                children: <Widget>[
                  _ChannelGroupSidebar(
                    groups: availableGroups,
                    selectedGroup: currentGroup,
                    onSelected: (group) => setState(() => _selectedGroup = group),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _LiveContentPanel(
                      selectedIptv: state.selectedIptv,
                      currentChannel: currentChannel,
                      visibleChannels: visibleChannels,
                      isChannelLoading: state.isChannelLoading,
                      onSelectChannel: (channel) => ref
                          .read(iptvNotifierProvider.notifier)
                          .selectChannel(channel),
                      onPlayChannel: _playChannel,
                      onWatchReplay: _watchReplay,
                      buildProgramTimeline: _buildProgramTimeline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _MiniPlayerBar(
              channel: currentChannel,
              onPlay: currentChannel == null ? null : () => _playChannel(currentChannel),
              onReplay: currentChannel == null ? null : () => _watchReplay(currentChannel),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 2),
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
        if (channel.headers != null && channel.headers!.isNotEmpty)
          'headers': jsonEncode(channel.headers),
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

class _LiveSourceHeader extends StatelessWidget {
  const _LiveSourceHeader({
    required this.iptvs,
    required this.selectedIptvId,
    required this.isLoading,
    required this.errorMessage,
    required this.onTapIptv,
  });

  final List<Iptv> iptvs;
  final String? selectedIptvId;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<Iptv> onTapIptv;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const PrimaryText('直播源切换', style: AppTypography.h3),
            const Spacer(),
            StatusChip(
              label: isLoading ? '刷新中' : '在线',
              tone: isLoading ? StatusChipTone.warning : StatusChipTone.success,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        const SecondaryText('优先重构频道浏览与当前播放结构，直播源能力继续复用现有数据层。'),
        const SizedBox(height: AppSpacing.md),
        if (isLoading) const LinearProgressIndicator(),
        if (errorMessage != null) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          _LiveErrorBanner(message: errorMessage!),
        ],
        const SizedBox(height: AppSpacing.md),
        if (iptvs.isEmpty)
          const FunctionCard(
            title: '暂无直播源',
            description: '当前没有可切换的直播源，下拉刷新后重试。',
            icon: LucideIcons.radioTower,
            onTap: _noop,
          )
        else
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: iptvs.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final iptv = iptvs[index];
                return _IptvTile(
                  iptv: iptv,
                  selected: selectedIptvId == iptv.id,
                  onTap: () => onTapIptv(iptv),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ChannelGroupSidebar extends StatelessWidget {
  const _ChannelGroupSidebar({
    required this.groups,
    required this.selectedGroup,
    required this.onSelected,
  });

  final List<String> groups;
  final String? selectedGroup;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: isDark ? AppShadows.darkCard : AppShadows.sm,
      ),
      child: groups.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: SecondaryText('暂无分组'),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.sm),
              itemCount: groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final group = groups[index];
                final selected = group == selectedGroup;
                return _SidebarGroupItem(
                  label: group,
                  selected: selected,
                  onTap: () => onSelected(group),
                );
              },
            ),
    );
  }
}

class _SidebarGroupItem extends StatelessWidget {
  const _SidebarGroupItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primarySoft
                : (isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtle),
            borderRadius: AppRadius.card,
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (isDark ? AppColors.borderDark : AppColors.border),
            ),
          ),
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: selected
                  ? AppColors.primary
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveContentPanel extends StatelessWidget {
  const _LiveContentPanel({
    required this.selectedIptv,
    required this.currentChannel,
    required this.visibleChannels,
    required this.isChannelLoading,
    required this.onSelectChannel,
    required this.onPlayChannel,
    required this.onWatchReplay,
    required this.buildProgramTimeline,
  });

  final Iptv? selectedIptv;
  final Channel? currentChannel;
  final List<Channel> visibleChannels;
  final bool isChannelLoading;
  final ValueChanged<Channel> onSelectChannel;
  final ValueChanged<Channel> onPlayChannel;
  final ValueChanged<Channel> onWatchReplay;
  final List<_ProgramItem> Function(Channel channel) buildProgramTimeline;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final channel = currentChannel;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: isDark ? AppShadows.darkCard : AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: AppSpacing.cardInsets,
            child: _CurrentLiveHero(
              selectedIptv: selectedIptv,
              currentChannel: currentChannel,
              onPlay: channel == null ? null : () => onPlayChannel(channel),
              onReplay: channel == null ? null : () => onWatchReplay(channel),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Divider(height: 1),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: _ChannelListSection(
                      channels: visibleChannels,
                      currentChannelId: currentChannel?.id,
                      isChannelLoading: isChannelLoading,
                      onSelectChannel: onSelectChannel,
                      onPlayChannel: onPlayChannel,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: _ProgramPanel(
                      currentChannel: currentChannel,
                      programItems: channel == null
                          ? const <_ProgramItem>[]
                          : buildProgramTimeline(channel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentLiveHero extends StatelessWidget {
  const _CurrentLiveHero({
    required this.selectedIptv,
    required this.currentChannel,
    required this.onPlay,
    required this.onReplay,
  });

  final Iptv? selectedIptv;
  final Channel? currentChannel;
  final VoidCallback? onPlay;
  final VoidCallback? onReplay;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const PrimaryText('当前播放', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.xs),
              SecondaryText(selectedIptv?.name ?? '未选择直播源'),
              const SizedBox(height: AppSpacing.md),
              PrimaryText(
                currentChannel?.name ?? '请选择频道开始播放',
                style: AppTypography.h2,
              ),
              const SizedBox(height: AppSpacing.xs),
              SecondaryText(currentChannel?.group ?? '频道分组将显示在这里'),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          children: <Widget>[
            PrimaryButton(
              label: '播放直播',
              size: AppButtonSize.small,
              onPressed: onPlay,
            ),
            const SizedBox(height: AppSpacing.sm),
            SecondaryButton(
              label: '回看入口',
              size: AppButtonSize.small,
              onPressed: onReplay,
            ),
          ],
        ),
      ],
    );
  }
}

class _ChannelListSection extends StatelessWidget {
  const _ChannelListSection({
    required this.channels,
    required this.currentChannelId,
    required this.isChannelLoading,
    required this.onSelectChannel,
    required this.onPlayChannel,
  });

  final List<Channel> channels;
  final String? currentChannelId;
  final bool isChannelLoading;
  final ValueChanged<Channel> onSelectChannel;
  final ValueChanged<Channel> onPlayChannel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const PrimaryText('频道列表', style: AppTypography.h3),
            const Spacer(),
            if (isChannelLoading)
              const SizedBox(
                width: AppIconSize.sm,
                height: AppIconSize.sm,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: channels.isEmpty
              ? const Center(child: SecondaryText('暂无频道数据'))
              : ListView.separated(
                  itemCount: channels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final channel = channels[index];
                    return _ChannelTile(
                      channel: channel,
                      selected: currentChannelId == channel.id,
                      onTap: () => onSelectChannel(channel),
                      action: OutlineActionButton(
                        label: '播放',
                        size: AppButtonSize.small,
                        onPressed: () => onPlayChannel(channel),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ProgramPanel extends StatelessWidget {
  const _ProgramPanel({
    required this.currentChannel,
    required this.programItems,
  });

  final Channel? currentChannel;
  final List<_ProgramItem> programItems;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceSubtleDark : AppColors.surfaceSubtle,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PrimaryText('节目单', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.xs),
          SecondaryText(
            currentChannel == null
                ? '选择频道后查看当前节目安排'
                : '${currentChannel!.name} 的基础节目流',
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: programItems.isEmpty
                ? const Center(child: SecondaryText('暂无节目安排'))
                : ListView.separated(
                    itemCount: programItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) => _ProgramTile(program: programItems[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MiniPlayerBar extends StatelessWidget {
  const _MiniPlayerBar({
    required this.channel,
    required this.onPlay,
    required this.onReplay,
  });

  final Channel? channel;
  final VoidCallback? onPlay;
  final VoidCallback? onReplay;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.card,
        boxShadow: isDark ? AppShadows.darkCard : AppShadows.floating,
      ),
      child: Row(
        children: <Widget>[
          const Icon(LucideIcons.radio, color: Colors.white, size: AppIconSize.lg),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  channel?.name ?? '未选择频道',
                  style: AppTypography.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  channel?.group ?? '底部迷你播放器已就位',
                  style: AppTypography.caption.copyWith(color: const Color(0xFFE2E8F0)),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          OutlineActionButton(
            label: '回看',
            size: AppButtonSize.small,
            onPressed: onReplay,
          ),
          const SizedBox(width: AppSpacing.sm),
          PrimaryButton(
            label: '播放',
            size: AppButtonSize.small,
            onPressed: onPlay,
          ),
        ],
      ),
    );
  }
}

class _LiveErrorBanner extends StatelessWidget {
  const _LiveErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: AppRadius.card,
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: SecondaryText(
        message,
        style: AppTypography.bodySmall.copyWith(color: const Color(0xFF991B1B)),
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Ink(
          width: 220,
          padding: AppSpacing.cardInsets,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primarySoft
                : (isDark ? AppColors.surfaceDark : AppColors.surface),
            borderRadius: AppRadius.card,
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (isDark ? AppColors.borderDark : AppColors.border),
            ),
            boxShadow: isDark ? AppShadows.darkCard : AppShadows.sm,
          ),
          child: Row(
            children: <Widget>[
              const Icon(LucideIcons.radioTower, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    PrimaryText(
                      iptv.name,
                      style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SecondaryText(
                      iptv.isText ? '文本直播源' : '远程直播源',
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(LucideIcons.badgeCheck, color: AppColors.primary),
            ],
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Ink(
          padding: AppSpacing.cardInsets,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primarySoft
                : (isDark ? AppColors.surfaceSubtleDark : AppColors.surface),
            borderRadius: AppRadius.card,
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (isDark ? AppColors.borderDark : AppColors.border),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(LucideIcons.tv, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    PrimaryText(
                      channel.name,
                      style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SecondaryText(channel.group ?? '未分组'),
                    if (channel.url.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSpacing.xs),
                      CaptionText(
                        channel.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (action != null) ...<Widget>[
                const SizedBox(width: AppSpacing.md),
                action!,
              ],
            ],
          ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 56,
          child: CaptionText(program.timeLabel),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              PrimaryText(program.title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.xs),
              SecondaryText(program.status),
            ],
          ),
        ),
      ],
    );
  }
}

void _noop() {}
