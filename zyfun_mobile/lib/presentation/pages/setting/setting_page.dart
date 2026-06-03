import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../data/services/config_import_service.dart';
import '../../components/app_bottom_nav_bar.dart';
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
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ShadCard(
            title: Text('外观', style: theme.textTheme.h4),
            description: const Text('调整主题和基础显示选项。'),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('主题模式', style: theme.textTheme.large),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _ThemeModeButton(
                        label: '跟随系统',
                        selected: setting.theme == 'system',
                        onPressed: () => notifier.updateThemeMode('system'),
                      ),
                      _ThemeModeButton(
                        label: '浅色',
                        selected: setting.theme == 'light',
                        onPressed: () => notifier.updateThemeMode('light'),
                      ),
                      _ThemeModeButton(
                        label: '深色',
                        selected: setting.theme == 'dark',
                        onPressed: () => notifier.updateThemeMode('dark'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('硬件加速', style: theme.textTheme.large),
                      ),
                      ShadSwitch(
                        value: setting.hardwareAcceleration,
                        onChanged: (value) =>
                            notifier.updateHardwareAcceleration(value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ShadCard(
            title: Text('配置摘要', style: theme.textTheme.h4),
            description: const Text('当前展示关键配置，并提供统一组件展示入口。'),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('语言：${setting.lang}'),
                  const SizedBox(height: 8),
                  Text('超时：${setting.timeout} ms'),
                  const SizedBox(height: 8),
                  Text('默认热搜：${setting.hot}'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ShadButton.outline(
                      onPressed: () => context.push('/shadcn'),
                      child: const Text('查看 shadcn 组件库'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ShadCard(
            title: Text('导入配置', style: theme.textTheme.h4),
            description: const Text('导入桌面版 JSON 配置，当前优先接入可用的 T1_JSON 站点。'),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ShadInput(
                    controller: _pathController,
                    placeholder: const Text('输入工作区中的 JSON 文件路径'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '支持直接选择手机本地 JSON 文件，也支持手动填写工作区路径。',
                    style: theme.textTheme.small,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ShadButton.outline(
                      onPressed: _isImporting ? null : _pickLocalConfigFile,
                      child: const Text('选择本地 JSON 文件'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ShadButton(
                      onPressed: _isImporting ? null : () => _importConfig(context),
                      child: Text(_isImporting ? '导入中...' : '导入配置'),
                    ),
                  ),
                  if (_importSummary != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _importSucceeded
                              ? theme.colorScheme.primary.withValues(alpha: 0.08)
                              : theme.colorScheme.destructive.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _importSucceeded
                                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                                : theme.colorScheme.destructive.withValues(alpha: 0.3),
                          ),
                        ),
                      child: Text(
                        _importSummary!,
                        style: theme.textTheme.small.copyWith(
                          color: _importSucceeded
                              ? theme.colorScheme.primary
                              : theme.colorScheme.destructive,
                        ),
                      ),
                    ),
                  ],
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

class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return ShadButton(onPressed: onPressed, child: Text(label));
    }
    return ShadButton.outline(onPressed: onPressed, child: Text(label));
  }
}
