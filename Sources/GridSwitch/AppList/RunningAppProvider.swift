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
    let activeApp = NSWorkspace.shared.frontmostApplication
    var sorted = apps
    if let activePid = activeApp?.processIdentifier,
      let index = sorted.firstIndex(where: { $0.pid == activePid })
    {
      let active = sorted.remove(at: index)
      sorted.insert(active, at: 0)
    }
    return sorted
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
