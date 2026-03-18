#!/bin/bash

echo "=========================================="
echo "  GitHub 仓库创建和推送脚本"
echo "=========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查 git
if ! command -v git &> /dev/null; then
    echo -e "${RED}[错误] 未找到 Git！请先安装 Git${NC}"
    echo "下载地址: https://git-scm.com/download"
    exit 1
fi

# 检查 GitHub CLI
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}[警告] 未找到 GitHub CLI (gh)${NC}"
    echo "建议安装: https://cli.github.com/"
    echo ""
    echo "或者你可以手动操作:"
    echo "1. 访问 https://github.com/new 创建新仓库"
    echo "2. 仓库名: TranslatorApp"
    echo "3. 不勾选 'Initialize this repository with a README'"
    echo ""
fi

# 进入项目目录
cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)
REPO_NAME="TranslatorApp"

echo -e "${GREEN}[信息] 项目目录: $PROJECT_DIR${NC}"
echo ""

# 初始化 git 仓库
if [ ! -d ".git" ]; then
    echo -e "${GREEN}[信息] 初始化 Git 仓库...${NC}"
    git init
    git branch -M main
fi

# 配置 git（如果未配置）
if [ -z "$(git config user.name)" ]; then
    echo "请输入你的 GitHub 用户名:"
    read -r username
    git config user.name "$username"
fi

if [ -z "$(git config user.email)" ]; then
    echo "请输入你的 GitHub 邮箱:"
    read -r email
    git config user.email "$email"
fi

# 添加所有文件
echo -e "${GREEN}[信息] 添加文件到 Git...${NC}"
git add .

# 提交
echo -e "${GREEN}[信息] 提交代码...${NC}"
git commit -m "Initial commit: Chinese-Uzbek Translator App with GitHub Actions"

# 检查是否已配置远程仓库
if ! git remote get-url origin &> /dev/null; then
    echo ""
    echo "=========================================="
    echo "  请先在 GitHub 上创建仓库"
    echo "=========================================="
    echo ""
    echo "步骤:"
    echo "1. 访问 https://github.com/new"
    echo "2. 仓库名称: $REPO_NAME"
    echo "3. 选择 Public 或 Private"
    echo "4. 不要勾选 'Add a README file'"
    echo "5. 点击 'Create repository'"
    echo ""
    echo "创建完成后，输入你的仓库 URL:"
    echo "(例如: https://github.com/你的用户名/$REPO_NAME.git)"
    read -r repo_url
    
    git remote add origin "$repo_url"
fi

# 推送到 GitHub
echo -e "${GREEN}[信息] 推送到 GitHub...${NC}"
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}==========================================${NC}"
    echo -e "${GREEN}[成功] 代码已推送到 GitHub！${NC}"
    echo -e "${GREEN}==========================================${NC}"
    echo ""
    echo "接下来:"
    echo "1. 访问你的 GitHub 仓库"
    echo "2. 点击 'Actions' 标签查看构建进度"
    echo "3. 等待构建完成（约 3-5 分钟）"
    echo "4. 构建完成后，在 'Actions' 页面下载 APK"
    echo ""
    echo "或者访问 Releases 页面直接下载:"
    echo "https://github.com/$(git config user.name)/$REPO_NAME/releases"
    echo ""
else
    echo -e "${RED}[错误] 推送失败！${NC}"
    echo "请检查:"
    echo "1. 是否已登录 GitHub"
    echo "2. 仓库 URL 是否正确"
    echo "3. 是否有推送权限"
fi
