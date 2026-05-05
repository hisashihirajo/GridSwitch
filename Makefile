APP_NAME = GridSwitch
EXECUTABLE = .build/arm64-apple-macosx/debug/$(APP_NAME)
SIGN_IDENTITY = GridSwitch Developer
BUNDLE_ID = com.local.GridSwitch

# デフォルト: ビルド＋署名
.PHONY: build run clean release

build:
	swift build
	@codesign --force --sign "$(SIGN_IDENTITY)" --identifier "$(BUNDLE_ID)" --entitlements Resources/GridSwitch.entitlements "$(EXECUTABLE)" 2>/dev/null
	@# 署名検証: ad-hoc署名だとInput Monitoring権限が無効化される
	@if codesign -d --verbose=0 "$(EXECUTABLE)" 2>&1 | grep -q "adhoc"; then \
		echo "❌ エラー: ad-hoc署名です。証明書 '$(SIGN_IDENTITY)' が見つかりません"; \
		exit 1; \
	fi
	@echo "ビルド＋署名完了"

run: build
	@pkill -x "$(APP_NAME)" 2>/dev/null || true
	@sleep 0.5
	@nohup "$(EXECUTABLE)" > /tmp/gridswitch.log 2>&1 &
	@sleep 1.5
	@# EventTapが有効かTCC権限を確認
	@if ! grep -q "CGEventTap開始" /tmp/gridswitch.log 2>/dev/null; then \
		echo "❌ EventTap起動失敗。ログ: /tmp/gridswitch.log"; \
		exit 1; \
	fi
	@# Input Monitoring権限が失われていないか確認
	@if grep -q "Input Monitoring権限チェック: 未許可" /tmp/gridswitch.log 2>/dev/null; then \
		echo "⚠️  Input Monitoring権限が失われています。"; \
		echo "   実行: sudo tccutil reset ListenEvent com.local.GridSwitch"; \
		echo "   その後: システム設定 > プライバシーとセキュリティ > 入力監視 で再許可"; \
	fi
	@echo "起動完了（ログ: /tmp/gridswitch.log）"

clean:
	swift package clean

release:
	./scripts/build-app.sh
