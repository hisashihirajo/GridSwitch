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
  // セキュア入力を握っている原因プロセス（特定できなければ nil）
  private var secureInputCulprit: SecureInputCulprit?
  // 通知バナーの「原因アプリを終了して解除」ボタン用の識別子
  private let secureInputCategoryID = "secure-input-stuck"
  private let secureInputResolveActionID = "secure-input-resolve"

  // 生バイナリ実行（.appバンドル外。make run 等）では UNUserNotificationCenter が
  // bundleProxyForCurrentProcess is nil でクラッシュするため、通知機能は .app 実行時のみ有効化する。
  // メニューバーの⚠️警告は通知に依存しないので、通知無効時も引き続き機能する。
  private var canUseUserNotifications: Bool {
    Bundle.main.bundleURL.pathExtension == "app"
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    // ログインしても出てこない状態にならないようにする（点検: ~/bin/check-menubar-apps.py）
    MenuBarBoot.handleLoginArguments()
    MenuBarBoot.seedPosition()
    MenuBarBoot.ensureRegistered()
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
      UNUserNotificationCenter.current().delegate = self
      registerSecureInputNotificationCategory()
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    } else {
      NSLog("[GridSwitch] .appバンドル外実行のため通知機能を無効化（メニューバー⚠️警告のみ動作）")
    }

    secureInputMonitor.onStuckChanged = { [weak self] stuck, culprit in
      self?.isSecureInputStuck = stuck
      self?.secureInputCulprit = culprit
      self?.updateMenuBarIconForSecureInput(stuck)
      self?.rebuildMenu()
      if stuck {
        self?.postSecureInputNotification(culprit: culprit)
      }
    }
    secureInputMonitor.start()
  }

  // 通知バナーに「原因アプリを終了して解除」ボタンを持たせる。
  // アクションのタイトルは事前登録が必要なため、言語変更時に登録し直す。
  private func registerSecureInputNotificationCategory() {
    guard canUseUserNotifications else { return }
    let action = UNNotificationAction(
      identifier: secureInputResolveActionID,
      title: L10n.secureInputResolveAction,
      options: [.foreground]
    )
    let category = UNNotificationCategory(
      identifier: secureInputCategoryID,
      actions: [action],
      intentIdentifiers: [],
      options: []
    )
    UNUserNotificationCenter.current().setNotificationCategories([category])
  }

  // セキュア入力スタックを通知バナーで知らせる
  private func postSecureInputNotification(culprit: SecureInputCulprit?) {
    guard canUseUserNotifications else { return }
    let content = UNMutableNotificationContent()
    content.title = L10n.secureInputTitle
    content.body = L10n.secureInputMessage(appName: culprit?.displayName)
    // 終了させても支障が小さい既知のパスワードマネージャのときだけ解除ボタンを出す。
    if let culprit = culprit, culprit.isKnownPasswordManager {
      content.categoryIdentifier = secureInputCategoryID
    }
    let request = UNNotificationRequest(
      identifier: secureInputCategoryID,
      content: content,
      trigger: nil
    )
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
  }

  // 原因アプリを終了してセキュア入力を解除する。結果はアラートで知らせる。
  private func resolveSecureInput(_ culprit: SecureInputCulprit) {
    // 終了と解除待ちで数秒かかるため、UIを止めないようバックグラウンドで実行する。
    DispatchQueue.global(qos: .userInitiated).async {
      let terminated = SecureInputMonitor.terminate(culprit)
      let released = terminated && SecureInputMonitor.waitUntilReleased(timeout: 6)
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        if released {
          let alert = NSAlert()
          alert.messageText = L10n.secureInputResolvedTitle
          alert.informativeText = L10n.secureInputResolvedMessage(appName: culprit.displayName)
          alert.alertStyle = .informational
          alert.runModal()
        } else {
          self.showSecureInputNotResolvedAlert()
        }
      }
    }
  }

  private func showSecureInputNotResolvedAlert() {
    let alert = NSAlert()
    alert.messageText = L10n.secureInputNotResolvedTitle
    alert.informativeText = L10n.secureInputNotResolvedMessage
    alert.alertStyle = .warning
    alert.runModal()
  }

  @objc private func settingsDidChange() {
    rebuildMenu()
    // 言語が変わると通知ボタンの文言も変わるため登録し直す
    registerSecureInputNotificationCategory()
  }

  private func setupMenuBarIcon() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    statusItem.autosaveName = MenuBarBoot.autosaveName
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
        title: L10n.secureInputMenuItem(appName: secureInputCulprit?.displayName),
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
    // 表示の直前に原因プロセスを取り直す（検知時から入れ替わっていることがある）
    if let latest = SecureInputMonitor.currentCulprit() {
      secureInputCulprit = latest
    }
    let culprit = secureInputCulprit

    let alert = NSAlert()
    alert.messageText = L10n.secureInputTitle
    alert.informativeText = L10n.secureInputMessage(appName: culprit?.displayName)
    alert.alertStyle = .warning

    // 終了させても支障が小さい既知のパスワードマネージャのときだけ解除ボタンを出す。
    if let culprit = culprit, culprit.isKnownPasswordManager {
      alert.addButton(withTitle: L10n.secureInputQuitButton(appName: culprit.displayName))
      alert.addButton(withTitle: L10n.closeButton)
      if alert.runModal() == .alertFirstButtonReturn {
        resolveSecureInput(culprit)
      }
      return
    }
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

// MARK: - 通知バナーのボタン操作

extension AppDelegate: UNUserNotificationCenterDelegate {
  // GridSwitch がフォアグラウンドでも通知バナーを出す
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .sound])
  }

  // 「原因アプリを終了して解除」ボタンが押されたときの処理
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    defer { completionHandler() }
    guard response.actionIdentifier == secureInputResolveActionID else { return }
    // ボタンを押した時点で保持元が入れ替わっていることがあるため取り直す
    guard let culprit = SecureInputMonitor.currentCulprit() else {
      showSecureInputNotResolvedAlert()
      return
    }
    secureInputCulprit = culprit
    resolveSecureInput(culprit)
  }
}
