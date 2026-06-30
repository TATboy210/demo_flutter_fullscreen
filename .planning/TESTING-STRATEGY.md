# 跨平台测试策略

## 问题

用户只有 Windows 系统，无法直接测试 Linux 和 macOS 平台。

## 解决方案

使用 **Mock 平台实现** + **平台接口测试** 的方式，在 Windows 上模拟所有平台行为。

---

## 测试架构

```
┌─────────────────────────────────────────────────────────────────┐
│                      测试金字塔                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                    ┌─────────────┐                              │
│                    │   E2E 测试   │  ← 需要实际平台 (可选)        │
│                    │  (手动验证)  │                              │
│                    └──────┬──────┘                              │
│                           │                                     │
│              ┌────────────┴────────────┐                        │
│              │     集成测试 (Widget)     │  ← Flutter test       │
│              │   demo_fullscreen/test   │                        │
│              └────────────┬────────────┘                        │
│                           │                                     │
│         ┌─────────────────┴─────────────────┐                   │
│         │         单元测试 (Mock)             │  ← 核心测试       │
│         │  fullscreen_window/test            │                   │
│         │  - 平台接口测试                     │                   │
│         │  - 跨平台模拟测试                   │                   │
│         │  - 依赖兼容性测试                   │                   │
│         └───────────────────────────────────┘                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 测试类型

### 1. 平台接口测试 (已实现)

**文件:** `fullscreen_window/test/fullscreen_window_mock_test.dart`

**测试内容:**
- ✅ 平台接口基础测试
- ✅ Token 验证机制
- ✅ 跨平台模拟测试 (通用)
- ✅ macOS 原版测试 (无实现 - 预期抛出异常)
- ✅ macOS 修改版测试 (有实现 - 预期正常工作)
- ✅ Windows 测试
- ✅ Linux 测试
- ✅ 错误处理测试

**测试结果:** 14/14 通过

### 2. 依赖兼容性测试 (待实现)

**文件:** `fullscreen_window/test/dependency_test.dart`

**测试内容:**
- plugin_platform_interface 版本兼容性
- web 包版本兼容性
- SDK 约束验证
- 传递依赖检查

### 3. Widget 测试 (待实现)

**文件:** `demo_fullscreen/test/widget_test.dart`

**测试内容:**
- 三个按钮渲染
- 状态切换
- 日志记录
- API 对比面板

---

## Mock 平台实现

### Mock 类层级

```
MockFullscreenWindowPlatform (基类)
├── MockMacOSOriginalPlatform   (模拟原版 macOS - 无实现)
├── MockMacOSModifiedPlatform   (模拟修改版 macOS - 有实现)
├── MockWindowsPlatform         (模拟 Windows)
└── MockLinuxPlatform           (模拟 Linux)
```

### 各平台模拟行为

| 平台 | setFullScreen | getScreenSize |
|------|---------------|---------------|
| macOS 原版 | ❌ MissingPluginException | ❌ MissingPluginException |
| macOS 修改版 | ✅ NSWindow.toggleFullScreen | ✅ NSScreen.frame × backingScaleFactor |
| Windows | ✅ SetWindowLong + ShowWindow | ✅ GetWindowRect |
| Linux | ✅ gtk_window_fullscreen | ✅ gdk_monitor_get_geometry |

---

## 运行测试

### 运行所有单元测试
```bash
cd D:/demo_flutter_fullscreen/fullscreen_window
flutter test
```

### 运行特定测试文件
```bash
flutter test test/fullscreen_window_mock_test.dart
```

### 运行带覆盖率的测试
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 测试覆盖矩阵

| 测试场景 | Windows | Linux | macOS 原版 | macOS 修改版 |
|----------|---------|-------|-----------|-------------|
| setFullScreen 成功 | ✅ | ✅ | ❌ (预期) | ✅ |
| setFullScreen 失败 | - | - | ✅ (预期) | - |
| getScreenSize 成功 | ✅ | ✅ | ❌ (预期) | ✅ |
| getScreenSize Retina | - | - | - | ✅ |
| MissingPluginException | - | - | ✅ | - |
| 错误恢复 | ✅ | ✅ | ✅ | ✅ |

---

## 优势

1. **无需实际平台** — 在 Windows 上测试所有平台行为
2. **快速反馈** — 单元测试运行速度快
3. **可重复** — 测试结果一致
4. **覆盖全面** — 包括正常和异常场景
5. **易于维护** — Mock 类清晰分离

---

## 局限性

1. **无法测试原生代码** — Mock 只模拟 Dart 层行为
2. **无法测试系统集成** — 需要实际平台验证
3. **无法测试性能** — 需要实际平台测量

---

## 建议

### 短期 (当前)
- ✅ 使用 Mock 测试验证逻辑正确性
- ✅ 使用虚拟环境在 demo 中模拟不同平台

### 中期 (可选)
- 使用 GitHub Actions 在 Linux/macOS 上运行测试
- 使用 Docker 容器测试 Linux 行为

### 长期 (可选)
- 在实际 macOS 设备上验证原生实现
- 在实际 Linux 设备上验证 GTK 集成

---

*Last updated: 2026-06-30*
