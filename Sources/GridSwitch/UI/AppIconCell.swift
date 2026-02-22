import AppKit

// アプリアイコンセル
class AppIconCell: NSView {
  private let iconView = NSImageView()
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

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  private func setup() {
    // セル自体のクリッピングを無効化（バッジがはみ出せるように）
    wantsLayer = true
    layer?.masksToBounds = false

    // ハイライト背景
    highlightView.wantsLayer = true
    highlightView.layer?.cornerRadius = SwitcherAppearance.highlightCornerRadius
    highlightView.isHidden = true
    addSubview(highlightView)

    // アイコン
    iconView.imageScaling = .scaleProportionallyUpOrDown
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
    numberBadge.wantsLayer = true
    numberBadge.layer?.backgroundColor = NSColor.clear.cgColor
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
    notificationBadgeBg.layer?.backgroundColor = NSColor.systemRed.cgColor
    notificationBadgeBg.layer?.borderColor = NSColor.white.withAlphaComponent(0.9).cgColor
    notificationBadgeBg.layer?.borderWidth = 1.5
    notificationBadgeBg.isHidden = true
    addSubview(notificationBadgeBg)

    notificationBadge.textColor = .white
    notificationBadge.alignment = .center
    notificationBadge.isBezeled = false
    notificationBadge.drawsBackground = false
    notificationBadge.isHidden = true
    addSubview(notificationBadge)
  }

  func configure(with appInfo: AppInfo, shortcutNumber: Int? = nil) {
    iconView.image = appInfo.icon
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
    iconView.frame = NSRect(x: iconX, y: iconY, width: iconSize, height: iconSize)

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

  private func updateHighlight() {
    highlightView.isHidden = !isHighlighted
    if isHighlighted {
      highlightView.layer?.backgroundColor = SwitcherAppearance.highlightColor.cgColor
      highlightView.layer?.borderColor = SwitcherAppearance.highlightBorderColor.cgColor
      highlightView.layer?.borderWidth = SwitcherAppearance.highlightBorderWidth
    }
  }
}
