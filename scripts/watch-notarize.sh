#!/bin/bash
# 複数の公証送信IDを長時間・静かに監視し、最初にAcceptedになったもので
# staple→配布zip→検証→通知まで行う。Apple側バックログ用。
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_BUNDLE="$PROJECT_DIR/build/GridSwitch.app"
DIST_ZIP="$PROJECT_DIR/build/GridSwitch.zip"
PROFILE="notarize-lifescape"
IDS=("$@")
[ ${#IDS[@]} -gt 0 ] || { echo "使い方: watch-notarize.sh <id> [id...]"; exit 1; }

# 60秒間隔・最大360回(6時間)
for i in $(seq 1 360); do
  for ID in "${IDS[@]}"; do
    ST=$(xcrun notarytool info "$ID" --keychain-profile "$PROFILE" 2>/dev/null | awk -F': ' '/status:/{print $2}' | tail -1)
    if [ "$ST" = "Accepted" ]; then
      echo "[OK] Accepted: $ID （${i}回目/$(date -u +%H:%MZ)）"
      xcrun stapler staple "$APP_BUNDLE"
      rm -f "$DIST_ZIP"; ditto -c -k --keepParent "$APP_BUNDLE" "$DIST_ZIP"
      spctl -a -vvv -t install "$APP_BUNDLE" 2>&1 | head -4
      xcrun stapler validate "$APP_BUNDLE" 2>&1 | tail -1
      echo "[完了] $DIST_ZIP"
      osascript -e 'display notification "GridSwitch v1.3 公証完了・配布zip作成OK" with title "GridSwitch リリース" sound name "Glass"' 2>/dev/null || true
      exit 0
    fi
    if [ "$ST" = "Invalid" ] || [ "$ST" = "Rejected" ]; then
      echo "[NG] $ST: $ID"; xcrun notarytool log "$ID" --keychain-profile "$PROFILE" 2>&1 | head -40; exit 2
    fi
  done
  # 10分ごとだけ生存ログ
  [ $((i % 10)) -eq 0 ] && echo "  [$(date -u +%H:%MZ)] まだ In Progress（${i}分経過）"
  sleep 60
done
echo "[時間切れ] 6時間Acceptedにならず。Apple側の長期バックログ。後で再確認を。"
osascript -e 'display notification "公証が6時間未完了。Apple側バックログの可能性。" with title "GridSwitch リリース" sound name "Basso"' 2>/dev/null || true
exit 0
