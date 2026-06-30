# Research — Phase 3: 修改

**Date:** 2026-06-30
**Status:** Complete

## 研究目标

确定如何为 fullscreen_window 添加 macOS 原生全屏支持。

## macOS 原生插件开发

### FlutterPlugin 协议 (ObjC)

```objc
#import <Flutter/Flutter.h>

@interface MyPlugin : NSObject <FlutterPlugin>
@end

// 实现
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel = [FlutterMethodChannel
      methodChannelWithName:@"my_channel"
            binaryMessenger:[registrar messenger]];
  MyPlugin *instance = [[MyPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}
```

### NSWindow.toggleFullScreen API

```objc
// 进入/退出全屏
[window toggleFullScreen:nil];

// 检测当前状态
BOOL isFullScreen = (window.styleMask & NSWindowStyleMaskFullScreen) != 0;
```

### NSScreen 获取屏幕尺寸

```objc
NSScreen *screen = [NSScreen mainScreen];
NSRect frame = screen.frame;
CGFloat scale = screen.backingScaleFactor;
CGFloat width = frame.size.width * scale;   // 物理像素
CGFloat height = frame.size.height * scale;
```

## pubspec.yaml 注册

```yaml
flutter:
  plugin:
    platforms:
      macos:
        pluginClass: FullscreenWindowPlugin
```

## 文件结构

```
fullscreen_window/
└── macos/
    └── Classes/
        ├── FullscreenWindowPlugin.h
        └── FullscreenWindowPlugin.m
```

## 结论

Phase 3 的修改任务明确：创建 ObjC 头文件和实现文件，注册 macOS 平台。代码模式与 Windows/Linux 一致。

## 参考

- Flutter macOS 插件: https://flutter.dev/development/platform-integration/macos/c-interop
- NSWindow API: https://developer.apple.com/documentation/appkit/nswindow
