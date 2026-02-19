import AppKit
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
  private var statusItem: NSStatusItem!
  private let switcherManager = AppSwitcherManager()
  private lazy var settingsWindowController = SettingsWindowController()

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSLog("[GridSwitch] applicationDidFinishLaunching")
    setupMenuBarIcon()
    NSLog("[GridSwitch] メニューバーアイコン設定完了")
    switcherManager.start()
    NSLog("[GridSwitch] 起動完了")

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
  }

  @objc private func settingsDidChange() {
    rebuildMenu()
  }

  private func setupMenuBarIcon() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    if let button = statusItem.button {
      button.image = NSImage(
        systemSymbolName: "square.grid.2x2",
        accessibilityDescription: "GridSwitch"
      )
    }

    rebuildMenu()
  }

  private func rebuildMenu() {
    let menu = NSMenu()
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

  @objc private func showSettings() {
    settingsWindowController.showWindow()
  }

  @objc private func quit() {
    NSApplication.shared.terminate(nil)
  }
}
