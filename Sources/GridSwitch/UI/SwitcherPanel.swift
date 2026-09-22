import AppKit

// ボーダーレスオーバーレイパネル
class SwitcherPanel: NSPanel {
  private let gridViewController = GridViewController()
  private let effectView = NSVisualEffectView()
  private let backgroundOverlay = NSView()
  private let backgroundImageView = NSView()

  // パネル表示中のマウス移動監視。
  // スイッチャーはアプリが非アクティブなまま表示されるため、通常の mouseMoved は
  // アプリに配送されない。グローバルモニタで拾ってホバー選択に反映する。
  private var mouseMoveMonitor: Any?

  // 表示中は macOS に「操作に即応すべき処理中」と伝える。
  // GridSwitch は常に裏で動くアプリなので、メモリや CPU が逼迫すると優先度を下げられ、
  // マウスの追従が遅れる。表示している間だけ優先度を上げてもらう。
  private var latencyActivity: NSObjectProtocol?

  init() {
    super.init(
      contentRect: NSRect(x: 0, y: 0, width: 400, height: 400),
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: true
    )

    // パネル設定
    level = .statusBar
    isOpaque = false
    backgroundColor = .clear
    hasShadow = true
    isMovableByWindowBackground = false
    hidesOnDeactivate = false
    collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

    // システムの開閉アニメーション（中心へ縮めながらぼかす）を切る。
    // これが途中で止まると、パネルが一回り小さいまま・中身がぼけたまま居座る。
    // 表示・非表示は下の alphaValue のフェードで自前に行う。
    animationBehavior = .none

    // 背景ぼかし効果（ベース）
    effectView.material = .hudWindow
    effectView.blendingMode = .behindWindow
    effectView.state = .active
    effectView.wantsLayer = true
    effectView.layer?.cornerRadius = SwitcherAppearance.panelCornerRadius
    effectView.layer?.masksToBounds = true

    // 背景画像（effectViewの上、最背面）- 短辺に合わせてクロップ（Aspect Fill）
    backgroundImageView.wantsLayer = true
    backgroundImageView.layer?.contentsGravity = .resizeAspectFill
    backgroundImageView.layer?.cornerRadius = SwitcherAppearance.panelCornerRadius
    backgroundImageView.layer?.masksToBounds = true

    // 背景色オーバーレイ（画像の上に重ねる）
    backgroundOverlay.wantsLayer = true
    backgroundOverlay.layer?.cornerRadius = SwitcherAppearance.panelCornerRadius
    backgroundOverlay.layer?.masksToBounds = true

    contentView = effectView
    effectView.addSubview(backgroundImageView)
    effectView.addSubview(backgroundOverlay)
    effectView.addSubview(gridViewController.view)

    // マウスクリックを受け付ける
    acceptsMouseMovedEvents = true
  }

  func showWithApps(_ apps: [AppInfo]) {
    guard !apps.isEmpty else { return }

    beginLatencyActivity()
    gridViewController.updateApps(apps)

    // パネルサイズを計算してリサイズ
    let panelSize = SwitcherAppearance.panelSize(for: apps.count)
    let frame = centeredFrame(size: panelSize)
    setFrame(frame, display: true)

    // サブビューのフレーム更新
    effectView.frame = NSRect(origin: .zero, size: panelSize)
    backgroundImageView.frame = effectView.bounds
    backgroundOverlay.frame = effectView.bounds
    gridViewController.view.frame = effectView.bounds

    // 設定から背景を適用
    applyBackgroundSettings()

    // 表示直後はホバー選択を抑制（カーソルが動いてから追従を開始）
    gridViewController.beginHoverTracking()

    // フェードインアニメーション
    alphaValue = 0
    orderFrontRegardless()

    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.15
      self.animator().alphaValue = 1
    }

