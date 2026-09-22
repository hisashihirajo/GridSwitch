import AppKit

// アプリアイコンセル
class AppIconCell: NSView {
  // NSImageView は生成するたびに AppKit 内部でメモリが漏れる（1個あたり約2KB）。
  // Cmd+Tab のたびに積み上がり、メモリが逼迫するとスワップに追い出されて
  // ホバー追従が遅れる原因になるため、レイヤーに縮小済みの画像を直接載せる。
  private let iconView = NSView()
  private var icon: NSImage?
  private let nameLabel = NSTextField(labelWithString: "")
  private let highlightView = NSView()
  private let numberBadge = NSTextField(labelWithString: "")
  private let notificationBadge = NSTextField(labelWithString: "")
  private let notificationBadgeBg = NSView()

  var isHighlighted: Bool = false {
    didSet {
      updateHighlight()
    }
  }

  // マウスがこのセルに乗ったときに呼ばれる
  var onHover: (() -> Void)?

  private var hoverTrackingArea: NSTrackingArea?

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  private func setup() {
    // ハイライト背景
    highlightView.wantsLayer = true
    highlightView.isHidden = true
    addSubview(highlightView)

    // アイコン
    iconView.wantsLayer = true
    iconView.layer?.contentsGravity = .resizeAspect
    addSubview(iconView)

    // ラベル
    nameLabel.font = NSFont.systemFont(ofSize: SwitcherAppearance.labelFontSize)
    nameLabel.textColor = .labelColor
    nameLabel.alignment = .center
    nameLabel.lineBreakMode = .byTruncatingTail
    nameLabel.maximumNumberOfLines = 1
    addSubview(nameLabel)

    // 数字オーバーレイ（アイコン中央に薄く表示）
    numberBadge.font = NSFont.systemFont(ofSize: 64, weight: .heavy)
    numberBadge.textColor = NSColor.white.withAlphaComponent(0.85)
    numberBadge.alignment = .center
    numberBadge.isBezeled = false
    numberBadge.drawsBackground = false
    numberBadge.shadow = {
      let s = NSShadow()
      s.shadowColor = NSColor.black.withAlphaComponent(1.0)
      s.shadowBlurRadius = 16
      s.shadowOffset = NSSize(width: 0, height: -2)
      return s
    }()
    numberBadge.isHidden = true
    addSubview(numberBadge)

    // 通知バッジ（Dock風の赤い丸にカウント表示）
    notificationBadgeBg.wantsLayer = true
    notificationBadgeBg.isHidden = true
    addSubview(notificationBadgeBg)

    notificationBadge.textColor = .white
    notificationBadge.alignment = .center
    notificationBadge.isBezeled = false
    notificationBadge.drawsBackground = false
    notificationBadge.isHidden = true
    addSubview(notificationBadge)
  }

  // マウスホバー追従用のトラッキングエリア。
  // スイッチャーは非アクティブなパネル（.nonactivatingPanel）上に出るため、
  // 通常の mouseMoved はアプリに配送されない。.activeAlways のトラッキングエリアなら
  // アプリが非アクティブでも mouseEntered / mouseMoved を受け取れる。
  override func updateTrackingAreas() {
    super.updateTrackingAreas()
    if let area = hoverTrackingArea {
      removeTrackingArea(area)
    }
    let area = NSTrackingArea(
      rect: .zero,
      options: [.mouseEnteredAndExited, .mouseMoved, .activeAlways, .inVisibleRect],
      owner: self,
      userInfo: nil
    )
    addTrackingArea(area)
    hoverTrackingArea = area
  }

  override func mouseEntered(with event: NSEvent) {
    onHover?()
  }

