import AppKit

// 実行中アプリの情報モデル
struct AppInfo: Hashable {
  let name: String
  let icon: NSImage
  let pid: pid_t
  let bundleIdentifier: String?

  // MRU識別用キー（bundleId:名前 で同じbundleIdのPWAアプリを区別）
  var mruKey: String {
    let id = bundleIdentifier ?? "unknown"
    return "\(id):\(name)"
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(pid)
  }

  static func == (lhs: AppInfo, rhs: AppInfo) -> Bool {
    return lhs.pid == rhs.pid
  }

  // NSRunningApplicationから生成
  static func from(_ app: NSRunningApplication) -> AppInfo? {
    guard let name = app.localizedName else { return nil }
    var resolvedName = name
    var resolvedIcon = app.icon ?? NSImage(
      systemSymbolName: "app.fill",
      accessibilityDescription: name
    ) ?? NSImage()

    // 開発中Electronアプリの名前・アイコンをpackage.jsonから解決
    if isDevElectronApp(app), let bundleURL = app.bundleURL {
      let info = resolveDevElectronInfo(bundleURL)
      if let devName = info.name {
        resolvedName = devName
      }
      if let devIcon = info.icon {
        resolvedIcon = devIcon
      }
    }

    return AppInfo(
      name: resolvedName,
      icon: resolvedIcon,
      pid: app.processIdentifier,
      bundleIdentifier: app.bundleIdentifier
    )
  }

  // MARK: - 開発中Electronアプリ対応

  private static let devElectronMarker = "/node_modules/electron/dist/Electron.app"

  // 開発中Electronアプリかどうか判定
  private static func isDevElectronApp(_ app: NSRunningApplication) -> Bool {
    guard let bundleURL = app.bundleURL else { return false }
    return bundleURL.path.contains(devElectronMarker)
  }

  // package.jsonからアプリ名とアイコンを取得
  private static func resolveDevElectronInfo(_ bundleURL: URL) -> (name: String?, icon: NSImage?) {
    let path = bundleURL.path
    guard let range = path.range(of: devElectronMarker) else {
      return (nil, nil)
    }
    let projectRoot = String(path[path.startIndex..<range.lowerBound])
    let packageJsonPath = projectRoot + "/package.json"

    guard let data = FileManager.default.contents(atPath: packageJsonPath),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else {
      return (nil, nil)
    }

    // 名前の解決: build.productName > productName > name
    let buildDict = json["build"] as? [String: Any]
    let name = (buildDict?["productName"] as? String)
      ?? (json["productName"] as? String)
      ?? (json["name"] as? String)

    // アイコンの解決: build.mac.icon のパスから読み込む
    let icon = resolveDevElectronIcon(buildDict: buildDict, projectRoot: projectRoot)

    return (name, icon)
  }

  // build.mac.icon または build.icon からアイコンを読み込む
  private static func resolveDevElectronIcon(
    buildDict: [String: Any]?,
    projectRoot: String
  ) -> NSImage? {
    guard let buildDict = buildDict else { return nil }

    // build.mac.icon > build.icon の順で探す
    let macDict = buildDict["mac"] as? [String: Any]
    guard let iconRelPath = (macDict?["icon"] as? String) ?? (buildDict["icon"] as? String) else {
      return nil
    }

    let iconPath = projectRoot + "/" + iconRelPath

    // 指定パスをそのまま試す
    if let img = NSImage(contentsOfFile: iconPath) {
      return img
    }

    // 拡張子なしの場合、.icns → .png の順で探す
    if URL(fileURLWithPath: iconPath).pathExtension.isEmpty {
      for ext in ["icns", "png"] {
        if let img = NSImage(contentsOfFile: iconPath + "." + ext) {
          return img
        }
      }
    }

    return nil
  }
}
