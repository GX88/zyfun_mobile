import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ShadcnComponentsPage extends StatefulWidget {
  const ShadcnComponentsPage({super.key});

  @override
  State<ShadcnComponentsPage> createState() => _ShadcnComponentsPageState();
}

class _ShadcnComponentsPageState extends State<ShadcnComponentsPage> {
  final GlobalKey<ShadFormState> _formKey = GlobalKey<ShadFormState>();
  bool _notificationsEnabled = true;
  double _volume = 0.68;
  int _progress = 64;
  String _activeTab = 'overview';
  String? _selectedSource = 't1';
  Map<String, dynamic> _submittedFormValue = const <String, dynamic>{};

  static const List<({String label, String status, String type})> _siteRows =
      <({String label, String status, String type})>[
        (label: '推荐源 A', status: '在线', type: 'T1_JSON'),
        (label: '蓝光源 B', status: '维护中', type: 'T3_XML'),
        (label: '备用源 C', status: '在线', type: 'T4_CMS'),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shadcn 组件库'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ShadCard(
            title: Text('组件概览', style: theme.textTheme.h4),
            description: const Text('集中展示当前项目使用和准备复用的 shadcn_ui 核心组件。'),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      ShadButton(
                        onPressed: () {},
                        leading: const Icon(LucideIcons.play),
                        child: const Text('Primary'),
                      ),
                      ShadButton.secondary(
                        onPressed: () {},
                        child: const Text('Secondary'),
                      ),
                      ShadButton.destructive(
                        onPressed: () {},
                        child: const Text('Destructive'),
                      ),
                      ShadButton.outline(
                        onPressed: () {},
                        child: const Text('Outline'),
                      ),
                      ShadButton.ghost(
                        onPressed: () {},
                        child: const Text('Ghost'),
                      ),
                      ShadButton.link(
                        onPressed: () {},
                        child: const Text('Link'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const ShadInput(
                    initialValue: 'https://api.example.com',
                    placeholder: Text('输入站点接口地址'),
                    leading: Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(LucideIcons.search),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ShadTabs<String>(
            value: _activeTab,
            onChanged: (value) => setState(() => _activeTab = value),
            tabBarConstraints: const BoxConstraints(maxWidth: 760),
            contentConstraints: const BoxConstraints(maxWidth: 760),
            tabs: <ShadTab<String>>[
              ShadTab<String>(
                value: 'overview',
                content: _buildInteractiveTab(theme),
                child: const Text('交互组件'),
              ),
              ShadTab<String>(
                value: 'table',
                content: _buildTableTab(theme),
                child: const Text('表格与菜单'),
              ),
              ShadTab<String>(
                value: 'form',
                content: _buildFormTab(theme),
                child: const Text('表单'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveTab(ShadThemeData theme) {
    return ShadCard(
      title: Text('交互组件', style: theme.textTheme.h4),
      description: const Text('对话框、开关、滑块、进度条和选择器示例。'),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                ShadButton.outline(
                  onPressed: _showConfirmDialog,
                  child: const Text('打开确认对话框'),
                ),
                SizedBox(
                  width: 220,
                  child: ShadSelect<String>(
                    minWidth: 220,
                    initialValue: _selectedSource,
                    placeholder: const Text('选择默认解析线路'),
                    options: const <ShadOption<String>>[
                      ShadOption(value: 't1', child: Text('主线路 T1_JSON')),
                      ShadOption(value: 't3', child: Text('高速线路 T3_XML')),
                      ShadOption(value: 't4', child: Text('兼容线路 T4_CMS')),
                    ],
                    selectedOptionBuilder: (context, value) => Text(
                      switch (value) {
                        't1' => '主线路 T1_JSON',
                        't3' => '高速线路 T3_XML',
                        't4' => '兼容线路 T4_CMS',
                        _ => '未选择',
                      },
                    ),
                    onChanged: (value) => setState(() => _selectedSource = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text('弹幕通知', style: theme.textTheme.large),
                ),
                ShadSwitch(
                  value: _notificationsEnabled,
                  onChanged: (value) => setState(() => _notificationsEnabled = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('音量 ${(_volume * 100).round()}%', style: theme.textTheme.small),
            ShadSlider(
              min: 0,
              max: 1,
              initialValue: _volume,
              onChanged: (value) => setState(() => _volume = value),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text('资源同步进度', style: theme.textTheme.small),
                ),
                Text('$_progress%', style: theme.textTheme.small),
              ],
            ),
            const SizedBox(height: 8),
            ShadProgress(value: _progress / 100),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: <Widget>[
                ShadButton.outline(
                  onPressed: _progress == 0
                      ? null
                      : () => setState(() => _progress = (_progress - 10).clamp(0, 100)),
                  child: const Text('回退 10%'),
                ),
                ShadButton.outline(
                  onPressed: _progress == 100
                      ? null
                      : () => setState(() => _progress = (_progress + 10).clamp(0, 100)),
                  child: const Text('前进 10%'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableTab(ShadThemeData theme) {
    return ShadCard(
      title: Text('表格与菜单', style: theme.textTheme.h4),
      description: const Text('展示站点状态表格和长按上下文菜单能力。'),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ShadContextMenuRegion(
              items: const <Widget>[
                ShadContextMenuItem.inset(child: Text('刷新线路状态')),
                ShadContextMenuItem.inset(child: Text('复制接口地址')),
                ShadContextMenuItem(
                  leading: Icon(LucideIcons.check),
                  child: Text('设为默认站点'),
                ),
              ],
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.border),
                ),
                child: Text(
                  '长按或右键这里，查看站点管理菜单',
                  style: theme.textTheme.small,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: ShadTable.list(
                header: const <ShadTableCell>[
                  ShadTableCell.header(child: Text('站点名称')),
                  ShadTableCell.header(child: Text('状态')),
                  ShadTableCell.header(child: Text('类型')),
                ],
                footer: const <ShadTableCell>[
                  ShadTableCell.footer(child: Text('总计')),
                  ShadTableCell.footer(child: Text('3 个站点')),
                  ShadTableCell.footer(child: Text('已接入 3 类接口')),
                ],
                children: _siteRows
                    .map(
                      (row) => <ShadTableCell>[
                        ShadTableCell(child: Text(row.label)),
                        ShadTableCell(child: Text(row.status)),
                        ShadTableCell(child: Text(row.type)),
                      ],
                    )
                    .toList(),
                columnSpanExtent: (index) {
                  if (index == 0) {
                    return const FractionalTableSpanExtent(0.4);
                  }
                  return const RemainingTableSpanExtent();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTab(ShadThemeData theme) {
    return ShadCard(
      title: Text('表单组件', style: theme.textTheme.h4),
      description: const Text('使用 ShadForm、输入框和选择框构建站点配置表单。'),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: ShadForm(
          key: _formKey,
          initialValue: const <String, dynamic>{
            'siteName': '主站点',
            'sourceType': 't1',
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ShadInputFormField(
                id: 'siteName',
                label: const Text('站点名称'),
                placeholder: const Text('输入站点名称'),
                validator: (value) {
                  if (value.length < 2) {
                    return '站点名称至少 2 个字符';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ShadSelectFormField<String>(
                id: 'sourceType',
                minWidth: 320,
                placeholder: const Text('选择接口类型'),
                options: const <ShadOption<String>>[
                  ShadOption(value: 't1', child: Text('T1_JSON')),
                  ShadOption(value: 't3', child: Text('T3_XML')),
                  ShadOption(value: 't4', child: Text('T4_CMS')),
                ],
                selectedOptionBuilder: (context, value) => Text(value),
                validator: (value) {
                  if (value == null) {
                    return '请选择接口类型';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ShadButton(
                onPressed: _submitForm,
                child: const Text('保存表单'),
              ),
              if (_submittedFormValue.isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Text(
                    '已提交：站点=${_submittedFormValue['siteName']}，类型=${_submittedFormValue['sourceType']}',
                    style: theme.textTheme.small,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showConfirmDialog() {
    return showShadDialog<void>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('切换默认线路'),
        description: const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('当前操作会把默认解析线路切换到所选站点。'),
        ),
        actions: <Widget>[
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ShadButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确认切换'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    final formState = _formKey.currentState;
    if (formState == null) {
      return;
    }

    if (formState.saveAndValidate()) {
      setState(() {
        _submittedFormValue = formState.value;
      });
    }
  }
}
