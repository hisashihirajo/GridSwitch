import AppKit
import CoreGraphics

// Cmd+Tab傍受の中核
// CGEventTapコールバックはCの関数ポインタが必要なため、グローバルコンテキストで管理
class KeyboardEventHandler {
  // シングルトン（CGEventTapコールバックからアクセスするため）
  static let shared = KeyboardEventHandler()

  private var eventTap: CFMachPort?
  private var runLoopSource: CFRunLoopSource?

  // 状態管理
  private(set) var isCmdHeld = false
  private(set) var isShiftHeld = false
  private(set) var isSwitcherActive = false

  // コールバック
  var onCmdTabPressed: (() -> Void)?         // Cmd+Tab初回押下 → パネル表示
  var onTabPressed: (() -> Void)?            // Tab追加押下 → 次のアプリ選択
  var onShiftTabPressed: (() -> Void)?       // Shift+Tab → 前のアプリ選択
  var onCmdReleased: (() -> Void)?           // Cmd解放 → アプリ切り替え
  var onEscPressed: (() -> Void)?            // Esc → キャンセル
  var onArrowUp: (() -> Void)?               // ↑ → 上に移動
  var onArrowDown: (() -> Void)?             // ↓ → 下に移動
  var onArrowLeft: (() -> Void)?             // ← → 左に移動
  var onArrowRight: (() -> Void)?            // → → 右に移動
  var onNumberPressed: ((Int) -> Void)?      // 数字キー(0-9) → 直接アプリ選択
  var onQuitPressed: (() -> Void)?            // Q → 選択中のアプリを終了

  private let tabKeyCode: UInt16 = 48
  private let qKeyCode: UInt16 = 12
  private let escKeyCode: UInt16 = 53
  private let arrowUpKeyCode: UInt16 = 126
  private let arrowDownKeyCode: UInt16 = 125
  private let arrowLeftKeyCode: UInt16 = 123
  private let arrowRightKeyCode: UInt16 = 124

  // 数字キー: 1-9, 0 のキーコード（メインキーボード上段）
  private let numberKeyCodes: [UInt16: Int] = [
    18: 1, 19: 2, 20: 3, 21: 4, 23: 5,
    22: 6, 26: 7, 28: 8, 25: 9, 29: 0,
  ]

  private init() {}

  func start() -> Bool {
    guard AccessibilityChecker.isAccessibilityGranted() else {
      NSLog("アクセシビリティ権限がありません")
      return false
    }

    let eventMask: CGEventMask =
      (1 << CGEventType.keyDown.rawValue)
      | (1 << CGEventType.flagsChanged.rawValue)

    // CGEventTap作成
    // .cgSessionEventTap: セッションレベル
    // .headInsertEventTap: システムハンドラより先に処理
    // .defaultTap: イベントを変更・消費可能
    guard
      let tap = CGEvent.tapCreate(
        tap: .cgSessionEventTap,
        place: .headInsertEventTap,
        options: .defaultTap,
        eventsOfInterest: eventMask,
        callback: eventTapCallback,
        userInfo: nil
      )
    else {
      NSLog("CGEventTapの作成に失敗しました")
      return false
    }

    eventTap = tap
    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
    CGEvent.tapEnable(tap: tap, enable: true)

    NSLog("CGEventTap開始: Cmd+Tab傍受を有効化")
    return true
  }

  func stop() {
    if let tap = eventTap {
      CGEvent.tapEnable(tap: tap, enable: false)
    }
    if let source = runLoopSource {
      CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
    }
    eventTap = nil
    runLoopSource = nil
    isCmdHeld = false
    isSwitcherActive = false
    NSLog("CGEventTap停止")
  }

  // スイッチャーの状態をリセット（外部から呼び出し用）
  func deactivateSwitcher() {
    isSwitcherActive = false
  }

