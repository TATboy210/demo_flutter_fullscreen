# fullscreen_window 依赖结构对比分析

## 版本对比

| 项目 | 原版 1.2.1 | 修改版 1.3.0 |
|------|-----------|-------------|
| SDK 约束 | `>=2.17.0 <3.0.0` | `>=3.0.0 <4.0.0` |
| Flutter 约束 | `>=2.10.0` | `>=3.10.0` |
| macOS 支持 | ❌ 声明但无实现 | ✅ 原生 ObjC 实现 |

---

## 依赖树对比

### 原版 1.2.1 依赖树

```
fullscreen_window 1.2.1
├── flutter (SDK)
├── flutter_web_plugins (SDK)
├── plugin_platform_interface ^2.0.2
└── web ^1.0.0

传递依赖: 0
原生代码: Windows (C++), Linux (C)
缺失平台: macOS (声明但无实现)
```

### 修改版 1.3.0 依赖树

```
fullscreen_window 1.3.0
├── flutter (SDK)
├── flutter_web_plugins (SDK)
├── plugin_platform_interface ^2.0.2
└── web ^1.0.0

传递依赖: 0
原生代码: Windows (C++), Linux (C), macOS (ObjC)
完整平台: ✅ 所有平台支持
```

---

## 平台实现对比图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          App-facing API 层                                  │
│                    fullscreen_window.dart                                   │
│              final FullScreenWindow = Platform.instance                     │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                       Platform Interface 层                                 │
│               fullscreen_window_platform_interface.dart                     │
│         - FullScreenWindowPlatform (抽象类)                                  │
│         - PlatformInterface.verify() token 验证                             │
│         - 单例模式 _instance                                                 │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        MethodChannel 层                                     │
│              fullscreen_window_method_channel.dart                          │
│         - 通道名: "fullscreen_window"                                       │
│         - 方法: setFullScreen, getScreenSize                                │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
                    ▼               ▼               ▼
┌───────────────────────┐ ┌───────────────────────┐ ┌───────────────────────┐
│    Windows (C++)      │ │     Linux (C)         │ │     macOS (ObjC)      │
│                       │ │                       │ │                       │
│ 原版: ✅ 已实现        │ │ 原版: ✅ 已实现        │ │ 原版: ❌ 未实现        │
│ 修改版: ✅ 已实现      │ │ 修改版: ✅ 已实现      │ │ 修改版: ✅ 已实现      │
│                       │ │                       │ │                       │
│ API:                  │ │ API:                  │ │ API:                  │
│ SetWindowLong         │ │ gtk_window_fullscreen │ │ NSWindow.             │
│ ShowWindow            │ │ gtk_window_unfullscreen│ │   toggleFullScreen    │
│ SetWindowPlacement    │ │ gdk_monitor_get_      │ │ NSScreen.frame ×      │
│                       │ │   geometry            │ │   backingScaleFactor  │
└───────────────────────┘ └───────────────────────┘ └───────────────────────┘

┌───────────────────────┐ ┌───────────────────────┐
│   Android/iOS (Dart)  │ │      Web (JS)         │
│                       │ │                       │
│ 原版: ✅ 已实现        │ │ 原版: ✅ 已实现        │
│ 修改版: ✅ 已实现      │ │ 修改版: ✅ 已实现      │
│                       │ │                       │
│ API:                  │ │ API:                  │
│ SystemChrome.         │ │ requestFullscreen()   │
│   setEnabledSystemUIMode│ │ exitFullscreen()     │
└───────────────────────┘ └───────────────────────┘
```

---

## pubspec.yaml 差异对比

### 1. SDK 约束差异

```yaml
# 原版 1.2.1
environment:
  sdk: '>=2.17.0 < 3.0.0'    # Dart 2.x
  flutter: ">=2.10.0"         # Flutter 2.x

# 修改版 1.3.0
environment:
  sdk: '>=3.0.0 <4.0.0'      # Dart 3.x
  flutter: ">=3.10.0"         # Flutter 3.x
```

**影响:**
- 原版支持 Dart 2.x，修改版仅支持 Dart 3.x
- 修改版使用了 Dart 3.x 的新特性

### 2. 平台声明差异

```yaml
# 原版 1.2.1
flutter:
  plugin:
    platforms:
      windows:
        pluginClass: FullscreenWindowPluginCApi
      linux:
        pluginClass: FullscreenWindowPlugin
      web:
        pluginClass: FullScreenWindowWeb
        fileName: fullscreen_window_web.dart
      android:
        dartPluginClass: FullScreenWindowAndroid
      ios:
        dartPluginClass: FullScreenWindowAndroid
      # ❌ macOS 未声明

# 修改版 1.3.0
flutter:
  plugin:
    platforms:
      windows:
        pluginClass: FullscreenWindowPluginCApi
      linux:
        pluginClass: FullscreenWindowPlugin
      web:
        pluginClass: FullScreenWindowWeb
        fileName: fullscreen_window_web.dart
      android:
        dartPluginClass: FullScreenWindowAndroid
      ios:
        dartPluginClass: FullScreenWindowAndroid
      macos:                          # ✅ 新增 macOS 声明
        pluginClass: FullscreenWindowPlugin
```

### 3. 依赖项对比

```yaml
# 两个版本的依赖完全相同
dependencies:
  flutter:
    sdk: flutter
  flutter_web_plugins:
    sdk: flutter
  plugin_platform_interface: ^2.0.2
  web: ^1.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

**结论:** 依赖项无变化，仅新增了 macOS 原生实现代码。

---

## 文件结构对比

### 原版 1.2.1 文件结构

