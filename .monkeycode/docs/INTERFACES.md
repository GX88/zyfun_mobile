# zyfun_mobile 接口文档

## 1. 页面路由接口

路由定义位于 `zyfun_mobile/lib/app/routes/app_routes.dart`。

| 路径 | 名称 | 页面实现 | 当前状态 |
|------|------|----------|----------|
| `/` | `home` | 重定向到 `/film` | 已实现 |
| `/film` | `film` | `FilmPage` | 已实现 |
| `/live` | `live` | `LivePage` | 页面占位 |
| `/history` | `history` | `HistoryPage` | 已实现 |
| `/favorite` | `favorite` | `PlaceholderPage` | 占位 |
| `/setting` | `setting` | `SettingPage` | 已实现 |
| `/player/:id` | `player` | `PlaceholderPage` | 占位 |
| `/detail/:id` | `detail` | `PlaceholderPage` | 占位 |
| `/search` | `search` | `SearchPage` | 已实现 |
| `/parse` | `parse` | `PlaceholderPage` | 占位 |

### 路由行为说明

- 应用初始路由是 `/film`。
- 首页 `/` 只承担跳转职责。
- `/player/:id` 和 `/detail/:id` 已保留动态参数能力，但当前仅展示占位文案。

## 2. Provider 接口

Provider 定义位于 `zyfun_mobile/lib/presentation/providers/app_providers.dart` 及相关 Provider 文件。

### 基础依赖 Provider

| Provider | 类型 | 说明 |
|----------|------|------|
| `appDatabaseProvider` | `Provider<AppDatabase>` | 提供数据库单例 |
| `keyValueStorageProvider` | `Provider<KeyValueStorage>` | 提供键值存储 |
| `apiClientProvider` | `Provider<ApiClient>` | 提供 Dio 客户端 |

### DAO Provider

| Provider | 输出 |
|----------|------|
| `siteDaoProvider` | `SiteDao` |
| `historyDaoProvider` | `HistoryDao` |
| `iptvDaoProvider` | `IptvDao` |
| `analyzeDaoProvider` | `AnalyzeDao` |
| `settingDaoProvider` | `SettingDao` |

### Repository Provider

| Provider | 输出 |
|----------|------|
| `siteRepositoryProvider` | `SiteRepositoryImpl` 作为 `SiteRepository` |
| `historyRepositoryProvider` | `HistoryRepositoryImpl` 作为 `HistoryRepository` |
| `iptvRepositoryProvider` | `IptvRepositoryImpl` 作为 `IptvRepository` |
| `analyzeRepositoryProvider` | `AnalyzeRepositoryImpl` 作为 `AnalyzeRepository` |
| `settingRepositoryProvider` | `SettingRepositoryImpl` 作为 `SettingRepository` |

### 页面状态 Provider

| Provider | 类型 | 说明 |
|----------|------|------|
| `siteNotifierProvider` | `StateNotifierProvider<SiteNotifier, SiteListState>` | 影视站点、分类、内容、搜索状态 |
| `historyListProvider` | `AsyncNotifierProvider<HistoryListNotifier, List<History>>` | 最近播放历史 |
| `settingNotifierProvider` | `StateNotifierProvider<SettingNotifier, Setting>` | 主题与基础设置 |

## 3. 仓库接口

## 3.1 SiteRepository

定义位于 `lib/domain/repositories/site_repository.dart`。

| 方法 | 返回 | 说明 |
|------|------|------|
| `getAllSites()` | `Future<List<Site>>` | 获取所有站点 |
| `getSiteById(id)` | `Future<Site?>` | 按 ID 查询站点 |
| `addSite(site)` | `Future<void>` | 新增站点 |
| `updateSite(site)` | `Future<void>` | 更新站点 |
| `deleteSite(id)` | `Future<void>` | 删除站点 |
| `setDefaultSite(id)` | `Future<void>` | 保存默认站点 ID |
| `getDefaultSite()` | `Future<String?>` | 读取默认站点 ID |
| `searchVideos(siteId, keyword)` | `Future<List<Video>>` | 当前返回演示搜索结果 |
| `getCategories(siteId)` | `Future<List<Category>>` | 从站点分类字符串生成分类 |
| `getVideosByCategory(siteId, categoryId, page)` | `Future<List<Video>>` | 当前返回演示视频列表 |
| `getVideoDetail(siteId, videoId)` | `Future<VideoDetail>` | 当前返回演示详情或搜索匹配详情 |
| `getPlayUrl(siteId, episodeUrl)` | `Future<String>` | 当前直接返回传入地址 |

## 3.2 IptvRepository

