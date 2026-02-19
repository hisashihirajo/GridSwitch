import AppKit

// アプリアイコンセル
class AppIconCell: NSView {
  private let iconView = NSImageView()
  private let nameLabel = NSTextField(labelWithString: "")
  private let highlightView = NSView()

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
  }

  func configure(with appInfo: AppInfo) {
    iconView.image = appInfo.icon
    nameLabel.stringValue = appInfo.name
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