```
fullscreen_window-1.2.1/
├── lib/
│   ├── fullscreen_window.dart
│   ├── fullscreen_window_android.dart
│   ├── fullscreen_window_method_channel.dart
│   ├── fullscreen_window_platform_interface.dart
│   └── fullscreen_window_web.dart
├── windows/
│   ├── CMakeLists.txt
│   ├── fullscreen_window_plugin.cpp
│   ├── fullscreen_window_plugin.h
│   └── ...
├── linux/
│   ├── CMakeLists.txt
│   ├── fullscreen_window_plugin.cc
│   └── ...
├── pubspec.yaml
└── README.md
```

### 修改版 1.3.0 文件结构

```
fullscreen_window-1.3.0/
├── lib/
│   ├── fullscreen_window.dart
│   ├── fullscreen_window_android.dart
│   ├── fullscreen_window_method_channel.dart
│   ├── fullscreen_window_platform_interface.dart
│   └── fullscreen_window_web.dart
├── windows/
│   ├── CMakeLists.txt
│   ├── fullscreen_window_plugin.cpp
│   ├── fullscreen_window_plugin.h
│   └── ...
├── linux/
│   ├── CMakeLists.txt
│   ├── fullscreen_window_plugin.cc
│   └── ...
├── macos/                              # ✅ 新增目录
│   └── Classes/
│       ├── FullscreenWindowPlugin.h    # ✅ 新增
│       └── FullscreenWindowPlugin.m    # ✅ 新增
├── pubspec.yaml
├── CHANGELOG.md
└── README.md
```

---

## 关键差异总结

### 1. 架构层面

| 维度 | 原版 1.2.1 | 修改版 1.3.0 |
|------|-----------|-------------|
| 插件类型 | 联邦插件 | 联邦插件 |
| 平台数量 | 5 个 (Win/Linux/Web/Android/iOS) | 6 个 (+macOS) |
| 原生实现 | 2 个 (Win/Linux) | 3 个 (+macOS) |
| Dart 实现 | 3 个 (Web/Android/iOS) | 3 个 (Web/Android/iOS) |

### 2. 实现方式对比

```
┌─────────────────────────────────────────────────────────────────┐
│                     平台实现方式对比                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Windows:  MethodChannel → C++ (Win32 API)                      │
│            └─ SetWindowLong, ShowWindow, SetWindowPlacement     │
│                                                                 │
│  Linux:    MethodChannel → C (GTK API)                          │
│            └─ gtk_window_fullscreen, gdk_monitor_get_geometry   │
│                                                                 │
│  macOS:    MethodChannel → ObjC (Cocoa API)  ← 新增             │
│            └─ NSWindow.toggleFullScreen, NSScreen.frame         │
│                                                                 │
│  Android:  Dart → SystemChrome.setEnabledSystemUIMode           │
│  iOS:      Dart → SystemChrome.setEnabledSystemUIMode           │
│  Web:      Dart → JS interop (requestFullscreen/exitFullscreen) │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 3. 问题分析

#### 原版 1.2.1 的问题

1. **macOS 缺失实现**
   - pubspec.yaml 声明了 `macos` 平台
   - 但 `macos/` 目录不存在
   - 运行时会抛出 `MissingPluginException`

2. **SDK 约束过旧**
   - `sdk: '>=2.17.0 < 3.0.0'` 不支持 Dart 3.x
   - 无法使用 Dart 3.x 的新特性

#### 修改版 1.3.0 的改进

1. **完整 macOS 支持**
   - 添加 `macos/Classes/FullscreenWindowPlugin.h/.m`
   - 使用 `NSWindow.toggleFullScreen` 实现全屏
   - 使用 `NSScreen.frame × backingScaleFactor` 获取屏幕尺寸

2. **SDK 约束更新**
   - `sdk: '>=3.0.0 <4.0.0'` 支持 Dart 3.x
   - `flutter: ">=3.10.0"` 支持最新 Flutter

3. **向后兼容**
   - 依赖项无变化
   - API 接口无变化
   - 现有代码无需修改

---

## 依赖复杂度对比

```
┌─────────────────────────────────────────────────────────────────┐
│                    依赖复杂度对比                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  原版 1.2.1:                                                    │
│  ┌─────────────────┐                                            │
│  │ fullscreen_window│                                            │
│  └────────┬────────┘                                            │
│           │                                                     │
│     ┌─────┴─────┐                                               │
│     │           │                                               │
│  ┌──┴──┐   ┌───┴───┐                                           │
│  │ SDK │   │ web ^1│                                             │
│  └─────┘   └───────┘                                            │
│                                                                 │
│  传递依赖: 0                                                    │
│  原生代码: 2 平台 (Win/Linux)                                    │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  修改版 1.3.0:                                                  │
│  ┌─────────────────┐                                            │
│  │ fullscreen_window│                                            │
│  └────────┬────────┘                                            │
│           │                                                     │
│     ┌─────┴─────┐                                               │
│     │           │                                               │
│  ┌──┴──┐   ┌───┴───┐                                           │
│  │ SDK │   │ web ^1│                                             │
│  └─────┘   └───────┘                                            │
│                                                                 │
│  传递依赖: 0 (无变化)                                            │
│  原生代码: 3 平台 (+macOS)                                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 结论

1. **依赖结构无变化** — 修改版保持了与原版相同的依赖树
2. **仅新增原生代码** — 添加了 macOS 的 ObjC 实现
3. **SDK 约束更新** — 支持 Dart 3.x 和 Flutter 3.x
4. **完全向后兼容** — 现有代码无需修改即可使用
5. **问题修复** — 解决了原版 macOS 缺失实现的问题
