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
  }

  func applicationWillTerminate(_ notification: Notification) {
    switcherManager.stop()
  }

  private func setupMenuBarIcon() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    if let button = statusItem.button {
      button.image = NSImage(
        systemSymbolName: "square.grid.2x2",
        accessibilityDescription: "GridSwitch"
      )
    }

    let menu = NSMenu()
    menu.addItem(
      NSMenuItem(
        title: "GridSwitch について",
        action: #selector(showAbout),
        keyEquivalent: ""
      )
    )
    menu.addItem(
      NSMenuItem(
        title: "設定...",
        action: #selector(showSettings),
        keyEquivalent: ","
      )
    )
    menu.addItem(NSMenuItem.separator())
    menu.addItem(
      NSMenuItem(
        title: "終了",
        action: #selector(quit),
        keyEquivalent: "q"
      )
    )

    statusItem.menu = menu
  }

  @objc private func showAbout() {
    let alert = NSAlert()
    alert.messageText = "GridSwitch"
    alert.informativeText = "グリッド型アプリケーションスイッチャー v1.0"
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
