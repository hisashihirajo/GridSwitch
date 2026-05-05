import AppKit
import ApplicationServices

// アクセシビリティ権限の確認・要求
enum AccessibilityChecker {
  // 権限チェック（付与済みならtrue）
  static func isAccessibilityGranted() -> Bool {
    return AXIsProcessTrusted()
  }

  // 権限要求ダイアログを表示
  static func requestAccessibility() -> Bool {
    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
    return AXIsProcessTrustedWithOptions(options)
  }

  // Input Monitoring権限チェック
  static func isInputMonitoringGranted() -> Bool {
    return CGPreflightListenEventAccess()
  }

  // Input Monitoring権限要求
  static func requestInputMonitoring() -> Bool {
    return CGRequestListenEventAccess()
  }

  // 権限がなければダイアログを出してアプリを終了案内
  static func ensureAccessibility() {
    NSLog("[GridSwitch] アクセシビリティ権限チェック: %@", isAccessibilityGranted() ? "許可済み" : "未許可")
    NSLog("[GridSwitch] Input Monitoring権限チェック: %@", isInputMonitoringGranted() ? "許可済み" : "未許可")

    if !isAccessibilityGranted() {
      let granted = requestAccessibility()
      if !granted {
        let alert = NSAlert()
        alert.messageText = L10n.accessibilityRequired
        alert.informativeText = L10n.accessibilityMessage
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
      }
    }

    // Input Monitoring権限を強制要求（CGPreflightListenEventAccessが嘘をつくケースがあるため無条件で呼ぶ）
    NSLog("[GridSwitch] Input Monitoring権限を要求（無条件）")
    let imGranted = requestInputMonitoring()
    NSLog("[GridSwitch] Input Monitoring権限要求結果: %@", imGranted ? "許可" : "未許可")
  }
}
