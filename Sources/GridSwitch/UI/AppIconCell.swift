import AppKit

// アプリアイコンセル
class AppIconCell: NSView {
  private let iconView = NSImageView()
  private let nameLabel = NSTextField(labelWithString: "")
  private let highlightView = NSView()
  private let numberBadge = NSTextField(labelWithString: "")

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
