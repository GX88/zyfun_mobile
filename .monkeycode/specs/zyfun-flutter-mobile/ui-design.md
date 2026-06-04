# zyfun Flutter 移动端 UI 重构设计文档

**Feature Name**: zyfun-flutter-mobile-ui  
**Created**: 2026-06-04  
**Design Type**: UI/UX 重构专项

---

## 1. 概述

### 1.1 设计目标

基于提供的 UI 设计图 (多源聚合影视播放器)，对 zyfun Flutter 移动端应用进行全面的 UI 重构，实现：

- **视觉统一**: 建立完整的设计系统和组件规范
- **体验优化**: 遵循 iOS/Android 移动端交互规范
- **高效开发**: 提供可复用的组件库和主题系统
- **品牌识别**: 建立独特的视觉识别系统

### 1.2 设计原则

1. **一致性**: 所有页面遵循统一的设计语言
2. **清晰性**: 信息层级明确，用户操作路径清晰
3. **效率性**: 减少操作步数，提升交互效率
4. **美感**: 简洁现代，符合当代移动应用审美

### 1.3 范围说明

**本设计专注于 UI 层面重构**，包括：
- ✅ 颜色系统和主题配置
- ✅ 字体和排版系统
- ✅ 组件库建设和规范化
- ✅ 页面布局和导航结构
- ✅ 图标系统
- ✅ 动效和过渡动画

**不考虑功能一致性** (功能实现由其他任务负责)：
- ❌ API 接口对接
- ❌ 业务逻辑实现
- ❌ 数据状态管理
- ❌ 性能优化

---

## 2. 设计系统

### 2.1 颜色系统

#### 2.1.1 主题色

```dart
// 主色 - 蓝紫色系
static const Color primary = Color(0xFF6366F1); // Indigo/蓝紫

// 辅助功能色
static const Color success = Color(0xFF22C55E);  // 成功/正常
static const Color warning = Color(0xFFF59E0B);  // 警告/热度
static const Color error = Color(0xFFEF4444);    // 错误/危险
static const Color info = Color(0xFF0EA5E9);     // 信息提示
```

#### 2.1.2 中性色

```dart
// 背景色
static const Color background = Color(0xFFFFFFFF);         // 主背景 (亮色)
static const Color backgroundDark = Color(0xFF0F172A);     // 主背景 (暗色)
static const Color surface = Color(0xFFF8FAFC);            // 卡片/表面
static const Color surfaceDark = Color(0xFF1E293B);        // 卡片/表面 (暗色)

// 文字色
static const Color textPrimary = Color(0xFF1E293B);        // 主文字 (深灰/近黑)
static const Color textSecondary = Color(0xFF64748B);      // 次要文字 (中灰)
static const Color textDisabled = Color(0xFFCBD5E1);       // 禁用文字 (浅灰)
static const Color textPrimaryDark = Color(0xFFF1F5F9);    // 主文字 (暗色)
static const Color textSecondaryDark = Color(0xFF94A3B8);  // 次要文字 (暗色)

// 边框色
static const Color border = Color(0xFFE2E8F0);             // 边框/分割线
static const Color borderDark = Color(0xFF334155);         // 边框 (暗色)
```

#### 2.1.3 渐变配置

```dart
// VIP 卡片渐变
static const LinearGradient vipGradient = LinearGradient(
  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// 播放器渐变按钮
static const LinearGradient primaryGradient = LinearGradient(
  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

// 首页功能图标渐变
static const LinearGradient iconGradient1 = LinearGradient(
  colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],  // 蓝色系
);
static const LinearGradient iconGradient2 = LinearGradient(
  colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],  // 紫色系
);
static const LinearGradient iconGradient3 = LinearGradient(
  colors: [Color(0xFFF472B6), Color(0xFFEC4899)],  // 粉色系
);
static const LinearGradient iconGradient4 = LinearGradient(
  colors: [Color(0xFF34D399), Color(0xFF10B981)],  // 绿色系
);
static const LinearGradient iconGradient5 = LinearGradient(
  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],  // 黄色系
);
```

### 2.2 字体系统

#### 2.2.1 字体家族

```dart
// 使用 Inter 字体 (参考设计稿 iOS 风格)
static const String fontFamily = 'Inter';

// 备选字体
static const String fontFamilyFallback = 'Noto Sans SC'; // 中文字体
```

#### 2.2.2 字号规范

