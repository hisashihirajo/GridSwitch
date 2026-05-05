#!/bin/bash
# GridSwitch.app ビルドスクリプト
# Releaseビルド → .appバンドル作成 → コード署名

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="GridSwitch"
BUILD_DIR="$PROJECT_DIR/.build"
APP_BUNDLE="$PROJECT_DIR/build/${APP_NAME}.app"

echo "=== GridSwitch アプリビルド ==="
echo "プロジェクト: $PROJECT_DIR"

# 1. Releaseビルド
echo ""
echo "[1/4] Release ビルド中..."
cd "$PROJECT_DIR"
swift build -c release

EXECUTABLE="$BUILD_DIR/release/$APP_NAME"
if [ ! -f "$EXECUTABLE" ]; then
  echo "エラー: 実行ファイルが見つかりません: $EXECUTABLE"
  exit 1
fi
echo "  → ビルド成功: $(du -h "$EXECUTABLE" | awk '{print $1}')"

# 2. .app バンドル構築
echo ""
echo "[2/4] アプリバンドル作成中..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# 実行ファイルをコピー
cp "$EXECUTABLE" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# Info.plist をコピー
cp "$PROJECT_DIR/Resources/Info.plist" "$APP_BUNDLE/Contents/"

# アイコンをコピー
if [ -f "$PROJECT_DIR/Resources/AppIcon.icns" ]; then
  cp "$PROJECT_DIR/Resources/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/"
  echo "  → アイコン配置完了"
fi

echo "  → バンドル構築完了"

# 3. コード署名（開発者証明書で署名 — アクセシビリティ権限の永続化に必要）
echo ""
echo "[3/4] コード署名中..."
SIGN_IDENTITY="GridSwitch Developer"
codesign --force --sign "$SIGN_IDENTITY" --identifier "com.local.GridSwitch" --entitlements "$PROJECT_DIR/Resources/GridSwitch.entitlements" --deep "$APP_BUNDLE"

# 署名検証: ad-hoc署名だとInput Monitoring権限が無効化される
if codesign -d --verbose=0 "$APP_BUNDLE" 2>&1 | grep -q "adhoc"; then
  echo "  ❌ エラー: ad-hoc署名です。証明書 '$SIGN_IDENTITY' が見つかりません"
  exit 1
fi
echo "  → 署名完了 (identity: $SIGN_IDENTITY)"

# 4. 完了
echo ""
echo "[4/4] 完了!"
echo "  アプリ: $APP_BUNDLE"
echo "  サイズ: $(du -sh "$APP_BUNDLE" | awk '{print $1}')"
echo ""
echo "インストール:"
echo "  cp -r \"$APP_BUNDLE\" /Applications/"
echo ""
echo "起動:"
echo "  open \"$APP_BUNDLE\""
