# Roadmap — Demo Fullscreen 双包对比测试

**Mode:** mvp
**Phases:** 2
**Requirements:** 18 total

---

## Phase 1: Core — 双包全屏控制

**Goal:** 添加 flutter_fullscreen 依赖，重写 main.dart 为双包对比页面，实现两个包各自的全屏切换和状态显示。
**Mode:** mvp

### Requirements

| ID | Requirement |
|----|-------------|
| CTRL-01 | 用户可以点击按钮使用 fullscreen_window 进入/退出全屏 |
| CTRL-02 | 用户可以点击按钮使用 flutter_fullscreen 进入/退出全屏 |
| CTRL-03 | 页面显示当前全屏状态（每个包各自的状态指示器） |
| CTRL-04 | 两个包的全屏操作互不干扰（独立调用） |
| UI-01 | 页面使用 Material 3 主题，与现有应用一致 |
| UI-02 | 页面布局清晰，两个包的控制区域左右或上下分明 |
| UI-03 | 中文界面，与现有应用一致 |

### Success Criteria

1. 用户点击 "fullscreen_window 全屏" 按钮后窗口进入全屏，状态指示器更新为"全屏中"
2. 用户点击 "flutter_fullscreen 全屏" 按钮后窗口进入全屏，状态指示器更新为"全屏中"
3. 两个包的按钮和状态指示器独立工作，互不影响
4. 页面使用 Material 3 主题，中文界面，布局左右分明
5. flutter_fullscreen 的 `ensureInitialized()` 在 main() 中正确调用

### Deliverables

- `pubspec.yaml`: 添加 `flutter_fullscreen` 依赖
- `lib/main.dart`: 重写为双包对比页面，含全屏按钮和状态指示器

---

## Phase 2: Enhancement — API 对比、依赖信息、调用日志

**Goal:** 添加 API 签名对比面板、依赖信息展示、调用日志记录功能，完成全部对比信息展示。
**Mode:** mvp

### Requirements

| ID | Requirement |
|----|-------------|
| API-01 | 页面展示两个包的 API 方法签名对比 |
| API-02 | 页面展示两个包的返回值差异 |
| API-03 | 页面展示平台支持矩阵 |
| API-04 | 页面展示两个包的通信架构差异 |
| DEP-01 | 页面展示两个包的依赖树 |
| DEP-02 | 页面展示两个包的体积差异 |
| DEP-03 | 页面展示已知陷阱列表 |
| LOG-01 | 页面记录每次 API 调用的时间戳和方法名 |
| LOG-02 | 页面显示调用结果（成功/失败/异常） |
| LOG-03 | 用户可以清空调用日志 |
| LOG-04 | 日志区域可滚动，最新的在最上面 |

### Success Criteria

1. 页面包含可折叠的 API 对比区域，展示方法签名、返回值、平台支持、架构差异
2. 页面包含依赖信息区域，展示依赖树、体积、已知陷阱
3. 每次全屏操作后日志区域显示带时间戳的调用记录和结果
4. 用户点击"清空日志"按钮后日志区域变为空
5. 日志区域可滚动，最新记录在最上方

### Deliverables

- `lib/main.dart`: 扩展为包含 API 对比面板、依赖信息区、调用日志区

---

## Phase Summary

| Phase | Requirements | Key Deliverable |
|-------|-------------|-----------------|
| 1: Core | 7 (CTRL-01..04, UI-01..03) | 双包全屏切换与状态显示 |
| 2: Enhancement | 11 (API-01..04, DEP-01..03, LOG-01..04) | API 对比、依赖信息、调用日志 |

**Total: 18/18 requirements mapped (100%)**

---

## Dependency Chain

```
Phase 1 (Core)
  └─ 全屏切换 + 状态显示
       └─ Phase 2 (Enhancement)
            └─ API 对比 + 依赖信息 + 调用日志
```

Phase 2 depends on Phase 1 (needs working fullscreen buttons to generate logs and test API behavior).

---

*Generated: 2026-06-29*
