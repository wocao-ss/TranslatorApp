#!/bin/bash

# 下载最新 APK 脚本

echo "=========================================="
echo "  下载最新 APK"
echo "=========================================="
echo ""

# GitHub 用户名和仓库名
REPO_OWNER="你的GitHub用户名"
REPO_NAME="TranslatorApp"

# 桌面路径
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    DESKTOP="$HOME/Desktop"
else
    # Linux
    DESKTOP="$HOME/Desktop"
fi

# 检查 curl
if ! command -v curl &> /dev/null; then
    echo "[错误] 未找到 curl！"
    exit 1
fi

# 获取最新 release 的下载链接
echo "[信息] 获取最新 APK 下载链接..."
API_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest"

# 使用 curl 获取 release 信息
RELEASE_INFO=$(curl -s "$API_URL")

# 解析下载链接
APK_URL=$(echo "$RELEASE_INFO" | grep -o '"browser_download_url": "[^"]*\.apk"' | cut -d'"' -f4)

if [ -z "$APK_URL" ]; then
    echo "[错误] 未找到 APK 下载链接！"
    echo "请检查:"
    echo "1. 仓库名称是否正确: $REPO_OWNER/$REPO_NAME"
    echo "2. 是否有发布版本"
    echo "3. 是否将脚本中的 REPO_OWNER 修改为你的 GitHub 用户名"
    exit 1
fi

echo "[信息] APK 下载链接: $APK_URL"

# 下载 APK
APK_NAME="TranslatorApp-latest.apk"
APK_PATH="$DESKTOP/$APK_NAME"

echo "[信息] 下载 APK 到桌面..."
curl -L -o "$APK_PATH" "$APK_URL"

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "[成功] APK 已下载到桌面！"
    echo "=========================================="
    echo ""
    echo "文件位置: $APK_PATH"
    echo ""
    echo "安装方法:"
    echo "1. 将 APK 传输到手机"
    echo "2. 在手机上点击安装"
    echo "3. 如果提示'未知来源'，请允许安装"
else
    echo "[错误] 下载失败！"
fi