  override func mouseMoved(with event: NSEvent) {
    onHover?()
  }

  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    guard window != nil else { return }
    // 画面の倍率（Retina かどうか）が確定したので描き直す
    updateIconContents()
    // layerが確実に存在するタイミングでCALayer設定を適用
    layer?.masksToBounds = false
    highlightView.layer?.cornerRadius = SwitcherAppearance.highlightCornerRadius
    notificationBadgeBg.layer?.backgroundColor = NSColor.systemRed.cgColor
    notificationBadgeBg.layer?.borderColor = NSColor.white.withAlphaComponent(0.9).cgColor
    notificationBadgeBg.layer?.borderWidth = 1.5
  }

  func configure(with appInfo: AppInfo, shortcutNumber: Int? = nil) {
    icon = appInfo.icon
    updateIconContents()
    nameLabel.stringValue = appInfo.name
    if let number = shortcutNumber {
      numberBadge.stringValue = "\(number)"
      numberBadge.isHidden = false
    } else {
      numberBadge.isHidden = true
    }
    // 通知バッジ
    if let badge = appInfo.badgeLabel, !badge.isEmpty {
      notificationBadge.stringValue = badge
      notificationBadge.isHidden = false
      notificationBadgeBg.isHidden = false
    } else {
      notificationBadge.isHidden = true
      notificationBadgeBg.isHidden = true
    }
    layoutSubviews()
  }

  override func layout() {
    super.layout()
    layoutSubviews()
  }

  private func layoutSubviews() {
    let iconSize = SwitcherAppearance.iconSize
    let iconX = (bounds.width - iconSize) / 2
    let iconY = bounds.height - iconSize - 8
    let iconFrame = NSRect(x: iconX, y: iconY, width: iconSize, height: iconSize)
    if iconView.frame != iconFrame {
      iconView.frame = iconFrame
      updateIconContents()
    }

    let labelHeight: CGFloat = 16
    let labelY = iconY - labelHeight - 2
    nameLabel.frame = NSRect(x: 4, y: labelY, width: bounds.width - 8, height: labelHeight)

    // 数字オーバーレイ: アイコンど真ん中に配置
    let badgeH: CGFloat = 72
    let badgeY = iconView.frame.midY - badgeH / 2
    numberBadge.frame = NSRect(x: iconView.frame.minX, y: badgeY, width: iconSize, height: badgeH)

    // 通知バッジ: Dock風にアイコン右上に配置
    if !notificationBadge.isHidden {
      let text = notificationBadge.stringValue
      // Dockバッジはアイコンサイズの約1/3の高さ
      let badgeHeight = round(iconSize * 0.32)
      let fontSize = round(badgeHeight * 0.65)
      notificationBadge.font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
      let badgeWidth = max(badgeHeight, CGFloat(text.count) * fontSize * 0.7 + badgeHeight * 0.5)
      // Dock風: バッジがアイコン右上に少し重なる位置
      let badgeX = iconView.frame.maxX - badgeWidth * 0.75
      let nbadgeY = iconView.frame.maxY - badgeHeight * 0.7

      notificationBadgeBg.frame = NSRect(x: badgeX, y: nbadgeY, width: badgeWidth, height: badgeHeight)
      notificationBadgeBg.layer?.cornerRadius = badgeHeight / 2

      notificationBadge.frame = NSRect(x: badgeX, y: nbadgeY, width: badgeWidth, height: badgeHeight)
    }

    highlightView.frame = bounds.insetBy(dx: 2, dy: 2)
  }

  // アイコンを表示サイズぶんのビットマップにしてレイヤーへ載せる
  private func updateIconContents() {
    guard let icon else {
      iconView.layer?.contents = nil
      return
    }
    let scale = window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 2
    iconView.layer?.contentsScale = scale
    iconView.layer?.contents = IconRasterCache.shared.image(
      for: icon,
      pointSize: SwitcherAppearance.iconSize,
      scale: scale
    )
  }

  private func updateHighlight() {
    highlightView.isHidden = !isHighlighted
    if isHighlighted {
      highlightView.layer?.backgroundColor = SwitcherAppearance.highlightColor.cgColor
      highlightView.layer?.borderColor = SwitcherAppearance.highlightBorderColor.cgColor
      highlightView.layer?.borderWidth = SwitcherAppearance.highlightBorderWidth
    }
  }
}

// アイコンを表示サイズに縮小したビットマップのキャッシュ。
// 元の NSImage は 1024px 級の表現を抱えているため、表示のたびに縮小し直さない。
final class IconRasterCache {
  static let shared = IconRasterCache()

  // 元画像が解放されたら縮小版も一緒に消える
  private let table = NSMapTable<NSImage, NSMutableDictionary>.weakToStrongObjects()

  func image(for icon: NSImage, pointSize: CGFloat, scale: CGFloat) -> CGImage? {
    let key = "\(pointSize)@\(scale)" as NSString
    let sizes: NSMutableDictionary
    if let existing = table.object(forKey: icon) {
      sizes = existing
    } else {
      sizes = NSMutableDictionary()
      table.setObject(sizes, forKey: icon)
    }
    if let cached = sizes[key] {
      return (cached as! CGImage)
    }
    guard let rendered = Self.render(icon, pointSize: pointSize, scale: scale) else { return nil }
    sizes[key] = rendered
    return rendered
  }

  private static func render(_ icon: NSImage, pointSize: CGFloat, scale: CGFloat) -> CGImage? {
    let pixels = max(1, Int((pointSize * scale).rounded()))
    guard
      let context = CGContext(
        data: nil,
        width: pixels,
        height: pixels,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
      )
    else { return nil }
    context.interpolationQuality = .high
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
    // 正方形でない画像（開発中Electronアプリの PNG など）は縦横比を保って中央に置く
    let side = CGFloat(pixels)
    let ratio = icon.size.width > 0 && icon.size.height > 0
      ? min(side / icon.size.width, side / icon.size.height) : 1
    let drawW = icon.size.width > 0 ? icon.size.width * ratio : side
    let drawH = icon.size.height > 0 ? icon.size.height * ratio : side
    icon.draw(
      in: NSRect(x: (side - drawW) / 2, y: (side - drawH) / 2, width: drawW, height: drawH),
      from: .zero,
      operation: .copy,
      fraction: 1
    )
    NSGraphicsContext.restoreGraphicsState()
    return context.makeImage()
  }
}
