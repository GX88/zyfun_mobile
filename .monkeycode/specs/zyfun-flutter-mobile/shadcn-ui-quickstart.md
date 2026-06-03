# shadcn_ui 快速开始指南

本文档提供 shadcn_ui 在 zyfun Flutter 项目中的快速开始指南。

## 1. 安装

### 1.1 添加依赖

```bash
# 进入项目目录
cd zyfun_mobile

# 安装 shadcn_ui 和图标库
flutter pub add shadcn_ui lucide_icons_flutter

# 安装其他核心依赖
flutter pub add flutter_riverpod riverpod_annotation go_router dio
flutter pub add json_annotation freezed_annotation
flutter pub add sqflite path shared_preferences flutter_secure_storage
flutter pub add fijkplayer permission_handler audio_service logger

# 安装开发依赖
flutter pub add --dev build_runner riverpod_generator json_serializable freezed
```

### 1.2 配置 pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  shadcn_ui: ^0.54.0
  lucide_icons_flutter: ^3.0.0
  flutter_riverpod: ^2.4.0
  go_router: ^12.0.0
  dio: ^5.4.0
  # ... 其他依赖
```

### 1.3 运行代码生成

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 2. 基础配置

### 2.1 配置 ShadApp

```dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      debugShowCheckedModeBanner: false,
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadZincColorScheme.light(),
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadSlateColorScheme.dark(),
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
```

### 2.2 配置路由 (go_router)

```dart
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/film',
      name: 'film',
      builder: (context, state) => const FilmPage(),
    ),
    GoRoute(
      path: '/player/:id',
      name: 'player',
      builder: (context, state) => PlayerPage(id: state.pathParameters['id']!),
    ),
  ],
);

// 在 ShadApp 中使用
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShadApp.custom(
      themeMode: ThemeMode.system,
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadZincColorScheme.light(),
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadSlateColorScheme.dark(),
      ),
      appBuilder: (context) {
        return MaterialApp.router(
          routerConfig: router,
          theme: ShadTheme.of(context).toThemeData(),
          localizationsDelegates: const [
            GlobalShadLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
        );
      },
    );
  }
}
```

## 3. 常用组件使用

### 3.1 按钮 (ShadButton)

```dart
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons_flutter.dart';

// Primary Button
ShadButton(
  child: const Text('Primary'),
  onPressed: () {},
)

// Secondary Button
ShadButton.secondary(
  child: const Text('Secondary'),
  onPressed: () {},
)

// Destructive Button
ShadButton.destructive(
  child: const Text('删除'),
  onPressed: () {},
)

// Outline Button
ShadButton.outline(
  child: const Text('Outline'),
  onPressed: () {},
)

// Ghost Button
ShadButton.ghost(
  child: const Text('Ghost'),
  onPressed: () {},
)

// 带图标的按钮
ShadButton(
  onPressed: () {},
  leading: const Icon(LucideIcons.mail),
  child: const Text('邮箱登录'),
)

// 加载状态按钮
ShadButton(
  onPressed: () {},
  leading: SizedBox.square(
    dimension: 16,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      color: ShadTheme.of(context).colorScheme.primaryForeground,
    ),
  ),
  child: const Text('加载中...'),
)

// 渐变色按钮
ShadButton(
  onPressed: () {},
  gradient: const LinearGradient(colors: [Colors.cyan, Colors.indigo]),
  child: const Text('渐变按钮'),
)
```

### 3.2 输入框 (ShadInput)

```dart
import 'package:shadcn_ui/shadcn_ui.dart';

// 基本输入框
ShadInput(
  controller: _controller,
  placeholder: const Text('请输入...'),
)

// 密码输入框
ShadInput(
  controller: _passwordController,
  obscureText: true,
  placeholder: const Text('密码'),
)

// 带验证的表单输入
ShadInputFormField(
  label: const Text('用户名'),
  initialValue: '',
  validator: (value) {
    if (value == null || value.isEmpty) {
      return '用户名不能为空';
    }
    return null;
  },
  onChanged: (value) {
    print('用户名：$value');
  },
)

// 搜索框
ShadInput(
  controller: _searchController,
  placeholder: const Text('搜索影视...'),
  prefix: const Icon(LucideIcons.search),
  suffix: _searchController.text.isNotEmpty
      ? IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => _searchController.clear(),
        )
      : null,
)
```

### 3.3 卡片 (ShadCard)

```dart
import 'package:shadcn_ui/shadcn_ui.dart';

