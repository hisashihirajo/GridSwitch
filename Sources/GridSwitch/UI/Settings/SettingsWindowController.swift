import AppKit

class SettingsWindowController: NSWindowController {
  let settings = Settings.shared

  // セクション間で参照されるUI要素
  var iconSizeSlider: NSSlider!
  var iconSizeLabel: NSTextField!
  var maxColumnsSlider: NSSlider!
  var maxColumnsLabel: NSTextField!
  var colorWell: NSColorWell!
  var opacitySlider: NSSlider!
  var opacityLabel: NSTextField!
  var imagePathLabel: NSTextField!
  var imageOpacitySlider: NSSlider!
  var imageOpacityLabel: NSTextField!
  var numberShortcutsCheckbox: NSButton!
  var launchAtLoginCheckbox: NSButton!
  var languagePopup: NSPopUpButton!
  var hiddenAppsCountLabel: NSTextField!
  var hiddenAppsWindow: NSWindow?
  var stackView: NSStackView!

  convenience init() {
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 420, height: 460),
      styleMask: [.titled, .closable],
      backing: .buffered,
      defer: true
    )
    window.title = L10n.settings
    window.center()
    window.isReleasedWhenClosed = false
    self.init(window: window)
    setupUI()
  }

  func setupUI() {
    guard let contentView = window?.contentView else { return }
    contentView.subviews.forEach { $0.removeFromSuperview() }

    let scrollView = NSScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.hasVerticalScroller = true
    scrollView.drawsBackground = false
    scrollView.borderType = .noBorder
    contentView.addSubview(scrollView)

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
    ])

    let documentView = FlippedView()
    documentView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.documentView = documentView

    stackView = NSStackView()
    stackView.orientation = .vertical
    stackView.alignment = .leading
    stackView.spacing = 16
    stackView.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    documentView.addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: documentView.topAnchor),
      stackView.leadingAnchor.constraint(equalTo: documentView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: documentView.trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: documentView.bottomAnchor),
      stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
    ])

    // セクション順: 言語 → 区切り → 外観群 → 非表示アプリ → 区切り → トグル群
    addLanguageSection()
    SettingsUIBuilder.addSeparator(to: stackView)
    addAppearanceSections()
    addHiddenAppsSection()
    SettingsUIBuilder.addSeparator(to: stackView)
    addNumberShortcutsCheckbox()
    addLaunchAtLoginCheckbox()
  }

  func showWindow() {
    window?.title = L10n.settings
    window?.center()
    window?.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
}
