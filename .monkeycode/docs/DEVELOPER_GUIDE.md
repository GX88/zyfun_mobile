# zyfun_mobile 开发者指南

## 1. 代码基线

当前项目位于 `zyfun_mobile/`，是一个 Flutter 移动应用。代码现状适合继续补齐真实数据接入、播放器、直播与更多页面能力。

优先阅读顺序：

1. `lib/main.dart`
2. `lib/app/app.dart`
3. `lib/app/routes/app_routes.dart`
4. `lib/presentation/providers/app_providers.dart`
5. `lib/data/datasources/local/app_database.dart`
6. `lib/data/repositories/`
7. `lib/presentation/pages/`
8. `lib/core/constants/`
9. `lib/theme/app_theme.dart`

## 2. 开发环境

根据 `pubspec.yaml`，当前项目依赖以下核心组件：

- Flutter `>=3.16.0`
- Dart `>=3.2.0 <4.0.0`
- `flutter_riverpod`
- `go_router`
- `shadcn_ui`
- `dio`
- `sqflite`
- `shared_preferences`
- `flutter_secure_storage`
- `fijkplayer`

## 3. 常用工作流

### 3.1 启动应用

在具备 Flutter 环境的机器上，从项目目录执行：

```bash
cd /workspace/zyfun_mobile
flutter pub get
flutter run
```

### 3.2 运行测试

仓库中已经存在单元测试和 Widget 级初始化测试，执行方式：

```bash
cd /workspace/zyfun_mobile
flutter test
```

### 3.3 生成代码

项目使用 `freezed`、`json_serializable`、`riverpod_generator` 相关依赖，生成代码时执行：

```bash
cd /workspace/zyfun_mobile
flutter pub run build_runner build --delete-conflicting-outputs
```

当前仓库里已经存在 `.g.dart` 和 `.freezed.dart` 文件，后续修改模型后需要重新生成。

## 4. 当前实现的几个关键点

## 4.1 设置加载时机

`ZyfunApp` 在 `initState` 中异步加载设置，因此主题模式由本地持久化结果驱动。调整设置页逻辑时，需要保证 `SettingNotifier` 的写入和读取保持一致。

## 4.2 影视页依赖演示数据

`FilmPage` 和 `SearchPage` 已经能跑通，但它们当前依赖 `SiteRepositoryImpl` 生成的演示数据。接入真实接口时，优先保持 `SiteRepository` 的接口不变，这样页面和状态层可以少改。

## 4.3 直播和解析处于仓库骨架阶段

`IptvRepositoryImpl` 与 `AnalyzeRepositoryImpl` 已有本地 CRUD 能力，适合作为下一阶段接入远程数据和业务逻辑的入口。

## 4.4 数据库存储边界

当前完整设置对象写入 `settings` 表，键为 `StorageKeys.setting`。同时默认站点、默认直播源、默认解析等信息使用 `KeyValueStorage` 单独保存。扩展配置时，先确认数据应该进入 SQLite 还是键值存储。

## 4.5 UI 重构基础层

当前仓库已经开始接入新的 UI design token 体系，后续 UI 改造优先复用这些底层常量，而不是在页面里写死数值：

- `AppColors`: 主题色、状态色、背景色、渐变
- `AppSpacing`: 页面边距、卡片间距、按钮内边距
- `AppRadius`: 按钮、输入框、卡片圆角
- `AppShadows`: 卡片和悬浮层阴影
- `AppTypography`: 标题、正文、说明、数字文本样式
- `AppIconSize`: 图标尺寸规范

新增组件时，优先保持这些 token 作为唯一视觉来源，避免页面级重复定义颜色或间距。

## 5. 测试现状

### 已覆盖

- Provider 初始化
- 路由注册和默认路由
- 主题配置
- 模型序列化
- DAO CRUD
- 仓库 CRUD 与演示逻辑

### 待补强

- 页面交互测试
- Provider 状态联动测试
- 远程 API 测试
- 播放器集成测试

## 6. 与规格文档协作的建议

继续开发时，建议把规格文档当作功能目标清单，而把现有代码当作实现真相来源。

优先顺序建议如下：

1. 先完成 `ApiClient` 之上的真实远程数据源。
2. 再替换 `SiteRepositoryImpl` 的演示视频生成逻辑。
3. 接着补齐直播、详情、播放器、解析页面。
4. 最后再扩展 AI、云同步、移动端高级能力。

这个顺序与当前代码的耦合度最低，也最符合已有页面和状态层结构。

## 7. 相关文件索引

- 应用入口：`/workspace/zyfun_mobile/lib/main.dart`
- 应用壳：`/workspace/zyfun_mobile/lib/app/app.dart`
- 路由：`/workspace/zyfun_mobile/lib/app/routes/app_routes.dart`
- Provider 注册：`/workspace/zyfun_mobile/lib/presentation/providers/app_providers.dart`
- 站点状态：`/workspace/zyfun_mobile/lib/presentation/providers/site_provider.dart`
- 设置状态：`/workspace/zyfun_mobile/lib/presentation/providers/setting_provider.dart`
- 历史状态：`/workspace/zyfun_mobile/lib/presentation/providers/history_provider.dart`
- 数据库：`/workspace/zyfun_mobile/lib/data/datasources/local/app_database.dart`
- 站点仓库：`/workspace/zyfun_mobile/lib/data/repositories/site_repository_impl.dart`
- 项目进度：`/workspace/zyfun_mobile/PROGRESS.md`
