import AppKit
import Carbon.HIToolbox
import Darwin
import Foundation
import IOKit

// セキュア入力を保持しているプロセス。
struct SecureInputCulprit {
  let pid: pid_t
  // 表示用の名前（例: 「Bitwarden（Safari拡張）」）
  let displayName: String
  let executablePath: String
  // 既知のパスワードマネージャ由来か。終了させても実害が小さいものだけ
  // ワンクリック解除の対象にする。
  let isKnownPasswordManager: Bool
}

// セキュアキー入力(Secure Input Mode)の検知。
//
// secure input が有効な間、CGEventTap には keyDown が配送されない（修飾キーの
// flagsChanged のみ流れる）。このため GridSwitch の Cmd+Tab が無反応になる。
// これは macOS の仕様で、パスワードマネージャ等が secure input を有効化したまま
// 解放し損ねると発生する。GridSwitch 側のバグでも署名/権限の問題でもない。
//
// 通常のパスワード入力でも secure input は一瞬有効になるため、誤通知を避ける目的で
// 一定時間(stuckThreshold)継続して有効な場合のみ「スタック」とみなして通知する。
// ただし Cmd+Tab を押したのに届かなかったとき（reportBlockedAttempt）は、10秒後も有効なら通知する。
//
// 保持元プロセスを終了させれば、ログアウトやMac再起動をしなくても解除できる
// （2026-09-08 に Bitwarden の Safari 拡張で実証）。
final class SecureInputMonitor {
  // スタック判定のしきい値（秒）。通常のパスワード入力は数秒で完了するため、
  // これを超えて継続している場合は解放漏れ（スタック）と判断する。
  private let stuckThreshold: TimeInterval = 90

  // チェック間隔（秒）
  private let checkInterval: TimeInterval = 5

  private var timer: Timer?
  private var enabledSince: Date?
  private(set) var isStuck = false

  // スタック検知時に特定した原因プロセス（解決できなければ nil）
  private(set) var culprit: SecureInputCulprit?

