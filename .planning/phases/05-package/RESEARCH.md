# Phase 5: 封包 (Package) — 研究文档

## 当前文件状态

### pubspec.yaml
```yaml
name: fullscreen_window
version: 1.2.1
environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"
```

**需要修改:**
- 版本号: `1.2.1` → `1.3.0`
- 原因: 添加 macOS 支持是新功能，遵循语义化版本

### CHANGELOG.md
当前内容:
```markdown
## 1.2.1

- refresh to upload to pub.dev (20250505)
- add 'Dart 3.x compatible' to description
- update SDK constraint to Dart 3.x

## 1.2.0

- try to fix iOS fullscreen not working (use SystemChrome.setEnabledSystemUIMode)
- update example
```

**需要修改:**
- 在开头添加 1.3.0 版本记录

### README.md
当前平台支持表:
```markdown
| Windows | Linux | Web | Android | iOS |
| :-----: | :-----: | :-----: | :-----: | :-----: |
|    ✔️    |    ✔️    |    ✔️    |    ✔️    |    ✔️    |
```

**需要修改:**
- 添加 macOS 列
- 更新安装说明版本号
- 添加 macOS 原生实现说明

---

## 版本号决策

### 语义化版本 (SemVer)
- **主版本 (X.0.0)** — 不兼容的 API 变更
- **次版本 (0.X.0)** — 向后兼容的功能新增
- **修订版本 (0.0.X)** — 向后兼容的缺陷修复

### 本次升级: 1.2.1 → 1.3.0
- **原因:** 添加 macOS 原生支持是新功能
- **类型:** 次版本升级
- **兼容性:** 向后兼容（不影响现有平台）

---

## CHANGELOG 格式

### Keep a Changelog 格式
```markdown
## [版本号] - 日期

### Added
- 新增功能

### Changed
- 变更功能

### Deprecated
- 废弃功能

### Removed
- 移除功能

### Fixed
- 修复缺陷

### Security
- 安全修复
```

### 本次更新内容
```markdown
## 1.3.0

### Added
- macOS native fullscreen support using NSWindow.toggleFullScreen
- macOS getScreenSize implementation using NSScreen.frame × backingScaleFactor

### Changed
- Updated SDK constraints for Dart 3.x compatibility
```

---

## README 更新清单

### 1. 平台支持表
```markdown
| Windows | Linux | macOS | Web | Android | iOS |
| :-----: | :-----: | :-----: | :-----: | :-----: | :-----: |
|    ✔️    |    ✔️    |    ✔️    |    ✔️    |    ✔️    |    ✔️    |
```

### 2. 安装说明
更新版本号:
```yaml
dependencies:
  fullscreen_window: ^1.3.0
```

### 3. 平台实现说明
添加 macOS 说明:
```markdown
### macOS

Uses native ObjC implementation with `NSWindow.toggleFullScreen` for fullscreen
and `NSScreen.frame × backingScaleFactor` for screen size.
```

---

## 验证清单

| 验证项 | 方法 |
|--------|------|
| 版本号正确 | 检查 pubspec.yaml |
| CHANGELOG 格式正确 | 人工审查 |
| README 平台表正确 | 人工审查 |
| flutter analyze 零错误 | 命令行验证 |
| 包可正常导入 | demo app 测试 |

---

## 风险点

1. **版本号冲突** — 确保 1.3.0 在 pub.dev 上不存在
2. **CHANGELOG 遗漏** — 确保所有变更都记录
3. **README 过时** — 确保所有平台信息最新
