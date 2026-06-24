import AppKit
import Foundation
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
  private var statusItem: NSStatusItem!
  private let switcherManager = AppSwitcherManager()
  private lazy var settingsWindowController = SettingsWindowController()

  // セキュア入力スタック検知
  private let secureInputMonitor = SecureInputMonitor()
  private var isSecureInputStuck = false

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSLog("[GridSwitch] applicationDidFinishLaunching")
    setupMenuBarIcon()
    NSLog("[GridSwitch] メニューバーアイコン設定完了")
    switcherManager.start()
    NSLog("[GridSwitch] 起動完了")

    setupSecureInputMonitor()

    // バックグラウンドでアップデートチェック
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
      UpdateChecker.shared.checkForUpdatesInBackground()
    }

    // 言語変更時にメニューを再構築
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(settingsDidChange),
      name: Settings.changedNotification,
      object: nil
    )
  }

  func applicationWillTerminate(_ notification: Notification) {
    switcherManager.stop()
    secureInputMonitor.stop()
  }

  // セキュア入力スタックの監視を開始し、検知時に通知＋メニューバー警告を出す
  private func setupSecureInputMonitor() {
    // 通知許可をリクエスト（拒否されてもメニューバー警告は機能する）
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

    secureInputMonitor.onStuckChanged = { [weak self] stuck in
      self?.isSecureInputStuck = stuck
      self?.updateMenuBarIconForSecureInput(stuck)
      self?.rebuildMenu()
      if stuck {
        self?.postSecureInputNotification()
      }
    }
    secureInputMonitor.start()
  }

  // セキュア入力スタックを通知バナーで知らせる
  private func postSecureInputNotification() {
    let content = UNMutableNotificationContent()
    content.title = L10n.secureInputTitle
    content.body = L10n.secureInputMessage
    let request = UNNotificationRequest(
      identifier: "secure-input-stuck",
      content: content,
      trigger: nil
    )
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
  }

  @objc private func settingsDidChange() {
    rebuildMenu()
  }

  private func setupMenuBarIcon() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    updateMenuBarIconForSecureInput(false)
    rebuildMenu()
  }

  // セキュア入力スタック時はメニューバーアイコンを警告表示に切り替える
  private func updateMenuBarIconForSecureInput(_ stuck: Bool) {
    guard let button = statusItem?.button else { return }
    let symbol = stuck ? "exclamationmark.triangle.fill" : "square.grid.2x2"
    button.image = NSImage(systemSymbolName: symbol, accessibilityDescription: "GridSwitch")
    button.toolTip = stuck ? L10n.secureInputTitle : nil
  }

  private func rebuildMenu() {
    let menu = NSMenu()

    // セキュア入力スタック時は最上部に警告項目を出す
    if isSecureInputStuck {
      let warningItem = NSMenuItem(
        title: L10n.secureInputMenuItem,
        action: #selector(showSecureInputInfo),
        keyEquivalent: ""
      )
      menu.addItem(warningItem)
      menu.addItem(NSMenuItem.separator())
    }

    menu.addItem(
      NSMenuItem(
        title: L10n.about,
        action: #selector(showAbout),
        keyEquivalent: ""
      )
    )
    menu.addItem(
      NSMenuItem(
        title: L10n.settingsMenu,
        action: #selector(showSettings),
        keyEquivalent: ","
      )
    )
    menu.addItem(
      NSMenuItem(
        title: L10n.checkForUpdates,
        action: #selector(checkForUpdates),
        keyEquivalent: ""
      )
    )
    menu.addItem(NSMenuItem.separator())
    menu.addItem(
      NSMenuItem(
        title: L10n.quit,
        action: #selector(quit),
        keyEquivalent: "q"
      )
    )

    statusItem.menu = menu
  }

  @objc private func showAbout() {
    let alert = NSAlert()
    alert.messageText = "GridSwitch"
    alert.informativeText = L10n.aboutDescription
    alert.alertStyle = .informational
    alert.runModal()
  }

  @objc private func showSecureInputInfo() {
    let alert = NSAlert()
    alert.messageText = L10n.secureInputTitle
    alert.informativeText = L10n.secureInputMessage
    alert.alertStyle = .warning
    alert.runModal()
  }

  @objc private func showSettings() {
    settingsWindowController.showWindow()
  }

  @objc private func checkForUpdates() {
    UpdateChecker.shared.checkForUpdatesManually()
  }

  @objc private func quit() {
    NSApplication.shared.terminate(nil)
  }
}
