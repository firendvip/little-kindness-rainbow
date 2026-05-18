# 小善彩虹屁 v1.1

小朋友专属彩虹屁生成器 🌈

## 功能特性

1. **随机生成彩虹屁** - 点击按钮即可生成鼓励性夸奖语句
2. **定制夸奖** - 输入"具体要夸的事情"，生成针对性夸奖
3. **缓存机制** - 预生成20条通用版，确保快速响应
4. **历史记录** - 自动保存生成历史，点击即可复制
5. **分享功能** - 一键分享到微信好友
6. **极致简约 UI** - 符合设计规范的渐变背景和卡片设计

## 技术栈

- **框架**: Flutter 3.29.2
- **状态管理**: Provider
- **网络请求**: http
- **本地存储**: shared_preferences
- **分享功能**: share_plus
- **剪贴板**: clipboard

## 构建步骤

### 本地构建（需要 Flutter 环境）

1. 安装 Flutter SDK（参考 https://flutter.dev/get-started）
2. 配置 Android SDK
3. 克隆本项目
4. 获取依赖：
   ```bash
   flutter pub get
   ```
5. 构建 APK：
   ```bash
   flutter build apk --release --dart-define=API_KEY=72a157d1d2e448c6babe29bb2301ee36.ItxX8jV56yCC8TrF
   ```
6. 生成的 APK 位于：`build/app/outputs/flutter-apk/app-release.apk`

### 使用 GitHub Actions 构建（无需本地环境）

1. 将代码推送到 GitHub 仓库
2. 在仓库的 **Settings > Secrets and variables > Actions** 中添加 Secret：
   - Name: `API_KEY`
   - Value: `72a157d1d2e448c6babe29bb2301ee36.ItxX8jV56yCC8TrF`
3. 进入 **Actions** 标签页
4. 选择 **Build Android APK** 工作流
5. 点击 **Run workflow**
6. 等待构建完成（约5-10分钟）
7. 下载 Artifact（APK 文件）

## API Key 配置

API Key 已提供：`72a157d1d2e448c6babe29bb2301ee36.ItxX8jV56yCC8TrF`

**重要**：API Key 已通过 `--dart-define` 注入，不会硬编码在代码中。请确保在构建时正确配置。

## 安装到设备

1. 将 APK 文件传输到 Android 设备
2. 在设备上启用"未知来源"安装（设置 > 安全 > 未知来源）
3. 点击 APK 文件进行安装

## 项目结构

```
lib/
  main.dart              # 应用入口
  screens/
    home_screen.dart     # 主页
    history_screen.dart  # 历史记录页
  services/
    api_service.dart     # API 调用服务
    cache_service.dart   # 缓存 + 历史记录服务
  models/
    rainbow_puff.dart    # 数据模型
```

## 设计规范

- 主背景：135° 线性渐变（#F0F4F8 → #E2E8F0 → #D5E0F0）
- 主卡片：rgba(255,255,255,0.95)，圆角 24px
- 品牌渐变：90° 从 #5E72E4 到 #825EE4
- 强调色：#9933FF

## 许可证

MIT License