```dart
// 标题层级
static const TextStyle h1 = TextStyle(    // 一级标题 - 页面标题
  fontSize: 24,
  fontWeight: FontWeight.bold,
  letterSpacing: -0.5,
);

static const TextStyle h2 = TextStyle(    // 二级标题 - 分区标题
  fontSize: 20,
  fontWeight: FontWeight.bold,
  letterSpacing: -0.3,
);

static const TextStyle h3 = TextStyle(    // 三级标题 - 卡片标题
  fontSize: 17,
  fontWeight: FontWeight.w600,
);

// 正文字体
static const TextStyle body = TextStyle(  // 主要正文
  fontSize: 15,
  fontWeight: FontWeight.normal,
  height: 1.5,
);

static const TextStyle bodySmall = TextStyle(  // 次要正文
  fontSize: 13,
  fontWeight: FontWeight.normal,
  height: 1.4,
);

static const TextStyle caption = TextStyle(  // 说明文字
  fontSize: 12,
  fontWeight: FontWeight.normal,
  height: 1.3,
);

// 数字显示 (评分、进度等)
static const TextStyle display = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  fontFeatures: [FontFeature.tabularFigures()],
);
```

#### 2.2.3 文本层级

| 层级 | 字号 | 字重 | 颜色 | 使用场景 |
|------|------|------|------|----------|
| Primary | 15-17px | 400-600 | textPrimary | 标题、正文 |
| Secondary | 13-15px | 400 | textSecondary | 副标题、说明文字 |
| Tertiary | 12px | 400 | textDisabled | 提示、辅助信息 |
| Numeric | 16px | 600 | primary | 评分、进度、数值 |

### 2.3 间距系统

#### 2.3.1 基础间距单位

```dart
// 基于 4px 网格系统
static const double spacing1 = 4;
static const double spacing2 = 8;
static const double spacing3 = 12;
static const double spacing4 = 16;
static const double spacing5 = 20;
static const double spacing6 = 24;
static const double spacing8 = 32;
static const double spacing10 = 40;
static const double spacing12 = 48;
```

#### 2.3.2 组件间距规范

| 位置 | 间距 | 说明 |
|------|------|------|
| 卡片内边距 | 16px | 卡片内容与边缘的距离 |
| 卡片间距 | 12px | 卡片之间的距离 |
| 列表项间距 | 12px | 列表项之间 |
| 按钮内边距 | 16x12px | 按钮的水平/垂直内边距 |
| 图标与文字间距 | 8px | 图标和文字的间距 |
| 页面边距 | 16px | 页面内容与屏幕边缘的距离 |

### 2.4 圆角系统

#### 2.4.1 圆角规范

```dart
// 圆角半径
static const double radiusXS = 4;    // 极小圆角 - 标签、徽章
static const double radiusSM = 6;    // 小圆角 - 按钮、输入框
static const double radiusMD = 8;    // 中圆角 - 卡片
static const double radiusLG = 12;   // 大圆角 - 大卡片、对话框
static const double radiusXL = 16;   // 超大圆角 - 模态窗
static const double radiusFull = 9999; // 全圆角 - 圆形按钮、头像
```

#### 2.4.2 使用场景

| 组件 | 圆角 | 说明 |
|------|------|------|
| 按钮 | 8px | 标准按钮 |
| 输入框 | 8px | 搜索框、表单输入 |
| 小卡片 | 12px | 视频卡片、列表项 |
| 大卡片 | 16px | 推荐卡片、Banner |
| 对话框 | 16px | 弹窗、对话框 |
| 头像 | 50% | 圆形头像 |
| 标签 | 4px | 状态标签、徽章 |

### 2.5 阴影系统

#### 2.5.1 阴影规范

```dart
// 浅色阴影
static const List<BoxShadow> shadowSm = [
  BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 4,
    offset: Offset(0, 1),
  ),
];

static const List<BoxShadow> shadowMd = [
  BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  ),
  BoxShadow(
    color: Color(0x06000000),
    blurRadius: 4,
    offset: Offset(0, 1),
  ),
];

static const List<BoxShadow> shadowLg = [
  BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  ),
  BoxShadow(
    color: Color(0x06000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  ),
];

// 悬浮卡片阴影
static const List<BoxShadow> shadowFloating = [
  BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 24,
    offset: Offset(0, 8),
  ),
];
```

#### 2.5.2 使用场景

| 组件 | 阴影 | 说明 |
|------|------|------|
| 按钮 | shadowSm | 轻微抬起感 |
| 卡片 | shadowMd | 标准卡片 |
| 悬浮按钮 | shadowLg | 强调悬浮 |
| 对话框/弹窗 | shadowFloating | 最深层级 |
| 按下状态 | none | 无阴影 |

