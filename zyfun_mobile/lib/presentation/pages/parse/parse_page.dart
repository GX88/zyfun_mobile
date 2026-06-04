import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../data/models/analyze.dart';
import '../../components/app_bottom_nav_bar.dart';
import '../../providers/app_providers.dart';

class ParsePage extends ConsumerStatefulWidget {
  const ParsePage({super.key});

  @override
  ConsumerState<ParsePage> createState() => _ParsePageState();
}

class _ParsePageState extends ConsumerState<ParsePage> {
  List<Analyze> _analyzes = const <Analyze>[];
  String? _defaultAnalyzeId;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadAnalyzes);
  }

  Future<void> _loadAnalyzes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(analyzeRepositoryProvider);
      var analyzes = await repository.getAllAnalyzes();
      if (analyzes.isEmpty) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final demo = Analyze(
          id: 'demo-analyze',
          key: 'demo-analyze',
          name: '演示解析',
          api: 'https://example.com/parse',
          type: 2,
          flag: const <String>['m3u8', 'mp4'],
          script: 'return json.url;',
          createdAt: now,
          updatedAt: now,
        );
        await repository.addAnalyze(demo);
        await repository.setDefaultAnalyze(demo.id);
        analyzes = await repository.getAllAnalyzes();
      }

      final defaultId = await repository.getDefaultAnalyze();
      if (!mounted) {
        return;
      }
      setState(() {
        _analyzes = analyzes;
        _defaultAnalyzeId = defaultId?.isNotEmpty == true ? defaultId : analyzes.first.id;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('解析配置'),
        actions: <Widget>[
          IconButton(
            tooltip: '新增解析',
            onPressed: _showCreateDialog,
            icon: const Icon(LucideIcons.plus),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAnalyzes,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            ShadCard(
              title: Text('默认解析', style: theme.textTheme.h4),
              description: const Text('管理解析接口列表，并切换默认解析线路。'),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildDefaultSelector(theme),
              ),
            ),
            const SizedBox(height: 16),
            ShadCard(
              title: Text('解析列表', style: theme.textTheme.h4),
              description: Text('共 ${_analyzes.length} 条解析配置'),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildAnalyzeList(theme),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(selectedIndex: 3),
    );
  }

  Widget _buildDefaultSelector(ShadThemeData theme) {
    if (_isLoading) {
      return const LinearProgressIndicator();
    }
    if (_errorMessage != null) {
      return Text(_errorMessage!, style: theme.textTheme.muted);
    }
    if (_analyzes.isEmpty) {
      return Text('暂无解析接口', style: theme.textTheme.muted);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ShadSelect<String>(
          minWidth: 240,
          initialValue: _defaultAnalyzeId,
          options: _analyzes
              .map(
                (item) => ShadOption<String>(
                  value: item.id,
                  child: Text(item.name),
                ),
              )
              .toList(),
          selectedOptionBuilder: (context, value) => Text(
            _analyzes.firstWhere((item) => item.id == value).name,
          ),
          placeholder: const Text('选择默认解析'),
          onChanged: (value) {
            if (value != null) {
              _setDefaultAnalyze(value);
            }
          },
        ),
        const SizedBox(height: 12),
        Text(
          '默认解析会优先用于需要二次解析的播放地址。',
          style: theme.textTheme.small,
        ),
      ],
    );
  }

  Widget _buildAnalyzeList(ShadThemeData theme) {
    if (_isLoading) {
      return const LinearProgressIndicator();
    }
    if (_errorMessage != null) {
      return Text(_errorMessage!, style: theme.textTheme.muted);
    }
    if (_analyzes.isEmpty) {
      return Text('暂无解析接口，点击右上角新增。', style: theme.textTheme.muted);
    }

    return Column(
      children: _analyzes
          .map(
            (analyze) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AnalyzeTile(
                analyze: analyze,
                isDefault: _defaultAnalyzeId == analyze.id,
                onSetDefault: () => _setDefaultAnalyze(analyze.id),
                onEdit: () => _showEditDialog(analyze),
                onDelete: () => _deleteAnalyze(analyze),
              ),
            ),
          )
          .toList(),
    );
  }

  Future<void> _setDefaultAnalyze(String id) async {
    await ref.read(analyzeRepositoryProvider).setDefaultAnalyze(id);
    if (!mounted) {
      return;
    }
    setState(() => _defaultAnalyzeId = id);
  }

  Future<void> _showCreateDialog() async {
    await _showEditDialog();
  }

  Future<void> _showEditDialog([Analyze? existing]) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final apiController = TextEditingController(text: existing?.api ?? '');
    final flagController = TextEditingController(text: existing?.flag.join(',') ?? '');
    final scriptController = TextEditingController(text: existing?.script ?? '');
    var type = existing?.type ?? 2;
    var isActive = existing?.isActive ?? true;

    return showShadDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => ShadDialog.alert(
          title: Text(existing == null ? '新增解析' : '编辑解析'),
          description: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: <Widget>[
                ShadInput(
                  controller: nameController,
                  placeholder: const Text('解析名称'),
                ),
                const SizedBox(height: 12),
                ShadInput(
                  controller: apiController,
                  placeholder: const Text('解析接口地址'),
                ),
                const SizedBox(height: 12),
                ShadSelect<int>(
                  minWidth: 240,
                  initialValue: type,
                  options: const <ShadOption<int>>[
                    ShadOption(value: 1, child: Text('Web 型解析')),
                    ShadOption(value: 2, child: Text('JSON 型解析')),
                  ],
                  selectedOptionBuilder: (context, value) => Text(value == 1 ? 'Web 型解析' : 'JSON 型解析'),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => type = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                ShadInput(
                  controller: flagController,
                  placeholder: const Text('匹配标识，使用逗号分隔'),
                ),
                const SizedBox(height: 12),
                ShadInput(
                  controller: scriptController,
                  placeholder: const Text('自定义脚本，可留空'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    const Expanded(child: Text('启用此解析接口')),
                    ShadSwitch(
                      value: isActive,
                      onChanged: (value) => setDialogState(() => isActive = value),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ShadButton.outline(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            ShadButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final api = apiController.text.trim();
                if (name.isEmpty || api.isEmpty) {
                  return;
                }

                final now = DateTime.now().millisecondsSinceEpoch;
                final analyze = Analyze(
                  id: existing?.id ?? 'analyze_$now',
                  key: existing?.key ?? 'analyze_$now',
                  name: name,
                  api: api,
                  type: type,
                  flag: flagController.text
                      .split(',')
                      .map((item) => item.trim())
                      .where((item) => item.isNotEmpty)
                      .toList(),
                  script: scriptController.text.trim(),
                  isActive: isActive,
                  createdAt: existing?.createdAt ?? now,
                  updatedAt: now,
                );

                final repository = ref.read(analyzeRepositoryProvider);
                if (existing == null) {
                  await repository.addAnalyze(analyze);
                } else {
                  await repository.updateAnalyze(analyze);
                }
                if (!mounted || !dialogContext.mounted) {
                  return;
                }
                Navigator.of(dialogContext).pop();
                await _loadAnalyzes();
              },
              child: Text(existing == null ? '新增' : '保存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAnalyze(Analyze analyze) async {
    await ref.read(analyzeRepositoryProvider).deleteAnalyze(analyze.id);
    if (_defaultAnalyzeId == analyze.id && _analyzes.length > 1) {
      final fallback = _analyzes.firstWhere((item) => item.id != analyze.id).id;
      await ref.read(analyzeRepositoryProvider).setDefaultAnalyze(fallback);
    }
    await _loadAnalyzes();
  }
}

class _AnalyzeTile extends StatelessWidget {
  const _AnalyzeTile({
    required this.analyze,
    required this.isDefault,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  final Analyze analyze;
  final bool isDefault;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDefault ? theme.colorScheme.primary : theme.colorScheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(analyze.name, style: theme.textTheme.large),
              ),
              if (isDefault)
                const ShadBadge(
                  child: Text('默认'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(analyze.api, style: theme.textTheme.small),
          const SizedBox(height: 8),
          Text(
            '${analyze.isWebType ? 'Web 型' : 'JSON 型'} · ${analyze.isActive ? '启用' : '停用'}',
            style: theme.textTheme.small,
          ),
          if (analyze.flag.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text('匹配标识：${analyze.flag.join(', ')}', style: theme.textTheme.small),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              ShadButton.outline(
                onPressed: onSetDefault,
                child: const Text('设为默认'),
              ),
              ShadButton.secondary(
                onPressed: onEdit,
                child: const Text('编辑'),
              ),
              ShadButton.destructive(
                onPressed: onDelete,
                child: const Text('删除'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
