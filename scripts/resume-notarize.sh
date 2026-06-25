#!/bin/bash
# 既存の公証送信(SUBMISSION_ID)の完了を待ち、staple→配布zip→検証まで行う。
# ネット断による一時エラーを許容して完了までリトライする。
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_BUNDLE="$PROJECT_DIR/build/GridSwitch.app"
DIST_ZIP="$PROJECT_DIR/build/GridSwitch.zip"
PROFILE="notarize-lifescape"
SUBMISSION_ID="${1:?使い方: resume-notarize.sh <submission-id>}"

echo "[待機] 公証完了をポーリング (id: $SUBMISSION_ID)"
for i in $(seq 1 240); do
  STATUS=$(xcrun notarytool info "$SUBMISSION_ID" --keychain-profile "$PROFILE" 2>/dev/null | awk -F': ' '/status:/{print $2}' | tail -1)
  echo "  [$i] status=${STATUS:-（取得失敗・ネット断?）}"
  case "$STATUS" in
    Accepted) echo "[OK] 公証承認"; break ;;
    Invalid|Rejected) echo "[NG] 公証失敗"; xcrun notarytool log "$SUBMISSION_ID" --keychain-profile "$PROFILE" 2>&1 | head -40; exit 2 ;;
  esac
  sleep 15
done

if [ "${STATUS:-}" != "Accepted" ]; then echo "[中断] 承認に至らず終了"; exit 3; fi

echo "[staple] チケット添付"
xcrun stapler staple "$APP_BUNDLE"

echo "[zip] 配布用zip作成"
rm -f "$DIST_ZIP"
ditto -c -k --keepParent "$APP_BUNDLE" "$DIST_ZIP"

echo "[検証] Gatekeeper"
spctl -a -vvv -t install "$APP_BUNDLE" 2>&1 | head -4
xcrun stapler validate "$APP_BUNDLE" 2>&1 | tail -1
echo "[完了] 配布zip: $DIST_ZIP"
osascript -e 'display notification "GridSwitch v1.3 公証完了・配布zip作成OK" with title "GridSwitch リリース" sound name "Glass"' 2>/dev/null || true
