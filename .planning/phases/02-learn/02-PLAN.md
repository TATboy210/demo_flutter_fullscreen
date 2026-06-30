---
phase: 02-learn
plan: 01
type: research
wave: 2
depends_on:
  - 01-unpack
files_modified: []
autonomous: true
requirements:
  - LEARN-01
  - LEARN-02
  - LEARN-03
  - LEARN-04
  - LEARN-05
must_haves:
  truths:
    - "理解联邦插件四层架构的工作原理"
    - "理解各平台原生实现的差异"
    - "确认 macOS 缺失原生实现的问题"
  artifacts:
    - "学习笔记或文档更新"
  key_links:
    - "现有研究文档: .planning/research/"
    - "源码: fullscreen_window/lib/"
---

<objective>
深度学习 fullscreen_window 的联邦插件架构，理解各平台实现差异，为后续修改奠定基础。

Purpose: 掌握架构知识，确保修改时遵循既有模式。
Output: 学习笔记（可复用现有 research/ 文档）。
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/research/ARCHITECTURE.md
@.planning/research/FEATURES.md
@.planning/research/PITFALLS.md
@fullscreen_window/lib/
</context>

<tasks>

<task type="auto" tdd="false">
  <name>Task 1: 学习联邦插件四层架构</name>
  <files>fullscreen_window/lib/</files>
  <behavior>
    - 阅读 fullscreen_window.dart 理解 App-facing API 层
    - 阅读 fullscreen_window_platform_interface.dart 理解 Platform Interface 层
    - 阅读 fullscreen_window_method_channel.dart 理解 MethodChannel 层
    - 阅读 fullscreen_window_android.dart 和 fullscreen_window_web.dart 理解平台实现层
    - 记录四层架构的关键设计模式
  </behavior>
  <action>
    **学习要点：**

    1. **App-facing API 层** (`fullscreen_window.dart`):
       - 全局变量 `FullScreenWindow` 类型为平台接口
       - 用户直接调用 `FullScreenWindow.setFullScreen(bool)`
       - 无需实例化，静态调用风格

    2. **Platform Interface 层** (`fullscreen_window_platform_interface.dart`):
       - 抽象类 `FullScreenWindowPlatform` 继承 `PlatformInterface`
       - 使用 `PlatformInterface.verify()` token 验证
       - 单例模式 `_instance`
       - 默认方法抛出 `UnimplementedError`

    3. **MethodChannel 层** (`fullscreen_window_method_channel.dart`):
       - 通道名: `"fullscreen_window"`
       - 方法: `setFullScreen` (参数: bool isFullScreen)
       - 方法: `getScreenSize` (参数: BuildContext? context)
       - 桌面平台的默认实现

    4. **Platform Impl 层**:
       - Android/iOS: 使用 `SystemChrome.setEnabledSystemUIOverlayMode`
       - Web: 使用 JS interop `requestFullscreen()` / `exitFullscreen()`
       - Windows: 原生 C++ (Win32 API)
       - Linux: 原生 C (GTK)
       - macOS: **缺失**（pubspec 声明但无实现文件）
  </action>
  <verify>
    <automated>ls D:/demo_flutter_fullscreen/fullscreen_window/lib/*.dart | wc -l</automated>
  </verify>
  <done>
    1. 理解四层架构的设计模式
    2. 理解 Platform Interface 的 token 验证机制
    3. 理解 MethodChannel 的通信协议
    4. 理解各平台实现的差异
  </done>
</task>

<task type="auto" tdd="false">
  <name>Task 2: 学习原生平台实现</name>
  <files>fullscreen_window/windows/, fullscreen_window/linux/</files>
  <behavior>
    - 阅读 Windows C++ 实现，理解 Win32 API 调用
    - 阅读 Linux C 实现，理解 GTK API 调用
    - 对比两个平台的实现差异
    - 记录 macOS 实现应遵循的模式
  </behavior>
  <action>
    **Windows 实现要点：**
    - 使用 `SetWindowLong` 保存/恢复窗口样式
    - 使用 `ShowWindow` + `SC_MAXIMIZE` / `SC_RESTORE`
    - 使用 `SetWindowPlacement` 管理窗口位置
    - 已知问题：退出全屏时 Flutter 布局异常（需要 `SWP_FRAMECHANGED`）

    **Linux 实现要点：**
    - 使用 `gtk_window_fullscreen()` / `gtk_window_unfullscreen()`
    - 使用 `gdk_monitor_get_geometry()` 获取屏幕尺寸
    - GTK 信号处理全屏状态变化

    **macOS 实现应遵循的模式：**
    - 使用 `NSWindow.toggleFullScreen:nil`
    - 使用 `NSWindowStyleMaskFullScreen` 检测当前状态
    - 使用 `NSScreen.frame` × `backingScaleFactor` 获取物理像素尺寸
    - 遵循 FlutterPlugin 协议注册方法调用处理器
  </action>
  <verify>
    <automated>ls D:/demo_flutter_fullscreen/fullscreen_window/windows/*.cpp && ls D:/demo_flutter_fullscreen/fullscreen_window/linux/*.cc && echo "PASS: native files exist" || echo "FAIL"</automated>
  </verify>
  <done>
    1. 理解 Windows C++ 实现的 Win32 API 调用
    2. 理解 Linux C 实现的 GTK API 调用
    3. 明确 macOS 实现应遵循的模式
  </done>
</task>

<task type="auto" tdd="false">
  <name>Task 3: 确认 macOS 缺失问题</name>
  <files>fullscreen_window/pubspec.yaml</files>
  <behavior>
    - 检查 pubspec.yaml 中的 macos 平台声明
    - 检查 macos/ 目录是否存在原生实现文件
    - 确认缺失问题的严重性
  </behavior>
  <action>
    **检查步骤：**

    1. 查看 pubspec.yaml 中的 plugin.platforms 部分
    2. 检查是否有 macos 平台声明
    3. 检查 macos/Classes/ 目录是否存在 .h/.m/.swift 文件
    4. 确认：pubspec 声明了 macOS 支持，但实际没有原生实现

    **问题影响：**
    - 在 macOS 上调用 `FullScreenWindow.setFullScreen()` 会抛出 `MissingPluginException`
    - 用户体验：应用崩溃或功能失效
    - 需要添加原生实现来修复
  </action>
  <verify>
    <automated>grep -q "macos" D:/demo_flutter_fullscreen/fullscreen_window/pubspec.yaml && echo "PASS: macos declared" || echo "FAIL"</automated>
  </verify>
  <done>
    1. 确认 pubspec.yaml 声明了 macOS 支持
    2. 确认 macos/ 目录缺失原生实现文件
    3. 理解问题的严重性和修复方案
  </done>
</task>

</tasks>

<verification>
1. 理解联邦插件四层架构
2. 理解各平台原生实现的差异
3. 确认 macOS 缺失问题
4. 明确 macOS 实现应遵循的模式
</verification>

<success_criteria>
1. 能够解释联邦插件四层架构的工作原理
2. 能够说明 Windows/Linux 原生实现的差异
3. 确认 macOS 缺失原生实现的问题
4. 明确 macOS 实现需要遵循的模式和 API
</success_criteria>

<output>
Create `.planning/phases/02-learn/02-SUMMARY.md` when done
</output>
