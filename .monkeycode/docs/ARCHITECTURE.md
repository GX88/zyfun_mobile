# zyfun_mobile 架构文档

## 1. 架构概览

当前项目采用典型 Flutter 分层结构，代码主要位于 `zyfun_mobile/lib/`，按应用壳、表示层、领域层、数据层、核心能力分组。

```text
main.dart
  -> LoggerConfig.init()
  -> ProviderScope
  -> ZyfunApp
      -> ShadApp.router
      -> GoRouter routes
      -> 页面 / Provider / Repository / DAO / SQLite
```

## 2. 目录结构

| 目录 | 当前职责 |
|------|----------|
| `lib/app/` | 应用壳与路由配置 |
| `lib/config/` | 日志等配置入口 |
| `lib/core/` | 常量、错误类型、工具能力、UI design tokens |
| `lib/data/models/` | 数据模型和生成代码 |
| `lib/data/datasources/local/` | SQLite、DAO、键值存储 |
| `lib/data/datasources/remote/` | Dio 基础客户端 |
| `lib/data/repositories/` | 仓库实现，连接本地存储与上层调用 |
| `lib/domain/repositories/` | 仓库抽象接口和部分状态模型 |
| `lib/presentation/pages/` | 页面 UI |
| `lib/presentation/providers/` | Riverpod Provider 与 Notifier |
| `lib/presentation/components/` | 通用组件，如底部导航、搜索栏、文本组件 |
| `lib/theme/` | Shad 主题配置与亮暗色视觉规范 |
| `test/` | 初始化、模型、DAO、仓库测试 |

## 3. 启动流程

### 3.1 应用启动

`lib/main.dart` 的启动流程如下：

1. `WidgetsFlutterBinding.ensureInitialized()` 初始化 Flutter 绑定。
2. `LoggerConfig.init()` 初始化日志系统。
3. 使用 `ProviderScope` 包裹 `ZyfunApp`，启用 Riverpod 依赖注入与状态管理。

### 3.2 应用壳

`lib/app/app.dart` 中的 `ZyfunApp` 负责：

- 在 `initState` 中调用 `settingNotifierProvider.notifier.load()` 读取本地设置。
- 根据 `Setting.theme` 映射到 `ThemeMode.light`、`ThemeMode.dark` 或 `ThemeMode.system`。
- 使用 `ShadApp.router` 绑定主题与路由。
- 主题定义由 `lib/theme/app_theme.dart` 驱动，并消费 `lib/core/constants/` 下的 UI token。
- 注册 `zh_CN`、`zh_TW`、`en` 三种 `Locale`。

## 4. 分层说明

## 4.1 表示层

表示层由页面、组件、Provider 组成。

### 页面现状

| 页面 | 当前状态 |
|------|----------|
| `FilmPage` | 可运行，能加载站点、分类、演示视频、最近搜索结果 |
| `SearchPage` | 可运行，依赖 `SiteNotifier` 执行搜索 |
| `HistoryPage` | 可运行，读取 `historyListProvider` 显示本地历史 |
| `SettingPage` | 可运行，可切换主题和硬件加速开关 |
| `LivePage` | UI 占位，说明未来接入 M3U / EPG |
| `Favorite`、`Player`、`Detail`、`Parse` | 路由存在，页面仍为 `PlaceholderPage` |

### 组件现状

- `AppBottomNavBar` 已切换为 4 栏设计稿风格，支持影视、探索、直播、我的四个入口。
- 新增 `presentation/components/app_bar.dart`，统一封装二级页标题栏、搜索型标题栏、Tab 型标题栏。
- `AppSearchBar` 已接入新的搜索输入框视觉规范。
- 新增 `presentation/components/texts.dart`，提供统一的主文本、次文本、说明文本、数字文本组件。
- 新增 `presentation/components/buttons/app_buttons.dart`，封装主按钮、次按钮、描边按钮、幽灵按钮、危险按钮、链接按钮和统一尺寸规范。
- 新增 `presentation/components/inputs/app_inputs.dart`，封装搜索输入框、普通文本输入框、密码输入框。
- 新增 `presentation/components/cards/app_cards.dart`，封装 Banner 卡片、功能卡片、统计卡片以及统一图片占位逻辑。
- 新增 `presentation/components/chips/app_chips.dart`，封装普通标签、状态标签和分类标签。
- 页面广泛使用 `ShadCard`、`ShadButton`、`ShadInput`、`ShadSwitch` 等 `shadcn_ui` 组件。

### 页面导航现状

- `FilmPage` 已切换为搜索型顶部栏，右侧提供历史和刷新图标。
- `SearchPage` 已切换为搜索型顶部栏。
- `LivePage` 已切换为 Tab 型顶部栏，顶部标签为“频道 / 收藏 / 最近”，右侧为搜索图标。
- `HistoryPage`、`AboutPage` 已切换为标准二级页标题栏。
- `SettingPage` 顶部标题已改为“我的”，与新版底部导航映射对齐。

