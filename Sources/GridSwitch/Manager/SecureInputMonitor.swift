import AppKit
import Carbon.HIToolbox
import Darwin
import Foundation
import IOKit

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
//
// スタック検知時は、原因アプリを IORegistry の kCGSSessionSecureInputPID から特定し、
// アプリ名を通知に含める（例: 「原因のアプリ: Microsoft Word」）。
final class SecureInputMonitor {
  // スタック判定のしきい値（秒）。通常のパスワード入力は数秒で完了するため、
  // これを超えて継続している場合は解放漏れ（スタック）と判断する。
  private let stuckThreshold: TimeInterval = 90

  // チェック間隔（秒）
  private let checkInterval: TimeInterval = 5

  private var timer: Timer?
  private var enabledSince: Date?
  private(set) var isStuck = false

  // スタック検知時に特定した原因アプリ名（解決できなければ nil）
  private(set) var culpritAppName: String?

  // スタック状態が変化したときにメインスレッドで呼ばれる。
  // stuck=true のとき、第2引数に原因アプリ名（特定できなければ nil）を渡す。
  var onStuckChanged: ((Bool, String?) -> Void)?

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
        culpritAppName = Self.secureInputCulpritName()
        let culpritLog = culpritAppName ?? "特定不可"
        NSLog("[GridSwitch] セキュア入力スタック検知: Cmd+Tabが無効化されています（原因: \(culpritLog)）")
        onStuckChanged?(true, culpritAppName)
      }
    } else {
      enabledSince = nil
      if isStuck {
        isStuck = false
        culpritAppName = nil
        NSLog("[GridSwitch] セキュア入力スタック解消")
        onStuckChanged?(false, nil)
      }
    }
  }

  // MARK: - 原因アプリの特定

  // セキュア入力を保持しているアプリ名を返す（特定できなければ nil）。
  static func secureInputCulpritName() -> String? {
    guard let pid = secureInputCulpritPID() else { return nil }
    return processDisplayName(forPID: pid)
  }

  // IORegistry の IOResources ノードが持つ IOConsoleUsers 配列から、
  // kCGSSessionSecureInputPID（セキュア入力を保持しているプロセスのPID）を読む。
  // 保持プロセスが無い場合は PID=0 なので nil を返す。
  private static func secureInputCulpritPID() -> pid_t? {
    let entry = IORegistryEntryFromPath(kIOMainPortDefault, "IOService:/IOResources")
    guard entry != MACH_PORT_NULL else { return nil }
    defer { IOObjectRelease(entry) }

    guard
      let prop = IORegistryEntryCreateCFProperty(
        entry, "IOConsoleUsers" as CFString, kCFAllocatorDefault, 0
      )?.takeRetainedValue(),
      let users = prop as? [[String: Any]]
    else { return nil }

    for user in users {
      if let pid = user["kCGSSessionSecureInputPID"] as? pid_t, pid != 0 {
        return pid
      }
    }
    return nil
  }

  // PID から表示用のアプリ名を解決する。
  // GUIアプリは NSRunningApplication で localizedName（例: 「Microsoft Word」）を取得。
  // Safari拡張(appex)等で解決できない場合は実行ファイル名にフォールバックする。
  private static func processDisplayName(forPID pid: pid_t) -> String? {
    if let app = NSRunningApplication(processIdentifier: pid),
      let name = app.localizedName, !name.isEmpty
    {
      return name
    }

    var pathBuffer = [CChar](repeating: 0, count: Int(MAXPATHLEN))
    let length = proc_pidpath(pid, &pathBuffer, UInt32(pathBuffer.count))
    if length > 0 {
      let path = String(cString: pathBuffer)
      return (path as NSString).lastPathComponent
    }
    return nil
  }
}
