---
phase: 03-modify
plan: 01
type: execute
wave: 3
depends_on:
  - 02-learn
files_modified:
  - fullscreen_window/pubspec.yaml
  - fullscreen_window/macos/Classes/FullscreenWindowPlugin.h
  - fullscreen_window/macos/Classes/FullscreenWindowPlugin.m
autonomous: true
requirements:
  - MODIFY-01
  - MODIFY-02
  - MODIFY-03
  - MODIFY-04
  - MODIFY-05
must_haves:
  truths:
    - "pubspec.yaml 的 SDK 约束适配 Dart 3.x"
    - "macOS 原生插件文件创建并实现 setFullScreen 和 getScreenSize"
    - "pubspec.yaml 正确注册 macos 平台"
  artifacts:
    - "fullscreen_window/pubspec.yaml (更新后)"
    - "fullscreen_window/macos/Classes/FullscreenWindowPlugin.h"
    - "fullscreen_window/macos/Classes/FullscreenWindowPlugin.m"
  key_links:
    - "NSWindow.toggleFullScreen API"
    - "FlutterPlugin 协议"
    - "MethodChannel 通信"
---

<objective>
为 fullscreen_window 添加 macOS 原生全屏支持，更新 SDK 约束适配 Dart 3.x。

Purpose: 填补 macOS 平台的原生实现空白。
Output: 完整的 macOS 原生插件实现，pubspec 平台注册。
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/research/ARCHITECTURE.md
@fullscreen_window/pubspec.yaml
@fullscreen_window/windows/
@fullscreen_window/linux/
</context>

<tasks>

<task type="auto" tdd="false">
  <name>Task 1: 更新 SDK 约束</name>
  <files>fullscreen_window/pubspec.yaml</files>
  <behavior>
    - 更新 Dart SDK 约束为 >=3.0.0 <4.0.0
    - 更新 Flutter SDK 约束（如需要）
    - 检查并更新依赖版本
  </behavior>
  <action>
    **1. 更新 SDK 约束:**

    将 `environment` 部分更新为：
    ```yaml
    environment:
      sdk: '>=3.0.0 <4.0.0'
      flutter: '>=3.10.0'
    ```

    **2. 检查依赖兼容性:**

    - `plugin_platform_interface: ^2.0.2` — 保持不变
    - `web: ^1.0.0` — 检查是否需要更新

    **3. 验证:**

    ```bash
    cd D:/demo_flutter_fullscreen/fullscreen_window && flutter pub get
    ```
  </action>
  <verify>
    <automated>cd D:/demo_flutter_fullscreen/fullscreen_window && flutter pub get 2>&1 | grep -q "Got dependencies" && echo "PASS" || echo "FAIL"</automated>
  </verify>
  <done>
    1. SDK 约束更新为 Dart 3.x
    2. flutter pub get 成功
    3. 无废弃 API 警告
  </done>
</task>

<task type="auto" tdd="false">
  <name>Task 2: 创建 macOS 原生插件头文件</name>
  <files>fullscreen_window/macos/Classes/FullscreenWindowPlugin.h</files>
  <behavior>
    - 创建 ObjC 头文件
    - 声明 FlutterPlugin 协议
    - 声明方法调用处理器
  </behavior>
  <action>
    **创建头文件:**

    ```objc
    #import <Flutter/Flutter.h>

    @interface FullscreenWindowPlugin : NSObject <FlutterPlugin>
    @end
    ```

    **文件路径:** `fullscreen_window/macos/Classes/FullscreenWindowPlugin.h`
  </action>
  <verify>
    <automated>ls D:/demo_flutter_fullscreen/fullscreen_window/macos/Classes/FullscreenWindowPlugin.h && echo "PASS" || echo "FAIL"</automated>
  </verify>
  <done>
    1. 头文件创建成功
    2. 声明了 FlutterPlugin 协议
    3. 文件路径正确
  </done>
</task>

