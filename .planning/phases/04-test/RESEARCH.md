# Phase 4: 测试 (Test) — 研究文档

## 现有 main.dart 结构分析

### 文件规模
- **743 行**
- 包含：数据类、StatelessWidget、StatefulWidget

### 核心组件

#### 1. LogEntry 数据类 (L12-26)
```dart
class LogEntry {
  final DateTime timestamp;
  final String packageName;
  final String methodName;
  final bool success;
  final String? errorMessage;
}
```

#### 2. MyApp (L28-42)
- MaterialApp + Material 3 主题
- 标题: '双包全屏对比'

#### 3. DualFullscreenPage (L44-743)
**状态变量 (L52-63):**
```dart
bool _fwFullscreen = false;
bool _fwToggling = false;
bool _ffFullscreen = false;
bool _ffToggling = false;
late final FullScreenListener _ffListener;
final List<LogEntry> _logs = [];
```

**关键方法:**
- `_addLog()` (L94-104) — 日志记录
- `_clearLogs()` (L106-110) — 清空日志
- `_toggleFwFullscreen()` (L112-143) — fullscreen_window 切换
- `_toggleFfFullscreen()` (L145-160) — flutter_fullscreen 切换
- `_isAnyFullscreen` (L162) — 全屏状态检查

**UI 结构 (L165-211):**
```
Scaffold
├── AppBar (非全屏时显示)
└── ListView
    ├── SizedBox(height: 400)
    │   └── Row
    │       ├── Expanded → _buildPackageCard(fw)
    │       └── Expanded → _buildPackageCard(ff)
    ├── _buildApiComparisonPanel()
    ├── _buildDependencyPanel()
    └── _buildLogPanel()
```

**可复用组件:**
- `_buildPackageCard()` (L213-268) — 通用包控制卡片
- `_buildSectionTitle()` (L270-275) — 通用段落标题
- `_buildApiComparisonPanel()` (L278-297) — API 对比面板
- `_buildSignatureTable()` (L299-336) — 方法签名对比表
- `_buildReturnValueTable()` (L338-372) — 返回值差异表
- `_buildPlatformMatrix()` (L374-425) — 平台支持矩阵
- `_buildArchitectureTable()` (L427-465) — 架构差异表
- `_buildDependencyPanel()` (L468-485) — 依赖信息面板
- `_buildDependencyTree()` (L487-529) — 依赖树
- `_buildSizeComparison()` (L531-577) — 体积对比
- `_buildPitfallsList()` (L579-605) — 已知陷阱列表
- `_buildLogPanel()` (L670-722) — 日志面板

---

## 三按钮改造方案

### 需要新增的内容

#### 1. 状态变量 (3 个)
```dart
// 修改后的 fullscreen_window 状态
bool _modFullscreen = false;
bool _modToggling = false;
```

#### 2. 切换方法 (1 个)
```dart
Future<void> _toggleModFullscreen() async {
  // 与 _toggleFwFullscreen 相同逻辑
  // 包名标记为 'fullscreen_window (modified)'
}
```

#### 3. UI 组件 (1 个)
- `_buildModCard()` — 第三个包控制卡片

#### 4. 修改现有 UI
- Row 布局从 2 个 Expanded 改为 3 个 Expanded
- AppBar 标题改为 '三包全屏对比'
- `_isAnyFullscreen` 添加 `_modFullscreen`

### 不需要修改的内容
- LogEntry 数据类 — 已通用
- _addLog() — 已通用
- _clearLogs() — 已通用
- _buildApiComparisonPanel() — 需扩展但结构不变
- _buildDependencyPanel() — 需扩展但结构不变
- _buildLogPanel() — 已通用
- _FfFullscreenListener — 仅用于 flutter_fullscreen

---

## 关键技术点

### 1. 同包不同实例
第三个按钮使用的是同一个 `fullscreen_window` 包（已修改），但作为独立测试点。
实际上，第一个按钮和第三个按钮调用的是同一个包的同一个 API。

### 2. Windows 布局修复
现有的 `_toggleFwFullscreen()` 包含 Windows 布局修复逻辑：
```dart
if (!_fwFullscreen && mounted) {
  await Future.delayed(const Duration(milliseconds: 150));
  if (mounted) {
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }
}
```

第三个按钮需要复制此逻辑。

### 3. 平台支持矩阵更新
修改后的 fullscreen_window 应该在 macOS 行显示绿色勾（支持），而不是红色叉（不支持）。

---

## 验证清单

| 验证项 | 方法 |
|--------|------|
| 三个按钮独立工作 | 手动测试每个按钮 |
| 第三个按钮调用正确 | 日志中显示 'fullscreen_window (modified)' |
| API 对比面板显示三列 | UI 检查 |
| 平台支持矩阵正确 | macOS 行第三个包显示绿色勾 |
| 日志记录所有操作 | 调用后检查日志 |
| flutter analyze 零错误 | 命令行验证 |

---

## 风险点

1. **同包调用冲突** — 实际上不会，因为是同一个包的同一个方法
2. **UI 空间不足** — 三个卡片并排可能需要调整宽度
3. **平台支持矩阵逻辑** — 需要根据修改后的包动态判断 macOS 支持状态
