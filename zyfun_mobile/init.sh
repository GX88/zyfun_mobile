#!/bin/bash

# 项目初始化脚本

echo "🚀 开始初始化 zyfun_mobile 项目..."

# 检查 Flutter 是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ 未检测到 Flutter，请先安装 Flutter SDK"
    exit 1
fi

echo "✅ Flutter 版本:"
flutter --version

# 安装依赖
echo "📦 安装依赖..."
flutter pub get

# 运行代码生成
echo "🔧 运行代码生成..."
flutter pub run build_runner build --delete-conflicting-outputs

# 分析代码
echo "🔍 分析代码..."
flutter analyze

echo "✅ 项目初始化完成!"
echo ""
echo "下一步:"
echo "1. 打开 lib/app/routes/app_routes.dart 配置路由"
echo "2. 实现数据仓库层"
echo "3. 开发 UI 页面"
echo ""
echo "运行应用：flutter run"
