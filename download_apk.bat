@echo off
chcp 65001 >nul
echo ==========================================
echo   下载最新 APK
echo ==========================================
echo.

REM GitHub 用户名和仓库名
set REPO_OWNER=你的GitHub用户名
set REPO_NAME=TranslatorApp

REM 桌面路径
set DESKTOP=%USERPROFILE%\Desktop

REM 检查 curl
where curl >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 未找到 curl！
    pause
    exit /b 1
)

REM 获取最新 release 的下载链接
echo [信息] 获取最新 APK 下载链接...
set API_URL=https://api.github.com/repos/%REPO_OWNER%/%REPO_NAME%/releases/latest

REM 使用 PowerShell 获取 release 信息
powershell -Command "$release = Invoke-RestMethod -Uri '%API_URL%'; $release.assets | Where-Object { $_.name -like '*.apk' } | Select-Object -ExpandProperty browser_download_url" > temp_url.txt

set /p APK_URL=<temp_url.txt
del temp_url.txt

if "%APK_URL%"=="" (
    echo [错误] 未找到 APK 下载链接！
    echo 请检查:
    echo 1. 仓库名称是否正确: %REPO_OWNER%/%REPO_NAME%
    echo 2. 是否有发布版本
    echo 3. 是否将脚本中的 REPO_OWNER 修改为你的 GitHub 用户名
    pause
    exit /b 1
)

echo [信息] APK 下载链接: %APK_URL%

REM 下载 APK
set APK_NAME=TranslatorApp-latest.apk
set APK_PATH=%DESKTOP%\%APK_NAME%

echo [信息] 下载 APK 到桌面...
curl -L -o "%APK_PATH%" "%APK_URL%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ==========================================
    echo [成功] APK 已下载到桌面！
    echo ==========================================
    echo.
    echo 文件位置: %APK_PATH%
    echo.
    echo 安装方法:
    echo 1. 将 APK 传输到手机
    echo 2. 在手机上点击安装
    echo 3. 如果提示'未知来源'，请允许安装
) else (
    echo [错误] 下载失败！
)

pause
