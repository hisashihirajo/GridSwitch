import AppKit

// 実行中アプリの取得・監視
class RunningAppProvider {
  private(set) var apps: [AppInfo] = []
  var onAppsChanged: (() -> Void)?

  init() {
    refreshApps()
    setupObservers()
  }

  deinit {
    NSWorkspace.shared.notificationCenter.removeObserver(self)
  }

  // .regularポリシーのアプリのみ取得（通常のGUIアプリ）
  func refreshApps() {
    apps = NSWorkspace.shared.runningApplications
      .filter { $0.activationPolicy == .regular }
      .compactMap { AppInfo.from($0) }
      .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
  }

  // 現在アクティブなアプリを先頭にしたリストを返す
  func appsWithActiveFirst() -> [AppInfo] {
    return Self.sortWithActiveFirst(
      apps: apps,
      activePid: NSWorkspace.shared.frontmostApplication?.processIdentifier
    )
  }

  // MRU順（最近使った順）でアプリリストを返す
  func appsWithMruOrder() -> [AppInfo] {
    return Self.orderByMru(
      apps: apps,
      mruOrder: Settings.shared.appMruOrder,
      hidden: Settings.shared.hiddenApps,
      activePid: NSWorkspace.shared.frontmostApplication?.processIdentifier
    )
  }

  // アクティブアプリを先頭にする純粋ロジック
  static func sortWithActiveFirst(apps: [AppInfo], activePid: pid_t?) -> [AppInfo] {
    var sorted = apps
    if let activePid,
       let index = sorted.firstIndex(where: { $0.pid == activePid })
    {
      let active = sorted.remove(at: index)
      sorted.insert(active, at: 0)
    }
    return sorted
  }

  // 非表示除外 + MRU順 + アクティブ先頭の純粋ロジック
  static func orderByMru(
    apps: [AppInfo],
    mruOrder: [String],
    hidden: [String],
    activePid: pid_t?
  ) -> [AppInfo] {
    var ordered: [AppInfo] = []
    var remaining = apps

    // 非表示アプリを除外
    let hiddenSet = Set(hidden)
    remaining.removeAll { hiddenSet.contains($0.mruKey) }

    // MRU順に並べる（mruKeyで同一bundleIdのPWAアプリも区別）
    for key in mruOrder {
      if let index = remaining.firstIndex(where: { $0.mruKey == key }) {
        ordered.append(remaining.remove(at: index))
      }
    }

    // MRUに含まれない新規アプリはアルファベット順で末尾に追加
    ordered.append(contentsOf: remaining)

    // アクティブアプリを先頭に
    if let activePid,
       let index = ordered.firstIndex(where: { $0.pid == activePid })
    {
      let active = ordered.remove(at: index)
      ordered.insert(active, at: 0)
    }

    return ordered
  }

  private func setupObservers() {
    let nc = NSWorkspace.shared.notificationCenter

    nc.addObserver(
      self,
      selector: #selector(appLaunched(_:)),
      name: NSWorkspace.didLaunchApplicationNotification,
      object: nil
    )

    nc.addObserver(
      self,
      selector: #selector(appTerminated(_:)),
      name: NSWorkspace.didTerminateApplicationNotification,
      object: nil
    )
  }

  @objc private func appLaunched(_ notification: Notification) {
    refreshApps()
    onAppsChanged?()
  }

  @objc private func appTerminated(_ notification: Notification) {
    refreshApps()
    onAppsChanged?()
  }
}
