# Requirements — fullscreen_window 解包优化 + macOS 支持

**Date:** 2026-06-30
**Source:** 架构分析 + 用户方向确认

## v1 Requirements

### 源码解包 (FORK)

- [ ] **FORK-01**: 从 pub cache 复制 fullscreen_window 1.2.1 源码到项目本地目录
- [ ] **FORK-02**: 更新 demo_fullscreen/pubspec.yaml 使用本地 path 引用
- [ ] **FORK-03**: 验证 flutter pub get 成功，现有功能不受影响

### SDK 适配 (SDK)

- [ ] **SDK-01**: 更新 pubspec.yaml 的 Dart SDK 约束适配 Dart 3.x
- [ ] **SDK-02**: 检查并修复废弃 API 调用
- [ ] **SDK-03**: 更新 analysis_options.yaml

### macOS 原生实现 (MAC)

- [ ] **MAC-01**: 创建 macos/Classes/FullscreenWindowPlugin.h
- [ ] **MAC-02**: 创建 macos/Classes/FullscreenWindowPlugin.m (setFullScreen + getScreenSize)
- [ ] **MAC-03**: 更新 pubspec.yaml 添加 macos 平台注册

### 验证 (VER)

- [ ] **VER-01**: flutter analyze 无错误
- [ ] **VER-02**: demo 应用功能正常
- [ ] **VER-03**: macOS 代码结构正确

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| FORK-01~03 | Phase 1 | Pending |
| SDK-01~03 | Phase 1 | Pending |
| MAC-01~03 | Phase 2 | Pending |
| VER-01~03 | Phase 3 | Pending |

---
*Generated: 2026-06-30*
