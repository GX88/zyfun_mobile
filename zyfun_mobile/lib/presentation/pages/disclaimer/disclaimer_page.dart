import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/constants/constants.dart';
import '../../providers/app_launch_provider.dart';

class DisclaimerPage extends ConsumerStatefulWidget {
  const DisclaimerPage({super.key});

  @override
  ConsumerState<DisclaimerPage> createState() => _DisclaimerPageState();
}

class _DisclaimerPageState extends ConsumerState<DisclaimerPage> {
  bool _isSubmitting = false;

  Future<void> _acceptDisclaimer() async {
    setState(() => _isSubmitting = true);
    await ref.read(appLaunchControllerProvider).acceptDisclaimer();
    if (!mounted) {
      return;
    }
    context.go(RouteConstants.film);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('免责声明'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                ShadCard(
                  title: Text('使用须知', style: theme.textTheme.h3),
                  description: const Text('请在继续使用前阅读以下说明。'),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '本应用仅提供公开站点聚合与本地播放器能力，所有资源内容均来自用户自行配置或第三方公开接口。',
                          style: theme.textTheme.large,
                        ),
                        const SizedBox(height: 16),
                        const _DisclaimerItem(
                          title: '内容责任',
                          description: '请确认您拥有访问、播放和保存相关内容的合法权限。',
                        ),
                        const _DisclaimerItem(
                          title: '数据来源',
                          description: '首次启动会初始化默认配置，后续站点、直播源和解析接口由用户自行管理。',
                        ),
                        const _DisclaimerItem(
                          title: '风险提示',
                          description: '请勿导入来源不明的配置文件，并注意保护个人账号、Cookie 和其他敏感信息。',
                        ),
                        const SizedBox(height: 24),
                        ShadButton(
                          onPressed: _isSubmitting ? null : _acceptDisclaimer,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('我已阅读并继续'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DisclaimerItem extends StatelessWidget {
  const _DisclaimerItem({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              LucideIcons.badgeInfo,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: theme.textTheme.large),
                const SizedBox(height: 4),
                Text(description, style: theme.textTheme.muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
