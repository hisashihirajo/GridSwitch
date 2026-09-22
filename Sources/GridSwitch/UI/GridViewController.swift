import AppKit

// グリッドレイアウトでアプリアイコンを表示するビューコントローラー
class GridViewController: NSViewController {
  private var apps: [AppInfo] = []
  private var cells: [AppIconCell] = []
  private(set) var selectedIndex: Int = 0

  // パネル表示時のマウス位置。実際にマウスが動くまではホバー選択を無視するための基準点。
  // （カーソルの真下にパネルが出ただけでキーボードの初期選択が奪われるのを防ぐ）
  private var hoverAnchor: NSPoint?

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

  // 選択中のアプリをリストから除去し、グリッドを再構築して残りのアプリを返す
  func removeSelectedApp() -> [AppInfo] {
    guard selectedIndex >= 0, selectedIndex < apps.count else { return apps }
    apps.remove(at: selectedIndex)
    // 選択インデックスを調整
    if apps.isEmpty {
      selectedIndex = 0
    } else if selectedIndex >= apps.count {
      selectedIndex = apps.count - 1
    }
    rebuildGrid()
    return apps
  }

  // パネル表示時に呼ぶ。この時点のマウス位置を基準にし、
  // カーソルが実際に動くまではホバーによる選択変更を抑制する。
  func beginHoverTracking() {
    hoverAnchor = NSEvent.mouseLocation
  }

  // ホバーによる選択。カーソルが動く前のイベントは無視する。
  func hoverSelect(_ index: Int) {
    if let anchor = hoverAnchor {
      let current = NSEvent.mouseLocation
      let moved = abs(current.x - anchor.x) > 2 || abs(current.y - anchor.y) > 2
      guard moved else { return }
      hoverAnchor = nil
    }
    guard index != selectedIndex else { return }
    selectIndex(index)
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

  // セルは作り直さず使い回す。AppKit のビューは生成のたびに内部でメモリが漏れるものがあり、
  // Cmd+Tab ごとに全セルを作り直すと、長く使うほどメモリを食ってホバー追従が遅くなる。
  private func rebuildGrid() {
    // 余ったセルを外す
    while cells.count > apps.count {
      cells.removeLast().removeFromSuperview()
    }

    guard !apps.isEmpty else { return }

    let columns = SwitcherAppearance.columns(for: apps.count)
    let cellW = SwitcherAppearance.cellWidth
    let cellH = SwitcherAppearance.cellHeight
    let spacing = SwitcherAppearance.interItemSpacing
    let inset = SwitcherAppearance.sectionInset
    let totalRows = Int(ceil(Double(apps.count) / Double(columns)))

    for (index, app) in apps.enumerated() {
      let col = index % columns
      let row = index / columns

      // AppKitの座標系: 左下が原点なので、行を反転
      let flippedRow = totalRows - 1 - row

      let x = inset + CGFloat(col) * (cellW + spacing)
      let y = inset + CGFloat(flippedRow) * (cellH + spacing)
      let frame = NSRect(x: x, y: y, width: cellW, height: cellH)

      let cell: AppIconCell
      if index < cells.count {
        cell = cells[index]
        cell.frame = frame
      } else {
        cell = AppIconCell(frame: frame)
        cell.onHover = { [weak self] in
          self?.hoverSelect(index)
        }
        view.addSubview(cell)
        cells.append(cell)
      }
      // 0-9番目のアプリにショートカット番号バッジを表示（1,2,...,9,0）
      let shortcutNumber: Int? = Settings.shared.showNumberShortcuts && index < 10 ? (index + 1) % 10 : nil
      cell.configure(with: app, shortcutNumber: shortcutNumber)
      cell.isHighlighted = (index == selectedIndex)
    }
  }

  // バッジ情報を非同期で更新（グリッド再構築なし）
  func updateBadges(_ badges: [pid_t: String]) {
    for (index, app) in apps.enumerated() where index < cells.count {
      if let badge = badges[app.pid] {
        apps[index].badgeLabel = badge
        let shortcutNumber: Int? = Settings.shared.showNumberShortcuts && index < 10 ? (index + 1) % 10 : nil
        cells[index].configure(with: apps[index], shortcutNumber: shortcutNumber)
      }
    }
  }

  private func updateSelection() {
    for (index, cell) in cells.enumerated() {
      cell.isHighlighted = (index == selectedIndex)
    }
  }
}
