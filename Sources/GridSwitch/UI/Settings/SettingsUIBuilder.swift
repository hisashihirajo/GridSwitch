import AppKit

// ScrollView内でコンテンツを上寄せにするためのFlipped NSView
final class FlippedView: NSView {
  override var isFlipped: Bool { true }
}

enum SettingsUIBuilder {
  static func makeRow() -> NSStackView {
    let row = NSStackView()
    row.orientation = .horizontal
    row.alignment = .centerY
    row.spacing = 8
    return row
  }

  static func addSeparator(to stackView: NSStackView) {
    let separator = NSBox()
    separator.boxType = .separator
    stackView.addArrangedSubview(separator)
    separator.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -40).isActive = true
  }
}
