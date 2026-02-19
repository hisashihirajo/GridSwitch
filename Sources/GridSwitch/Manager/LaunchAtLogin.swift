import ServiceManagement

// ログイン時の自動起動を管理
enum LaunchAtLogin {
  private static let service = SMAppService.mainApp

  static var isEnabled: Bool {
    return service.status == .enabled
  }

  static func setEnabled(_ enabled: Bool) {
    do {
      if enabled {
        try service.register()
        NSLog("[GridSwitch] ログイン項目に登録しました")
      } else {
        try service.unregister()
        NSLog("[GridSwitch] ログイン項目から解除しました")
      }
    } catch {
      NSLog("[GridSwitch] ログイン項目の変更に失敗: %@", error.localizedDescription)
    }
  }
}
