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
      ? "グリッド型アプリケーションスイッチャー v1.0"
      : "Grid Application Switcher v1.0"
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
