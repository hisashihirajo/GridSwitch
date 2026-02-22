import AppKit
import ApplicationServices

// アプリ識別用の軽量struct（AppInfoへの依存を排除）
public struct DockBadgeApp {
  public let name: String
  public let pid: pid_t
  public let bundleIdentifier: String?

  public init(name: String, pid: pid_t, bundleIdentifier: String?) {
    self.name = name
    self.pid = pid
    self.bundleIdentifier = bundleIdentifier
  }
}

// Dockのバッジ数をAccessibility APIで取得（キャッシュ付き）
public class DockBadgeKit {
  public static let shared = DockBadgeKit()

  // キャッシュ（アプリ名 → バッジ文字列）
  private var cachedBadges: [String: String] = [:]
  private var timer: Timer?

  private init() {}

  // 定期更新を開始（メインスレッドのタイマー）
  public func startPeriodicUpdate(interval: TimeInterval = 2.0) {
    refreshBadges()
    timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
      self?.refreshBadges()
    }
  }

  public func stopPeriodicUpdate() {
    timer?.invalidate()
    timer = nil
  }

  // キャッシュから全バッジを取得（アプリ名 → バッジ文字列）
  public func getAllBadges() -> [String: String] {
    return cachedBadges
  }

  // キャッシュからバッジを取得（pid → バッジ文字列）
  public func getBadges(for apps: [DockBadgeApp]) -> [pid_t: String] {
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
