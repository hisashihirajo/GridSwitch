import AppKit

// グリッドレイアウトでアプリアイコンを表示するビューコントローラー
class GridViewController: NSViewController {
  private var apps: [AppInfo] = []
  private var cells: [AppIconCell] = []
  private(set) var selectedIndex: Int = 0

  override func loadView() {
    view = NSView()
  }

  func updateApps(_ newApps: [AppInfo]) {
    apps = newApps
    selectedIndex = min(1, max(0, apps.count - 1))  // 2番目（直前のアプリ）を初期選択
    rebuildGrid()
  }

  func selectNext() {
    guard !apps.isEmpty else { return }
    selectedIndex = (selectedIndex + 1) % apps.count
    updateSelection()
  }

  func selectPrevious() {
    guard !apps.isEmpty else { return }
    selectedIndex = (selectedIndex - 1 + apps.count) % apps.count
    updateSelection()
  }

  func selectUp() {
    guard !apps.isEmpty else { return }
    let columns = SwitcherAppearance.columns(for: apps.count)
    let newIndex = selectedIndex - columns
    if newIndex >= 0 {
      selectedIndex = newIndex
      updateSelection()
    }
  }

  func selectDown() {
    guard !apps.isEmpty else { return }
    let columns = SwitcherAppearance.columns(for: apps.count)
    let newIndex = selectedIndex + columns
    if newIndex < apps.count {
      selectedIndex = newIndex
      updateSelection()
    }
  }

  func selectLeft() {
    guard !apps.isEmpty else { return }
    let columns = SwitcherAppearance.columns(for: apps.count)
    let col = selectedIndex % columns
    if col > 0 {
      selectedIndex -= 1
      updateSelection()
    }
  }

  func selectRight() {
    guard !apps.isEmpty else { return }
    let columns = SwitcherAppearance.columns(for: apps.count)
    let col = selectedIndex % columns
    if col < columns - 1 && selectedIndex + 1 < apps.count {
      selectedIndex += 1
      updateSelection()
    }
  }

  func selectedApp() -> AppInfo? {
    guard selectedIndex >= 0, selectedIndex < apps.count else { return nil }
    return apps[selectedIndex]
  }

  func selectIndex(_ index: Int) {
    guard index >= 0, index < apps.count else { return }
    selectedIndex = index
    updateSelection()
  }

  // 座標からセルのインデックスを返す
  func indexOfCell(at point: NSPoint) -> Int? {
    for (index, cell) in cells.enumerated() {
      if cell.frame.contains(point) {
        return index
      }
    }
    return nil
  }

  private func rebuildGrid() {
    // 既存セルをクリア
    cells.forEach { $0.removeFromSuperview() }
    cells.removeAll()

    guard !apps.isEmpty else { return }

    let columns = SwitcherAppearance.columns(for: apps.count)
    let cellW = SwitcherAppearance.cellWidth
    let cellH = SwitcherAppearance.cellHeight
    let spacing = SwitcherAppearance.interItemSpacing
    let inset = SwitcherAppearance.sectionInset

    for (index, app) in apps.enumerated() {
      let col = index % columns
      let row = index / columns

      let totalRows = Int(ceil(Double(apps.count) / Double(columns)))
      // AppKitの座標系: 左下が原点なので、行を反転
      let flippedRow = totalRows - 1 - row

      let x = inset + CGFloat(col) * (cellW + spacing)
      let y = inset + CGFloat(flippedRow) * (cellH + spacing)

      let cell = AppIconCell(
        frame: NSRect(x: x, y: y, width: cellW, height: cellH)
      )
      // 0-9番目のアプリにショートカット番号バッジを表示（1,2,...,9,0）
      let shortcutNumber: Int? = Settings.shared.showNumberShortcuts && index < 10 ? (index + 1) % 10 : nil
      cell.configure(with: app, shortcutNumber: shortcutNumber)
      cell.isHighlighted = (index == selectedIndex)

      view.addSubview(cell)
      cells.append(cell)
    }
  }

  private func updateSelection() {
    for (index, cell) in cells.enumerated() {
      cell.isHighlighted = (index == selectedIndex)
    }
  }
}