### UI Token 现状

当前 UI 重构已新增一组基础 design token，位于 `lib/core/constants/`：

- `colors.dart`: 主题色、状态色、中性色、渐变定义
- `spacing.dart`: 4px 网格间距体系和常用 EdgeInsets
- `radius.dart`: 按钮、输入框、卡片等圆角规范
- `shadows.dart`: 浅色/深色阴影预设
- `typography.dart`: 字体、字号、字重和数字文本规范
- `icons.dart`: 图标尺寸规范

## 4.2 状态管理层

当前使用 `flutter_riverpod`，尚未使用代码生成 Provider。

核心 Provider：

- `appDatabaseProvider`: 提供 `AppDatabase.instance`
- `keyValueStorageProvider`: 提供轻量级键值存储
- `apiClientProvider`: 提供 `ApiClient`
- DAO Provider: `siteDaoProvider`、`historyDaoProvider`、`iptvDaoProvider`、`analyzeDaoProvider`、`settingDaoProvider`
- Repository Provider: `siteRepositoryProvider`、`historyRepositoryProvider`、`iptvRepositoryProvider`、`analyzeRepositoryProvider`、`settingRepositoryProvider`

核心状态对象：

- `SiteNotifier`: 管理站点、分类、视频列表、搜索状态。
- `HistoryListNotifier`: 基于 `AsyncNotifier<List<History>>` 加载最近历史。
- `SettingNotifier`: 管理主题和硬件加速等设置。

## 4.3 领域层

`lib/domain/repositories/` 当前主要承担接口定义职责：

- `SiteRepository`
- `IptvRepository`
- `AnalyzeRepository`
- `HistoryRepository`
- `SettingRepository`

其中 `SiteRepository` 文件里还定义了：

- `Category`
- `SiteListState`

这说明当前项目的领域边界仍较轻量，部分状态结构直接与仓库接口文件放在一起。

## 4.4 数据层

### 本地数据

`AppDatabase` 使用 `sqflite` 创建数据库 `zyfun.db`，当前创建以下表：

- `sites`
- `iptvs`
- `analyzes`
- `histories`
- `favorites`
- `settings`

并为 `histories.updatedAt`、`favorites.createdAt` 建立索引。

DAO 已落地，仓库实现通过 DAO 完成 CRUD。

### 远程数据

`ApiClient` 基于 `dio` 封装了：

- 统一超时配置
- `User-Agent: zyfun-mobile/1.0.0`
- `get` / `post` 方法
- `DioException -> AppException` 映射

当前仓库里还没有完整的 `SiteApi`、`IptvApi`、`ParseApi` 等服务实现，因此远程层目前还是基础设施状态。

## 5. 当前关键实现策略

## 5.1 影视站点联调策略

`SiteRepositoryImpl` 当前以本地站点配置为基础，生成演示数据支撑页面联调：

- `getCategories` 从 `Site.categories` 的逗号分隔字符串生成分类。
- `getVideosByCategory` 根据分类与页码生成 12 条演示视频。
- `searchVideos` 根据关键字生成 8 条演示结果。
- `getVideoDetail` 从搜索结果中回填详情，或生成兜底详情。
- `getPlayUrl` 直接返回传入的 `episodeUrl`。

该实现让页面可以在真实接口尚未接入时完成 UI、路由和状态流联调。

## 5.2 直播与解析策略

- `IptvRepositoryImpl` 已有本地 CRUD 和默认值保存逻辑。
- `parseM3u`、`getChannels` 仍返回空列表。
- `AnalyzeRepositoryImpl` 已有本地 CRUD 和默认解析配置逻辑，尚未执行真实解析调用。

## 5.3 设置持久化策略

`SettingRepositoryImpl` 将完整 `Setting` 对象序列化为 JSON，使用 `settings` 表中的 `StorageKeys.setting` 进行保存与读取。

## 6. 测试结构

当前测试覆盖主要集中在基础层：

- `test/app/app_initialization_test.dart`: Provider、路由、主题初始化。
- `test/data/models/model_serialization_test.dart`: 模型序列化与边界行为。
- `test/data/datasources/local/dao/database_dao_test.dart`: DAO 与数据库表行为。
- `test/data/repositories/repository_impl_test.dart`: 仓库 CRUD 与演示逻辑。

UI 页面、复杂状态交互、远程接口集成测试当前尚未看到对应实现。

## 7. 与规格文档的差距

从规格视角看，当前代码已经落地“基础架构 + 本地数据层 + 部分页面”，以下目标仍待实现：

- 真实视频站点 API 适配
- 播放器与播放控制
- 直播频道和 EPG
- 解析接口调用
- 收藏功能
- 完整设置项
- 云同步、AI、移动端高级特性

这些内容在 `.monkeycode/specs/zyfun-flutter-mobile/` 中有设计与任务拆解，代码层当前尚未完全覆盖。
