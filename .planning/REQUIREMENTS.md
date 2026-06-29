# Requirements — Demo Fullscreen 双包对比测试

**Date:** 2026-06-29
**Source:** Research findings + user scoping

## v1 Requirements

### 全屏控制 (CTRL)

- [ ] **CTRL-01**: 用户可以点击按钮使用 fullscreen_window 进入/退出全屏
- [ ] **CTRL-02**: 用户可以点击按钮使用 flutter_fullscreen 进入/退出全屏
- [ ] **CTRL-03**: 页面显示当前全屏状态（每个包各自的状态指示器）
- [ ] **CTRL-04**: 两个包的全屏操作互不干扰（独立调用）

### API 对比 (API)

- [ ] **API-01**: 页面展示两个包的 API 方法签名对比
- [ ] **API-02**: 页面展示两个包的返回值差异（Future<void> vs void, 有无状态回读）
- [ ] **API-03**: 页面展示平台支持矩阵（Windows/Linux/macOS/iOS/Android/Web）
- [ ] **API-04**: 页面展示两个包的通信架构差异（MethodChannel 单向 vs 双向监听）

### 依赖信息 (DEP)

- [ ] **DEP-01**: 页面展示两个包的依赖树（直接依赖和传递依赖）
- [ ] **DEP-02**: 页面展示两个包的体积差异
- [ ] **DEP-03**: 页面展示已知陷阱列表（从 PITFALLS.md 提取关键项）

### 调用日志 (LOG)

- [ ] **LOG-01**: 页面记录每次 API 调用的时间戳和方法名
- [ ] **LOG-02**: 页面显示调用结果（成功/失败/异常）
- [ ] **LOG-03**: 用户可以清空调用日志
- [ ] **LOG-04**: 日志区域可滚动，最新的在最上面

### UI/UX (UI)

- [ ] **UI-01**: 页面使用 Material 3 主题，与现有应用一致
- [ ] **UI-02**: 页面布局清晰，两个包的控制区域左右或上下分明
- [ ] **UI-03**: 中文界面，与现有应用一致

## v2 Requirements (Deferred)

- [ ] 状态监听回调展示（flutter_fullscreen 的 FullScreenListener）
- [ ] 多窗口场景测试
- [ ] Web 平台测试
- [ ] 自动化测试用例

## Out of Scope

- 生产级架构 — 这是学习/测试项目
- 移动端适配 — 专注桌面平台
- 状态管理方案 — 单文件足够
- 国际化 — 中文硬编码即可

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| CTRL-01 | Phase 1: Core | Pending |
| CTRL-02 | Phase 1: Core | Pending |
| CTRL-03 | Phase 1: Core | Pending |
| CTRL-04 | Phase 1: Core | Pending |
| API-01 | Phase 2: Enhancement | Pending |
| API-02 | Phase 2: Enhancement | Pending |
| API-03 | Phase 2: Enhancement | Pending |
| API-04 | Phase 2: Enhancement | Pending |
| DEP-01 | Phase 2: Enhancement | Pending |
| DEP-02 | Phase 2: Enhancement | Pending |
| DEP-03 | Phase 2: Enhancement | Pending |
| LOG-01 | Phase 2: Enhancement | Pending |
| LOG-02 | Phase 2: Enhancement | Pending |
| LOG-03 | Phase 2: Enhancement | Pending |
| LOG-04 | Phase 2: Enhancement | Pending |
| UI-01 | Phase 1: Core | Pending |
| UI-02 | Phase 1: Core | Pending |
| UI-03 | Phase 1: Core | Pending |

---

*Generated: 2026-06-29*
