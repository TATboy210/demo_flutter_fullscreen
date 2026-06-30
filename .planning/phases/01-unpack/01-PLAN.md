---
phase: 01-unpack
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - demo_fullscreen/pubspec.yaml
autonomous: true
requirements:
  - UNPACK-01
  - UNPACK-02
  - UNPACK-03
must_haves:
  truths:
    - "fullscreen_window 1.2.1 源码完整复制到 fullscreen_window/ 目录"
    - "demo_fullscreen/pubspec.yaml 使用 path: ../fullscreen_window 引用"
    - "flutter pub get 成功执行，无版本冲突"
  artifacts:
    - "fullscreen_window/ (完整源码)"
    - "demo_fullscreen/pubspec.yaml (path 依赖)"
  key_links:
    - "pub cache 路径: ~/.pub-cache/hosted/pub.dev/fullscreen_window-1.2.1"
    - "或通过 flutter pub cache list 查找"
---

<objective>
从 pub cache 复制 fullscreen_window 1.2.1 源码到项目本地目录，配置 demo_fullscreen 使用本地 path 依赖。

Purpose: 获取完整源码以便后续学习和修改。
Output: fullscreen_window/ 目录包含完整源码，demo_fullscreen 使用本地依赖。
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/REQUIREMENTS.md
@.planning/ROADMAP.md
</context>

<tasks>

<task type="auto" tdd="false">
  <name>Task 1: 从 pub cache 复制 fullscreen_window 源码</name>
  <files>fullscreen_window/</files>
  <behavior>
    - 查找 pub cache 中的 fullscreen_window 1.2.1 目录
    - 复制整个目录到项目根目录下的 fullscreen_window/
    - 验证复制完整性（lib/, windows/, linux/, pubspec.yaml 等）
  </behavior>
  <action>
    **1. 查找 pub cache 路径:**

    ```bash
    # Windows 路径通常在:
    # %LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\fullscreen_window-1.2.1
    # 或
    # %APPDATA%\Pub\Cache\hosted\pub.dev\fullscreen_window-1.2.1

    # 查找方法:
    dart pub cache list
    # 或直接搜索:
    find "$LOCALAPPDATA/Pub/Cache" -name "fullscreen_window-1.2.1" -type d 2>/dev/null
    find "$APPDATA/Pub/Cache" -name "fullscreen_window-1.2.1" -type d 2>/dev/null
    ```

    **2. 复制源码:**

    ```bash
    # 删除已有的旧 fork（如果存在）
    rm -rf D:/demo_flutter_fullscreen/fullscreen_window

    # 复制 pub cache 中的源码
    cp -r "<pub_cache_path>/fullscreen_window-1.2.1" D:/demo_flutter_fullscreen/fullscreen_window
    ```

    **3. 验证复制完整性:**

    确认以下文件/目录存在：
    - `fullscreen_window/pubspec.yaml`
    - `fullscreen_window/lib/` (包含 5 个 Dart 文件)
    - `fullscreen_window/windows/` (C++ 实现)
    - `fullscreen_window/linux/` (C 实现)
    - `fullscreen_window/test/`
  </action>
  <verify>
    <automated>ls D:/demo_flutter_fullscreen/fullscreen_window/pubspec.yaml && echo "PASS: pubspec exists" || echo "FAIL"</automated>
  </verify>
  <done>
    1. fullscreen_window/ 目录存在且包含完整源码
    2. pubspec.yaml 显示版本 1.2.1
    3. lib/, windows/, linux/ 目录结构完整
  </done>
</task>

<task type="auto" tdd="false">
  <name>Task 2: 配置 demo_fullscreen 使用本地依赖</name>
  <files>demo_fullscreen/pubspec.yaml</files>
  <behavior>
    - 修改 demo_fullscreen/pubspec.yaml 中的 fullscreen_window 依赖为 path 引用
    - 保留 flutter_fullscreen 依赖不变
    - 执行 flutter pub get 验证
  </behavior>
  <action>
    **1. 修改 pubspec.yaml:**

    将 `fullscreen_window: ^1.2.1` 改为：
    ```yaml
    fullscreen_window:
      path: ../fullscreen_window
    ```

    保持其他依赖不变（flutter_fullscreen: ^1.2.0 等）。

    **2. 执行 flutter pub get:**

    ```bash
    cd D:/demo_flutter_fullscreen/demo_fullscreen && flutter pub get
    ```

    **3. 验证依赖解析:**

    确认输出包含 "Got dependencies" 或类似成功消息。
  </action>
  <verify>
    <automated>cd D:/demo_flutter_fullscreen/demo_fullscreen && flutter pub get 2>&1 | grep -q "Got dependencies" && echo "PASS: pub get succeeded" || echo "FAIL"</automated>
  </verify>
  <done>
    1. pubspec.yaml 包含 fullscreen_window path 依赖
    2. flutter pub get 成功执行
    3. 无版本冲突或依赖错误
  </done>
</task>

</tasks>

<verification>
1. fullscreen_window/ 目录包含完整源码（pubspec.yaml, lib/, windows/, linux/）
2. demo_fullscreen/pubspec.yaml 使用 path: ../fullscreen_window
3. flutter pub get 成功，无错误
</verification>

<success_criteria>
1. fullscreen_window 1.2.1 源码完整复制到本地
2. demo_fullscreen 正确引用本地依赖
3. flutter pub get 无错误
4. 现有功能不受影响（main.dart 可正常运行）
</success_criteria>

<output>
Create `.planning/phases/01-unpack/01-SUMMARY.md` when done
</output>
