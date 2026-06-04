import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/app_providers.dart';
import '../../../services/sniffer_service.dart';

class SnifferPage extends ConsumerStatefulWidget {
  const SnifferPage({super.key, this.initialUrl});

  final String? initialUrl;

  @override
  ConsumerState<SnifferPage> createState() => _SnifferPageState();
}

class _SnifferPageState extends ConsumerState<SnifferPage> {
  late final SnifferViewController _controller;
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(snifferServiceProvider).createController();
    _urlController = TextEditingController(text: widget.initialUrl ?? 'https://example.com');
    if ((widget.initialUrl ?? '').trim().isNotEmpty) {
      Future<void>.microtask(() => _controller.loadUrl(widget.initialUrl!.trim()));
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('嗅探服务')),
      body: ValueListenableBuilder<SnifferViewState>(
        valueListenable: _controller.stateListenable,
        builder: (context, state, _) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: ShadCard(
                  title: Text('WebView 嗅探容器', style: theme.textTheme.h4),
                  description: const Text('当前先接入页面加载、前进后退与刷新能力，资源规则嗅探将在下一步实现。'),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ShadInput(
                          controller: _urlController,
                          placeholder: const Text('输入要加载的页面地址，例如 https://example.com'),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            ShadButton(
                              onPressed: _loadCurrentUrl,
                              child: const Text('加载页面'),
                            ),
                            ShadButton.outline(
                              onPressed: state.canGoBack ? _controller.goBack : null,
                              child: const Text('后退'),
                            ),
                            ShadButton.outline(
                              onPressed: state.canGoForward ? _controller.goForward : null,
                              child: const Text('前进'),
                            ),
                            ShadButton.outline(
                              onPressed: _controller.reload,
                              child: const Text('刷新'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.isLoading ? '页面加载中...' : '页面已就绪',
                          style: theme.textTheme.small,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '当前地址：${state.currentUrl.isEmpty ? '尚未加载' : state.currentUrl}',
                          style: theme.textTheme.small,
                        ),
                        if ((state.pageTitle ?? '').isNotEmpty) ...<Widget>[
                          const SizedBox(height: 8),
                          Text('页面标题：${state.pageTitle}', style: theme.textTheme.small),
                        ],
                        if ((state.lastError ?? '').isNotEmpty) ...<Widget>[
                          const SizedBox(height: 8),
                          Text(
                            '加载错误：${state.lastError}',
                            style: theme.textTheme.small.copyWith(
                              color: theme.colorScheme.destructive,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.border),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _controller.buildView(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _loadCurrentUrl() async {
    await _controller.loadUrl(_urlController.text.trim());
  }
}
