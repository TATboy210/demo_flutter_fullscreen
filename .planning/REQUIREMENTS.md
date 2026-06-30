# Requirements — fullscreen_window macOS 支持扩展

**Date:** 2026-06-30
**Source:** 用户需求 + 架构分析

## v1 Requirements

### Phase 1: 解包 (UNPACK)

- [ ] **UNPACK-01**: 从 pub cache 复制 fullscreen_window 1.2.1 源码到 `fullscreen_window/` 目录
- [ ] **UNPACK-02**: 更新 demo_fullscreen/pubspec.yaml 使用本地 path 引用
- [ ] **UNPACK-03**: 验证 flutter pub get 成功，现有功能不受影响

### Phase 2: 学习 (LEARN)

- [ ] **LEARN-01**: 理解联邦插件四层架构（App API → Platform Interface → MethodChannel → Platform Impl）
- [ ] **LEARN-02**: 理解 Windows C++ 原生实现（Win32 API）
- [ ] **LEARN-03**: 理解 Linux C 原生实现（GTK）
- [ ] **LEARN-04**: 理解 Web/Android Dart 实现
- [ ] **LEARN-05**: 确认 macOS 缺失原生实现的问题

### Phase 3: 修改 (MODIFY)

- [ ] **MODIFY-01**: 更新 pubspec.yaml 的 Dart SDK 约束适配 Dart 3.x
- [ ] **MODIFY-02**: 创建 macos/Classes/FullscreenWindowPlugin.h
- [ ] **MODIFY-03**: 创建 macos/Classes/FullscreenWindowPlugin.m（setFullScreen + getScreenSize）
- [ ] **MODIFY-04**: 更新 pubspec.yaml 添加 macos 平台注册
- [ ] **MODIFY-05**: 检查并修复废弃 API 调用

### Phase 4: 测试 (TEST)

- [ ] **TEST-01**: demo app 添加第三个按钮（修改后的 fullscreen_window）
- [ ] **TEST-02**: 第三个按钮展示完整功能（API对比、差异、依赖、日志）
- [ ] **TEST-03**: flutter analyze 零错误
- [ ] **TEST-04**: Windows 功能回归测试
- [ ] **TEST-05**: Linux 功能回归测试（如有环境）
- [ ] **TEST-06**: macOS 功能测试（如有环境）

### Phase 5: 封包 (PACKAGE)

- [ ] **PACKAGE-01**: 更新版本号（1.2.1 → 1.3.0 或类似）
- [ ] **PACKAGE-02**: 更新 CHANGELOG.md
- [ ] **PACKAGE-03**: 更新 README.md（说明 macOS 支持）
- [ ] **PACKAGE-04**: 清理无用文件和注释
- [ ] **PACKAGE-05**: flutter analyze 零错误零警告

### Phase 6: 发布 (PUBLISH)

- [ ] **PUBLISH-01**: 创建 GitHub 新仓库
- [ ] **PUBLISH-02**: 推送修改后的源码到 GitHub
- [ ] **PUBLISH-03**: demo_fullscreen 改用 git URL 依赖
- [ ] **PUBLISH-04**: 验证 git URL 依赖正常工作

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| UNPACK-01~03 | Phase 1 | Pending |
| LEARN-01~05 | Phase 2 | Pending |
| MODIFY-01~05 | Phase 3 | Pending |
| TEST-01~06 | Phase 4 | Pending |
| PACKAGE-01~05 | Phase 5 | Pending |
| PUBLISH-01~04 | Phase 6 | Pending |

---

*Generated: 2026-06-30*
