---
phase: 05-package
plan: 01
type: execute
wave: 5
depends_on:
  - 04-test
files_modified:
  - fullscreen_window/CHANGELOG.md
  - fullscreen_window/README.md
  - fullscreen_window/pubspec.yaml
autonomous: true
requirements:
  - PACKAGE-01
  - PACKAGE-02
  - PACKAGE-03
  - PACKAGE-04
  - PACKAGE-05
---

<objective>
清理修改后的包，更新版本号和文档，准备发布。

Purpose: 确保包的质量和文档完整性。
Output: 更新的 CHANGELOG.md、README.md、pubspec.yaml。
</objective>

<tasks>

<task type="auto" tdd="false">
  <name>Task 1: 更新版本号</name>
  <files>fullscreen_window/pubspec.yaml</files>
  <behavior>
    - 将版本号从 1.2.1 更新为 1.3.0（添加 macOS 支持是新功能）
    - 验证版本号格式正确
  </behavior>
  <action>
    在 pubspec.yaml 中将 `version: 1.2.1` 改为 `version: 1.3.0`
  </action>
  <done>版本号更新为 1.3.0</done>
</task>

<task type="auto" tdd="false">
  <name>Task 2: 更新 CHANGELOG.md</name>
  <files>fullscreen_window/CHANGELOG.md</files>
  <behavior>
    - 添加 1.3.0 版本的变更记录
    - 说明添加了 macOS 原生支持
  </behavior>
  <action>
    在 CHANGELOG.md 开头添加：
    ```markdown
    ## 1.3.0

    - Added macOS native fullscreen support (NSWindow.toggleFullScreen)
    - Added macOS getScreenSize implementation (NSScreen × backingScaleFactor)
    - Updated SDK constraints for Dart 3.x
    ```
  </action>
  <done>CHANGELOG.md 更新完成</done>
</task>

<task type="auto" tdd="false">
  <name>Task 3: 更新 README.md</name>
  <files>fullscreen_window/README.md</files>
  <behavior>
    - 在平台支持列表中添加 macOS
    - 更新使用说明（如需要）
  </behavior>
  <action>
    在 README.md 的平台支持部分添加 macOS：
    - macOS: Native ObjC implementation using NSWindow.toggleFullScreen
  </action>
  <done>README.md 更新完成</done>
</task>

<task type="auto" tdd="false">
  <name>Task 4: 验证 flutter analyze</name>
  <files>fullscreen_window/</files>
  <behavior>
    - 执行 flutter analyze 确保零错误零警告
    - 修复任何问题
  </behavior>
  <action>
    ```bash
    cd D:/demo_flutter_fullscreen/fullscreen_window && flutter analyze
    ```
  </action>
  <done>flutter analyze 零错误零警告</done>
</task>

</tasks>

<success_criteria>
1. 版本号更新为 1.3.0
2. CHANGELOG.md 包含 macOS 支持说明
3. README.md 更新平台支持列表
4. flutter analyze 零错误零警告
</success_criteria>

<output>Create `.planning/phases/05-package/05-SUMMARY.md` when done</output>
