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
  // セキュア入力を握っている原因アプリ名（特定できなければ nil）
  private var secureInputCulpritAppName: String?

  // 生バイナリ実行（.appバンドル外。make run 等）では UNUserNotificationCenter が
  // bundleProxyForCurrentProcess is nil でクラッシュするため、通知機能は .app 実行時のみ有効化する。
  // メニューバーの⚠️警告は通知に依存しないので、通知無効時も引き続き機能する。
  private var canUseUserNotifications: Bool {
    Bundle.main.bundleURL.pathExtension == "app"
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSLog("[GridSwitch] applicationDidFinishLaunching")
    setupMenuBarIcon()
    NSLog("[GridSwitch] メニューバーアイコン設定完了")
    switcherManager.start()
    NSLog("[GridSwitch] 起動完了")

    setupSecureInputMonitor()

    // バックグラウンドでアップデートチェック（.appバンドル実行時のみ）。
    // 生バイナリ実行（make run）では currentVersion="0.0.0" で常に更新ありと誤判定し、
    // relaunch(open .build/...)失敗→terminate で自滅するため無効化する。
    if canUseUserNotifications {
      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
        UpdateChecker.shared.checkForUpdatesInBackground()
      }
    } else {
      NSLog("[GridSwitch] .appバンドル外実行のため自動更新チェックを無効化")
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
    if canUseUserNotifications {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    } else {
      NSLog("[GridSwitch] .appバンドル外実行のため通知機能を無効化（メニューバー⚠️警告のみ動作）")
    }

    secureInputMonitor.onStuckChanged = { [weak self] stuck, appName in
      self?.isSecureInputStuck = stuck
      self?.secureInputCulpritAppName = appName
      self?.updateMenuBarIconForSecureInput(stuck)
      self?.rebuildMenu()
      if stuck {
        self?.postSecureInputNotification(appName: appName)
      }
    }
    secureInputMonitor.start()
  }

  // セキュア入力スタックを通知バナーで知らせる
  private func postSecureInputNotification(appName: String?) {
    guard canUseUserNotifications else { return }
    let content = UNMutableNotificationContent()
    content.title = L10n.secureInputTitle
    content.body = L10n.secureInputMessage(appName: appName)
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
        title: L10n.secureInputMenuItem(appName: secureInputCulpritAppName),
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
    alert.informativeText = L10n.secureInputMessage(appName: secureInputCulpritAppName)
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
