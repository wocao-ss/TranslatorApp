# 中文-乌兹别克语翻译应用

## 功能特性

- ✅ 中文 ↔ 乌兹别克语双向翻译
- ✅ 语音输入（语音识别）
- ✅ 语音输出（文字转语音）
- ✅ 一键切换翻译方向
- ✅ 复制翻译结果
- ✅ 离线翻译模型下载

## 自动构建

本项目使用 GitHub Actions 自动构建 APK。

### 下载最新 APK

1. 访问 [Actions](../../actions) 页面
2. 点击最新的工作流运行记录
3. 在 "Artifacts" 部分下载 `translator-app-apk`

或者访问 [Releases](../../releases) 页面下载。

## 技术栈

- **语言**: Kotlin
- **翻译引擎**: Google ML Kit Translation
- **语音识别**: Android SpeechRecognizer
- **语音合成**: Android TextToSpeech
- **UI**: Material Design 3

## 项目结构

```
TranslatorApp/
├── app/
│   ├── src/main/
│   │   ├── java/com/example/translator/
│   │   │   └── MainActivity.kt
│   │   ├── res/layout/activity_main.xml
│   │   ├── res/values/strings.xml
│   │   ├── res/values/colors.xml
│   │   └── res/values/themes.xml
│   │   └── AndroidManifest.xml
│   └── build.gradle
├── .github/workflows/build.yml
├── build.gradle
└── README.md
```

## 如何运行

### 1. 环境要求
- Android Studio Hedgehog (2023.1.1) 或更高版本
- Android SDK 34
- JDK 17

### 2. 打开项目
1. 打开 Android Studio
2. 选择 "Open an existing project"
3. 选择 `TranslatorApp` 文件夹

### 3. 构建并运行
1. 连接安卓设备或启动模拟器
2. 点击 "Run" 按钮 (Shift + F10)

## 权限说明

应用需要以下权限：
- `INTERNET` - 下载翻译模型
- `RECORD_AUDIO` - 语音输入

## 注意事项

1. **首次使用**需要下载翻译模型（约 30-50MB），建议在 WiFi 环境下使用
2. **语音识别**需要设备支持 Google 语音服务
3. **语音合成**需要设备安装对应语言的 TTS 引擎

## 语言代码

- 中文: `zh-CN`
- 乌兹别克语: `uz-UZ`

## 许可证

MIT License
