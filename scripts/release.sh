#!/bin/bash
# GridSwitch リリースビルド + 公証(notarization) + staple + 配布zip作成
#
# 前提: notarytool の資格情報プロファイルが Keychain に保存済みであること
#   xcrun notarytool store-credentials "notarize-lifescape" \
#     --apple-id <AppleID> --team-id LA555PK2S7 --password <App用パスワード>
#
# このスクリプトは公開(GitHub Release作成)はしない。配布用zipを作るところまで。

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="GridSwitch"
APP_BUNDLE="$PROJECT_DIR/build/${APP_NAME}.app"
NOTARIZE_ZIP="$PROJECT_DIR/build/${APP_NAME}-notarize.zip"
DIST_ZIP="$PROJECT_DIR/build/${APP_NAME}.zip"
KEYCHAIN_PROFILE="notarize-lifescape"

echo "=== GridSwitch リリース（公証込み）==="

# 1. 署名済み .app をビルド（build-app.sh: Release + Developer ID署名 + hardened runtime）
echo ""
echo "[1/6] アプリビルド + 署名"
"$SCRIPT_DIR/build-app.sh" >/dev/null
echo "  → $APP_BUNDLE"

# 2. 公証用zipを作成（ditto --keepParent で .app ごと固める）
echo ""
echo "[2/6] 公証用zip作成"
rm -f "$NOTARIZE_ZIP"
ditto -c -k --keepParent "$APP_BUNDLE" "$NOTARIZE_ZIP"
echo "  → $NOTARIZE_ZIP"

# 3. 公証サービスに送信（完了まで待つ）
echo ""
echo "[3/6] Appleへ公証を送信（数分かかることがあります）"
xcrun notarytool submit "$NOTARIZE_ZIP" \
  --keychain-profile "$KEYCHAIN_PROFILE" \
  --wait

# 4. チケットを .app に staple（オフラインのGatekeeper検証用）
echo ""
echo "[4/6] staple（チケット添付）"
xcrun stapler staple "$APP_BUNDLE"

# 5. 配布用zipを作成（staple済みの.appから）
echo ""
echo "[5/6] 配布用zip作成"
rm -f "$DIST_ZIP"
ditto -c -k --keepParent "$APP_BUNDLE" "$DIST_ZIP"
echo "  → $DIST_ZIP"

# 6. Gatekeeper検証
echo ""
echo "[6/6] Gatekeeper検証（accepted になればOK）"
spctl -a -vvv -t install "$APP_BUNDLE" 2>&1 | head -5 || true
xcrun stapler validate "$APP_BUNDLE" 2>&1 | tail -1

echo ""
echo "=== 完了 ==="
echo "配布zip: $DIST_ZIP"
VER=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP_BUNDLE/Contents/Info.plist")
echo "バージョン: $VER"
echo ""
echo "GitHub Release を作成するには:"
echo "  gh release create v$VER \"$DIST_ZIP\" --title \"GridSwitch v$VER\" --notes \"...\""
