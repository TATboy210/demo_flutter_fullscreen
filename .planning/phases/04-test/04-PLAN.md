---
phase: 04-test
plan: 01
type: execute
wave: 4
depends_on:
  - 03-modify
files_modified:
  - demo_fullscreen/lib/main.dart
autonomous: true
requirements:
  - TEST-01
  - TEST-02
  - TEST-03
  - TEST-04
  - TEST-05
  - TEST-06
must_haves:
  truths:
    - "demo app 包含三个全屏切换按钮"
    - "第三个按钮使用修改后的 fullscreen_window 包"
    - "所有按钮展示完整功能（API对比、差异、依赖、日志）"
    - "flutter analyze 零错误"
  artifacts:
    - "demo_fullscreen/lib/main.dart (三按钮版本)"
  key_links:
    - "现有 main.dart: 744 行，包含双包对比"
    - "需要扩展为三包对比"
---

<objective>
修改 demo app 添加第三个按钮，测试修改后的 fullscreen_window 包，展示完整功能对比。

Purpose: 验证修改后的包在所有平台上正常工作。
Output: 三按钮对比页面，包含 API 对比、差异、依赖、日志。
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@demo_fullscreen/lib/main.dart
@fullscreen_window/lib/
</context>

<tasks>

<task type="auto" tdd="false">
  <name>Task 1: 分析现有 main.dart 结构</name>
  <files>demo_fullscreen/lib/main.dart</files>
  <behavior>
    - 阅读现有 main.dart 理解双包对比结构
    - 识别需要修改的部分
    - 设计三按钮布局方案
  </behavior>
  <action>
    **分析要点：**

    1. **现有结构：**
       - LogEntry 数据类
       - MyApp (MaterialApp)
       - DualFullscreenPage (StatefulWidget)
       - 状态变量: _fwFullscreen, _ffFullscreen, _fwToggling, _ffToggling, _ffListener
       - 日志: _logs, _addLog(), _clearLogs()
       - 切换方法: _toggleFwFullscreen(), _toggleFfFullscreen()
       - UI: Row 布局，两个 Expanded 包控制区

    2. **需要修改的部分：**
       - 重命名 DualFullscreenPage 为 TripleFullscreenPage（或保持原名）
       - 添加第三个按钮的状态变量
       - 添加第三个按钮的切换方法
       - 修改 UI 布局为三个并排区域
       - 扩展 API 对比面板添加第三个包的信息

    3. **三按钮布局方案：**
       - 使用 Row 布局，三个 Expanded 包控制区
       - 每个区域包含：包名标题、状态图标、状态文字、切换按钮
       - 保持现有 Material 3 主题和中文标签
  </action>
  <verify>
    <automated>wc -l D:/demo_flutter_fullscreen/demo_fullscreen/lib/main.dart</automated>
  </verify>
  <done>
    1. 理解现有 main.dart 结构
    2. 识别需要修改的部分
    3. 设计三按钮布局方案
  </done>
</task>

<task type="auto" tdd="false">
  <name>Task 2: 添加第三个按钮的状态和方法</name>
  <files>demo_fullscreen/lib/main.dart</files>
  <behavior>
    - 添加第三个按钮的状态变量: _modFullscreen, _modToggling
    - 添加第三个按钮的切换方法: _toggleModFullscreen()
    - 使用修改后的 fullscreen_window 包（同一个包，但作为第三个测试点）
    - 添加日志记录
  </behavior>
  <action>
    **1. 添加状态变量:**

    ```dart
    bool _modFullscreen = false;
    bool _modToggling = false;
    ```

    **2. 添加切换方法:**

    ```dart
    Future<void> _toggleModFullscreen() async {
      if (_modToggling) return;
      _modToggling = true;
      final previous = _modFullscreen;
      setState(() => _modFullscreen = !_modFullscreen);
      try {
        await FullScreenWindow.setFullScreen(_modFullscreen);
        _addLog('fullscreen_window (modified)', 'setFullScreen', true);
        if (!_modFullscreen && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() {});
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _modFullscreen = previous);
          _addLog('fullscreen_window (modified)', 'setFullScreen', false, e.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('fullscreen_window (modified) 失败: $e')),
          );
        }
      } finally {
        _modToggling = false;
      }
    }
    ```

    **注意：** 第三个按钮使用的是同一个 `fullscreen_window` 包（已修改为支持 macOS），
    但作为独立的测试点来验证修改后的功能。实际上，第一个按钮和第三个按钮调用的是同一个包，
    只是为了对比展示而分开。
  </action>
  <verify>
    <automated>grep -q "_modFullscreen" D:/demo_flutter_fullscreen/demo_fullscreen/lib/main.dart && echo "PASS" || echo "FAIL"</automated>
  </verify>
  <done>
    1. 添加了 _modFullscreen 和 _modToggling 状态变量
    2. 添加了 _toggleModFullscreen() 方法
    3. 包含日志记录和错误处理
    4. 包含 Windows 布局修复
  </done>
