# 记忆快照

本文件保存当前会话中稳定有效的协作记忆，作为项目文档使用。

## 说明

- 工作区当前不存在独立的 `.monkeycode/MEMORY.md` 文件
- 本文档记录当前任务过程中已经明确的长期协作约束与偏好

## 当前记忆

### 输出与协作

- 日期: 2026-06-03
- Context: 当前项目协作约束
- Instructions:
  - 所有回复使用简体中文
  - 直接持续执行任务，优先落代码和验证结果
  - 代码修改后执行分析和测试进行回归验证

### 项目执行方式

- 日期: 2026-06-03
- Context: zyfun Flutter 移动端实现任务
- Instructions:
  - 严格按照 `/workspace/.monkeycode/specs/zyfun-flutter-mobile/tasklist.md` 的顺序推进
  - 从未完成项继续执行，并同步更新任务状态
  - 前端技术方案使用 Flutter
  - UI 组件库使用 `shadcn_ui`
  - 目标平台为 Android 和 iOS
  - 前端功能尽量与原桌面版 1:1 还原

### 发布与预览

- 日期: 2026-06-03
- Context: 当前项目交付方式
- Instructions:
  - 优先产出可安装包供用户下载查看
  - GitHub Release 用于分发预览 APK
