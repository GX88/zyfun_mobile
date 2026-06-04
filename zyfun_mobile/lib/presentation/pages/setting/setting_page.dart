import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/constants/constants.dart';
import '../../../data/services/config_import_service.dart';
import '../../components/app_bottom_nav_bar.dart';
import '../../components/app_bar.dart';
import '../../components/buttons/app_buttons.dart';
import '../../components/cards/app_cards.dart';
import '../../components/chips/app_chips.dart';
import '../../components/inputs/app_inputs.dart';
import '../../components/texts.dart';
import '../../providers/iptv_provider.dart';
import '../../providers/setting_provider.dart';
import '../../providers/site_provider.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  static const String _defaultImportPath =
      '/workspace/.monkeycode-tmp-files/05f39be6-config-1.json';

  late final TextEditingController _pathController;
  bool _isImporting = false;
  String? _importSummary;
  bool _importSucceeded = false;

  @override
  void initState() {
    super.initState();
    _pathController = TextEditingController(text: _defaultImportPath);
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setting = ref.watch(settingNotifierProvider);
    final notifier = ref.read(settingNotifierProvider.notifier);
    final stats = <({String label, String value})>[
      (label: '历史', value: '12'),
      (label: '收藏', value: '24'),
      (label: '下载', value: '8'),
      (label: '线路', value: setting.defaultSite.isEmpty ? '0' : '1'),
    ];

    return Scaffold(
      appBar: ZySectionAppBar(
        title: '我的',
        actions: <Widget>[
          IconButton(
            tooltip: '关于',
            onPressed: () => context.push('/about'),
            icon: const Icon(LucideIcons.bell, size: AppIconSize.md),
          ),
          IconButton(
            tooltip: '设置',
            onPressed: () => context.push('/about'),
            icon: const Icon(LucideIcons.settings2, size: AppIconSize.md),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: AppSpacing.pageInsets,
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  _UserHeroCard(setting: setting),
                  const SizedBox(height: AppSpacing.lg),
                  _VipCard(setting: setting),
                  const SizedBox(height: AppSpacing.lg),
                  _StatsGrid(stats: stats),
                  const SizedBox(height: AppSpacing.lg),
                  _FunctionMenuSection(setting: setting),
                  const SizedBox(height: AppSpacing.lg),
                  _PreferencePanel(setting: setting, notifier: notifier),
                  const SizedBox(height: AppSpacing.lg),
                  _ImportPanel(
                    controller: _pathController,
                    isImporting: _isImporting,
                    importSummary: _importSummary,
                    importSucceeded: _importSucceeded,
                    onPickFile: _pickLocalConfigFile,
                    onImport: () => _importConfig(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 3),
    );
  }

  Future<void> _importConfig(BuildContext context) async {
    setState(() {
      _isImporting = true;
      _importSummary = null;
    });

    try {
      final result = await ref
          .read(settingNotifierProvider.notifier)
          .importDesktopConfigFile(_pathController.text.trim());
      await _refreshImportedData();
      if (!mounted) {
        return;
      }
      setState(() {
        _importSucceeded = true;
        _importSummary = _buildImportSummary(result);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _importSucceeded = false;
        _importSummary = '导入失败：$error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  Future<void> _pickLocalConfigFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['json'],
      withData: true,
    );
    final file = result?.files.single;
    if (!mounted || file == null) {
      return;
    }

    final bytes = file.bytes;
    if (bytes != null && bytes.isNotEmpty) {
      await _importPickedFileBytes(bytes, file.name);
      return;
    }

    final path = file.path;
    if (path == null || path.isEmpty) {
      setState(() {
        _importSucceeded = false;
        _importSummary = '读取所选文件失败，请重新选择 JSON 文件。';
      });
      return;
    }

    setState(() {
      _pathController.text = path;
    });
  }

  Future<void> _importPickedFileBytes(List<int> bytes, String fileName) async {
    setState(() {
      _isImporting = true;
      _importSummary = null;
    });

    try {
      final result = await ref
          .read(settingNotifierProvider.notifier)
          .importDesktopConfigBytes(bytes);
      await _refreshImportedData();
      if (!mounted) {
        return;
      }
      setState(() {
        _importSucceeded = true;
        _pathController.text = fileName;
        _importSummary = _buildImportSummary(result);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _importSucceeded = false;
        _importSummary = '导入失败：$error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  Future<void> _refreshImportedData() async {
    await ref.read(siteNotifierProvider.notifier).loadSites();
    await ref.read(iptvNotifierProvider.notifier).loadIptvs();
  }

  String _buildImportSummary(ConfigImportResult result) {
    final summary =
        '导入完成：站点 ${result.sitesImported}，直播源 ${result.iptvsImported}，解析 ${result.analyzesImported}。';
    if (result.skippedSites > 0) {
      return '$summary 跳过 ${result.skippedSites} 个暂不支持的站点类型。';
    }
    return summary;
  }
}

class _UserHeroCard extends StatelessWidget {
  const _UserHeroCard({required this.setting});

  final dynamic setting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF0F172A), Color(0xFF334155), Color(0xFF475569)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.largeCard,
        boxShadow: AppShadows.lg,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            ),
            child: const Icon(LucideIcons.userRound, color: Colors.white, size: 32),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'ZyFun 用户',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  '多源播放体验优先 · 收藏你的观影节奏',
                  style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: AppRadius.chip,
            ),
            child: Text(
              setting.theme == 'dark' ? 'Night' : 'VIP',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _VipCard extends StatelessWidget {
  const _VipCard({required this.setting});

  final dynamic setting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: const BoxDecoration(
        gradient: AppColors.vipGradient,
        borderRadius: AppRadius.largeCard,
        boxShadow: AppShadows.lg,
      ),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'ZyFun 高级会员',
                  style: TextStyle(color: Color(0xFF451A03), fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  '更快线路切换、个性化推荐、更多播放偏好管理。',
                  style: TextStyle(color: Color(0xFF78350F), fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          PrimaryButton(
            label: setting.hardwareAcceleration ? '已启用' : '立即开通',
            size: AppButtonSize.small,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<({String label, String value})> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(stats.length, (index) {
        final stat = stats[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == stats.length - 1 ? 0 : AppSpacing.sm),
            child: StatCard(label: stat.label, value: stat.value),
          ),
        );
      }),
    );
  }
}

class _FunctionMenuSection extends StatelessWidget {
  const _FunctionMenuSection({required this.setting});

  final dynamic setting;

  @override
  Widget build(BuildContext context) {
    final items = <({String title, String subtitle, IconData icon, VoidCallback onTap})>[
      (
        title: '播放历史',
        subtitle: '继续上次观看内容',
        icon: LucideIcons.history,
        onTap: () => context.push('/history'),
      ),
      (
        title: '我的收藏',
        subtitle: '查看已收藏影片与资源',
        icon: LucideIcons.star,
        onTap: () => context.push('/favorite'),
      ),
      (
        title: 'AI 功能',
        subtitle: '打开本地 AI 推荐入口',
        icon: LucideIcons.sparkles,
        onTap: () => context.push('/ai'),
      ),
      (
        title: '嗅探工具',
        subtitle: '调试网页容器与页面加载',
        icon: LucideIcons.radar,
        onTap: () => context.push('/sniffer'),
      ),
      (
        title: '关于应用',
        subtitle: '查看版本与后续规划',
        icon: LucideIcons.info,
        onTap: () => context.push('/about'),
      ),
      (
        title: '组件预览',
        subtitle: '进入 shadcn 组件库展示页',
        icon: LucideIcons.layoutGrid,
        onTap: () => context.push('/shadcn'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const PrimaryText('功能列表', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.md),
        Column(
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _MenuItemCard(
                    title: item.title,
                    subtitle: item.subtitle,
                    icon: item.icon,
                    onTap: item.onTap,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
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
          padding: AppSpacing.cardInsets,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
            boxShadow: isDark ? AppShadows.darkCard : AppShadows.sm,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Icon(icon, color: Colors.white, size: AppIconSize.md),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    PrimaryText(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: AppSpacing.xs),
                    SecondaryText(subtitle),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, size: AppIconSize.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreferencePanel extends StatelessWidget {
  const _PreferencePanel({required this.setting, required this.notifier});

  final dynamic setting;
  final dynamic notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.border,
        ),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? AppShadows.darkCard
            : AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PrimaryText('偏好设置', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.xs),
          const SecondaryText('把常用设置下沉到我的页底部，保留现有可用能力。'),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              _ThemeModeChip(
                label: '跟随系统',
                selected: setting.theme == 'system',
                onTap: () => notifier.updateThemeMode('system'),
              ),
              _ThemeModeChip(
                label: '浅色',
                selected: setting.theme == 'light',
                onTap: () => notifier.updateThemeMode('light'),
              ),
              _ThemeModeChip(
                label: '深色',
                selected: setting.theme == 'dark',
                onTap: () => notifier.updateThemeMode('dark'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    PrimaryText('硬件加速'),
                    SizedBox(height: AppSpacing.xs),
                    SecondaryText('播放器优先使用硬件解码'),
                  ],
                ),
              ),
              ShadSwitch(
                value: setting.hardwareAcceleration,
                onChanged: (value) => notifier.updateHardwareAcceleration(value),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeModeChip extends StatelessWidget {
  const _ThemeModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppChip(label: label, selected: selected, onTap: onTap);
  }
}

class _ImportPanel extends StatelessWidget {
  const _ImportPanel({
    required this.controller,
    required this.isImporting,
    required this.importSummary,
    required this.importSucceeded,
    required this.onPickFile,
    required this.onImport,
  });

  final TextEditingController controller;
  final bool isImporting;
  final String? importSummary;
  final bool importSucceeded;
  final VoidCallback onPickFile;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.border,
        ),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? AppShadows.darkCard
            : AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PrimaryText('导入配置', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.xs),
          const SecondaryText('保留桌面版 JSON 导入能力，作为我的页的高级工具入口。'),
          const SizedBox(height: AppSpacing.md),
          TextInput(
            controller: controller,
            placeholder: '输入工作区中的 JSON 文件路径',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlineActionButton(
                  label: '选择本地文件',
                  onPressed: isImporting ? null : onPickFile,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PrimaryButton(
                  label: isImporting ? '导入中...' : '导入配置',
                  onPressed: isImporting ? null : onImport,
                ),
              ),
            ],
          ),
          if (importSummary != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: AppSpacing.cardInsets,
              decoration: BoxDecoration(
                color: importSucceeded ? AppColors.successSoft : AppColors.errorSoft,
                borderRadius: AppRadius.card,
                border: Border.all(
                  color: importSucceeded ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                ),
              ),
              child: SecondaryText(
                importSummary!,
                style: AppTypography.bodySmall.copyWith(
                  color: importSucceeded ? const Color(0xFF166534) : const Color(0xFF991B1B),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
