# Research — Phase 2: 学习

**Date:** 2026-06-30
**Status:** Complete
**Source:** 现有研究文档 + 源码分析

## 研究目标

深度理解 fullscreen_window 的联邦插件架构，为 Phase 3 的 macOS 实现奠定基础。

## 已有研究文档

### 核心文档（.planning/research/）

| 文档 | 内容 | 状态 |
|------|------|------|
| ARCHITECTURE.md | 联邦插件四层架构详解 | ✅ 可用 |
| FEATURES.md | API Surface + 平台支持矩阵 | ✅ 可用 |
| PITFALLS.md | 16 个已知陷阱 | ✅ 可用 |
| STACK.md | 技术栈分析 | ✅ 可用 |
| SUMMARY.md | 两包对比总结 | ✅ 可用 |

## 联邦插件四层架构

### Layer 1: App-facing API
- 文件: `fullscreen_window.dart`
- 全局变量 `FullScreenWindow` 类型为平台接口
- 用户直接调用 `FullScreenWindow.setFullScreen(bool)`
- 无需实例化，静态调用风格

### Layer 2: Platform Interface
- 文件: `fullscreen_window_platform_interface.dart`
- 抽象类 `FullScreenWindowPlatform` 继承 `PlatformInterface`
- 使用 `PlatformInterface.verify()` token 验证
- 单例模式 `_instance`
- 默认方法抛出 `UnimplementedError`

### Layer 3: MethodChannel
- 文件: `fullscreen_window_method_channel.dart`
- 通道名: `"fullscreen_window"`
- 方法: `setFullScreen` (参数: bool isFullScreen)
- 方法: `getScreenSize` (参数: BuildContext? context)
- 桌面平台的默认实现

### Layer 4: Platform Implementations
- Android/iOS: `fullscreen_window_android.dart` — SystemChrome
- Web: `fullscreen_window_web.dart` — JS interop
- Windows: `windows/fullscreen_window_plugin.cpp` — Win32 API
- Linux: `linux/fullscreen_window_plugin.cc` — GTK
- macOS: **缺失**（pubspec 声明但无实现文件）

## 各平台原生实现

### Windows (C++)
- 使用 `SetWindowLong` 保存/恢复窗口样式
- 使用 `ShowWindow` + `SC_MAXIMIZE` / `SC_RESTORE`
- 使用 `SetWindowPlacement` 管理窗口位置
- 已知问题：退出全屏时 Flutter 布局异常（需要 `SWP_FRAMECHANGED`）

### Linux (C)
- 使用 `gtk_window_fullscreen()` / `gtk_window_unfullscreen()`
- 使用 `gdk_monitor_get_geometry()` 获取屏幕尺寸
- GTK 信号处理全屏状态变化

### macOS（应遵循的模式）
- 使用 `NSWindow.toggleFullScreen:nil`
- 使用 `NSWindowStyleMaskFullScreen` 检测当前状态
- 使用 `NSScreen.frame` × `backingScaleFactor` 获取物理像素尺寸
- 遵循 FlutterPlugin 协议注册方法调用处理器

## macOS 缺失问题

**问题：** fullscreen_window 1.2.1 的 pubspec.yaml 声明了 macOS 支持，但实际没有原生实现文件。

**影响：** 在 macOS 上调用 `FullScreenWindow.setFullScreen()` 会抛出 `MissingPluginException`。

**修复方案：** Phase 3 将添加 macOS 原生实现。

## 结论

Phase 2 的学习目标可以通过现有研究文档完全覆盖。无需额外研究，直接进入 Phase 3 修改阶段。

## 参考

- 现有研究: `.planning/research/`
- 源码: `fullscreen_window/lib/`
- Windows 实现: `fullscreen_window/windows/`
- Linux 实现: `fullscreen_window/linux/`
