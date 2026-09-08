import Foundation

// 対応言語
enum Language: String, CaseIterable {
  case ja = "ja"
  case en = "en"

  var displayName: String {
    switch self {
    case .ja: return "日本語"
    case .en: return "English"
    }
  }
}

// アプリ内ローカライズ文字列
enum L10n {
  // 現在の言語
  static var current: Language {
    return Language(rawValue: Settings.shared.language) ?? .ja
  }

  // 設定画面
  static var settings: String { current == .ja ? "設定" : "Settings" }
  static var iconSize: String { current == .ja ? "アイコンサイズ:" : "Icon Size:" }
  static var maxColumns: String { current == .ja ? "1行の最大数:" : "Max per Row:" }
  static var backgroundColor: String { current == .ja ? "背景色:" : "Background:" }
  static var backgroundOpacity: String { current == .ja ? "背景の透過:" : "BG Opacity:" }
  static var backgroundImage: String { current == .ja ? "背景画像:" : "BG Image:" }
  static var imageOpacity: String { current == .ja ? "画像の透過:" : "Image Opacity:" }
  static var selectImage: String { current == .ja ? "選択..." : "Select..." }
  static var clearImage: String { current == .ja ? "クリア" : "Clear" }
  static var selectImageTitle: String { current == .ja ? "背景画像を選択" : "Select Background Image" }
  static var noImage: String { current == .ja ? "未設定" : "Not Set" }
  static var numberShortcuts: String { current == .ja ? "数字キーでアプリを切り替え" : "Switch apps with number keys" }
  static var launchAtLogin: String { current == .ja ? "Mac起動時に自動で起動する" : "Launch at Login" }
  static var language: String { current == .ja ? "言語:" : "Language:" }

  // 非表示アプリ
  static var hiddenApps: String { current == .ja ? "非表示アプリ:" : "Hidden Apps:" }
  static var hiddenAppsDescription: String { current == .ja ? "チェックしたアプリはスイッチャーに表示されません" : "Checked apps will be hidden from the switcher" }
  static var editHiddenApps: String { current == .ja ? "編集..." : "Edit..." }
  static var hiddenAppsWindowTitle: String { current == .ja ? "非表示アプリの設定" : "Hidden Apps Settings" }
  static var noHiddenApps: String { current == .ja ? "なし" : "None" }

  // メニュー
  static var about: String { current == .ja ? "GridSwitch について" : "About GridSwitch" }
  static var settingsMenu: String { current == .ja ? "設定..." : "Settings..." }
  static var quit: String { current == .ja ? "終了" : "Quit" }

  // About
  static var aboutDescription: String {
    current == .ja
      ? "グリッド型アプリケーションスイッチャー v1.3"
      : "Grid Application Switcher v1.3"
  }

  // アップデート
  static var checkForUpdates: String { current == .ja ? "アップデートを確認..." : "Check for Updates..." }
  static var updateAvailable: String { current == .ja ? "アップデートがあります" : "Update Available" }
  static func updateMessage(newVersion: String) -> String {
    current == .ja
      ? "GridSwitch v\(newVersion) が利用可能です。今すぐ更新しますか？"
      : "GridSwitch v\(newVersion) is available. Would you like to update now?"
  }
  static var updateNow: String { current == .ja ? "今すぐ更新" : "Update Now" }
  static var updateLater: String { current == .ja ? "後で" : "Later" }
  static var noUpdateAvailable: String { current == .ja ? "最新バージョンです" : "You're up to date" }
  static var downloading: String { current == .ja ? "ダウンロード中..." : "Downloading..." }
  static var updateFailed: String { current == .ja ? "アップデートに失敗しました" : "Update failed" }

  // セキュア入力スタック
  // 原因アプリ名が特定できた場合はメニュー項目にも表示する（例:「⚠️ セキュア入力が有効・原因: Bitwarden（Safari拡張）」）
  static func secureInputMenuItem(appName: String?) -> String {
    if let appName = appName {
      return current == .ja
        ? "⚠️ セキュア入力が有効・原因: \(appName)（Cmd+Tab無効）"
        : "⚠️ Secure Input active · \(appName) (Cmd+Tab disabled)"
    }
    return current == .ja
      ? "⚠️ セキュア入力が有効（Cmd+Tab無効）"
      : "⚠️ Secure Input active (Cmd+Tab disabled)"
  }