### 2.6 图标系统

#### 2.6.1 图标库

使用 **Lucide Icons** 作为主要图标库：

```dart
// 导航图标
LucideIcons.home          // 首页
LucideIcons.search        // 搜索
LucideIcons.tv            // 直播
LucideIcons.user          // 我的
LucideIcons.history       // 历史

// 功能图标
LucideIcons.play          // 播放
LucideIcons.pause         // 暂停
LucideIcons.download      // 下载
LucideIcons.star          // 收藏
LucideIcons.share         // 分享
LucideIcons.settings      // 设置
LucideIcons.bell          // 通知
LucideIcons.clock         // 历史/时间
LucideIcons.refreshCw     // 刷新
LucideIcons.moreVertical  // 更多
LucideIcons.filter        // 筛选
LucideIcons.x             // 关闭

// 状态图标
LucideIcons.check         // 成功
LucideIcons.alertCircle   // 警告
LucideIcons.xCircle       // 错误
LucideIcons.info          // 信息
```

#### 2.6.2 图标尺寸

```dart
static const double iconXS = 14;   // 极小图标 - 标签内
static const double iconSM = 16;   // 小图标 - 按钮内
static const double iconMD = 20;   // 标准图标 - 导航、列表
static const double iconLG = 24;   // 大图标 - 功能入口
static const double iconXL = 32;   // 超大图标 - 首页功能入口
static const double icon2XL = 48;  // 特大图标 - 空状态
```

#### 2.6.3 首页功能图标配色

| 功能 | 渐变 | 图标颜色 |
|------|------|----------|
| 电视剧 | 蓝色渐变 | 白色 |
| 电影 | 紫色渐变 | 白色 |
| 综艺 | 粉色渐变 | 白色 |
| 动漫 | 绿色渐变 | 白色 |
| 纪录片 | 黄色渐变 | 白色 |

---

## 3. 组件规范

### 3.1 顶部导航栏 (AppBar)

#### 3.1.1 结构规范

```
┌─────────────────────────────────────┐
│ [返回]  [    标题/搜索框    ]  [操作] │
└─────────────────────────────────────┘
```

| 位置 | 元素 | 尺寸 | 说明 |
|------|------|------|------|
| 左侧 | 返回箭头 | 20x20 | 可选，二级页面显示 |
| 中间 | 标题/搜索框 | 自适应 | 页面标题或搜索入口 |
| 右侧 | 操作图标 | 20x20 | 1-2 个操作图标 |

#### 3.1.2 高度规范

- 标准高度：56px (不含状态栏)
- 包含状态栏：88px (iPhone) / 80px (Android)
- 大标题模式：96px

#### 3.1.3 页面顶栏类型

见 `UI_ANALYSIS_REPORT.md` 第 10 节详细清单

### 3.2 底部导航栏 (TabBar)

#### 3.2.1 结构

```
┌─────────────────────────────────────┐
│  [影视]    [探索]    [直播]    [我的]  │
└─────────────────────────────────────┘
```

#### 3.2.2 规格

