# zyfun Flutter 移动端 UI 重构实施计划

**Feature Name**: zyfun-flutter-mobile-ui  
**Created**: 2026-06-04  
**优先级**: 高

---

## 需求实施计划

- [x] 1. 配置主题系统和颜色规范
   - 创建主题配置文件 `lib/theme/app_theme.dart`
   - 实现主色系统 (#6366F1 蓝紫色)
   - 实现辅助色系统 (成功 #22C55E, 警告 #F59E0B, 危险 #EF4444, 信息 #0EA5E9)
   - 实现中性色系统 (背景色、文字色、边框色)
   - 实现渐变配置 (VIP 卡片、功能图标、按钮渐变)
   - 参考：`ui-design.md` 第 2.1 节

- [ ] 2. 实现字体和排版系统
   - [ ] 2.1 配置字体家族
     - 导入 Inter 字体文件到 `assets/fonts/`
     - 配置中文字体降级 (Noto Sans SC)
     - 在 `pubspec.yaml` 中注册字体

   - [x] 2.2 定义字号规范
     - 实现标题层级样式 (h1: 24px, h2: 20px, h3: 17px)
     - 实现正文字体样式 (body: 15px, bodySmall: 13px, caption: 12px)
     - 实现数字显示样式 (display: 16px, 表格数字)

   - [x] 2.3 实现文本层级组件
     - 创建 `PrimaryText` 组件 (主文字)
     - 创建 `SecondaryText` 组件 (次要文字)
     - 创建 `CaptionText` 组件 (说明文字)
     - 创建 `NumericText` 组件 (数字显示)

- [x] 3. 实现间距和布局系统
   - 创建间距常量文件 `lib/core/constants/spacing.dart`
   - 实现 4px 网格系统 (spacing1: 4, spacing2: 8, ... spacing12: 48)
   - 定义页面边距规范 (16px)
   - 定义卡片内边距规范 (16px)
   - 定义组件间距规范 (按钮内边距、图标文字间距等)

- [x] 4. 实现圆角和阴影系统
   - [x] 4.1 定义圆角规范
     - 创建圆角常量文件 `lib/core/constants/radius.dart`
     - 实现 6 级圆角 (radiusXS: 4, radiusSM: 6, radiusMD: 8, radiusLG: 12, radiusXL: 16, radiusFull: 9999)

   - [x] 4.2 定义阴影规范
     - 创建阴影常量文件 `lib/core/constants/shadows.dart`
     - 实现浅阴影 (shadowSm, shadowMd, shadowLg, shadowFloating)
     - 配置暗色模式阴影适配

- [x] 5. 集成图标系统
   - 安装 Lucide Icons: `flutter pub add lucide_icons_flutter`
   - 创建图标使用规范文档
   - 定义图标尺寸常量 (iconXS: 14, iconSM: 16, iconMD: 20, iconLG: 24, iconXL: 32, icon2XL: 48)
   - 配置首页功能图标渐变色

- [x] 6. 实现基础组件库 (基于 shadcn_ui)
   - [x] 6.1 按钮组件封装
     - 创建 `lib/presentation/components/buttons/` 目录
     - 封装 PrimaryButton (主按钮)
     - 封装 SecondaryButton (次按钮)
     - 封装 OutlineButton (描边按钮)
     - 封装 GhostButton (幽灵按钮)
     - 封装 DestructiveButton (危险按钮)
     - 封装 LinkButton (链接按钮)
     - 实现三种尺寸 (Small: 36px, Medium: 44px, Large: 52px)

   - [x] 6.2 输入框组件封装
     - 创建 `lib/presentation/components/inputs/` 目录
     - 封装 SearchInput (搜索框) - 高度 40px
     - 封装 TextInput (文本输入框)
     - 封装 PasswordInput (密码输入框)
     - 实现表单验证支持
     - 实现三种状态 (默认、聚焦、禁用)

   - [x] 6.3 卡片组件封装
     - 创建 `lib/presentation/components/cards/` 目录
     - 封装 VideoCard (视频卡片) - 240-280px 高
     - 封装 HeroBannerCard (Banner 卡片) - 180-220px 高
     - 封装 FunctionCard (功能卡片) - 72px 高
     - 封装 StatCard (统计卡片)
     - 实现封面图加载和占位
     - 实现播放进度条覆盖层

   - [x] 6.4 标签组件封装
     - 创建 `lib/presentation/components/chips/` 目录
     - 封装 Chip (普通标签) - 高度 28px
     - 封装 StatusChip (状态标签) - 正常/警告/危险/信息
     - 封装 CategoryChip (分类标签)
     - 实现状态颜色映射

- [ ] 7. 检查点 - 基础组件验证
   - 运行 `flutter analyze` 确保无代码错误
   - 创建组件展示页面验证所有组件渲染正确
   - 如有疑问请询问用户

- [x] 8. 实现顶部导航栏组件
   - [x] 8.1 创建 AppBar 组件
     - 创建 `lib/presentation/components/app_bar.dart`
     - 实现标准 AppBar (高度 56px)
     - 实现大标题 AppBar (高度 96px)
     - 实现搜索框 AppBar

   - [x] 8.2 实现页面顶栏类型
     - 实现首页类型 (搜索框 + 历史/刷新图标)
     - 实现探索页类型 (搜索框 + 历史图标)
     - 实现直播页类型 (Tab 切换 + 搜索图标)
     - 实现我的页类型 (通知 + 设置图标)
     - 实现详情页类型 (无顶栏，内容区)
     - 实现二级页类型 (返回箭头 + 标题 + 操作按钮)
     - 参考：`UI_ANALYSIS_REPORT.md` 第 10 节

- [x] 9. 实现底部导航栏组件
   - 创建 `lib/presentation/components/bottom_nav_bar.dart`
   - 配置 4 个 Tab (影视、探索、直播、我的)
   - 实现图标尺寸 24x24
   - 实现选中态颜色 (#6366F1)
   - 实现未选中态颜色 (#64748B)
   - 实现高度规范 (83px 含安全区 / 56px 不含)
   - 可选：实现顶部指示线 (2px 高)

- [ ] 10. 实现列表项组件
   - [ ] 10.1 标准列表项
     - 创建 `lib/presentation/components/list_items/` 目录
     - 封装 StandardListItem (标准列表项) - 高度 72px
     - 封装 VideoListItem (视频列表项)
     - 封装 SettingListItem (设置列表项) - 高度 56px

   - [ ] 10.2 列表项元素
     - 实现图标/海报区域 (48x48, 圆角 8px)
     - 实现标题和副标题布局
     - 实现右侧操作区 (箭头/按钮)
     - 实现开关组件集成

- [ ] 11. 实现进度条组件
   - 创建 `lib/presentation/components/progress/` 目录
   - 封装 PlaybackProgressBar (播放进度条) - 高度 4px
   - 封装 BufferProgressBar (缓冲进度条) - 高度 3px
   - 封装 LinearProgress (线性进度条)
   - 实现滑块交互 (拖拽、点击跳转)
   - 实现颜色配置 (activeColor: primary, inactiveColor: border)

- [ ] 12. 检查点 - 组件库完整性验证
   - 确保所有基础组件已实现
   - 组件支持亮色/暗色模式切换
   - 组件支持响应式布局
   - 如有疑问请询问用户

- [ ] 13. 实现弹框和对话框组件
   - 创建 `lib/presentation/components/dialogs/` 目录
   - 封装 ConfirmDialog (确认对话框) - 宽度 320px
   - 封装 AlertDialog (警告对话框)
   - 封装 LoadingDialog (加载对话框)
   - 封装 BottomSheet (底部弹层)
   - 实现圆角 16px, 内边距 24px, 阴影 shadowFloating

- [ ] 14. 实现开关组件
   - 创建 `lib/presentation/components/switches/` 目录
   - 封装 AppSwitch (应用开关)
   - 实现尺寸规范 (宽度 44px, 高度 26px, 滑块直径 22px)
   - 实现开启颜色 (primary)
   - 实现关闭颜色 (border)

- [ ] 15. 实现空状态和加载组件
   - [ ] 15.1 空状态组件
     - 创建 `lib/presentation/components/empty_states/` 目录
     - 封装 EmptyData (空数据)
     - 封装 EmptySearch (无搜索结果)
     - 封装 EmptyNetwork (网络错误)
     - 实现特大图标 (48px) + 说明文字布局

   - [ ] 15.2 加载组件
     - 创建 `lib/presentation/components/loading/` 目录
     - 封装 LoadingSpinner (旋转加载器) - 1s 循环
     - 封装 ShimmerLoading (骨架屏) - 1.5s 循环
     - 封装 PullRefresh (下拉刷新)

- [ ] 16. 实现页面布局模板
   - [ ] 16.1 首页布局模板
     - 创建 `lib/presentation/layouts/home_layout.dart`
     - 实现 CustomScrollView 结构
     - 实现顶部搜索区 (56px)
     - 实现分类切换 Tab (44px)
     - 实现大推荐 Banner (200px)
     - 实现快捷入口 (80px)
     - 实现继续观看 (200px)
     - 实现源状态监控 (120px)
     - 参考：`ui-design.md` 第 4.1 节

   - [ ] 16.2 列表页布局模板
     - 创建 `lib/presentation/layouts/list_layout.dart`
     - 实现左侧分类栏 (100px 宽)
     - 实现右侧内容区 (Expanded)
     - 实现 Grid 布局 (2 列)
     - 参考：`ui-design.md` 第 4.2 节

   - [ ] 16.3 详情页布局模板
     - 创建 `lib/presentation/layouts/detail_layout.dart`
     - 实现海报和标题信息区
     - 实现操作按钮区
     - 实现简介 Tab
     - 实现选集列表
     - 实现相关推荐
     - 参考：`ui-design.md` 第 4.3 节

   - [ ] 16.4 播放页布局模板
     - 创建 `lib/presentation/layouts/player_layout.dart`
     - 实现播放器窗口 (16:9)
     - 实现功能 Tabs
     - 实现源列表/选集区 (200px)
     - 参考：`ui-design.md` 第 4.4 节

   - [ ] 16.5 我的页布局模板
     - 创建 `lib/presentation/layouts/profile_layout.dart`
     - 实现用户信息区 (120px)
     - 实现 VIP 卡片 (140px)
     - 实现数据统计 (80px)
     - 实现功能列表
     - 参考：`ui-design.md` 第 4.5 节

- [x] 17. 实现具体页面 UI
   - [x] 17.1 首页 (FilmPage)
     - 重构 `lib/presentation/pages/film/film_page.dart`
     - 应用首页布局模板
     - 实现搜索框组件
     - 实现分类 Tabs 组件
     - 实现 Banner 卡片组件
     - 实现快捷入口 (5 个圆形图标 + 渐变)
     - 实现继续观看横向列表
     - 实现源状态监控卡片

   - [ ] 17.2 探索页 (ExplorePage)
     - 重构 `lib/presentation/pages/explore/explore_page.dart`
     - 应用列表页布局模板
     - 实现左侧分类导航
     - 实现右侧视频 Grid 列表
     - 实现筛选组件 (年代、类型、地区)
     - 实现搜索历史记录

   - [ ] 17.3 直播页 (LivePage)
     - 重构 `lib/presentation/pages/live/live_page.dart`
     - 实现 Tab 切换顶栏 (频道/收藏/最近)
     - 实现左侧频道分类
     - 实现右侧频道列表
     - 实现底部迷你播放器

   - [ ] 17.4 我的页 (ProfilePage)
     - 重构 `lib/presentation/pages/profile/profile_page.dart`
     - 应用我的页布局模板
     - 实现用户信息区 (头像、昵称)
     - 实现 VIP 卡片 (金色渐变)
     - 实现数据统计区
     - 实现功能列表 (历史、收藏、下载、设置、关于)

   - [ ] 17.5 详情页 (VideoDetailPage)
     - 重构 `lib/presentation/pages/detail/video_detail_page.dart`
     - 应用详情页布局模板
     - 实现海报展示区
     - 实现标题和标签
     - 实现操作按钮 (播放/收藏/下载)
     - 实现简介和选集 Tabs
     - 实现选集 Grid
     - 实现相关推荐列表

   - [ ] 17.6 播放页 (PlayerPage)
     - 重构 `lib/presentation/pages/player/player_page.dart`
     - 应用播放页布局模板
     - 实现播放器容器
     - 实现控制栏组件
     - 实现源选择 Tabs
     - 实现清晰度选择
     - 实现选集列表
     - 实现弹幕开关

   - [ ] 17.7 历史页 (HistoryPage)
     - 重构 `lib/presentation/pages/history/history_page.dart`
     - 实现标准 AppBar (返回 + 标题 + 编辑)
     - 实现历史记录列表
     - 实现播放位置标记
     - 实现单条删除和批量清空

   - [ ] 17.8 收藏页 (FavoritePage)
     - 重构 `lib/presentation/pages/favorite/favorite_page.dart`
     - 实现标准 AppBar (返回 + 标题)
     - 实现收藏视频 Grid 列表
     - 实现取消收藏操作

   - [ ] 17.9 搜索页 (SearchPage)
     - 重构 `lib/presentation/pages/search/search_page.dart`
     - 实现搜索输入框
     - 实现搜索历史记录
     - 实现搜索建议和联想
     - 实现搜索结果列表

   - [ ] 17.10 设置页 (SettingsPage)
     - 重构 `lib/presentation/pages/setting/setting_page.dart`
     - 实现标准 AppBar (返回 + 标题)
     - 实现设置列表分组
     - 实现开关组件
     - 实现选择器组件
     - 实现导入导出功能 UI

   - [ ] 17.11 关于页 (AboutPage)
     - 重构 `lib/presentation/pages/about/about_page.dart`
     - 实现应用信息卡片
     - 实现版本号显示
     - 实现检查更新按钮
     - 实现开源协议说明

   - [ ] 17.12 AI 功能页 (AiPage)
     - 重构 `lib/presentation/pages/ai/ai_page.dart`
     - 实现 AI 配置表单
     - 实现 API Key 输入
     - 实现模型选择
     - 实现推荐列表展示

- [ ] 18. 检查点 - 页面完整性验证
   - 确保所有 12 个页面 UI 已完成
   - 页面间路由跳转正常
   - 页面支持亮色/暗色模式
   - 运行 `flutter analyze` 验证代码质量
   - 如有疑问请询问用户

- [ ] 19. 实现动效系统
   - [ ] 19.1 配置过渡动画
     - 创建 `lib/core/animations/page_transitions.dart`
     - 实现 slideRight (300ms, Ease Out)
     - 实现 slideLeft (300ms, Ease In)
     - 实现 fade (200ms)

   - [ ] 19.2 配置交互动画
     - 创建 `lib/core/animations/interaction_animations.dart`
     - 实现按钮按下动画 (Scale Down, 100ms)
     - 实现卡片展开动画 (Scale Up, 250ms, Spring)
     - 实现列表项出现动画 (Fade In Up, 200ms)

   - [ ] 19.3 配置反馈动画
     - 创建 `lib/core/animations/feedback_animations.dart`
     - 实现成功动画 (Check Scale Up, 300ms)
     - 实现错误动画 (Shake, 400ms)
     - 实现点赞动画 (Heart Pulse, 600ms)
     - 实现收藏动画 (Star Fill, 300ms)

   - [ ] 19.4 配置加载动画
     - 创建 `lib/core/animations/loading_animations.dart`
     - 实现旋转加载器 (1s 循环)
     - 实现骨架屏扫光 (1.5s 循环)
     - 实现下拉刷新动画

- [ ] 20. 实现暗色模式适配
   - 创建暗色主题配置 `lib/theme/dark_theme.dart`
   - 实现颜色映射 (background: #0F172A, surface: #1E293B, textPrimary: #F1F5F9, textSecondary: #94A3B8, border: #334155)
   - 实现图片暗色适配 (降低亮度 10%)
   - 实现阴影暗色适配 (增加透明度和模糊半径)
   - 实现图标暗色适配 (半透明白色)
   - 实现渐变暗色适配 (降低饱和度)

- [ ] 21. 实现响应式布局
   - 创建 `lib/core/utils/responsive_builder.dart`
   - 实现 ScreenSize 枚举 (phone, tablet, desktop)
   - 实现 ResponsiveBuilder 组件
   - 实现手机布局 (<600px)
   - 实现平板布局 (600-900px)
   - 实现桌面布局 (>900px)

- [ ] 22. 实现全面屏适配
   - 使用 SafeArea 组件包裹页面
   - 实现刘海屏适配
   - 实现底部手势区适配
   - 实现状态栏适配 (透明/不透明)

- [ ] 23. 检查点 - 移动端适配验证
   - 在 iOS Simulator 测试
   - 在 Android Emulator 测试
   - 测试不同屏幕尺寸
   - 测试横竖屏切换
   - 如有疑问请询问用户

- [ ]* 24. 为 UI 组件编写 Widget 测试
   - [ ]* 24.1 测试基础组件
     - 测试按钮组件渲染
     - 测试输入框组件渲染
     - 测试卡片组件渲染
     - 测试标签组件渲染

   - [ ]* 24.2 测试布局组件
     - 测试 AppBar 组件
     - 测试 BottomNavBar 组件
     - 测试列表项组件

   - [ ]* 24.3 测试页面组件
     - 测试首页渲染
     - 测试探索页渲染
     - 测试播放页渲染
     - 测试我的页渲染

   - [ ]* 24.4 测试暗色模式
     - 测试组件暗色模式渲染
     - 测试页面暗色模式渲染
     - 测试主题切换

- [ ]* 25. 编写 UI 文档
   - [ ]* 25.1 编写组件使用文档
     - 记录所有组件 API
     - 提供使用示例代码
     - 记录最佳实践

   - [ ]* 25.2 更新设计文档
     - 记录设计决策
     - 记录颜色/字体/间距规范
     - 记录组件使用规范

- [ ] 26. 最终验收
   - 运行 `flutter analyze` 确保无警告
   - 运行 `flutter test` 确保测试通过
   - 手动测试所有页面 UI
   - 验证设计还原度 (颜色、字体、间距、圆角、阴影)
   - 验证交互流畅度 (动画 60fps)
   - 验证响应时间 (<300ms)

---

## 补充说明

### 文件组织结构

```
lib/
├── core/
│   ├── constants/
│   │   ├── colors.dart           # 颜色常量
│   │   ├── spacing.dart          # 间距常量
│   │   ├── radius.dart           # 圆角常量
│   │   ├── shadows.dart          # 阴影常量
│   │   └── typography.dart       # 字体常量
│   ├── animations/
│   │   ├── page_transitions.dart # 页面过渡动画
│   │   ├── interaction_animations.dart # 交互动画
│   │   ├── feedback_animations.dart # 反馈动画
│   │   └── loading_animations.dart # 加载动画
│   └── utils/
│       └── responsive_builder.dart # 响应式布局工具
├── theme/
│   ├── app_theme.dart            # 主题配置
│   ├── light_theme.dart          # 亮色主题
│   └── dark_theme.dart           # 暗色主题
└── presentation/
    ├── components/               # 组件库
    │   ├── buttons/              # 按钮组件
    │   ├── inputs/               # 输入组件
    │   ├── cards/                # 卡片组件
    │   ├── chips/                # 标签组件
    │   ├── list_items/           # 列表项组件
    │   ├── progress/             # 进度条组件
    │   ├── dialogs/              # 对话框组件
    │   ├── switches/             # 开关组件
    │   ├── empty_states/         # 空状态组件
    │   └── loading/              # 加载组件
    ├── layouts/                  # 布局模板
    │   ├── home_layout.dart
    │   ├── list_layout.dart
    │   ├── detail_layout.dart
    │   ├── player_layout.dart
    │   └── profile_layout.dart
    └── pages/                    # 页面
        ├── film/
        ├── explore/
        ├── live/
        ├── profile/
        ├── detail/
        ├── player/
        ├── history/
        ├── favorite/
        ├── search/
        ├── setting/
        ├── about/
        └── ai/
```

### 参考文件

- [`ui-design.md`](./ui-design.md) - UI 设计详细规范
- [`UI_ANALYSIS_REPORT.md`](./../../UI_ANALYSIS_REPORT.md) - UI 分析报告
- [`design.md`](./design.md) - 技术设计文档
- [`requirements.md`](./requirements.md) - 需求文档
- [`shadcn-ui-quickstart.md`](./shadcn-ui-quickstart.md) - shadcn_ui 使用指南

### 关键指标

| 指标 | 目标值 | 测量方式 |
|------|--------|----------|
| 视觉还原度 | >95% | 设计稿对比 |
| 动画帧率 | 60fps | Flutter DevTools |
| 页面切换时间 | <300ms | 计时器测量 |
| 首屏渲染时间 | <1.5s | 冷启动测试 |
| 内存占用 | <200MB | 性能监控 |
| 组件测试覆盖 | >80% | 测试报告 |

---

**创建日期**: 2026-06-04  
**最后更新**: 2026-06-04  
**版本**: 1.0.0
