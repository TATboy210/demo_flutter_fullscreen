# Roadmap — fullscreen_window macOS 支持扩展

**Mode:** mvp
**Phases:** 6
**Requirements:** 28 total

---

## Phase 1: 解包 (Unpack)

**Goal:** 从 pub cache 复制 fullscreen_window 1.2.1 源码到本地，配置为本地依赖。
**Status:** ⏳ Pending

### Requirements

| ID | Requirement | Status |
|----|-------------|--------|
| UNPACK-01 | 从 pub cache 复制源码到 fullscreen_window/ | ⏳ Pending |
| UNPACK-02 | demo_fullscreen 使用 path 引用 | ⏳ Pending |
| UNPACK-03 | flutter pub get 验证 | ⏳ Pending |

### Deliverables

- `fullscreen_window/` — 完整源码副本
- `demo_fullscreen/pubspec.yaml` — path 依赖配置

---

## Phase 2: 学习 (Learn)

**Goal:** 深度理解 fullscreen_window 的联邦插件架构和各平台实现。
**Status:** ⏳ Pending

### Requirements

| ID | Requirement | Status |
|----|-------------|--------|
| LEARN-01 | 理解联邦插件四层架构 | ⏳ Pending |
| LEARN-02 | 理解 Windows C++ 实现 | ⏳ Pending |
| LEARN-03 | 理解 Linux C 实现 | ⏳ Pending |
| LEARN-04 | 理解 Web/Android Dart 实现 | ⏳ Pending |
| LEARN-05 | 确认 macOS 缺失问题 | ⏳ Pending |

### Deliverables

- 学习笔记或文档更新（可复用现有 research/ 文档）

---

## Phase 3: 修改 (Modify)

**Goal:** 为 fullscreen_window 添加 macOS 原生全屏支持，适配 Dart 3.x SDK。
**Status:** ⏳ Pending

### Requirements

| ID | Requirement | Status |
|----|-------------|--------|
| MODIFY-01 | 更新 SDK 约束适配 Dart 3.x | ⏳ Pending |
| MODIFY-02 | 创建 macOS ObjC 头文件 | ⏳ Pending |
| MODIFY-03 | 实现 setFullScreen + getScreenSize | ⏳ Pending |
| MODIFY-04 | 注册 macos 平台到 pubspec | ⏳ Pending |
| MODIFY-05 | 修复废弃 API 调用 | ⏳ Pending |

### Deliverables

- `fullscreen_window/macos/Classes/FullscreenWindowPlugin.h`
- `fullscreen_window/macos/Classes/FullscreenWindowPlugin.m`
- `fullscreen_window/pubspec.yaml` — macOS 平台注册 + SDK 更新

---

## Phase 4: 测试 (Test)

**Goal:** 在 demo app 中添加第三个按钮，完整测试修改后的包。
**Status:** ⏳ Pending

### Requirements

| ID | Requirement | Status |
|----|-------------|--------|
| TEST-01 | 添加第三个按钮（修改后的 fullscreen_window） | ⏳ Pending |
| TEST-02 | 展示完整功能（API对比、差异、依赖、日志） | ⏳ Pending |
| TEST-03 | flutter analyze 零错误 | ⏳ Pending |
| TEST-04 | Windows 功能回归测试 | ⏳ Pending |
| TEST-05 | Linux 功能回归测试 | ⏳ Pending |
| TEST-06 | macOS 功能测试 | ⏳ Pending |

### Deliverables

- `demo_fullscreen/lib/main.dart` — 三按钮对比页面

---

## Phase 5: 封包 (Package)

**Goal:** 清理修改后的包，更新版本号和文档。
**Status:** ⏳ Pending

### Requirements

| ID | Requirement | Status |
|----|-------------|--------|
| PACKAGE-01 | 更新版本号 | ⏳ Pending |
| PACKAGE-02 | 更新 CHANGELOG.md | ⏳ Pending |
| PACKAGE-03 | 更新 README.md | ⏳ Pending |
| PACKAGE-04 | 清理无用文件 | ⏳ Pending |
| PACKAGE-05 | flutter analyze 零警告 | ⏳ Pending |

### Deliverables

- 更新的 CHANGELOG.md
- 更新的 README.md
- 清理后的源码

---

## Phase 6: 发布 (Publish)

**Goal:** 推送到 GitHub 新仓库，demo app 改用 git URL 依赖。
**Status:** ⏳ Pending

### Requirements

| ID | Requirement | Status |
|----|-------------|--------|
| PUBLISH-01 | 创建 GitHub 新仓库 | ⏳ Pending |
| PUBLISH-02 | 推送源码到 GitHub | ⏳ Pending |
| PUBLISH-03 | demo_fullscreen 改用 git URL | ⏳ Pending |
| PUBLISH-04 | 验证 git URL 依赖正常 | ⏳ Pending |

### Deliverables

- GitHub 仓库 URL
- 更新的 demo_fullscreen/pubspec.yaml

---

## Phase Summary

| Phase | Requirements | Status |
|-------|-------------|--------|
| 1: 解包 | 3 | ⏳ Pending |
| 2: 学习 | 5 | ⏳ Pending |
| 3: 修改 | 5 | ⏳ Pending |
| 4: 测试 | 6 | ⏳ Pending |
| 5: 封包 | 5 | ⏳ Pending |
| 6: 发布 | 4 | ⏳ Pending |

**Progress: 0/28 requirements complete (0%)**

---

## Dependency Chain

```
Phase 1: 解包
  └─ Phase 2: 学习
       └─ Phase 3: 修改
            └─ Phase 4: 测试
                 └─ Phase 5: 封包
                      └─ Phase 6: 发布
```

---

*Generated: 2026-06-30*
