import AppKit

// ボーダーレスオーバーレイパネル
class SwitcherPanel: NSPanel {
  private let gridViewController = GridViewController()
  private let effectView = NSVisualEffectView()
  private let backgroundOverlay = NSView()
  private let backgroundImageView = NSView()

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

    // フェードインアニメーション
    alphaValue = 0
    orderFrontRegardless()

    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.15
      self.animator().alphaValue = 1
    }
  }

  func dismiss() {
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

  // マウスクリックでアプリ選択時のコールバック
  var onClickActivate: (() -> Void)?

  func selectedApp() -> AppInfo? {
    return gridViewController.selectedApp()
  }

  // マウス移動時にセルのハイライトを追従
  private func handleMouseMoved(at point: NSPoint) {
    guard let contentView = self.contentView else { return }
    let localPoint = contentView.convert(point, from: nil)
    if let index = gridViewController.indexOfCell(at: localPoint) {
      gridViewController.selectIndex(index)
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
