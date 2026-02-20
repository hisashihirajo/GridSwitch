import AppKit

// 視覚スタイル（設定値を参照）
enum SwitcherAppearance {
  // アイコンサイズ（設定から取得）
  static var iconSize: CGFloat { Settings.shared.iconSize }
  // セルサイズ（アイコンサイズに連動）
  static var cellWidth: CGFloat { Settings.shared.cellWidth }
  static var cellHeight: CGFloat { Settings.shared.cellHeight }
  // セル間スペース
  static let interItemSpacing: CGFloat = 8
  // セクション余白
  static let sectionInset: CGFloat = 20
  // グリッド最大列数（設定から取得）
  static var maxColumns: Int { Settings.shared.maxColumns }
  // パネル角丸
  static let panelCornerRadius: CGFloat = 16
  // ラベルフォントサイズ
  static let labelFontSize: CGFloat = 11
  // 選択ハイライト
  static let highlightCornerRadius: CGFloat = 10
  static let highlightColor = NSColor.controlAccentColor.withAlphaComponent(0.3)
  static let highlightBorderColor = NSColor.controlAccentColor
  static let highlightBorderWidth: CGFloat = 2

  // グリッド列数（設定値を使用、アプリ数が少ない場合はその数に合わせる）
  static func columns(for itemCount: Int) -> Int {
    return min(itemCount, maxColumns)
  }

  // パネルサイズを計算
  static func panelSize(for itemCount: Int) -> NSSize {
    let cols = columns(for: itemCount)
    let rows = Int(ceil(Double(itemCount) / Double(cols)))
    let width = sectionInset * 2 + CGFloat(cols) * cellWidth + CGFloat(cols - 1) * interItemSpacing
    let height =
      sectionInset * 2 + CGFloat(rows) * cellHeight + CGFloat(rows - 1) * interItemSpacing
    return NSSize(width: width, height: height)
  }
}