<task type="auto" tdd="false">
  <name>Task 3: 实现 macOS 原生插件</name>
  <files>fullscreen_window/macos/Classes/FullscreenWindowPlugin.m</files>
  <behavior>
    - 实现 FlutterPlugin 协议的 registerWithRegistrar 方法
    - 实现 handleMethodCall:result 方法
    - 实现 setFullScreen: 使用 NSWindow.toggleFullScreen
    - 实现 getScreenSize: 使用 NSScreen.frame × backingScaleFactor
    - 处理错误情况（无主窗口等）
  </behavior>
  <action>
    **创建实现文件:**

    ```objc
    #import "FullscreenWindowPlugin.h"

    @implementation FullscreenWindowPlugin

    + (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
      FlutterMethodChannel *channel = [FlutterMethodChannel
          methodChannelWithName:@"fullscreen_window"
                binaryMessenger:[registrar messenger]];
      FullscreenWindowPlugin *instance = [[FullscreenWindowPlugin alloc] init];
      [registrar addMethodCallDelegate:instance channel:channel];
    }

    - (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
      if ([@"setFullScreen" isEqualToString:call.method]) {
        [self setFullScreen:call result:result];
      } else if ([@"getScreenSize" isEqualToString:call.method]) {
        [self getScreenSize:call result:result];
      } else {
        result(FlutterMethodNotImplemented);
      }
    }

    - (void)setFullScreen:(FlutterMethodCall *)call result:(FlutterResult)result {
      NSWindow *window = [NSApp mainWindow];
      if (!window) {
        result([FlutterError errorWithCode:@"NO_WINDOW"
                                   message:@"No main window found"
                                   details:nil]);
        return;
      }

      BOOL isFullScreen = [call.arguments boolValue];
      BOOL currentlyFullScreen = (window.styleMask & NSWindowStyleMaskFullScreen) != 0;

      if (isFullScreen != currentlyFullScreen) {
        [window toggleFullScreen:nil];
      }

      result(nil);
    }

    - (void)getScreenSize:(FlutterMethodCall *)call result:(FlutterResult)result {
      NSScreen *screen = [NSScreen mainScreen];
      if (!screen) {
        result([FlutterError errorWithCode:@"NO_SCREEN"
                                   message:@"No screen found"
                                   details:nil]);
        return;
      }

      NSRect frame = screen.frame;
      CGFloat scale = screen.backingScaleFactor;

      NSDictionary *size = @{
        @"width": @(frame.size.width * scale),
        @"height": @(frame.size.height * scale),
      };

      result(size);
    }

    @end
    ```

    **文件路径:** `fullscreen_window/macos/Classes/FullscreenWindowPlugin.m`
  </action>
  <verify>
    <automated>ls D:/demo_flutter_fullscreen/fullscreen_window/macos/Classes/FullscreenWindowPlugin.m && echo "PASS" || echo "FAIL"</automated>
  </verify>
  <done>
    1. 实现文件创建成功
    2. 实现了 registerWithRegistrar 方法
    3. 实现了 handleMethodCall:result 方法
    4. 实现了 setFullScreen 使用 NSWindow.toggleFullScreen
    5. 实现了 getScreenSize 使用 NSScreen.frame × backingScaleFactor
    6. 处理了错误情况
  </done>
</task>

<task type="auto" tdd="false">
  <name>Task 4: 注册 macOS 平台到 pubspec</name>
  <files>fullscreen_window/pubspec.yaml</files>
  <behavior>
    - 在 plugin.platforms 部分添加 macos 平台声明
    - 指定 pluginClass 为 FullscreenWindowPlugin
    - 验证 YAML 格式正确
  </behavior>
  <action>
    **添加 macOS 平台声明:**

    在 `flutter.plugin.platforms` 部分添加：
    ```yaml
    macos:
      pluginClass: FullscreenWindowPlugin
    ```

    **完整 platforms 部分示例:**
    ```yaml
    flutter:
      plugin:
        platforms:
          android:
            dartPluginClass: FullScreenWindowAndroid
          ios:
            dartPluginClass: FullScreenWindowAndroid
          linux:
            pluginClass: FullscreenWindowPlugin
          macos:
            pluginClass: FullscreenWindowPlugin
          web:
            pluginClass: FullScreenWindowWeb
            fileName: fullscreen_window_web.dart
          windows:
            pluginClass: FullscreenWindowPluginCApi
    ```
  </action>
  <verify>
    <automated>grep -A 2 "macos:" D:/demo_flutter_fullscreen/fullscreen_window/pubspec.yaml | grep -q "pluginClass" && echo "PASS" || echo "FAIL"</automated>
  </verify>
  <done>
    1. macOS 平台声明添加到 pubspec.yaml
    2. pluginClass 正确指向 FullscreenWindowPlugin
    3. YAML 格式正确
  </done>
</task>

</tasks>

<verification>
1. pubspec.yaml SDK 约束适配 Dart 3.x
2. macOS 原生插件文件创建并实现
3. pubspec.yaml 正确注册 macos 平台
4. flutter pub get 成功
</verification>

<success_criteria>
1. SDK 约束更新为 Dart 3.x
2. FullscreenWindowPlugin.h 创建并声明 FlutterPlugin 协议
3. FullscreenWindowPlugin.m 实现 setFullScreen 和 getScreenSize
4. pubspec.yaml 正确注册 macos 平台
5. flutter pub get 无错误
</success_criteria>

<output>
Create `.planning/phases/03-modify/03-SUMMARY.md` when done
</output>
