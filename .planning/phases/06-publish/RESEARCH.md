# Phase 6: 发布 (Publish) — 研究文档

## 当前依赖配置

### demo_fullscreen/pubspec.yaml
```yaml
dependencies:
  fullscreen_window:
    path: ../fullscreen_window
  flutter_fullscreen: ^1.2.0
```

**当前状态:** 使用本地路径依赖

---

## GitHub 发布方案

### 1. 创建 GitHub 仓库

**仓库名称:** `fullscreen_window` (或 `fullscreen_window_macos`)

**仓库设置:**
- 可见性: Public（开源）或 Private（私有）
- 初始化: 不要自动初始化（本地已有代码）
- 描述: "A Flutter plugin for fullscreen window with macOS native support"

### 2. 推送代码到 GitHub

**步骤:**
```bash
# 1. 在 fullscreen_window 目录初始化 git
cd D:/demo_flutter_fullscreen/fullscreen_window
git init
git add .
git commit -m "feat: add macOS native fullscreen support"

# 2. 添加远程仓库
git remote add origin https://github.com/<username>/fullscreen_window.git

# 3. 推送
git push -u origin master
```

### 3. 更新 demo app 依赖

**从路径依赖改为 git URL 依赖:**

```yaml
# 之前
fullscreen_window:
  path: ../fullscreen_window

# 之后
fullscreen_window:
  git:
    url: https://github.com/<username>/fullscreen_window.git
    ref: master
```

---

## Git URL 依赖语法

### 基本格式
```yaml
dependencies:
  package_name:
    git:
      url: https://github.com/user/repo.git
      ref: branch_name  # 可选，默认为默认分支
```

### 可选参数
```yaml
dependencies:
  package_name:
    git:
      url: https://github.com/user/repo.git
      ref: master        # 分支名、tag 或 commit SHA
      path: packages/pkg # 子目录路径（monorepo 场景）
```

### 本次使用
```yaml
fullscreen_window:
  git:
    url: https://github.com/<username>/fullscreen_window.git
    ref: master
```

---

## 验证清单

| 验证项 | 方法 |
|--------|------|
| GitHub 仓库创建成功 | 浏览器访问仓库 URL |
| 代码推送成功 | 检查远程仓库内容 |
| git URL 依赖可用 | `flutter pub get` 成功 |
| demo app 正常运行 | 手动测试三个按钮 |
| flutter analyze 零错误 | 命令行验证 |

---

## 风险点

1. **GitHub 认证** — 确保有推送权限
2. **仓库命名冲突** — 确保仓库名可用
3. **git URL 缓存** — Flutter 可能缓存 git 依赖，需要 `flutter pub cache clean`
4. **分支名** — 确保使用正确的分支名（master 或 main）

---

## 后续步骤

### 可选: 发布到 pub.dev
如果需要发布到 pub.dev，需要:
1. 确保包名可用
2. 运行 `flutter pub publish --dry-run` 检查
3. 运行 `flutter pub publish` 发布

### 可选: 创建 Release
在 GitHub 上创建 release:
1. 创建 tag: `git tag v1.3.0`
2. 推送 tag: `git push origin v1.3.0`
3. 在 GitHub 上创建 release