  // CGEventTapがタイムアウトで無効化された場合の再有効化
  func reEnableTapIfNeeded() {
    guard let tap = eventTap else { return }
    if !CGEvent.tapIsEnabled(tap: tap) {
      NSLog("CGEventTapが無効化されていたため再有効化")
      CGEvent.tapEnable(tap: tap, enable: true)
    }
  }

  // メインのイベント処理ロジック
  func handleEvent(type: CGEventType, event: CGEvent) -> CGEvent? {
    // タイムアウトで無効化された場合の復帰
    if type == .tapDisabledByTimeout {
      reEnableTapIfNeeded()
      return event
    }

    switch type {
    case .flagsChanged:
      return handleFlagsChanged(event)
    case .keyDown:
      return handleKeyDown(event)
    default:
      return event
    }
  }

  // 修飾キーの状態変化を処理
  private func handleFlagsChanged(_ event: CGEvent) -> CGEvent? {
    let flags = event.flags
    let cmdHeld = flags.contains(.maskCommand)
    let shiftHeld = flags.contains(.maskShift)

    isShiftHeld = shiftHeld

    if cmdHeld && !isCmdHeld {
      // Cmdが押された
      isCmdHeld = true
    } else if !cmdHeld && isCmdHeld {
      // Cmdが離された
      isCmdHeld = false
      if isSwitcherActive {
        isSwitcherActive = false
        DispatchQueue.main.async { [weak self] in
          self?.onCmdReleased?()
        }
        return nil  // イベント消費
      }
    }

    return event
  }

  // キー押下を処理
  private func handleKeyDown(_ event: CGEvent) -> CGEvent? {
    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))

    // Escキー処理（スイッチャーがアクティブな場合）
    if keyCode == escKeyCode && isSwitcherActive {
      isSwitcherActive = false
      isCmdHeld = false
      DispatchQueue.main.async { [weak self] in
        self?.onEscPressed?()
      }
      return nil  // イベント消費
    }

    // 矢印キー処理（スイッチャーがアクティブな場合）
    if isSwitcherActive {
      var arrowCallback: (() -> Void)?
      switch keyCode {
      case arrowUpKeyCode: arrowCallback = onArrowUp
      case arrowDownKeyCode: arrowCallback = onArrowDown
      case arrowLeftKeyCode: arrowCallback = onArrowLeft
      case arrowRightKeyCode: arrowCallback = onArrowRight
      default: break
      }
      if let callback = arrowCallback {
        DispatchQueue.main.async { callback() }
        return nil  // イベント消費
      }

      // 数字キー処理（0-9で直接アプリ切り替え、設定でON時のみ）
      if Settings.shared.showNumberShortcuts, let number = numberKeyCodes[keyCode] {
        DispatchQueue.main.async { [weak self] in
          self?.onNumberPressed?(number)
        }
        return nil  // イベント消費
      }

      // Qキー処理 → 選択中のアプリを終了
      if keyCode == qKeyCode {
        DispatchQueue.main.async { [weak self] in
          self?.onQuitPressed?()
        }
        return nil  // イベント消費
      }
    }

    // Tab + Cmd保持中
    if keyCode == tabKeyCode && isCmdHeld {
      if !isSwitcherActive {
        // 初回Cmd+Tab → スイッチャー表示
        isSwitcherActive = true
        DispatchQueue.main.async { [weak self] in
          self?.onCmdTabPressed?()
        }
      } else {
        // 追加Tab → 選択移動
        if isShiftHeld {
          DispatchQueue.main.async { [weak self] in
            self?.onShiftTabPressed?()
          }
        } else {
          DispatchQueue.main.async { [weak self] in
            self?.onTabPressed?()
          }
        }
      }
      return nil  // イベント消費（macOS標準スイッチャーを抑制）
    }

    return event
  }
}

// CGEventTapのCコールバック関数
private func eventTapCallback(
  proxy: CGEventTapProxy,
  type: CGEventType,
  event: CGEvent,
  userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
  let result = KeyboardEventHandler.shared.handleEvent(type: type, event: event)
  if let result = result {
    return Unmanaged.passUnretained(result)
  }
  return nil  // イベント消費
}
