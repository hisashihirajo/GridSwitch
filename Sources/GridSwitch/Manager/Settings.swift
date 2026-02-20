import AppKit

// UserDefaultsで永続化する設定
class Settings {
  static let shared = Settings()

  private let defaults = UserDefaults.standard

  // キー
  private enum Key: String {
    case iconSize
    case backgroundColorR
    case backgroundColorG
    case backgroundColorB
    case backgroundOpacity
    case backgroundImagePath
    case backgroundImageOpacity
    case language
    case appMruOrder
    case hiddenApps
    case maxColumns
    case showNumberShortcuts
  }

  private init() {
    registerDefaults()
  }

  private func registerDefaults() {
    defaults.register(defaults: [
      Key.iconSize.rawValue: 64.0,
      Key.backgroundColorR.rawValue: 0.0,
      Key.backgroundColorG.rawValue: 0.0,
      Key.backgroundColorB.rawValue: 0.0,
      Key.backgroundOpacity.rawValue: 0.85,
      Key.backgroundImageOpacity.rawValue: 1.0,
      Key.language.rawValue: "ja",
      Key.maxColumns.rawValue: 8,
      Key.showNumberShortcuts.rawValue: true,
    ])
  }

  // アイコンサイズ（32〜128）
  var iconSize: CGFloat {
    get { CGFloat(defaults.double(forKey: Key.iconSize.rawValue)) }
    set {
      defaults.set(Double(newValue), forKey: Key.iconSize.rawValue)
      notifyChanged()
    }
  }

  // 背景色
  var backgroundColor: NSColor {
    get {
      NSColor(
        red: CGFloat(defaults.double(forKey: Key.backgroundColorR.rawValue)),
        green: CGFloat(defaults.double(forKey: Key.backgroundColorG.rawValue)),
        blue: CGFloat(defaults.double(forKey: Key.backgroundColorB.rawValue)),
        alpha: 1.0
      )
    }
    set {
      var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
      let converted = newValue.usingColorSpace(.sRGB) ?? newValue
      converted.getRed(&r, green: &g, blue: &b, alpha: &a)
      defaults.set(Double(r), forKey: Key.backgroundColorR.rawValue)
      defaults.set(Double(g), forKey: Key.backgroundColorG.rawValue)
      defaults.set(Double(b), forKey: Key.backgroundColorB.rawValue)
      notifyChanged()
    }
  }

  // 背景透過レベル（0.0〜1.0）
  var backgroundOpacity: CGFloat {
    get { CGFloat(defaults.double(forKey: Key.backgroundOpacity.rawValue)) }
    set {
      defaults.set(Double(newValue), forKey: Key.backgroundOpacity.rawValue)
      notifyChanged()
    }
  }

  // 背景画像の透過レベル（0.0〜1.0）
  var backgroundImageOpacity: CGFloat {
    get { CGFloat(defaults.double(forKey: Key.backgroundImageOpacity.rawValue)) }
    set {
      defaults.set(Double(newValue), forKey: Key.backgroundImageOpacity.rawValue)
      notifyChanged()
    }
  }

  // 背景画像パス（空文字列 = なし）
  var backgroundImagePath: String {
    get { defaults.string(forKey: Key.backgroundImagePath.rawValue) ?? "" }
    set {
      defaults.set(newValue, forKey: Key.backgroundImagePath.rawValue)
      notifyChanged()
    }
  }

  // 背景画像を読み込み（設定済みかつファイルが存在する場合）
  var backgroundImage: NSImage? {
    let path = backgroundImagePath
    guard !path.isEmpty else { return nil }
    return NSImage(contentsOfFile: path)
  }

  // 言語
  var language: String {
    get { defaults.string(forKey: Key.language.rawValue) ?? "ja" }
    set {
      defaults.set(newValue, forKey: Key.language.rawValue)
      notifyChanged()
    }
  }

  // 非表示アプリ（mruKeyの配列）
  var hiddenApps: [String] {
    get { defaults.stringArray(forKey: Key.hiddenApps.rawValue) ?? [] }
    set {
      defaults.set(newValue, forKey: Key.hiddenApps.rawValue)
      notifyChanged()
    }
  }

  // MRU順序（bundleIdentifierの配列、最近使った順）
  var appMruOrder: [String] {
    get { defaults.stringArray(forKey: Key.appMruOrder.rawValue) ?? [] }
    set {
      defaults.set(newValue, forKey: Key.appMruOrder.rawValue)
    }
  }

  // 1行あたりの最大列数（4〜12）
  var maxColumns: Int {
    get { defaults.integer(forKey: Key.maxColumns.rawValue) }
    set {
      defaults.set(min(max(newValue, 4), 12), forKey: Key.maxColumns.rawValue)
      notifyChanged()
    }
  }

  // 数字キーショートカットの表示・有効化
  var showNumberShortcuts: Bool {
    get { defaults.bool(forKey: Key.showNumberShortcuts.rawValue) }
    set {
      defaults.set(newValue, forKey: Key.showNumberShortcuts.rawValue)
      notifyChanged()
    }
  }

  // セルサイズ（アイコンサイズに連動）
  var cellWidth: CGFloat { iconSize + 36 }
  var cellHeight: CGFloat { iconSize + 36 }

  // 変更通知
  static let changedNotification = Notification.Name("SettingsChanged")

  private func notifyChanged() {
    NotificationCenter.default.post(name: Settings.changedNotification, object: nil)
  }
}
