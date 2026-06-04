# zyfun_mobile 项目文档索引

## 项目概览

`zyfun_mobile` 是一个基于 Flutter 3.16 的移动端应用，目标是将原 zyfun 桌面端重构为 Android / iOS 双端应用。当前仓库中的代码已经完成应用壳、主题、路由、本地数据模型、SQLite 数据访问、部分仓库实现，以及影视、历史、设置等基础页面。

本文档严格基于当前仓库代码生成，并参考 `.monkeycode/specs/zyfun-flutter-mobile/requirements.md`、`design.md`、`tasklist.md` 说明目标范围。规格文档描述的是计划目标，本文档中的“当前实现”以 `zyfun_mobile/` 下现有代码为准。

## 文档清单

| 文件 | 说明 |
|------|------|
| [ARCHITECTURE.md](./ARCHITECTURE.md) | 说明当前代码结构、运行流程、分层关系和已实现模块 |
| [INTERFACES.md](./INTERFACES.md) | 说明页面路由、仓库接口、数据库表、Provider 和当前对外契约 |
| [DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md) | 说明开发环境、关键入口、测试现状、生成代码和后续接入注意事项 |

## 当前实现摘要

### 已实现

- Flutter 应用入口、`ProviderScope`、日志初始化。
- `ShadApp.router` 主题配置和基础国际化配置。
- 新的 UI design token 基础层，包含颜色、间距、圆角、阴影、排版和图标尺寸常量。
- GoRouter 路由骨架，包含 `/film`、`/live`、`/history`、`/favorite`、`/setting`、`/player/:id`、`/detail/:id`、`/search`、`/parse`。
- SQLite 数据库初始化与表结构创建。
- `Site`、`Iptv`、`Analyze`、`History`、`Favorite`、`Setting`、`Video` 等模型及其生成代码。
- 本地 DAO 与 `SiteRepositoryImpl`、`HistoryRepositoryImpl`、`IptvRepositoryImpl`、`AnalyzeRepositoryImpl`、`SettingRepositoryImpl`。
- `siteNotifierProvider`、`historyListProvider`、`settingNotifierProvider`。
- 影视页、历史页、设置页、搜索页的可运行 UI。
- 初始化测试、模型测试、DAO 测试、仓库测试。

### 当前仍为占位或演示逻辑

- 远程站点 API 的真实请求编排尚未接入，`SiteRepositoryImpl` 当前返回演示视频数据。
- 直播页、收藏页、解析页、播放器页、详情页仍以占位页面或占位能力为主。
- `ApiClient` 已有 Dio 基础封装，当前仓库里还没有完整远程数据源服务层落地。
- `IptvRepositoryImpl` 中 `parseM3u` 和 `getChannels` 返回空列表。
- `AnalyzeRepositoryImpl` 仅实现本地配置 CRUD 和默认值读写。

## 规格与代码的关系

- 规格文档定义了完整移动端目标，包括播放器、直播、解析、收藏、AI、云同步等能力。
- 当前代码对应的实现阶段更接近“应用基础骨架 + 本地数据层 + 部分页面联调”。
- 阅读项目时，建议先以代码现状理解系统，再用规格文档判断后续待实现范围。

## 代码入口

- 应用入口：`zyfun_mobile/lib/main.dart`
- 应用壳：`zyfun_mobile/lib/app/app.dart`
- 路由配置：`zyfun_mobile/lib/app/routes/app_routes.dart`
- UI token：`zyfun_mobile/lib/core/constants/`
- 依赖注册：`zyfun_mobile/lib/presentation/providers/app_providers.dart`
- SQLite 初始化：`zyfun_mobile/lib/data/datasources/local/app_database.dart`

## 相关参考

- 需求文档：`/workspace/.monkeycode/specs/zyfun-flutter-mobile/requirements.md`
- 技术设计：`/workspace/.monkeycode/specs/zyfun-flutter-mobile/design.md`
- 实施计划：`/workspace/.monkeycode/specs/zyfun-flutter-mobile/tasklist.md`
- 进度说明：`/workspace/zyfun_mobile/PROGRESS.md`
