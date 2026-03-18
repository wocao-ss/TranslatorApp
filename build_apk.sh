#!/bin/bash

echo "=========================================="
echo "  中文-乌兹别克语翻译应用 - 构建脚本"
echo "=========================================="
echo ""

# 检查 Android SDK
if [ -z "$ANDROID_HOME" ]; then
    if [ -d "$HOME/Android/Sdk" ]; then
        export ANDROID_HOME="$HOME/Android/Sdk"
    elif [ -d "$HOME/Library/Android/sdk" ]; then
        export ANDROID_HOME="$HOME/Library/Android/sdk"
    else
        echo "[错误] 未找到 Android SDK！"
        echo "请先安装 Android Studio 并配置 ANDROID_HOME 环境变量"
        exit 1
    fi
fi

echo "[信息] 使用 Android SDK: $ANDROID_HOME"
echo ""

# 检查 Java
if ! command -v java &> /dev/null; then
    echo "[错误] 未找到 Java！请先安装 JDK 17 或更高版本"
    exit 1
fi

# 创建 Gradle Wrapper（如果不存在）
if [ ! -f "./gradlew" ]; then
    echo "[信息] 创建 Gradle Wrapper..."
    mkdir -p gradle/wrapper
    
    # 下载 wrapper 文件
    curl -L -o gradle/wrapper/gradle-wrapper.jar \
        https://raw.githubusercontent.com/gradle/gradle/v8.0.0/gradle/wrapper/gradle-wrapper.jar 2>/dev/null || \
        echo "警告: 无法下载 gradle-wrapper.jar"
    
    curl -L -o gradle/wrapper/gradle-wrapper.properties \
        https://raw.githubusercontent.com/gradle/gradle/v8.0.0/gradle/wrapper/gradle-wrapper.properties 2>/dev/null || \
        echo "警告: 无法下载 gradle-wrapper.properties"
    
    # 创建 gradlew 脚本
    cat > gradlew << 'EOF'
#!/bin/sh

APP_HOME="$( cd "$( dirname "$0" )" && pwd )"
APP_NAME="Gradle"

DEFAULT_JVM_OPTS='"-Xmx64m" "-Xms64m"'

CLASSPATH=$APP_HOME/gradle/wrapper/gradle-wrapper.jar

exec java $DEFAULT_JVM_OPTS $JAVA_OPTS $GRADLE_OPTS \
    "-Dorg.gradle.appname=$APP_NAME" \
    -classpath "$CLASSPATH" \
    org.gradle.wrapper.GradleWrapperMain "$@"
EOF
    chmod +x gradlew
fi

echo "[信息] 开始构建 APK..."
echo ""

# 构建 Release APK
if [ -f "./gradlew" ]; then
    ./gradlew assembleRelease
else
    echo "[警告] 未找到 Gradle Wrapper，尝试使用系统 Gradle..."
    gradle assembleRelease
fi

if [ $? -ne 0 ]; then
    echo ""
    echo "[错误] 构建失败！"
    echo "请检查:"
    echo "1. 是否安装了 Android Studio"
    echo "2. 是否配置了 ANDROID_HOME 环境变量"
    echo "3. 是否有网络连接（下载依赖需要）"
    exit 1
fi

echo ""
echo "=========================================="
echo "[成功] APK 构建完成！"
echo "=========================================="
echo ""
echo "安装包位置:"
echo "app/build/outputs/apk/release/app-release-unsigned.apk"
echo ""
echo "如需安装到手机:"
echo "1. 开启手机的 USB 调试模式"
echo "2. 连接手机到电脑"
echo "3. 运行: adb install app/build/outputs/apk/release/app-release-unsigned.apk"
echo ""