- 高度：83px (包含底部安全区) / 56px (不含)
- 图标尺寸：24x24
- 文字大小：10-12px
- 选中态颜色：primary (#6366F1)
- 未选中态颜色：textSecondary

#### 3.2.3 选中态效果

- 图标颜色变为主题色
- 文字颜色变为主题色
- 可添加顶部指示线 (2px 高)

### 3.3 按钮

#### 3.3.1 类型

```dart
// Primary Button - 主按钮
ShadButton(
  child: Text('播放'),
  onPressed: () {},
)

// Secondary Button - 次按钮
ShadButton.secondary(
  child: Text('收藏'),
  onPressed: () {},
)

// Outline Button - 描边按钮
ShadButton.outline(
  child: Text('取消'),
  onPressed: () {},
)

// Ghost Button - 幽灵按钮
ShadButton.ghost(
  child: Text('换一换'),
  onPressed: () {},
)

// Destructive Button - 危险按钮
ShadButton.destructive(
  child: Text('删除'),
  onPressed: () {},
)

// Link Button - 链接按钮
ShadButton.link(
  child: Text('查看更多'),
  onPressed: () {},
)
```

#### 3.3.2 尺寸

| 尺寸 | 高度 | 内边距 | 字号 | 使用场景 |
|------|------|--------|------|----------|
| Small | 36px | 12x16px | 14px | 列表页操作 |
| Medium | 44px | 12x20px | 15px | 标准按钮 |
| Large | 52px | 16x24px | 16px | 主要操作、播放页 |

#### 3.3.3 圆角

- 标准圆角：8px
- 全圆角：50% (胶囊形)

### 3.4 搜索框

#### 3.4.1 规格

```dart
// 标准搜索框
ShadInput(
  placeholder: Text('搜索剧集、演员、导演'),
  prefixIcon: Icon(LucideIcons.search, size: 20),
  height: 40,
)
```

- 高度：40px
- 背景色：surface
- 边框：1px border
- 圆角：8px
- 内边距：12px

#### 3.4.2 状态

| 状态 | 样式 |
|------|------|
| 默认 | border 边框 |
| 聚焦 | primary 边框，2px |
| 禁用 | border 边框，50% 透明度 |

### 3.5 卡片

#### 3.5.1 视频卡片

```
┌─────────────────┐
│                 │
│     封面图      │
│                 │
│   [播放进度条]  │
├─────────────────┤
│  剧名 (1 行)     │
│  副标题 (1 行)   │
└─────────────────┘
```

**规格**:
- 宽度：自适应 (Grid 布局)
- 高度：240-280px
- 圆角：12px
- 阴影：shadowMd
- 间距：12px

**封面图**:
- 宽高比：16:9 或 3:4
- 圆角：12px (顶部)

**进度条**:
- 高度：3px
- 颜色：primary
- 位置：封面图底部

**文字信息**:
- 标题：15px, 600, 1 行截断
- 副标题：13px, 400, textSecondary

#### 3.5.2 Banner 卡片 (大推荐卡)

```
┌─────────────────────────────────────┐
│                                     │
│            全屏 Banner 图             │
│                                     │
│  ▓▓▓▓▓ 剧名和简介 (底部渐变遮罩) ▓▓▓  │
└─────────────────────────────────────┘
```

**规格**:
- 宽度：100% - 32px (页面边距)
- 高度：180-220px
- 圆角：16px
- 阴影：shadowLg

#### 3.5.3 功能卡片 (我的页面)

```
┌─────────────────────────────────────┐
│  [图标]  功能名称             [>]  │
│         功能描述                    │
└─────────────────────────────────────┘
```

**规格**:
- 高度：72px
- 圆角：12px
- 图标尺寸：24x24
- 右侧箭头：16x16

### 3.6 列表项

#### 3.6.1 标准列表项

```
┌─────────────────────────────────────┐
│ [图标/海报]  标题              [操作] │
│             副标题                  │
└─────────────────────────────────────┘
```

**规格**:
- 高度：72px
- 图标尺寸：48x48 (圆角 8px)
- 标题：15px, 600
- 副标题：13px, textSecondary

#### 3.6.2 设置列表项

```
┌─────────────────────────────────────┐
│  设置项名称                    [开关] │
└─────────────────────────────────────┘
```

**规格**:
- 高度：56px
- 文字：15px
- 开关：ShadSwitch

### 3.7 标签 (Chip)

#### 3.7.1 规格

```dart
// 普通标签
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(4),
    border: Border.all(color: border),
  ),
  child: Text('4K', style: TextStyle(fontSize: 12)),
)
```

- 高度：28px
- 圆角：4px
- 字号：12px
- 内边距：6x12px

#### 3.7.2 状态标签

| 状态 | 背景色 | 文字色 | 边框色 |
|------|--------|--------|--------|
| 正常 | #DCFCE7 | #166534 | #86EFAC |
| 警告 | #FEF3C7 | #92400E | #FCD34D |
| 危险 | #FEE2E2 | #991B1B | #FCA5A5 |
| 信息 | #DBEAFE | #1E40AF | #93C5FD |

### 3.8 进度条

#### 3.8.1 播放进度条

```dart
ShadSlider(
  value: progress,
  onChanged: (value) {},
  height: 4,
  activeColor: primary,
  inactiveColor: border,
)
```

**规格**:
- 高度：4px
- 圆角：2px
- 滑块尺寸：12x12 (圆形)
- 滑块颜色：primary

#### 3.8.2 缓冲进度条

- 高度：3px
- 颜色：primary (30% 透明度)
- 动画：线性无限循环

### 3.9 对话框

#### 3.9.1 确认对话框

```
┌─────────────────────────────────────┐
│              标题                    │
│                                      │
│  内容描述内容内容描述内容内容描述    │
│                                      │
│     [取消]          [确认]          │
└─────────────────────────────────────┘
```

**规格**:
- 宽度：320px
- 圆角：16px
- 内边距：24px
- 阴影：shadowFloating

### 3.10 开关 (Switch)

#### 3.10.1 规格

```dart
ShadSwitch(
  value: enabled,
  onChanged: (value) {},
)
```

- 宽度：44px
- 高度：26px
- 开启颜色：primary
- 关闭颜色：border
- 滑块直径：22px

---

## 4. 页面布局模板

### 4.1 首页布局 (Home)

```dart
Scaffold(
  body: CustomScrollView(
    slivers: [
      // 1. 顶部搜索区 (高度：56px)
      SliverToBoxAdapter(
        child: SearchBarSection(),
      ),
      
      // 2. 分类切换 Tab (高度：44px)
      SliverToBoxAdapter(
        child: CategoryTabs(),
      ),
      
      // 3. 大推荐 Banner (高度：200px)
      SliverToBoxAdapter(
        child: HeroBanner(),
      ),
      
      // 4. 快捷入口 (高度：80px)
      SliverToBoxAdapter(
        child: QuickActions(),
      ),
      
      // 5. 继续观看 (高度：200px)
      SliverToBoxAdapter(
        child: ContinueWatching(),
      ),
      
      // 6. 源状态监控 (高度：120px)
      SliverToBoxAdapter(
        child: SourceStatus(),
      ),
    ],
  ),
  bottomNavigationBar: BottomNavBar(),
)
```

### 4.2 列表页布局 (List)

```dart
Scaffold(
  appBar: AppBar(
    title: Text('探索'),
    actions: [IconButton(icon: Icon(LucideIcons.clock), onPressed: () {})],
  ),
  body: Row(
    children: [
      // 左侧分类栏 (宽度：100px)
      SizedBox(
        width: 100,
        child: CategorySidebar(),
      ),
      // 右侧内容区
      Expanded(
        child: CustomScrollView(
          slivers: [
            // 搜索/筛选区
            SliverToBoxAdapter(child: FilterSection()),
            // 视频列表
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(...),
            ),
          ],
        ),
      ),
    ],
  ),
  bottomNavigationBar: BottomNavBar(),
)
```

### 4.3 详情页布局 (Detail)

```dart
Scaffold(
  body: CustomScrollView(
    slivers: [
      // 1. 海报和标题信息
      SliverToBoxAdapter(
        child: HeroSection(
          poster: posterUrl,
          title: title,
          tags: tags,
          rating: rating,
        ),
      ),
      
      // 2. 操作按钮区
      SliverToBoxAdapter(
        child: ActionButtons(
          onPlay: () {},
          onFavorite: () {},
          onDownload: () {},
        ),
      ),
      
      // 3. 简介 Tab
      SliverToBoxAdapter(
        child: ShadTabs(...),
      ),
      
      // 4. 选集列表
      SliverToBoxAdapter(
        child: EpisodeGrid(),
      ),
      
      // 5. 相关推荐
      SliverToBoxAdapter(
        child: RelatedVideos(),
      ),
    ],
  ),
)
```

### 4.4 播放页布局 (Player)

```dart
Scaffold(
  body: Column(
    children: [
      // 1. 播放器窗口 (16:9)
      AspectRatio(
        aspectRatio: 16 / 9,
        child: VideoPlayer(),
      ),
      
      // 2. 功能 Tabs
      Expanded(
        child: ShadTabs(
          tabs: ['播放源', '清晰度', '字幕', '设置'],
          contents: [...],
        ),
      ),
      
      // 3. 源列表/选集
      Container(
        height: 200,
        child: SourceList(),
      ),
    ],
  ),
)
```

### 4.5 我的页面布局 (Profile)

```dart
Scaffold(
  body: CustomScrollView(
    slivers: [
      // 1. 用户信息区 (高度：120px)
      SliverToBoxAdapter(
        child: UserInfoSection(
          avatar: avatarUrl,
          nickname: nickname,
          vipLevel: vipLevel,
        ),
      ),
      
      // 2. VIP 卡片 (高度：140px)
      SliverToBoxAdapter(
        child: VipCard(),
      ),
      
      // 3. 数据统计 (高度：80px)
      SliverToBoxAdapter(
        child: StatsSection(
          history: 12,
          favorite: 24,
          download: 8,
        ),
      ),
      
      // 4. 功能列表
      SliverList(
        delegate: SliverChildListDelegate([
          SettingItem(icon: Icons.history, title: '播放历史', onTap: () {}),
          SettingItem(icon: Icons.star, title: '我的收藏', onTap: () {}),
          SettingItem(icon: Icons.download, title: '我的下载', onTap: () {}),
          SettingItem(icon: Icons.settings, title: '设置', onTap: () {}),
          SettingItem(icon: Icons.info, title: '关于', onTap: () {}),
        ]),
      ),
    ],
  ),
  bottomNavigationBar: BottomNavBar(),
)
```

---

## 5. 导航系统

### 5.1 路由配置

```dart
final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: [
    // 主框架 (底部导航)
    GoRoute(
      path: '/home',
      builder: (context, state) => MainLayout(),
      routes: [
        GoRoute(path: 'film', builder: (context, state) => FilmPage()),
        GoRoute(path: 'explore', builder: (context, state) => ExplorePage()),
        GoRoute(path: 'live', builder: (context, state) => LivePage()),
        GoRoute(path: 'profile', builder: (context, state) => ProfilePage()),
      ],
    ),
    
    // 二级页面
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) => VideoDetailPage(),
    ),
    GoRoute(
      path: '/player/:id',
      builder: (context, state) => PlayerPage(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => HistoryPage(),
    ),
    GoRoute(
      path: '/favorite',
      builder: (context, state) => FavoritePage(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => SearchPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => SettingsPage(),
    ),
  ],
);
```

### 5.2 导航动画

- 页面进入：slideRight (300ms)
- 页面退出：slideLeft (300ms)
- Tab 切换：fade (200ms)

---

## 6. 动效规范

### 6.1 过渡动画

| 动作 | 类型 | 时长 | 曲线 |
|------|------|------|------|
| 页面进入 | Slide Right | 300ms | Ease Out |
| 页面退出 | Slide Left | 300ms | Ease In |
| 卡片展开 | Scale Up | 250ms | Spring |
| 卡片收起 | Scale Down | 250ms | Spring |
| 按钮按下 | Scale Down | 100ms | Ease Out |
| 列表项出现 | Fade In Up | 200ms | Ease Out |

### 6.2 加载动画

- Loading Spinner: 旋转圆形 (1s 循环)
- Shimmer: 渐变扫光 (1.5s 循环)
- Pull Refresh: 弹性下拉

### 6.3 反馈动画

| 反馈类型 | 动画 | 时长 |
|----------|------|------|
| 成功 | Check Scale Up | 300ms |
| 错误 | Shake | 400ms |
| 点赞 | Heart Pulse | 600ms |
| 收藏 | Star Fill | 300ms |

---

## 7. 暗色模式适配

### 7.1 颜色映射

| 亮色 | 暗色 |
|------|------|
| #FFFFFF (background) | #0F172A |
| #F8FAFC (surface) | #1E293B |
| #1E293B (textPrimary) | #F1F5F9 |
| #64748B (textSecondary) | #94A3B8 |
| #E2E8F0 (border) | #334155 |

### 7.2 特殊适配

- 图片：降低亮度 10%
- 阴影：增加透明度和模糊半径
- 图标：使用半透明白色
- 渐变：降低饱和度

---

## 8. 参考文件

- [UI 分析报告](./../../UI_ANALYSIS_REPORT.md) - 详细的 UI 设计分析
- [需求文档](./requirements.md) - 功能需求说明
- [技术设计](./design.md) - 技术架构设计
- [shadcn_ui 快速开始](./shadcn-ui-quickstart.md) - UI 组件库使用指南

---

## 9. 验收标准

### 9.1 视觉还原度

- 颜色系统：与设计稿误差不超过 5%
- 字体层级：清晰可辨，层级分明
- 间距系统：统一遵循 4px 网格
- 圆角阴影：符合设计规范

### 9.2 交互体验

- 点击热区：最小 44x44px
- 动画流畅：60fps
- 响应时间：<300ms
- 手势支持：滑动、双击、长按

### 9.3 兼容性

- iOS 14.0+ 完整支持
- Android 8.0+ 完整支持
- 全面屏/刘海屏适配
- 横竖屏适配

### 9.4 性能指标

- 首屏渲染时间 <1.5s
- 页面切换 <300ms
- 列表滚动 60fps
- 内存占用 <200MB

---

**文档版本**: 1.0.0  
**创建日期**: 2026-06-04  
**最后更新**: 2026-06-04
