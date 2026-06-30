# Release CI セットアップ手順

`vX.Y` タグを push すると `.github/workflows/release.yml` が走り、**ビルド→署名→公証→staple→GitHub Release作成**まで自動で行う。
初回だけ以下の Secrets を登録する（証明書・公証資格情報はチーム/アカウント単位なので一度作れば他アプリでも使い回せる）。

公証は **Apple ID + App用パスワード + Team ID** 方式を使う。App Store Connect API キーは「アクセス権をリクエスト」の承認関門があり即時発行できないため採用しない（App用パスワードは appleid.apple.com で即時発行でき、notarytool では同等に使える）。

## 1. Developer ID 証明書を .p12 で書き出す

Keychain Access（キーチェーンアクセス）で：
1. 「ログイン」キーチェーン →「分類: 自分の証明書」
2. **Developer ID Application: LIFE SCAPE, K.K.** を**秘密鍵ごと**（▶で展開して鍵も一緒に選択）右クリック →「2項目を書き出す…」
3. `.p12` 形式で保存（書き出しパスワードを設定 → これが `DEVELOPER_ID_CERT_PASSWORD`）

base64化:
```
base64 -i DeveloperID.p12 | pbcopy   # → DEVELOPER_ID_CERT_P12_BASE64
```

## 2. 公証用 App用パスワード（appleid.apple.com）

1. https://appleid.apple.com にサインイン（Developerアカウントの Apple ID）
2. 「サインインとセキュリティ」→「App用パスワード」→「+」で新規生成（名前: 例 `GridSwitch Notarize CI`）
3. 表示された `xxxx-xxxx-xxxx-xxxx` を控える（**再表示不可なので保管**）→ これが `APPLE_APP_PASSWORD`

Team ID は LIFE SCAPE のもの: **LA555PK2S7**（`APPLE_TEAM_ID`）。

## 3. GitHub Secrets を登録

リポジトリ Settings → Secrets and variables → Actions、または gh CLI：
```
gh secret set DEVELOPER_ID_CERT_P12_BASE64 --repo hisashihirajo/GridSwitch < <(base64 -i DeveloperID.p12)
gh secret set DEVELOPER_ID_CERT_PASSWORD   --repo hisashihirajo/GridSwitch   # 対話で入力
gh secret set KEYCHAIN_PASSWORD            --repo hisashihirajo/GridSwitch   # 任意のランダム文字列
gh secret set APPLE_ID                     --repo hisashihirajo/GridSwitch   # 公証用Apple IDのメール
gh secret set APPLE_APP_PASSWORD           --repo hisashihirajo/GridSwitch   # xxxx-xxxx-xxxx-xxxx
gh secret set APPLE_TEAM_ID                --repo hisashihirajo/GridSwitch   # LA555PK2S7
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
