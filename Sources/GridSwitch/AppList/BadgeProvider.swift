import AppKit
import ApplicationServices

// Dockのバッジ数をAccessibility APIで取得（キャッシュ付き）
class BadgeProvider {
  static let shared = BadgeProvider()

  // キャッシュ（アプリ名 → バッジ文字列）
  private var cachedBadges: [String: String] = [:]
  private var timer: Timer?

  private init() {}

  // 定期更新を開始（メインスレッドのタイマー）
  func startPeriodicUpdate() {
    refreshBadges()
    timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
      self?.refreshBadges()
    }
  }

  func stopPeriodicUpdate() {
    timer?.invalidate()
    timer = nil
  }

  // キャッシュからバッジを取得（pid → バッジ文字列）
  func getBadges(for apps: [AppInfo]) -> [pid_t: String] {
    guard !cachedBadges.isEmpty else { return [:] }

    var result: [pid_t: String] = [:]
    for app in apps {
      // アプリ名で照合
      if let badge = cachedBadges[app.name] {
        result[app.pid] = badge
        continue
      }
      // bundleIdentifierからアプリ名を取得して照合
      if let bundleId = app.bundleIdentifier,
         let bundleURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
        let bundleName = FileManager.default.displayName(atPath: bundleURL.path)
          .replacingOccurrences(of: ".app", with: "")
        if let badge = cachedBadges[bundleName] {
          result[app.pid] = badge
        }
      }
    }
    return result
  }

  // DockのAXリストからバッジを取得してキャッシュ更新
  private func refreshBadges() {
    guard let dockApp = NSRunningApplication.runningApplications(
      withBundleIdentifier: "com.apple.dock"
    ).first else { return }

    let dockElement = AXUIElementCreateApplication(dockApp.processIdentifier)

    var children: AnyObject?
    guard AXUIElementCopyAttributeValue(dockElement, kAXChildrenAttribute as CFString, &children) == .success,
          let childrenArray = children as? [AXUIElement]
    else { return }

    var badges: [String: String] = [:]

    for child in childrenArray {
      var items: AnyObject?
      guard AXUIElementCopyAttributeValue(child, kAXChildrenAttribute as CFString, &items) == .success,
            let itemsArray = items as? [AXUIElement]
      else { continue }

      for item in itemsArray {
        var statusLabel: AnyObject?
        guard AXUIElementCopyAttributeValue(item, "AXStatusLabel" as CFString, &statusLabel) == .success,
              let badge = statusLabel as? String, !badge.isEmpty
        else { continue }

        var title: AnyObject?
        if AXUIElementCopyAttributeValue(item, kAXTitleAttribute as CFString, &title) == .success,
           let name = title as? String {
          badges[name] = badge
        }
      }
    }

    cachedBadges = badges
  }
}
