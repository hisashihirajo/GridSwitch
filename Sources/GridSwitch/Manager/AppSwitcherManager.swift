import AppKit

// 全コンポーネントの連携を管理
class AppSwitcherManager {
  private let appProvider = RunningAppProvider()
  private let panel = SwitcherPanel()
  private let eventHandler = KeyboardEventHandler.shared

  func start() {
    // アクセシビリティ権限の確認・要求
    AccessibilityChecker.ensureAccessibility()

    // イベントハンドラのコールバック設定
    eventHandler.onCmdTabPressed = { [weak self] in
      self?.showSwitcher()
    }

    eventHandler.onTabPressed = { [weak self] in
      self?.panel.selectNext()
    }

    eventHandler.onShiftTabPressed = { [weak self] in
      self?.panel.selectPrevious()
    }

    eventHandler.onCmdReleased = { [weak self] in
      self?.activateSelectedApp()
    }

    eventHandler.onEscPressed = { [weak self] in
      self?.cancelSwitcher()
    }

    eventHandler.onArrowUp = { [weak self] in
      self?.panel.selectUp()
    }

    eventHandler.onArrowDown = { [weak self] in
      self?.panel.selectDown()
    }

    eventHandler.onArrowLeft = { [weak self] in
      self?.panel.selectLeft()
    }

    eventHandler.onArrowRight = { [weak self] in
      self?.panel.selectRight()
    }

    // マウスクリックでアプリ切り替え
    panel.onClickActivate = { [weak self] in
      self?.activateSelectedApp()
    }

    // アプリリスト変更の監視
    appProvider.onAppsChanged = { [weak self] in
      self?.appProvider.refreshApps()
    }

    // アプリのアクティベーション通知でMRUを常時追跡
    NSWorkspace.shared.notificationCenter.addObserver(
      self,
      selector: #selector(appDidActivate(_:)),
      name: NSWorkspace.didActivateApplicationNotification,
      object: nil
    )

    // CGEventTap開始
    let started = eventHandler.start()
    if !started {
      NSLog("CGEventTapの開始に失敗。アクセシビリティ権限を確認してください。")
    }

    // タイムアウト復帰のための定期チェック
    Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
      self?.eventHandler.reEnableTapIfNeeded()
    }
  }

  func stop() {
    eventHandler.stop()
    panel.dismiss()
    NSWorkspace.shared.notificationCenter.removeObserver(self)
  }

  // アプリがアクティブになるたびにMRU先頭に記録
  @objc private func appDidActivate(_ notification: Notification) {
    guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
      let bundleId = app.bundleIdentifier
    else { return }

    var order = Settings.shared.appMruOrder
    order.removeAll { $0 == bundleId }
    order.insert(bundleId, at: 0)
    Settings.shared.appMruOrder = order
  }

  private func showSwitcher() {
    appProvider.refreshApps()
    let apps = appProvider.appsWithMruOrder()
    panel.showWithApps(apps)
  }

  private func activateSelectedApp() {
    guard let appInfo = panel.selectedApp() else {
      panel.dismiss()
      return
    }

    panel.dismiss()

    // 選択されたアプリをアクティブにする
    // （MRU更新はappDidActivate通知で自動的に行われる）
    let runningApps = NSWorkspace.shared.runningApplications
    if let app = runningApps.first(where: { $0.processIdentifier == appInfo.pid }) {
      app.activate()
    }
  }

  private func cancelSwitcher() {
    panel.dismiss()
  }
}
