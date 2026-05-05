#!/bin/bash
# 開発用: ビルド → 署名 → 起動
# 使い方: ./scripts/dev.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="GridSwitch"
EXECUTABLE="$PROJECT_DIR/.build/arm64-apple-macosx/debug/$APP_NAME"
SIGN_IDENTITY="GridSwitch Developer"
BUNDLE_ID="com.local.GridSwitch"

cd "$PROJECT_DIR"

# 既存プロセスを停止
pkill -f "$APP_NAME" 2>/dev/null || true
sleep 0.3

# ビルド
echo "ビルド中..."
swift build 2>&1 | tail -3

# 署名（アクセシビリティ権限の維持に必要）
echo "署名中..."
codesign --force --sign "$SIGN_IDENTITY" --identifier "$BUNDLE_ID" "$EXECUTABLE"

# 起動（nohupでシェル終了後も維持）
echo "起動中..."
nohup "$EXECUTABLE" > /tmp/gridswitch.log 2>&1 &
echo "PID: $!"
echo "完了（ログ: /tmp/gridswitch.log）"
