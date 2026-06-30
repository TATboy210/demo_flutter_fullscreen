# Roadmap — fullscreen_window 解包优化 + macOS 支持

**Mode:** mvp
**Phases:** 3
**Requirements:** 12 total

---

## Phase 1: 架构分析与源码 Fork

**Goal:** 深度解构 fullscreen_window 联邦插件架构，Fork 源码到本地，适配 Dart 3.x SDK。
**Status:** ✅ Complete

### Requirements

| ID | Requirement | Status |
|----|-------------|--------|
| ARCH-01 | 理解 fullscreen_window 5 平台源码级架构 | ✅ Done |
| ARCH-02 | 理解 MethodChannel 通信机制 | ✅ Done |
| ARCH-03 | 理解 Windows/Linux 原生全屏实现 | ✅ Done |
| FORK-01 | Fork fullscreen_window-1.2.1 源码到本地 | ✅ Done |
| SDK-01 | 更新 SDK 约束适配 Dart 3.x | ✅ Done |
| SDK-02 | flutter pub get 验证依赖解析 | ✅ Done |

### Deliverables

- `fullscreen_window/` — 完整源码 fork
- `fullscreen_window/pubspec.yaml` — SDK 约束已更新

---

## Phase 2: macOS 原生支持

**Goal:** 为 fullscreen_window 添加 macOS 原生全屏支持，使用 NSWindow.toggleFullScreen API。
**Status:** ✅ Complete

### Requirements

| ID | Requirement | Status |
|----|-------------|--------|
| MAC-01 | 创建 macOS ObjC 插件类 | ✅ Done |
| MAC-02 | 实现 setFullScreen (NSWindow.toggleFullScreen) | ✅ Done |
| MAC-03 | 实现 getScreenSize (NSScreen × backingScaleFactor) | ✅ Done |
| REG-01 | pubspec.yaml 注册 macos 平台 | ✅ Done |
| REG-02 | demo_fullscreen 引用本地路径 | ✅ Done |

### Deliverables

- `fullscreen_window/macos/Classes/FullscreenWindowPlugin.h` — ObjC 头文件
- `fullscreen_window/macos/Classes/FullscreenWindowPlugin.m` — ObjC 实现
- `fullscreen_window/pubspec.yaml` — macOS 平台注册
- `demo_fullscreen/pubspec.yaml` — 本地路径引用

---

## Phase 3: 验证与质量保证

**Goal:** 验证 fork 后的代码质量、功能正确性，更新项目文档。
**Status:** ⏳ In Progress (2/3)

### Requirements

| ID | Requirement | Status |
|----|-------------|--------|
| VER-01 | flutter analyze 零问题通过 | ✅ Done |
| VER-02 | Windows 功能回归测试 | ⏳ Pending |
| VER-03 | 更新 ROADMAP/STATE 反映新方向 | ⏳ In Progress |

### Deliverables

- 更新的 ROADMAP.md（本文件）
- 更新的 STATE.md

---

## Phase Summary

| Phase | Requirements | Status |
|-------|-------------|--------|
| 1: 架构分析与源码 Fork | 6 | ✅ Complete |
| 2: macOS 原生支持 | 5 | ✅ Complete |
| 3: 验证与质量保证 | 3 | ⏳ In Progress (2/3) |

**Progress: 10/12 requirements complete (83%)**

---

## Dependency Chain

```
Phase 1: 架构分析 + Fork + SDK 适配
  └─ Phase 2: macOS 原生代码 + 平台注册
       └─ Phase 3: 验证 + 文档更新
```

---

*Generated: 2026-06-30*