  // ブラウザ拡張プロセスの表示名（例: 「Bitwarden（Safari拡張）」）
  static func browserExtensionName(appName: String) -> String {
    current == .ja ? "\(appName)（Safari拡張）" : "\(appName) (Safari extension)"
  }

  static var secureInputTitle: String {
    current == .ja ? "Cmd+Tab が一時的に無効です" : "Cmd+Tab is temporarily disabled"
  }

  // 原因プロセスを特定できた場合は、それを終了すれば直ることを案内する。
  // ログアウトやMac再起動は不要（保持元プロセスを終了させれば解除される）。
  static func secureInputMessage(appName: String?) -> String {
    if let appName = appName {
      return current == .ja
        ? "macOSの「セキュアキー入力」が有効なため、Cmd+Tab スイッチャーが反応しません。\n\n原因のアプリ: \(appName)\n\n下のボタンでこのアプリを終了すると、その場で解除されます。Macの再起動もログアウトも必要ありません。終了したアプリは、次に必要になったときに自動で起動し直します。\n\nGridSwitch の不具合や権限の問題ではありません。"
        : "macOS \"Secure Input\" is active, so the Cmd+Tab switcher won't respond.\n\nApp holding Secure Input: \(appName)\n\nQuitting that app with the button below releases it immediately. No logout or restart needed; the app relaunches on its own when it is next needed.\n\nThis is not a GridSwitch bug or a permissions issue."
    }
    return current == .ja
      ? "macOSの「セキュアキー入力」が有効なため、Cmd+Tab スイッチャーが反応しません。\n\nこれはパスワードマネージャ等の別アプリが原因で、GridSwitch の不具合や権限の問題ではありません。\n\n原因のアプリを特定できませんでした。パスワードマネージャ（Bitwarden・1Password 等）とそのブラウザ拡張を終了すると解除されます。それでも直らない場合はログアウトして再ログインしてください。"
      : "macOS \"Secure Input\" is active, so the Cmd+Tab switcher won't respond.\n\nThis is caused by another app (e.g. a password manager), not a GridSwitch bug or a permissions issue.\n\nThe responsible app could not be identified. Quitting your password manager (Bitwarden, 1Password, etc.) and its browser extension releases it. If it persists, log out and back in."
  }

  // 解除ボタン（アラート）
  static func secureInputQuitButton(appName: String) -> String {
    current == .ja ? "\(appName) を終了して解除" : "Quit \(appName) and release"
  }
  // 解除ボタン（通知バナー。事前登録が必要なため固定文言）
  static var secureInputResolveAction: String {
    current == .ja ? "原因アプリを終了して解除" : "Quit the responsible app"
  }
  static var closeButton: String { current == .ja ? "閉じる" : "Close" }

  static var secureInputResolvedTitle: String {
    current == .ja ? "Cmd+Tab が使えるようになりました" : "Cmd+Tab is working again"
  }
  static func secureInputResolvedMessage(appName: String) -> String {
    current == .ja
      ? "\(appName) を終了し、セキュアキー入力を解除しました。"
      : "Quit \(appName) and released Secure Input."
  }
  static var secureInputNotResolvedTitle: String {
    current == .ja ? "解除できませんでした" : "Could not release Secure Input"
  }
  static var secureInputNotResolvedMessage: String {
    current == .ja
      ? "アプリを終了しましたが、セキュアキー入力が有効なままです。他のアプリも保持している可能性があります。\n\nパスワードマネージャとそのブラウザ拡張をすべて終了しても直らない場合は、ログアウトして再ログインしてください。"
      : "The app was quit, but Secure Input is still active. Another app may also be holding it.\n\nIf quitting every password manager and its browser extension does not help, log out and back in."
  }

  // アクセシビリティ
  static var accessibilityRequired: String {
    current == .ja ? "アクセシビリティ権限が必要です" : "Accessibility Permission Required"
  }
  static var accessibilityMessage: String {
    current == .ja
      ? "システム設定 > プライバシーとセキュリティ > アクセシビリティ で GridSwitch を許可してください。\n許可後、アプリを再起動してください。"
      : "Please allow GridSwitch in System Settings > Privacy & Security > Accessibility.\nRestart the app after granting permission."
  }
}