</task>

<task type="auto" tdd="false">
  <name>Task 3: 修改 UI 布局为三按钮</name>
  <files>demo_fullscreen/lib/main.dart</files>
  <behavior>
    - 将 Row 布局从两个 Expanded 改为三个 Expanded
    - 第三个区域显示 "fullscreen_window (modified)" 标题
    - 保持现有 Material 3 主题和中文标签
    - 调整卡片宽度和间距
  </behavior>
  <action>
    **修改 UI 布局:**

    将现有的 Row 布局：
    ```dart
    Row(
      children: [
        Expanded(child: _buildFwCard()),
        Expanded(child: _buildFfCard()),
      ],
    )
    ```

    改为：
    ```dart
    Row(
      children: [
        Expanded(child: _buildFwCard()),
        const SizedBox(width: 8),
        Expanded(child: _buildFfCard()),
        const SizedBox(width: 8),
        Expanded(child: _buildModCard()),
      ],
    )
    ```

    **添加 _buildModCard() 方法:**

    ```dart
    Widget _buildModCard() {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'fullscreen_window\n(modified)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Icon(
              _modFullscreen ? Icons.fullscreen : Icons.fullscreen_exit,
              size: 64,
              color: _modFullscreen ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              _modFullscreen ? '全屏中' : '窗口模式',
              style: TextStyle(
                fontSize: 18,
                color: _modFullscreen ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _toggleModFullscreen,
              icon: Icon(_modFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
              label: Text(_modFullscreen ? '退出全屏' : '进入全屏'),
            ),
          ],
        ),
      );
    }
    ```
  </action>
  <verify>
    <automated>grep -q "_buildModCard" D:/demo_flutter_fullscreen/demo_fullscreen/lib/main.dart && echo "PASS" || echo "FAIL"</automated>
  </verify>
  <done>
    1. UI 布局改为三个并排区域
    2. 添加了 _buildModCard() 方法
    3. 第三个区域显示 "fullscreen_window (modified)" 标题
    4. 保持了现有主题和中文标签
  </done>
</task>

<task type="auto" tdd="false">
  <name>Task 4: 扩展 API 对比面板</name>
  <files>demo_fullscreen/lib/main.dart</files>
  <behavior>
    - 在 API 对比面板中添加第三个包的信息
    - 更新平台支持矩阵（macOS 现在支持）
    - 更新架构差异表
  </behavior>
  <action>
    **更新 API 对比面板:**

    1. **方法签名对比表：**
       - 添加第三列 "fullscreen_window (modified)"
       - 与原始 fullscreen_window 相同的 API，但支持 macOS

    2. **平台支持矩阵：**
       - 更新 macOS 行，第三个包显示绿色勾
       - 原始 fullscreen_window 仍显示红色叉

    3. **架构差异表：**
       - 添加第三列对比
       - 说明修改后的包添加了 macOS 原生实现
  </action>
  <verify>
    <automated>grep -q "fullscreen_window (modified)" D:/demo_flutter_fullscreen/demo_fullscreen/lib/main.dart && echo "PASS" || echo "FAIL"</automated>
  </verify>
  <done>
    1. API 对比面板包含三个包的信息
    2. 平台支持矩阵正确显示 macOS 支持状态
    3. 架构差异表包含修改说明
  </done>
</task>

<task type="auto" tdd="false">
  <name>Task 5: 验证 flutter analyze</name>
  <files>demo_fullscreen/lib/main.dart</files>
  <behavior>
    - 执行 flutter analyze 确保零错误
    - 修复任何警告或错误
  </behavior>
  <action>
    **执行分析:**

    ```bash
    cd D:/demo_flutter_fullscreen/demo_fullscreen && flutter analyze lib/main.dart
    ```

    **预期结果：**
    - No issues found!
    - 无错误、无警告
  </action>
  <verify>
    <automated>cd D:/demo_flutter_fullscreen/demo_fullscreen && flutter analyze lib/main.dart 2>&1 | tail -5</automated>
  </verify>
  <done>
    1. flutter analyze 零错误
    2. 无废弃 API 警告
    3. 代码符合 Dart 规范
  </done>
</task>

</tasks>

<verification>
1. demo app 包含三个全屏切换按钮
2. 第三个按钮使用修改后的 fullscreen_window 包
3. 所有按钮展示完整功能
4. flutter analyze 零错误
</verification>

<success_criteria>
1. 三个按钮独立工作，互不干扰
2. 第三个按钮正确调用修改后的 fullscreen_window
3. API 对比面板展示三个包的信息
4. 平台支持矩阵正确显示 macOS 支持状态
5. 调用日志记录所有操作
6. flutter analyze 零错误
</success_criteria>

<output>
Create `.planning/phases/04-test/04-SUMMARY.md` when done
</output>
