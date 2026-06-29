# Demo Fullscreen — 双包对比测试

## What This Is

一个 Flutter 桌面应用，用于对比学习 `fullscreen_window` 和 `flutter_fullscreen` 两个全屏插件的 API 行为差异。通过同时接入两个包，在同一页面展示它们的调用方式、返回值、平台支持等差异，帮助开发者理解并选型。

## Core Value

在同一环境中直观对比两个全屏插件的 API 行为和平台表现差异。

## Requirements

### Validated

<!-- 从现有代码推断 -->

- ✓ Flutter Material 3 应用框架 — existing
- ✓ fullscreen_window 集成与全屏切换 — existing
- ✓ 桌面平台支持 (Windows/Linux/macOS) — existing
- ✓ 基础 UI：全屏按钮、状态图标、中英文提示 — existing

### Active

- [ ] 接入 flutter_fullscreen 包作为第二对比对象
- [ ] 重写 main.dart 为双包对比测试页面
- [ ] 页面同时展示两个包的 API 调用按钮和状态
- [ ] 显示 API 行为差异（调用方式、返回值、平台支持）
- [ ] 记录两个包在当前平台的实际表现

### Out of Scope

- 生产级应用架构 — 这是学习/测试项目
- 移动端 (iOS/Android) 适配 — 专注桌面平台
- 状态管理方案 (Provider/Riverpod) — 单文件足够
- 国际化 — 中文硬编码即可

## Context

**技术背景：**
- 当前项目使用 `fullscreen_window: ^1.2.1`，提供 `FullScreenWindow.setFullScreen(bool)` 静态方法
- `flutter_fullscreen` 是另一个全屏插件，API 设计可能不同
- 两个包的平台实现、返回值、错误处理方式可能存在差异

**学习目标：**
- 理解两个包各自的 API 签名和调用模式
- 对比平台支持范围（哪些 OS 有原生实现）
- 观察实际全屏效果差异（AppBar 处理、窗口边框等）
- 为后续选型提供实证依据

**代码库状态：**
- 单文件架构 (`lib/main.dart`，83 行)
- 无测试覆盖（现有测试是模板残留）
- 无错误处理（异步调用未 try/catch）

## Constraints

- **Tech stack**: Flutter + Dart，不引入额外框架
- **Platform**: 桌面平台 (Windows/Linux/macOS)，不考虑 Web/Mobile
- **Scope**: 单文件重写，不拆分模块
- **Dependencies**: 只添加 flutter_fullscreen，不引入其他新依赖

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| 双包同页面对比 | 直观展示差异，避免切换项目对比 | — Pending |
| 单文件架构 | 学习项目不需要模块化 | — Pending |
| 重写而非新建 | 用户明确要求替换现有 demo | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-06-29 after initialization*
