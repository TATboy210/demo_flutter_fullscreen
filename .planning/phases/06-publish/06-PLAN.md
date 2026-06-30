---
phase: 06-publish
plan: 01
type: execute
wave: 6
depends_on:
  - 05-package
files_modified:
  - demo_fullscreen/pubspec.yaml
autonomous: true
requirements:
  - PUBLISH-01
  - PUBLISH-02
  - PUBLISH-03
  - PUBLISH-04
---

<objective>
将修改后的包推送到 GitHub 新仓库，demo app 改用 git URL 依赖。

Purpose: 作为独立依赖供后续项目使用。
Output: GitHub 仓库 URL，更新的 pubspec.yaml。
</objective>

<tasks>

<task type="auto" tdd="false">
  <name>Task 1: 创建 GitHub 新仓库</name>
  <files>fullscreen_window/</files>
  <behavior>
    - 使用 gh CLI 创建新仓库
    - 初始化 git 并推送代码
  </behavior>
  <action>
    ```bash
    cd D:/demo_flutter_fullscreen/fullscreen_window
    git init
    git add .
    git commit -m "feat: add macOS native fullscreen support"
    gh repo create fullscreen-window-macos --public --source=. --push
    ```
  </action>
  <done>GitHub 仓库创建并推送完成</done>
</task>

<task type="auto" tdd="false">
  <name>Task 2: 更新 demo_fullscreen 使用 git URL 依赖</name>
  <files>demo_fullscreen/pubspec.yaml</files>
  <behavior>
    - 将 path 依赖改为 git URL 依赖
    - 执行 flutter pub get 验证
  </behavior>
  <action>
    将：
    ```yaml
    fullscreen_window:
      path: ../fullscreen_window
    ```

    改为：
    ```yaml
    fullscreen_window:
      git:
        url: https://github.com/<username>/fullscreen-window-macos.git
    ```

    然后执行：
    ```bash
    cd D:/demo_flutter_fullscreen/demo_fullscreen && flutter pub get
    ```
  </action>
  <done>demo_fullscreen 使用 git URL 依赖</done>
</task>

<task type="auto" tdd="false">
  <name>Task 3: 验证 git URL 依赖正常工作</name>
  <files>demo_fullscreen/</files>
  <behavior>
    - 执行 flutter pub get 确保依赖解析成功
    - 执行 flutter analyze 确保无错误
  </behavior>
  <action>
    ```bash
    cd D:/demo_flutter_fullscreen/demo_fullscreen
    flutter pub get
    flutter analyze
    ```
  </action>
  <done>git URL 依赖验证通过</done>
</task>

</tasks>

<success_criteria>
1. GitHub 仓库创建并推送成功
2. demo_fullscreen 使用 git URL 依赖
3. flutter pub get 成功
4. flutter analyze 零错误
</success_criteria>

<output>Create `.planning/phases/06-publish/06-SUMMARY.md` when done</output>
