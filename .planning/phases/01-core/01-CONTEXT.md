# Phase 1: Core - Context

**Gathered:** 2026-06-30
**Status:** Ready for planning

<domain>
## Phase Boundary

添加 flutter_fullscreen 依赖，重写 main.dart 为双包对比页面，实现两个包各自的全屏切换和状态显示。包含 7 个需求：CTRL-01~04（全屏控制）、UI-01~03（界面要求）。

核心交付物：
- `pubspec.yaml`: 添加 flutter_fullscreen 依赖
- `lib/main.dart`: 双包全屏对比页面（按钮、状态指示器、独立控制）

</domain>

<decisions>
## Implementation Decisions

### 包初始化策略
- **D-01:** flutter_fullscreen 必须在 `main()` 中 `runApp()` 前调用 `FullScreen.ensureInitialized()`，否则抛出字符串异常
- **D-02:** fullscreen_window 无需初始化，平台实例在导入时解析
- **D-03:** `main()` 需为 `async`，先调用 `WidgetsFlutterBinding.ensureInitialized()` 再调用 `FullScreen.ensureInitialized()`

### 状态管理模式
- **D-04:** 使用 `setState()` 直接管理状态（单文件架构，无需状态管理库）
- **D-05:** 两个包各自维护独立的 `_fwFullscreen` / `_ffFullscreen` 布尔状态
- **D-06:** fullscreen_window 使用手动状态跟踪（该包无 `isFullScreen` getter）
- **D-07:** flutter_fullscreen 使用 FullScreenListener 监听器模式确认状态变化

### 错误处理与防抖
- **D-08:** fullscreen_window 使用 try-catch 包裹，失败时回滚状态并显示 SnackBar
- **D-09:** flutter_fullscreen 返回 void（fire-and-forget），无法 try-catch，依赖 listener 确认
- **D-10:** 两个包各自使用防抖锁（`_fwToggling` / `_ffToggling`）防止快速重复点击竞态
- **D-11:** flutter_fullscreen 设置 3 秒超时回退机制，listener 未触发时手动更新状态

### flutter_fullscreen Listener 实现
- **D-12:** 使用 `FullScreenListener` mixin 创建自定义监听器类
- **D-13:** 监听 `onWindowEnterFullScreen` 和 `onWindowLeaveFullScreen` 回调
- **D-14:** 回调中通过 `mounted` 检查后 `setState` 更新状态
- **D-15:** `dispose()` 中调用 `FullScreen.removeListener(_ffListener)` 清理监听器

### UI 布局
- **D-16:** 使用 Material 3 主题（`useMaterial3: true`, `ColorScheme.fromSeed`）
- **D-17:** 左右 Row 布局，各用 `Expanded` + `Card` 包裹控制区域
- **D-18:** 每个区域包含：包名标题、状态图标（64px）、状态文字、切换按钮
- **D-19:** 全屏时隐藏 AppBar 以获得真正全屏体验
- **D-20:** 中文标签：全屏中/窗口模式、进入全屏/退出全屏

### Windows 布局修复
- **D-21:** fullscreen_window 退出全屏后需延迟 150ms + `addPostFrameCallback` 强制布局重建
- **D-22:** 这是 Windows 平台特有的布局恢复问题

### Claude's Discretion
- 用户跳过了灰色区域讨论，所有决策从现有代码实现中提取
- 文件组织保持单文件（用户未要求拆分）
- 错误处理使用 SnackBar（用户未要求其他方式）

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### 研究文档
- `.planning/research/SUMMARY.md` — 两个全屏包的完整对比研究
- `.planning/research/PITFALLS.md` — 16 个已知陷阱及预防方案

### 代码库分析
- `.planning/codebase/CONVENTIONS.md` — 编码规范（命名、状态管理、主题）
- `.planning/codebase/STRUCTURE.md` — 项目结构（单文件架构、目录布局）
- `.planning/codebase/STACK.md` — 技术栈（Flutter SDK、依赖版本）

### 需求文档
- `.planning/REQUIREMENTS.md` — 18 个需求（Phase 1 包含 CTRL-01~04, UI-01~03）
- `.planning/ROADMAP.md` — 路线图（Phase 1 目标和交付物）

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `lib/main.dart` — 完整的双包对比页面（~744 行），包含所有 Phase 1 和 Phase 2 功能
- `LogEntry` 模型 — 已实现的调用日志数据类
- `_FfFullscreenListener` — flutter_fullscreen 监听器实现

### Established Patterns
- `setState()` 直接状态管理 — 无状态管理库，适合单文件架构
- `SnackBar` 错误提示 — 直接在 catch 块中显示
- 防抖锁模式 — `_fwToggling` / `_ffToggling` 布尔锁
- Card + ExpansionTile 面板模式 — 用于 API 对比和依赖信息展示

### Integration Points
- `main()` 函数 — flutter_fullscreen 初始化入口
- `initState()` — listener 注册
- `dispose()` — listener 清理
- `_toggleFwFullscreen()` / `_toggleFfFullscreen()` — 全屏切换方法

</code_context>

<specifics>
## Specific Ideas

- 用户选择了"继续讨论并重新计划"，但跳过了灰色区域讨论
- 现有代码已实现 Phase 1 全部需求，重新计划可能关注代码质量或架构改进
- 用户未提出特定的视觉或行为偏好

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 1-Core*
*Context gathered: 2026-06-30*