  // スタック状態が変化したときにメインスレッドで呼ばれる。
  // stuck=true のとき、第2引数に原因プロセス（特定できなければ nil）を渡す。
  var onStuckChanged: ((Bool, SecureInputCulprit?) -> Void)?

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
        culprit = Self.currentCulprit()
        NSLog(
          "[GridSwitch] セキュア入力スタック検知: Cmd+Tabが無効化されています（原因: \(culprit?.displayName ?? "特定不可")）"
        )
        onStuckChanged?(true, culprit)
      }
    } else {
      enabledSince = nil
      if isStuck {
        isStuck = false
        culprit = nil
        NSLog("[GridSwitch] セキュア入力スタック解消")
        onStuckChanged?(false, nil)
      }
    }
  }

  // Cmd+Tab が届かなかったあと、通知するまで待つ秒数。
  // パスワード入力中の一瞬のセキュア入力では通知せず、残り続けているときだけ知らせる。
  private let blockedAttemptDelay: TimeInterval = 10
  private var isBlockedAttemptPending = false

  // Cmd を押して離す間にキーが届かなかったときに呼ぶ（メインスレッド）。
  // そのときセキュア入力が有効で、10秒後もまだ有効なら、しきい値を待たずにスタックとして通知する。
  func reportBlockedAttempt() {
    guard !isStuck, !isBlockedAttemptPending, IsSecureEventInputEnabled() else { return }
    isBlockedAttemptPending = true
    DispatchQueue.main.asyncAfter(deadline: .now() + blockedAttemptDelay) { [weak self] in
      guard let self else { return }
      self.isBlockedAttemptPending = false
      guard !self.isStuck, IsSecureEventInputEnabled() else { return }
      self.isStuck = true
      self.enabledSince = self.enabledSince ?? Date()
      self.culprit = Self.currentCulprit()
      NSLog(
        "[GridSwitch] Cmd+Tabがセキュア入力で届きませんでした（原因: \(self.culprit?.displayName ?? "特定不可")）"
      )
      self.onStuckChanged?(true, self.culprit)
    }
  }

  // MARK: - 解除

  // 原因プロセスを終了させる。終了できたら true。
  // 生存確認のため待ちが入るので、バックグラウンドスレッドから呼ぶこと。
  static func terminate(_ culprit: SecureInputCulprit) -> Bool {
    NSLog("[GridSwitch] セキュア入力の保持元を終了します: \(culprit.displayName) (pid=\(culprit.pid))")

    // まずはアプリとして行儀よく終了させる。
    if let app = NSRunningApplication(processIdentifier: culprit.pid) {
      app.terminate()
      if waitUntilExited(pid: culprit.pid, timeout: 2) { return true }
    }

    // Safari拡張(appex)等はアプリとしての終了要求では落ちないため、シグナルを送る。
    if kill(culprit.pid, SIGTERM) != 0 {
      // 既に終了していれば目的は達成されている。
      return executablePath(forPID: culprit.pid) == nil
    }
    return waitUntilExited(pid: culprit.pid, timeout: 3)
  }

  // 指定PIDのプロセスが終了するまで待つ。
  private static func waitUntilExited(pid: pid_t, timeout: TimeInterval) -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
      if executablePath(forPID: pid) == nil { return true }
      Thread.sleep(forTimeInterval: 0.2)
    }
    return executablePath(forPID: pid) == nil
  }

  // セキュア入力が解除されるまで待つ。timeout 秒以内に解除されたら true。
  // 呼び出し元スレッドをブロックするため、バックグラウンドから呼ぶこと。
  static func waitUntilReleased(timeout: TimeInterval) -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
      if !IsSecureEventInputEnabled() { return true }
      Thread.sleep(forTimeInterval: 0.3)
    }
    return !IsSecureEventInputEnabled()
  }

  // MARK: - 原因プロセスの特定

  // セキュア入力を保持しているプロセスを返す（特定できなければ nil）。
  //
  // IORegistry が持つ PID は当てにならない。保持していたプロセスが終了した後も
  // 古い PID がそのまま残り続けることがある（2026-09-08、既に終了した Ultenix の
  // PID が残り、実際の保持元は生きている Bitwarden の Safari 拡張だった）。
  // そのため、PID が生きているときだけ採用し、駄目なら既知のパスワードマネージャを
  // 実行中プロセスから探す。
  static func currentCulprit() -> SecureInputCulprit? {
    // パスワード欄にカーソルが残っているアプリが最も確実な手がかり。
    // IORegistry の PID は最後に有効化したプロセスでしかなく、背後で握り続けている
    // アプリとは限らない（2026-10-02、裏に回った Meta Business のパスワード欄が原因
    // だったのに、IORegistry は終了済みの Ultenix を指していた）。
    if let pid = appWithFocusedPasswordField(), let path = executablePath(forPID: pid) {
      return makeCulprit(pid: pid, path: path)
    }
    if let pid = secureInputPIDFromRegistry(), let path = executablePath(forPID: pid) {
      return makeCulprit(pid: pid, path: path)
    }
    return findRunningPasswordManager()
  }

  // 実行中のアプリのうち、パスワード欄（AXSecureTextField）にカーソルがあるものの PID を返す。
  // アクセシビリティ経由で読むだけなので、フォーカスは動かさない。
  private static func appWithFocusedPasswordField() -> pid_t? {
    let ownPID = ProcessInfo.processInfo.processIdentifier
    for app in NSWorkspace.shared.runningApplications where app.processIdentifier != ownPID {
      let element = AXUIElementCreateApplication(app.processIdentifier)
      AXUIElementSetMessagingTimeout(element, 0.3)
      var focused: CFTypeRef?
      guard
        AXUIElementCopyAttributeValue(element, kAXFocusedUIElementAttribute as CFString, &focused)
          == .success,
        let focused, CFGetTypeID(focused) == AXUIElementGetTypeID()
      else { continue }
      var subrole: CFTypeRef?
      AXUIElementCopyAttributeValue(
        focused as! AXUIElement, kAXSubroleAttribute as CFString, &subrole)
      if (subrole as? String) == (kAXSecureTextFieldSubrole as String) {
        return app.processIdentifier
      }
    }
    return nil
  }

  // IORegistry の IOResources ノードが持つ IOConsoleUsers 配列から、
  // kCGSSessionSecureInputPID（セキュア入力を保持しているプロセスのPID）を読む。
  private static func secureInputPIDFromRegistry() -> pid_t? {
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

  // セキュア入力を握ったまま解放し損ねる常習犯。実行ファイルのパスに含まれる語で判定する。
  // Safari/Chrome 拡張のプロセスは実行ファイル名が "safari" 等になるため、パス全体で見る。
  private static let passwordManagerKeywords = [
    "bitwarden", "1password", "dashlane", "lastpass", "keeper", "enpass",
    "nordpass", "roboform", "strongbox", "keepassxc", "proton pass", "protonpass",
  ]

  // 実行中プロセスから既知のパスワードマネージャを探す。
  // ブラウザ拡張(appex)が原因であることが多いので、拡張を先に返す。
  private static func findRunningPasswordManager() -> SecureInputCulprit? {
    var candidates: [SecureInputCulprit] = []
    for (pid, path) in runningProcesses() {
      let lower = path.lowercased()
      guard passwordManagerKeywords.contains(where: { lower.contains($0) }) else { continue }
      candidates.append(makeCulprit(pid: pid, path: path))
    }
    // 拡張プロセス優先。次にPIDの新しい順（最後に起動したものが握っている可能性が高い）。
    return candidates.sorted {
      let a = $0.executablePath.lowercased().contains(".appex")
      let b = $1.executablePath.lowercased().contains(".appex")
      if a != b { return a }
      return $0.pid > $1.pid
    }.first
  }

  // 実行中の全プロセスの (PID, 実行ファイルパス) を返す。取得できないものは除く。
  private static func runningProcesses() -> [(pid_t, String)] {
    let bufferSize = proc_listpids(UInt32(PROC_ALL_PIDS), 0, nil, 0)
    guard bufferSize > 0 else { return [] }
    let count = Int(bufferSize) / MemoryLayout<pid_t>.size
    var pids = [pid_t](repeating: 0, count: count)
    let written = proc_listpids(UInt32(PROC_ALL_PIDS), 0, &pids, bufferSize)
    guard written > 0 else { return [] }

    var result: [(pid_t, String)] = []
    for pid in pids where pid > 0 {
      if let path = executablePath(forPID: pid) {
        result.append((pid, path))
      }
    }
    return result
  }

  // PID から実行ファイルのパスを返す。プロセスが存在しなければ nil。
  // 生存確認も兼ねる（終了済みPIDでは必ず nil になる）。
  private static func executablePath(forPID pid: pid_t) -> String? {
    var buffer = [CChar](repeating: 0, count: Int(MAXPATHLEN))
    let length = proc_pidpath(pid, &buffer, UInt32(buffer.count))
    guard length > 0 else { return nil }
    return String(cString: buffer)
  }

  private static func makeCulprit(pid: pid_t, path: String) -> SecureInputCulprit {
    let lower = path.lowercased()
    return SecureInputCulprit(
      pid: pid,
      displayName: displayName(forPID: pid, path: path),
      executablePath: path,
      isKnownPasswordManager: passwordManagerKeywords.contains(where: { lower.contains($0) })
    )
  }

  // 表示用の名前を組み立てる。
  // GUIアプリは NSRunningApplication の localizedName（例:「Microsoft Word」）。
  // ブラウザ拡張(appex)は親アプリ名を拾って「Bitwarden（Safari拡張）」の形にする。
  private static func displayName(forPID pid: pid_t, path: String) -> String {
    // "/Applications/Bitwarden.app/Contents/PlugIns/safari.appex/Contents/MacOS/safari"
    // のような拡張プロセスは、親アプリ本体と区別できるよう「（Safari拡張）」を付ける。
    let components = (path as NSString).pathComponents
    let isExtension = components.contains { $0.hasSuffix(".appex") }

    if let app = NSRunningApplication(processIdentifier: pid),
      let name = app.localizedName, !name.isEmpty
    {
      return isExtension ? L10n.browserExtensionName(appName: name) : name
    }

    if let parentApp = components.first(where: { $0.hasSuffix(".app") }) {
      let name = (parentApp as NSString).deletingPathExtension
      return isExtension ? L10n.browserExtensionName(appName: name) : name
    }
    return (path as NSString).lastPathComponent
  }
}
