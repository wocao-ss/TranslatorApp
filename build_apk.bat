@echo off
chcp 65001 >nul
echo ==========================================
echo   中文-乌兹别克语翻译应用 - 构建脚本
echo ==========================================
echo.

REM 检查是否安装了 Android Studio
if exist "%LOCALAPPDATA%\Android\Sdk" (
    set ANDROID_SDK=%LOCALAPPDATA%\Android\Sdk
) else if exist "C:\Users\%USERNAME%\AppData\Local\Android\Sdk" (
    set ANDROID_SDK=C:\Users\%USERNAME%\AppData\Local\Android\Sdk
) else (
    echo [错误] 未找到 Android SDK！
    echo 请先安装 Android Studio 并配置 SDK
    pause
    exit /b 1
)

echo [信息] 找到 Android SDK: %ANDROID_SDK%
echo.

REM 检查 Gradle Wrapper
if not exist "gradlew.bat" (
    echo [信息] 创建 Gradle Wrapper...
    
    REM 下载 gradle wrapper
    if not exist "gradle\wrapper" mkdir "gradle\wrapper"
    
    powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/gradle/gradle/v8.0.0/gradle/wrapper/gradle-wrapper.jar' -OutFile 'gradle\wrapper\gradle-wrapper.jar'" 2>nul
    powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/gradle/gradle/v8.0.0/gradle/wrapper/gradle-wrapper.properties' -OutFile 'gradle\wrapper\gradle-wrapper.properties'" 2>nul
    
    REM 创建 gradlew.bat
    (
        echo @setlocal
        echo @set DIRNAME=%%~dp0
        echo @if "%%DIRNAME%%" == "" set DIRNAME=.
        echo @set APP_BASE_NAME=%%~n0
        echo @set APP_HOME=%%DIRNAME%%
        echo.
        echo @set DEFAULT_JVM_OPTS=
        echo.
        echo @findstr /V "@rem" "%%APP_HOME%%\gradle\wrapper\gradle-wrapper.properties" ^>nul 2^>nul
        echo @if errorlevel 1 goto fail
        echo.
        echo @set JAVA_EXE=java.exe
        echo @if not defined JAVA_HOME goto findJavaFromJavaHome
        echo @set JAVA_HOME=%%JAVA_HOME:"=%%
        echo @set JAVA_EXE=%%JAVA_HOME%%/bin/java.exe
        echo.
        echo @if exist "%%JAVA_EXE%%" goto init
        echo @echo.
        echo @echo ERROR: JAVA_HOME is set to an invalid directory: %%JAVA_HOME%%
        echo @echo.
        echo @echo Please set the JAVA_HOME variable to match the location of your Java installation.
        echo @goto fail
        echo.
        echo :findJavaFromJavaHome
        echo @set JAVA_HOME=%%JAVA_HOME:"=%%
        echo @set JAVA_EXE=%%JAVA_HOME%%/bin/java.exe
        echo.
        echo :init
        echo @rem Get command-line arguments
        echo @set CMD_LINE_ARGS=%%*
        echo.
        echo @rem Setup the command line
        echo @set CLASSPATH=%%APP_HOME%%\gradle\wrapper\gradle-wrapper.jar
        echo.
        echo @rem Execute Gradle
        echo "%%JAVA_EXE%%" %%DEFAULT_JVM_OPTS%% %%JAVA_OPTS%% %%GRADLE_OPTS%% "-Dorg.gradle.appname=%%APP_BASE_NAME%%" -classpath "%%CLASSPATH%%" org.gradle.wrapper.GradleWrapperMain %%CMD_LINE_ARGS%%
        echo.
        echo :end
        echo @rem End local scope for the variables with windows NT shell
        echo @if "%%ERRORLEVEL%%"=="0" goto mainEnd
        echo.
        echo :fail
        echo @rem Set variable GRADLE_EXIT_CONSOLE if you need the _script_ return code
        echo @if not "" == "%%GRADLE_EXIT_CONSOLE%%" exit 1
        echo exit /b 1
        echo.
        echo :mainEnd
        echo @if "%%OS%%"=="Windows_NT" endlocal
        echo.
        echo :omega
    ) > gradlew.bat
)

echo [信息] 开始构建 APK...
echo.

REM 构建 Release APK
if exist "gradlew.bat" (
    call gradlew.bat assembleRelease
) else (
    echo [警告] 未找到 Gradle Wrapper，尝试使用系统 Gradle...
    gradle assembleRelease
)

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [错误] 构建失败！
    echo 请检查:
    echo 1. 是否安装了 Android Studio
    echo 2. 是否配置了 ANDROID_HOME 环境变量
    echo 3. 是否有网络连接（下载依赖需要）
    pause
    exit /b 1
)

echo.
echo ==========================================
echo [成功] APK 构建完成！
echo ==========================================
echo.
echo 安装包位置:
echo app\build\outputs\apk\release\app-release-unsigned.apk
echo.
echo 如需安装到手机:
echo 1. 开启手机的 USB 调试模式
echo 2. 连接手机到电脑
echo 3. 运行: adb install app\build\outputs\apk\release\app-release-unsigned.apk
echo.
pause
