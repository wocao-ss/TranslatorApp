@echo off
chcp 65001 >nul
echo ==========================================
echo   GitHub 仓库创建和推送脚本
echo ==========================================
echo.

REM 检查 git
where git >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 未找到 Git！请先安装 Git
    echo 下载地址: https://git-scm.com/download/win
    pause
    exit /b 1
)

REM 检查 GitHub CLI
where gh >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [警告] 未找到 GitHub CLI (gh)
    echo 建议安装: https://cli.github.com/
    echo.
    echo 或者你可以手动操作:
    echo 1. 访问 https://github.com/new 创建新仓库
    echo 2. 仓库名: TranslatorApp
    echo 3. 不勾选 'Initialize this repository with a README'
    echo.
)

REM 进入项目目录
cd /d "%~dp0"
set PROJECT_DIR=%CD%
set REPO_NAME=TranslatorApp

echo [信息] 项目目录: %PROJECT_DIR%
echo.

REM 初始化 git 仓库
if not exist ".git" (
    echo [信息] 初始化 Git 仓库...
    git init
    git branch -M main
)

REM 配置 git（如果未配置）
for /f "tokens=*" %%a in ('git config user.name') do set GIT_USER=%%a
if "%GIT_USER%"=="" (
    set /p username="请输入你的 GitHub 用户名: "
    git config user.name "%username%"
)

for /f "tokens=*" %%a in ('git config user.email') do set GIT_EMAIL=%%a
if "%GIT_EMAIL%"=="" (
    set /p email="请输入你的 GitHub 邮箱: "
    git config user.email "%email%"
)

REM 添加所有文件
echo [信息] 添加文件到 Git...
git add .

REM 提交
echo [信息] 提交代码...
git commit -m "Initial commit: Chinese-Uzbek Translator App with GitHub Actions"

REM 检查是否已配置远程仓库
git remote get-url origin >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ==========================================
    echo   请先在 GitHub 上创建仓库
    echo ==========================================
    echo.
    echo 步骤:
    echo 1. 访问 https://github.com/new
    echo 2. 仓库名称: %REPO_NAME%
    echo 3. 选择 Public 或 Private
    echo 4. 不要勾选 'Add a README file'
    echo 5. 点击 'Create repository'
    echo.
    echo 创建完成后，输入你的仓库 URL:
    echo (例如: https://github.com/你的用户名/%REPO_NAME%.git)
    set /p repo_url="仓库URL: "
    
    git remote add origin %repo_url%
)

REM 推送到 GitHub
echo [信息] 推送到 GitHub...
git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ==========================================
    echo [成功] 代码已推送到 GitHub！
    echo ==========================================
    echo.
    echo 接下来:
    echo 1. 访问你的 GitHub 仓库
    echo 2. 点击 'Actions' 标签查看构建进度
    echo 3. 等待构建完成（约 3-5 分钟）
    echo 4. 构建完成后，在 'Actions' 页面下载 APK
    echo.
    echo 或者访问 Releases 页面直接下载
) else (
    echo [错误] 推送失败！
    echo 请检查:
    echo 1. 是否已登录 GitHub
    echo 2. 仓库 URL 是否正确
    echo 3. 是否有推送权限
)

pause
