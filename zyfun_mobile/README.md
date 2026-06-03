# zyfun_mobile

zyfun Flutter 移动端应用 - 跨平台视频播放器

基于 Flutter + shadcn_ui 构建，支持 Android 和 iOS 平台，1:1 还原原 Electron 版 zyfun 的所有功能。

## 技术栈

- **框架**: Flutter 3.16+
- **UI 组件**: [shadcn_ui](https://github.com/nank1ro/flutter-shadcn-ui) 0.54.0
- **状态管理**: Riverpod 2.4+
- **路由**: go_router 12.0+
- **网络**: dio 5.4+
- **数据库**: sqflite
- **播放器**: fijkplayer
- **图标**: lucide_icons_flutter

## 功能特性

- ✅ 影视浏览和搜索
- ✅ 电视直播
- ✅ 视频播放 (多格式支持)
- ✅ 弹幕功能
- ✅ 播放历史
- ✅ 收藏功能
- ✅ 解析接口配置
- ✅ 云同步 (WebDAV)
- ✅ 多语言支持 (简繁英等 16 种)
- ✅ 亮色/暗色主题

## 快速开始

### 环境要求

- Flutter SDK >= 3.16.0
- Dart SDK >= 3.2.0
- Android Studio / Xcode

### 安装依赖

```bash
cd zyfun_mobile
flutter pub get
```

### 运行应用

```bash
# 运行在 Chrome (web)
flutter run -d chrome

# 运行在 Android 设备
flutter run -d <device_id>

# 运行在 iOS 模拟器
flutter run -d ios

# 运行在 Android 模拟器
flutter run -d android
```

### 代码生成

```bash
# 运行代码生成器
flutter pub run build_runner build --delete-conflicting-outputs

# 监听模式
flutter pub run build_runner watch
```

### 构建发布版本

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 项目结构

```
lib/
├── main.dart                      # 应用入口
├── app/                           # 应用配置
│   ├── app.dart                  # 主应用组件
│   └── routes/                   # 路由配置
├── core/                          # 核心功能
│   ├── constants/                # 常量定义
│   ├── errors/                   # 错误定义
│   ├── utils/                    # 工具函数
│   └── extensions/               # 扩展方法
├── data/                          # 数据层
│   ├── models/                   # 数据模型
│   ├── repositories/             # 数据仓库实现
│   └── datasources/              # 数据源
├── domain/                        # 领域层
│   ├── entities/                 # 领域实体
│   ├── repositories/             # 仓库接口
│   └── usecases/                 # 用例
├── presentation/                  # 展示层
│   ├── providers/                # Riverpod Providers
│   ├── pages/                    # 页面
│   ├── components/               # 业务组件
│   └── shadcn/                   # shadcn_ui 封装
├── services/                      # 业务服务
└── config/                        # 配置
```

## 开发指南

### 添加新页面

1. 在 `lib/presentation/pages/` 创建页面文件
2. 在 `lib/app/routes/app_routes.dart` 添加路由
3. 在底部导航栏添加导航项 (如需)

### 添加新组件

1. 在 `lib/presentation/components/` 创建组件
2. 使用 shadcn_ui 组件作为基础
3. 遵循项目代码规范

### 状态管理

使用 Riverpod 进行状态管理:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() => state++;
  void decrement() => state--;
}
```

### 使用 shadcn_ui 组件

```dart
import 'package:shadcn_ui/shadcn_ui.dart';

ShadButton(
  child: const Text('点击'),
  onPressed: () {},
)
```

## 参考文档

- [需求文档](../../.monkeycode/specs/zyfun-flutter-mobile/requirements.md)
- [技术设计](../../.monkeycode/specs/zyfun-flutter-mobile/design.md)
- [实施计划](../../.monkeycode/specs/zyfun-flutter-mobile/tasklist.md)
- [shadcn_ui 快速开始](../../.monkeycode/specs/zyfun-flutter-mobile/shadcn-ui-quickstart.md)

## 相关项目

- [原项目 zyfun](https://github.com/Hiram-Wong/zyfun)
- [shadcn_ui Flutter](https://github.com/nank1ro/flutter-shadcn-ui)
- [fijkplayer](https://github.com/befovy/fijkplayer)

## 开发进度

- [x] 项目初始化和配置
- [x] 数据模型创建
- [x] 仓库接口定义
- [x] 数据层骨架实现
- [x] 状态管理层首批 Provider
- [x] 影视首页骨架
- [x] 直播页 / 历史页 / 设置页骨架
- [x] 主题切换联动
- [ ] 业务服务实现
- [ ] UI 组件实现
- [ ] 页面实现
- [ ] 播放器集成
- [ ] 测试和优化

## 许可证

AGPL-3.0 (与原项目保持一致)

## 贡献指南

欢迎提交 Issue 和 Pull Request！

---

**注意**: 此项目仅供个人学习交流使用，请勿用于商业用途。