    startMouseMoveMonitor()
  }

  private func beginLatencyActivity() {
    guard latencyActivity == nil else { return }
    latencyActivity = ProcessInfo.processInfo.beginActivity(
      options: [.userInitiated, .latencyCritical],
      reason: "Switcher panel is visible"
    )
  }

  private func endLatencyActivity() {
    if let activity = latencyActivity {
      ProcessInfo.processInfo.endActivity(activity)
      latencyActivity = nil
    }
  }

  // マウス移動を監視してホバー選択に反映する
  private func startMouseMoveMonitor() {
    stopMouseMoveMonitor()
    // マウスユーティリティの不具合でボタンが押しっぱなしになると、移動が mouseMoved ではなく
    // ドラッグとして流れてくる。その状態でもホバー追従できるようドラッグも監視する。
    mouseMoveMonitor = NSEvent.addGlobalMonitorForEvents(
      matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]
    ) { [weak self] _ in
      self?.handleMouseMovedOnScreen(NSEvent.mouseLocation)
    }
  }

  private func stopMouseMoveMonitor() {
    if let monitor = mouseMoveMonitor {
      NSEvent.removeMonitor(monitor)
      mouseMoveMonitor = nil
    }
  }

  // スクリーン座標のマウス位置からセルを特定してホバー選択
  private func handleMouseMovedOnScreen(_ screenPoint: NSPoint) {
    guard isVisible, let contentView = self.contentView else { return }
    let windowPoint = convertPoint(fromScreen: screenPoint)
    let localPoint = contentView.convert(windowPoint, from: nil)
    if let index = gridViewController.indexOfCell(at: localPoint) {
      gridViewController.hoverSelect(index)
    }
  }

  // バッジ情報を非同期で更新
  func updateBadges(_ badges: [pid_t: String]) {
    gridViewController.updateBadges(badges)
  }

  func dismiss() {
    stopMouseMoveMonitor()
    endLatencyActivity()
    NSAnimationContext.runAnimationGroup(
      { context in
        context.duration = 0.1
        self.animator().alphaValue = 0
      },
      completionHandler: {
        self.orderOut(nil)
      }
    )
  }

  override func sendEvent(_ event: NSEvent) {
    switch event.type {
    case .leftMouseDown:
      handleClick(at: event.locationInWindow)
      return
    case .mouseMoved:
      handleMouseMoved(at: event.locationInWindow)
      super.sendEvent(event)
      return
    default:
      break
    }
    super.sendEvent(event)
  }

  func selectNext() {
    gridViewController.selectNext()
  }

  func selectPrevious() {
    gridViewController.selectPrevious()
  }

  func selectUp() {
    gridViewController.selectUp()
  }

  func selectDown() {
    gridViewController.selectDown()
  }

  func selectLeft() {
    gridViewController.selectLeft()
  }

  func selectRight() {
    gridViewController.selectRight()
  }

  func selectIndex(_ index: Int) {
    gridViewController.selectIndex(index)
  }

  // マウスクリックでアプリ選択時のコールバック
  var onClickActivate: (() -> Void)?

  func selectedApp() -> AppInfo? {
    return gridViewController.selectedApp()
  }

  // 選択中のアプリをグリッドから除去してパネルを更新
  func removeSelectedApp() {
    let remainingApps = gridViewController.removeSelectedApp()
    if remainingApps.isEmpty {
      dismiss()
      return
    }
    // パネルサイズを再計算
    let panelSize = SwitcherAppearance.panelSize(for: remainingApps.count)
    let frame = centeredFrame(size: panelSize)
    setFrame(frame, display: true)
    effectView.frame = NSRect(origin: .zero, size: panelSize)
    backgroundImageView.frame = effectView.bounds
    backgroundOverlay.frame = effectView.bounds
    gridViewController.view.frame = effectView.bounds
  }

  // マウス移動時にセルのハイライトを追従（アプリがアクティブな場合の経路）
  private func handleMouseMoved(at point: NSPoint) {
    guard let contentView = self.contentView else { return }
    let localPoint = contentView.convert(point, from: nil)
    if let index = gridViewController.indexOfCell(at: localPoint) {
      gridViewController.hoverSelect(index)
    }
  }

  // クリックされたセルのインデックスを特定して選択・アクティブ化
  func handleClick(at point: NSPoint) {
    // contentView座標に変換
    guard let contentView = self.contentView else { return }
    let localPoint = contentView.convert(point, from: nil)
    if let index = gridViewController.indexOfCell(at: localPoint) {
      gridViewController.selectIndex(index)
      onClickActivate?()
    }
  }

  private func applyBackgroundSettings() {
    let settings = Settings.shared

    // 背景画像（CALayerのcontentsで設定し、contentsGravityでAspect Fill）
    let image = settings.backgroundImage
    backgroundImageView.layer?.contents = image
    backgroundImageView.isHidden = (image == nil)
    backgroundImageView.alphaValue = settings.backgroundImageOpacity

    // 背景色オーバーレイ
    let bgColor = settings.backgroundColor.withAlphaComponent(settings.backgroundOpacity)
    backgroundOverlay.layer?.backgroundColor = bgColor.cgColor
  }

  // アクティブスクリーンの中央に配置
  private func centeredFrame(size: NSSize) -> NSRect {
    let screen = NSScreen.main ?? NSScreen.screens.first!
    let screenFrame = screen.visibleFrame
    let x = screenFrame.midX - size.width / 2
    let y = screenFrame.midY - size.height / 2
    return NSRect(origin: NSPoint(x: x, y: y), size: size)
  }
}
