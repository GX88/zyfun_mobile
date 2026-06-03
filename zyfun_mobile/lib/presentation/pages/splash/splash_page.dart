import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../providers/app_launch_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({
    super.key,
    this.transitionDelay = const Duration(milliseconds: 900),
  });

  final Duration transitionDelay;

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(widget.transitionDelay);
    final target = await ref.read(appLaunchControllerProvider).resolveInitialRoute();
    if (!mounted) {
      return;
    }
    context.go(target);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              theme.colorScheme.primary.withValues(alpha: 0.12),
              theme.colorScheme.background,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(28),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.clapperboard,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text('zyfun', style: theme.textTheme.h2),
            const SizedBox(height: 8),
            Text(
              '正在准备站点配置与播放环境',
              style: theme.textTheme.muted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            Text(
              '首次启动将展示免责声明',
              style: theme.textTheme.small,
            ),
          ],
        ),
      ),
    );
  }
}
