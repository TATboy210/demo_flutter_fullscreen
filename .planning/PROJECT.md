# Demo Fullscreen — fullscreen_window macOS 支持扩展

## What This Is

从 pub.dev 获取 `fullscreen_window` 1.2.1 源码，深度学习其联邦插件架构，为其添加 macOS 原生全屏支持（NSWindow.toggleFullScreen），最终作为独立包发布到 GitHub。

## Core Value

为 fullscreen_window 添加 macOS 原生全屏支持，填补其平台覆盖空白，并作为独立依赖供后续项目使用。

## Workflow

```
1. 解包 → 从 pub cache 复制源码到本地
2. 学习 → 深度研究联邦插件架构（已有研究文档）
3. 修改 → 添加 macOS 原生实现 + SDK 适配
4. 测试 → demo app 三按钮对比测试
5. 封包 → 清理、版本号、changelog
6. 发布 → 推送到 GitHub，作为 git 依赖
```

## Requirements

### Validated

- ✓ Flutter Material 3 应用框架 — existing
- ✓ fullscreen_window 集成与全屏切换 — existing
- ✓ flutter_fullscreen 集成与全屏切换 — existing
- ✓ 桌面平台支持 (Windows/Linux/macOS) — existing
- ✓ 基础 UI：全屏按钮、状态图标、中英文提示 — existing
- ✓ 调用日志记录 — existing
- ✓ API 对比面板 — existing
- ✓ 依赖信息面板 — existing

### Active

- [ ] 从 pub cache 解包 fullscreen_window 1.2.1 源码
- [ ] 更新 SDK 约束适配 Dart 3.x
- [ ] 添加 macOS 原生全屏实现（NSWindow.toggleFullScreen）
- [ ] 添加 macOS getScreenSize 实现（NSScreen × backingScaleFactor）
- [ ] 注册 macOS 平台到 pubspec.yaml
- [ ] demo app 添加第三个按钮测试修改后的包
- [ ] 第三个按钮展示完整功能（API对比、差异、依赖、日志）
- [ ] flutter analyze 零错误
- [ ] Windows/Linux 功能回归测试
- [ ] 封包：清理、版本号、changelog
- [ ] 推送到 GitHub 新仓库
- [ ] demo_fullscreen 改用 git URL 依赖

### Out of Scope

- 生产级应用架构 — 这是学习/测试项目
- 移动端 (iOS/Android) 适配 — 专注桌面平台
- 发布到 pub.dev — 推送到 GitHub 即可
- Web 平台支持 — 专注桌面原生

## Context

**技术背景：**
- `fullscreen_window` 1.2.1 是联邦插件，支持 Windows (C++)、Linux (C)、Web (Dart)、Android/iOS (Dart)
- macOS 在 pubspec 中声明了支持，但实际没有原生实现文件（会抛 MissingPluginException）
- `flutter_fullscreen` 通过 window_manager 支持全平台，但依赖较重
- 已有完整的研究文档：架构分析、特性对比、陷阱清单

**学习目标：**
- 理解 Flutter 联邦插件的四层架构（App API → Platform Interface → MethodChannel → Platform Impl）
- 掌握 macOS 原生插件开发（ObjC/Swift + FlutterPlugin 协议）
- 对比两种全屏方案的 API 设计差异

**代码库状态：**
- demo_fullscreen: 单文件架构 (744 行)，包含双包对比 + 日志 + API 面板
- fullscreen_window (fork): 已有 macOS ObjC 实现，但基于旧的本地 fork
- 研究文档：5 份完整分析文档

## Constraints

- **Tech stack**: Flutter + Dart + ObjC（macOS 原生）
- **Platform**: 桌面平台 (Windows/Linux/macOS)
- **Scope**: 修改后的包作为独立 GitHub 仓库
- **Dependencies**: 不引入新依赖，保持 fullscreen_window 的轻量特性

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| ObjC 而非 Swift | 与现有 Windows/Linux 原生代码风格一致 | — Pending |
| NSWindow.toggleFullScreen | macOS 原生全屏 API，最简洁 | — Pending |
| GitHub 仓库发布 | 用户有 GitHub 账号，可创建新仓库 | — Pending |
| 三按钮对比 | 原始 vs flutter_fullscreen vs 修改后 | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

---

*Last updated: 2026-06-30*
