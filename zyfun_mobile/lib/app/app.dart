import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'routes/app_routes.dart';
import '../presentation/providers/setting_provider.dart';
import '../theme/app_theme.dart';

class ZyfunApp extends ConsumerStatefulWidget {
  const ZyfunApp({super.key});

  @override
  ConsumerState<ZyfunApp> createState() => _ZyfunAppState();
}

class _ZyfunAppState extends ConsumerState<ZyfunApp> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(settingNotifierProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final setting = ref.watch(settingNotifierProvider);
    final themeMode = switch (setting.theme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return ShadApp.router(
      title: 'zyfun',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('zh', 'TW'),
        Locale('en'),
      ],
    );
  }
}
