# Research — Phase 1: 解包

**Date:** 2026-06-30
**Status:** Complete

## 研究目标

确定如何从 pub cache 获取 fullscreen_window 1.2.1 源码并配置本地依赖。

## 发现

### 1. Pub Cache 路径

**Windows 路径：**
- `%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\fullscreen_window-1.2.1`
- 或 `%APPDATA%\Pub\Cache\hosted\pub.dev\fullscreen_window-1.2.1`

**查找方法：**
```bash
dart pub cache list
# 或
find "$LOCALAPPDATA/Pub/Cache" -name "fullscreen_window-1.2.1" -type d
```

### 2. 源码结构

fullscreen_window 1.2.1 包含：
- `lib/` — 5 个 Dart 文件（App API, Platform Interface, MethodChannel, Android, Web）
- `windows/` — C++ 原生实现（Win32 API）
- `linux/` — C 原生实现（GTK）
- `test/` — 测试文件
- `pubspec.yaml` — 包配置

### 3. 依赖配置

**当前状态：** demo_fullscreen/pubspec.yaml 已使用 path 引用
```yaml
fullscreen_window:
  path: ../fullscreen_window
```

**需要验证：** flutter pub get 成功执行

### 4. macOS 缺失问题

fullscreen_window 1.2.1 的 pubspec.yaml 声明了 macOS 支持，但实际没有原生实现文件。这是 Phase 3 需要修复的问题。

## 结论

Phase 1 的核心任务是从 pub cache 复制源码到本地，配置 path 依赖，验证 flutter pub get 成功。这是一个相对简单的操作阶段。

## 参考

- Pub Cache 文档: https://dart.dev/tools/pub/cmd/pub-cache
- Flutter 依赖管理: https://flutter.dev/development/packages-and-plugins/using-packages
