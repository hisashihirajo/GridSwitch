import Carbon.HIToolbox
import Foundation

// セキュアキー入力(Secure Input Mode)の検知。
//
// secure input が有効な間、CGEventTap には keyDown が配送されない（修飾キーの
// flagsChanged のみ流れる）。このため GridSwitch の Cmd+Tab が無反応になる。
// これは macOS の仕様で、パスワードマネージャ等が secure input を有効化したまま
// 解放し損ねると発生する。GridSwitch 側のバグでも署名/権限の問題でもなく、
// アプリ側でイベントタップを使う以上は回避できない。
//
// 通常のパスワード入力でも secure input は一瞬有効になるため、誤通知を避ける目的で
// 一定時間(stuckThreshold)継続して有効な場合のみ「スタック」とみなして通知する。
final class SecureInputMonitor {
  // スタック判定のしきい値（秒）。通常のパスワード入力は数秒で完了するため、
  // これを超えて継続している場合は解放漏れ（スタック）と判断する。
  private let stuckThreshold: TimeInterval = 90

  // チェック間隔（秒）
  private let checkInterval: TimeInterval = 5

  private var timer: Timer?
  private var enabledSince: Date?
  private(set) var isStuck = false

  // スタック状態が変化したときにメインスレッドで呼ばれる（true=検知, false=解消）
  var onStuckChanged: ((Bool) -> Void)?

  // 監視開始（メインRunLoopで実行）
  func start() {
    let timer = Timer(timeInterval: checkInterval, repeats: true) { [weak self] _ in
      self?.check()
    }
    RunLoop.main.add(timer, forMode: .common)
    self.timer = timer
  }

  func stop() {
    timer?.invalidate()
    timer = nil
  }

  private func check() {
    let enabled = IsSecureEventInputEnabled()

    if enabled {
      let since = enabledSince ?? Date()
      enabledSince = since
      if Date().timeIntervalSince(since) >= stuckThreshold && !isStuck {
        isStuck = true
        NSLog("[GridSwitch] セキュア入力スタック検知: Cmd+Tabが無効化されています")
        onStuckChanged?(true)
      }
    } else {
      enabledSince = nil
      if isStuck {
        isStuck = false
        NSLog("[GridSwitch] セキュア入力スタック解消")
        onStuckChanged?(false)
      }
    }
  }
}
