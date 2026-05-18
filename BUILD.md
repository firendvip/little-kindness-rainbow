# 构建 APK 指南（无需本地 Flutter 环境）

本指南将帮助你使用 GitHub Actions **免费云端编译** APK，无需在本地安装 Flutter 或 Android SDK。

## 前提条件

- 一个 GitHub 账户（免费注册：https://github.com）
- 能够访问 GitHub Actions（免费账户每月有 2000 分钟构建时间）

## 步骤一：创建 GitHub 仓库

1. 登录 GitHub
2. 点击右上角 `+` → `New repository`
3. 填写仓库信息：
   - **Repository name**: `little-kindness-rainbow`（或你喜欢的名字）
   - **Public/Private**: 选择 `Public`（私有仓库需要付费才能使用 Actions）
   - 勾选 `Add a README file`（可选）
4. 点击 `Create repository`

## 步骤二：上传代码到 GitHub

### 方法 A：使用 GitHub Web 界面（最简单）

1. 进入你的仓库
2. 点击 `Add file` → `Upload files`
3. 将项目文件夹中的所有文件拖拽到网页中
4. 填写提交信息（如 `Initial commit`）
5. 点击 `Commit changes`

### 方法 B：使用 Git 命令行（如果你熟悉 Git）

```bash
# 在项目根目录初始化 Git
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/你的用户名/仓库名.git
git push -u origin main
```

## 步骤三：配置 API Key（Secret）

1. 进入你的 GitHub 仓库
2. 点击 `Settings` 标签
3. 在左侧菜单找到 `Secrets and variables` → `Actions`
4. 点击 `New repository secret`
5. 填写：
   - **Name**: `API_KEY`
   - **Secret**: `72a157d1d2e448c6babe29bb2301ee36.ItxX8jV56yCC8TrF`
6. 点击 `Add secret`

## 步骤四：触发构建

1. 进入仓库的 `Actions` 标签
2. 在左侧选择 `Build Android APK` 工作流
3. 点击 `Run workflow` 按钮
4. 选择分支（通常是 `main`）
5. 点击 `Run workflow` 确认

## 步骤五：下载 APK

1. 等待构建完成（通常需要 5-10 分钟）
2. 构建完成后，在工作流程运行页面下方找到 `Artifacts` 部分
3. 点击 `little-kindness-rainbow-v1.1` 下载 ZIP 文件
4. 解压 ZIP，得到 `app-release.apk`

## 安装到 Android 设备

1. 将 `app-release.apk` 传输到 Android 手机（通过 USB、邮件、云盘等）
2. 在手机上打开 `设置` → `安全` → 启用 `未知来源`（不同品牌位置可能不同）
3. 使用文件管理器找到 APK 文件，点击安装
4. 安装完成后，即可打开"小善彩虹屁"应用

## 常见问题

### Q: 构建失败怎么办？
A: 检查 `Actions` 页面的错误日志，常见原因：
- API_KEY Secret 未配置或配置错误
- 代码不完整（确保所有文件都已上传）
- Flutter 版本问题（工作流使用 3.29.2，如有问题可修改）

### Q: 可以修改应用名称或图标吗？
A: 可以。修改以下文件：
- 应用名称：`android/app/src/main/AndroidManifest.xml` 中的 `android:label`
- 图标：替换 `android/app/src/main/res/mipmap-*` 目录下的图标文件

### Q: 如何更新应用？
A: 修改代码后，推送到 GitHub，然后重新运行 `Build Android APK` 工作流。

## 技术细节

- 构建环境：Ubuntu Latest
- Flutter 版本：3.29.2（稳定版）
- 构建命令：`flutter build apk --release --dart-define=API_KEY=${{ secrets.API_KEY }}`
- Artifact 保留时间：30 天

## 安全说明

API Key 通过 GitHub Secrets 注入，**不会**出现在构建日志或 APK 文件中。请确保：
- 不要将 API Key 硬编码在代码中
- 不要将 API Key 提交到 Git 仓库
- 定期检查 GitHub Secrets 配置

## 替代方案：使用 Codemagic（另一个云端构建服务）

如果你不想使用 GitHub Actions，也可以尝试 Codemagic（https://codemagic.io）：
1. 注册账户
2. 连接 GitHub 仓库
3. 配置构建工作流
4. 下载 APK

Codemagic 免费账户每月有 500 分钟构建时间。

---

如有任何问题，请参考 Flutter 官方文档：https://docs.flutter.dev/deployment/android
