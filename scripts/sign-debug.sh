#!/bin/bash
# デバッグビルドに開発者証明書で署名するスクリプト
# Xcodeアップデート後もアクセシビリティ権限を維持するために必要

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="GridSwitch"
EXECUTABLE="$PROJECT_DIR/.build/arm64-apple-macosx/debug/$APP_NAME"
SIGN_IDENTITY="GridSwitch Developer"
BUNDLE_ID="com.local.GridSwitch"

if [ ! -f "$EXECUTABLE" ]; then
  echo "エラー: 実行ファイルが見つかりません: $EXECUTABLE"
  echo "先に swift build を実行してください"
  exit 1
fi

echo "署名中: $EXECUTABLE"
codesign --force --sign "$SIGN_IDENTITY" --identifier "$BUNDLE_ID" "$EXECUTABLE"
echo "署名完了"
codesign -dvv "$EXECUTABLE" 2>&1 | grep -E "Identifier|Authority|TeamIdentifier"