// 基本卡片
ShadCard(
  title: const Text('项目卡片'),
  description: const Text('这是一个项目描述'),
  child: const Padding(
    padding: EdgeInsets.symmetric(vertical: 16),
    child: Text('卡片内容区域'),
  ),
  footer: Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      ShadButton.outline(
        child: const Text('取消'),
        onPressed: () {},
      ),
      const SizedBox(width: 8),
      ShadButton(
        child: const Text('确定'),
        onPressed: () {},
      ),
    ],
  ),
)

// 视频卡片示例
class VideoCard extends StatelessWidget {
  final Video video;
  
  const VideoCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    
    return ShadCard(
      width: 200,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面图
          CachedNetworkImage(
            imageUrl: video.cover,
            width: 200,
            height: 280,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8),
          // 标题
          Text(
            video.title,
            style: theme.textTheme.small,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // 简介
          Text(
            video.description ?? '',
            style: theme.textTheme.muted,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
```

### 3.4 对话框 (ShadDialog)

```dart
import 'package:shadcn_ui/shadcn_ui.dart';

// 确认对话框
ShadDialog.alert(
  context: context,
  title: const Text('确认删除'),
  description: const Text('确定要删除这个项目吗？此操作不可撤销。'),
  actions: [
    ShadButton.outline(
      child: const Text('取消'),
      onPressed: () => Navigator.pop(context),
    ),
    ShadButton.destructive(
      child: const Text('删除'),
      onPressed: () {
        // 执行删除操作
        Navigator.pop(context);
      },
    ),
  ],
)

// 自定义对话框
ShadDialog(
  context: context,
  title: const Text('创建项目'),
  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ShadInputFormField(
        label: const Text('项目名称'),
        controller: _nameController,
      ),
      const SizedBox(height: 16),
      ShadSelectFormField<String>(
        label: const Text('分类'),
        options: [
          ShadOption(value: 'movie', child: const Text('电影')),
          ShadOption(value: 'tv', child: const Text('电视剧')),
        ],
      ),
    ],
  ),
  actions: [
    ShadButton.outline(
      child: const Text('取消'),
      onPressed: () => Navigator.pop(context),
    ),
    ShadButton(
      child: const Text('创建'),
      onPressed: () {
        // 创建项目
        Navigator.pop(context);
      },
    ),
  ],
)
```

### 3.5 标签页 (ShadTabs)

```dart
import 'package:shadcn_ui/shadcn_ui.dart';

ShadTabs<String>(
  value: 'film',
  tabs: [
    ShadTab(
      value: 'film',
      child: const Text('影视'),
      content: const FilmListPage(),
    ),
    ShadTab(
      value: 'live',
      child: const Text('直播'),
      content: const LiveListPage(),
    ),
    ShadTab(
      value: 'favorite',
      child: const Text('收藏'),
      content: const FavoritePage(),
    ),
  ],
  onChanged: (value) {
    print('切换到：$value');
  },
)
```

### 3.6 开关 (ShadSwitch)

```dart
import 'package:shadcn_ui/shadcn_ui.dart';

// 基本开关
ShadSwitch(
  value: _enabled,
  onChanged: (value) {
    setState(() => _enabled = value);
  },
)

// 带标签的开关
Row(
  children: [
    const Text('启用弹幕'),
    const SizedBox(width: 8),
    ShadSwitch(
      value: _danmakuEnabled,
      onChanged: (value) {
        setState(() => _danmakuEnabled = value);
      },
    ),
  ],
)

// 设置项开关
class SettingItem extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final Function(bool) onChanged;

  const SettingItem({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(description),
      trailing: ShadSwitch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
```

### 3.7 滑块 (ShadSlider)

```dart
import 'package:shadcn_ui/shadcn_ui.dart';

// 基本滑块
ShadSlider(
  value: _progress,
  min: 0.0,
  max: 100.0,
  onChanged: (value) {
    setState(() => _progress = value);
  },
  onChangeEnd: (value) {
    print('最终值：$value');
  },
)

// 视频进度条
class VideoProgress extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final Function(Duration) onSeek;

  const VideoProgress({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return ShadSlider(
      value: progress,
      onChanged: (value) {
        final newPosition = Duration(
          milliseconds: (value * duration.inMilliseconds).round(),
        );
        onSeek(newPosition);
      },
    );
  }
}
```

### 3.8 下拉选择 (ShadSelect)

```dart
import 'package:shadcn_ui/shadcn_ui.dart';

// 基本选择框
ShadSelect<String>(
  placeholder: const Text('请选择'),
  options: [
    ShadOption(value: 'movie', child: const Text('电影')),
    ShadOption(value: 'tv', child: const Text('电视剧')),
    ShadOption(value: 'anime', child: const Text('动漫')),
  ],
  selectedOptionBuilder: (context, value) {
    return Text({
      'movie': '电影',
      'tv': '电视剧',
      'anime': '动漫',
    }[value] ?? '');
  },
  onChanged: (value) {
    print('选择了：$value');
  },
)

// 带搜索的选择框
ShadSelect<String>.searchable(
  placeholder: const Text('选择站点'),
  options: sites.map((site) {
    return ShadOption(
      value: site.id,
      child: Text(site.name),
    );
  }).toList(),
  selectedOptionBuilder: (context, value) {
    final site = sites.firstWhere(
      (s) => s.id == value,
      orElse: () => Site(id: '', name: ''),
    );
    return Text(site.name);
  },
  onChanged: (value) {
    // 切换站点
  },
)
```

### 3.9 提示消息 (ShadToast)

```dart
import 'package:shadcn_ui/shadcn_ui.dart';

// 显示成功提示
ShadToast.success(
  title: '操作成功',
  description: '数据已保存',
).show(context);

// 显示错误提示
ShadToast.error(
  title: '操作失败',
  description: '网络连接错误，请重试',
).show(context);

// 显示警告提示
ShadToast.warning(
  title: '注意',
  description: '此操作不可撤销',
).show(context);

// 显示信息提示
ShadToast.info(
  title: '提示',
  description: '新版本已发布',
).show(context);

// 自定义 Toast
ShadToast(
  title: const Text('自定义'),
  description: const Text('这是一个自定义的 Toast 消息'),
  icon: const Icon(LucideIcons.info),
  duration: const Duration(seconds: 3),
).show(context);
```

## 4. 主题定制

### 4.1 自定义颜色方案

```dart
import 'package:shadcn_ui/shadcn_ui.dart';

// 自定义颜色
final customTheme = ShadThemeData(
  brightness: Brightness.dark,
  colorScheme: ShadColorScheme(
    primary: Colors.blue.shade700,
    secondary: Colors.green.shade700,
    background: const Color(0xFF0A0A0A),
    surface: const Color(0xFF171717),
    foreground: Colors.white,
    border: Colors.grey.shade800,
  ),
);
```

### 4.2 自定义按钮主题

```dart
final theme = ShadThemeData(
  primaryButtonTheme: const ShadButtonTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    height: 44,
    padding: EdgeInsets.symmetric(horizontal: 24),
    borderRadius: BorderRadius.circular(8),
  ),
  secondaryButtonTheme: const ShadButtonTheme(
    backgroundColor: Colors.grey,
    foregroundColor: Colors.white,
  ),
);
```

## 5. 响应式布局

```dart
import 'package:shadcn_ui/shadcn_ui.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize size) builder;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    ScreenSize size;
    if (screenWidth < 600) {
      size = ScreenSize.phone;
    } else if (screenWidth < 900) {
      size = ScreenSize.tablet;
    } else {
      size = ScreenSize.desktop;
    }
    
    return builder(context, size);
  }
}

enum ScreenSize {
  phone,
  tablet,
  desktop,
}

// 使用示例
ResponsiveBuilder(
  builder: (context, size) {
    if (size == ScreenSize.phone) {
      return GridView.count(crossAxisCount: 2);
    } else {
      return GridView.count(crossAxisCount: 4);
    }
  },
)
```

## 6. 最佳实践

1. **统一使用 shadcn_ui 组件**，避免混用 Material 组件
2. **使用 theme.textTheme** 访问文本样式，保持一致性
3. **使用 ShadTheme.of(context)** 访问主题颜色
4. **表单验证使用 ShadInputFormField**，自动处理验证逻辑
5. **使用 Lucide Icons** 保持图标风格统一
6. **暗色模式单独测试**，确保所有组件都适配
7. **响应式布局**，适配不同屏幕尺寸

## 7. 参考资料

- [官方文档](https://mariuti.com/flutter-shadcn-ui/)
- [GitHub 仓库](https://github.com/nank1ro/flutter-shadcn-ui)
- [pub.dev 页面](https://pub.dev/packages/shadcn_ui)
- [组件演示](https://mariuti.com/flutter-shadcn-ui/components/button/)
