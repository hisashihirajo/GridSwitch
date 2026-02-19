import AppKit

// 実行中アプリの情報モデル
struct AppInfo: Hashable {
  let name: String
  let icon: NSImage
  let pid: pid_t
  let bundleIdentifier: String?

  func hash(into hasher: inout Hasher) {
    hasher.combine(pid)
  }

  static func == (lhs: AppInfo, rhs: AppInfo) -> Bool {
    return lhs.pid == rhs.pid
  }

  // NSRunningApplicationから生成
  static func from(_ app: NSRunningApplication) -> AppInfo? {
    guard let name = app.localizedName else { return nil }
    let icon = app.icon ?? NSImage(
      systemSymbolName: "app.fill",
      accessibilityDescription: name
    ) ?? NSImage()
    return AppInfo(
      name: name,
      icon: icon,
      pid: app.processIdentifier,
      bundleIdentifier: app.bundleIdentifier
    )
  }
}