| 方法 | 说明 |
|------|------|
| `getAllIptvs()` | 获取所有直播源 |
| `getIptvById(id)` | 查询直播源 |
| `addIptv(iptv)` / `updateIptv(iptv)` / `deleteIptv(id)` | 本地 CRUD |
| `setDefaultIptv(id)` / `getDefaultIptv()` | 默认直播源读写 |
| `parseM3u(content)` | 当前实现返回空列表 |
| `getChannels(iptvId)` | 当前实现返回空列表 |

## 3.3 AnalyzeRepository

| 方法 | 说明 |
|------|------|
| `getAllAnalyzes()` | 获取所有解析配置 |
| `getAnalyzeById(id)` | 查询解析配置 |
| `addAnalyze(analyze)` / `updateAnalyze(analyze)` / `deleteAnalyze(id)` | 本地 CRUD |
| `setDefaultAnalyze(id)` / `getDefaultAnalyze()` | 默认解析读写 |

## 3.4 HistoryRepository

| 方法 | 说明 |
|------|------|
| `getAllHistories()` | 获取全部历史 |
| `getHistoryById(id)` | 按 ID 查询 |
| `addHistory(history)` | 新增或替换历史 |
| `updateHistory(history)` | 更新历史 |
| `deleteHistory(id)` | 删除单条历史 |
| `clearAllHistories()` | 清空历史 |
| `getRecentHistories(limit)` | 按更新时间倒序获取最近记录 |

## 3.5 SettingRepository

| 方法 | 说明 |
|------|------|
| `getAllSettings()` | 读取完整设置对象 |
| `getSetting<T>(key)` | 按键读取单项值 |
| `updateSetting<T>(key, value)` | 更新单项值 |
| `importSetting(setting)` | 将完整 `Setting` JSON 写入存储 |
| `exportSetting()` | 导出完整设置 |
| `resetSetting()` | 删除完整设置 |

## 4. 数据库接口

数据库定义位于 `zyfun_mobile/lib/data/datasources/local/app_database.dart`。

### 4.1 数据库基础信息

- 数据库名：`zyfun.db`
- 版本号：`1`

### 4.2 表结构摘要

| 表名 | 主键 | 用途 |
|------|------|------|
| `sites` | `id` | 保存影视站点配置 |
| `iptvs` | `id` | 保存直播源配置 |
| `analyzes` | `id` | 保存解析接口配置 |
| `histories` | `id` | 保存播放历史 |
| `favorites` | `id` | 保存收藏记录 |
| `settings` | `key` | 保存设置键值 |

### 4.3 重点字段

`sites`:

- `key`, `name`, `api`, `playUrl`, `search`, `group`, `type`, `ext`, `categories`, `isActive`, `createdAt`, `updatedAt`

`iptvs`:

- `key`, `name`, `api`, `type`, `epg`, `logo`, `headers`, `isActive`, `createdAt`, `updatedAt`

`analyzes`:

- `key`, `name`, `api`, `type`, `flag`, `headers`, `script`, `isActive`, `createdAt`, `updatedAt`

`histories`:

- `siteId`, `videoId`, `title`, `cover`, `description`, `episodeUrl`, `episodeName`, `progress`, `duration`, `createdAt`, `updatedAt`

`favorites`:

- `siteId`, `videoId`, `title`, `cover`, `createdAt`

`settings`:

- `key`, `value`, `updatedAt`

### 4.4 索引

- `idx_histories_updated_at`
- `idx_favorites_created_at`

## 5. 网络客户端接口

`ApiClient` 定义位于 `zyfun_mobile/lib/data/datasources/remote/api_client.dart`。

### 已提供能力

- `get<T>(path, {queryParameters, options})`
- `post<T>(path, {data, queryParameters, options})`

### 默认行为

- 连接、接收、发送超时均使用 `ApiConstants.defaultTimeout`，当前值为 `5000ms`。
- 默认 `responseType` 为 `json`。
- 默认请求头包含 `User-Agent: zyfun-mobile/1.0.0`。
- 网络异常统一映射为 `AppException(type: AppErrorType.network, ...)`。

## 6. 当前 UI 交互契约

### FilmPage

- 打开页面时触发 `loadSites()`。
- 当本地站点为空时，`SiteNotifier` 会自动写入一个演示站点。
- 用户切换站点后，会刷新分类和视频列表。
- 搜索结果会保存在 `SiteListState.searchResults` 并在影视页与搜索页复用。

### HistoryPage

- 页面依赖 `historyListProvider`。
- 历史项展示标题、剧集名、进度文本和进度条。

### SettingPage

- 支持切换 `system`、`light`、`dark` 三种主题模式。
- 支持切换 `hardwareAcceleration`。
- 当前页面只展示语言、超时、默认热搜等摘要字段。
