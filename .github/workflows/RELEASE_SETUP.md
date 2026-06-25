# Release CI セットアップ手順

`vX.Y` タグを push すると `.github/workflows/release.yml` が走り、**ビルド→署名→公証→staple→GitHub Release作成**まで自動で行う。
初回だけ以下の Secrets を登録する（証明書・APIキーはチーム単位なので一度作れば他アプリでも使い回せる）。

## 1. Developer ID 証明書を .p12 で書き出す

Keychain Access（キーチェーンアクセス）で：
1. 「ログイン」キーチェーン →「分類: 自分の証明書」
2. **Developer ID Application: LIFE SCAPE, K.K.** を**秘密鍵ごと**（▶で展開して鍵も一緒に選択）右クリック →「2項目を書き出す…」
3. `.p12` 形式で保存（書き出しパスワードを設定 → これが `DEVELOPER_ID_CERT_PASSWORD`）

base64化:
```
base64 -i DeveloperID.p12 | pbcopy   # → DEVELOPER_ID_CERT_P12_BASE64
```

## 2. App Store Connect APIキー（公証用・CI推奨）

App Store Connect → ユーザとアクセス → 「Integrations / キー」→ Team Keys で新規生成：
- アクセス権: **App Manager**（公証に十分。Developerロールだと不足する場合あり）
- `.p8` をダウンロード（**再ダウンロード不可なので保管**）
- **Key ID** と **Issuer ID** を控える

base64化:
```
base64 -i AuthKey_XXXXXX.p8 | pbcopy   # → NOTARY_KEY_P8_BASE64
```

## 3. GitHub Secrets を登録

リポジトリ Settings → Secrets and variables → Actions、または gh CLI：
```
gh secret set DEVELOPER_ID_CERT_P12_BASE64 --repo hisashihirajo/GridSwitch < <(base64 -i DeveloperID.p12)
gh secret set DEVELOPER_ID_CERT_PASSWORD   --repo hisashihirajo/GridSwitch   # 対話で入力
gh secret set KEYCHAIN_PASSWORD            --repo hisashihirajo/GridSwitch   # 任意のランダム文字列
gh secret set NOTARY_KEY_P8_BASE64         --repo hisashihirajo/GridSwitch < <(base64 -i AuthKey_XXXXXX.p8)
gh secret set NOTARY_KEY_ID                --repo hisashihirajo/GridSwitch   # 例: ABCD1234XY
gh secret set NOTARY_ISSUER_ID             --repo hisashihirajo/GridSwitch   # 例: 12ab34cd-...
```

## 4. リリースの出し方

```
# Info.plist と Localization の版数を上げてコミットしてから
git tag v1.4
git push origin v1.4
```
→ GitHub の Actions タブで進行（ビルド→公証→Release）が見え、完了/失敗はメール通知。

## 注意（公証の既知挙動）
- 初回公証の長時間ホールドは**最初の1本だけ**。GridSwitch は既に初回を通過済みなので、CI実行は数分で完了する。
- それでも稀にAppleキューが遅いと `notarytool submit --wait` が数十分かかることがある（ジョブが回ったまま待つだけ）。
- ローカル手動公証は `~/.claude/skills/notarize-macos-app/` のスキル/スクリプトを使う。
