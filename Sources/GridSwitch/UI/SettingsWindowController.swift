import AppKit
import UniformTypeIdentifiers

class SettingsWindowController: NSWindowController {
  private let settings = Settings.shared
  private var iconSizeSlider: NSSlider!
  private var iconSizeLabel: NSTextField!
  private var colorWell: NSColorWell!
  private var opacitySlider: NSSlider!
  private var opacityLabel: NSTextField!
  private var imagePathLabel: NSTextField!
  private var imageOpacitySlider: NSSlider!
  private var imageOpacityLabel: NSTextField!
  private var launchAtLoginCheckbox: NSButton!
  private var languagePopup: NSPopUpButton!
  private var hiddenAppsCountLabel: NSTextField!
  private var hiddenAppsWindow: NSWindow?
  private var stackView: NSStackView!

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

  private func setupUI() {
    guard let contentView = window?.contentView else { return }

    // 既存のstackViewがあれば除去
    stackView?.removeFromSuperview()

    stackView = NSStackView()
    stackView.orientation = .vertical
    stackView.alignment = .leading
    stackView.spacing = 16
    stackView.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
    ])

    // 言語
    let langRow = makeRow()
    let langTitle = NSTextField(labelWithString: L10n.language)
    langTitle.font = .systemFont(ofSize: 13)
    langTitle.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    languagePopup = NSPopUpButton(frame: .zero, pullsDown: false)
    for lang in Language.allCases {
      languagePopup.addItem(withTitle: lang.displayName)
      languagePopup.lastItem?.representedObject = lang.rawValue
    }
    // 現在の言語を選択
    let currentLang = Language(rawValue: settings.language) ?? .ja
    if let index = Language.allCases.firstIndex(of: currentLang) {
      languagePopup.selectItem(at: index)
    }
    languagePopup.target = self
    languagePopup.action = #selector(languageChanged)

    langRow.addArrangedSubview(langTitle)
    langRow.addArrangedSubview(languagePopup)
    stackView.addArrangedSubview(langRow)

    // 区切り線（言語の後）
    let langSeparator = NSBox()
    langSeparator.boxType = .separator
    stackView.addArrangedSubview(langSeparator)
    langSeparator.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -40).isActive = true

    // アイコンサイズ
    let iconRow = makeRow()
    let iconTitle = NSTextField(labelWithString: L10n.iconSize)
    iconTitle.font = .systemFont(ofSize: 13)
    iconTitle.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    iconSizeSlider = NSSlider(value: Double(settings.iconSize), minValue: 32, maxValue: 128, target: self, action: #selector(iconSizeChanged))
    iconSizeSlider.widthAnchor.constraint(equalToConstant: 150).isActive = true

    iconSizeLabel = NSTextField(labelWithString: "\(Int(settings.iconSize))px")
    iconSizeLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    iconSizeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true

    iconRow.addArrangedSubview(iconTitle)
    iconRow.addArrangedSubview(iconSizeSlider)
    iconRow.addArrangedSubview(iconSizeLabel)
    stackView.addArrangedSubview(iconRow)

    // 背景色
    let colorRow = makeRow()
    let colorTitle = NSTextField(labelWithString: L10n.backgroundColor)
    colorTitle.font = .systemFont(ofSize: 13)
    colorTitle.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    colorWell = NSColorWell(style: .default)
    colorWell.color = settings.backgroundColor
    colorWell.target = self
    colorWell.action = #selector(backgroundColorChanged)
    colorWell.widthAnchor.constraint(equalToConstant: 44).isActive = true
    colorWell.heightAnchor.constraint(equalToConstant: 28).isActive = true

    colorRow.addArrangedSubview(colorTitle)
    colorRow.addArrangedSubview(colorWell)
    stackView.addArrangedSubview(colorRow)

    // 背景透過
    let opacityRow = makeRow()
    let opacityTitle = NSTextField(labelWithString: L10n.backgroundOpacity)
    opacityTitle.font = .systemFont(ofSize: 13)
    opacityTitle.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    opacitySlider = NSSlider(value: Double(settings.backgroundOpacity), minValue: 0.1, maxValue: 1.0, target: self, action: #selector(opacityChanged))
    opacitySlider.widthAnchor.constraint(equalToConstant: 150).isActive = true

    opacityLabel = NSTextField(labelWithString: "\(Int(settings.backgroundOpacity * 100))%")
    opacityLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    opacityLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true

    opacityRow.addArrangedSubview(opacityTitle)
    opacityRow.addArrangedSubview(opacitySlider)
    opacityRow.addArrangedSubview(opacityLabel)
    stackView.addArrangedSubview(opacityRow)

    // 背景画像
    let imageRow = makeRow()
    let imageTitle = NSTextField(labelWithString: L10n.backgroundImage)
    imageTitle.font = .systemFont(ofSize: 13)
    imageTitle.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    let selectButton = NSButton(title: L10n.selectImage, target: self, action: #selector(selectBackgroundImage))
    selectButton.bezelStyle = .push

    let clearButton = NSButton(title: L10n.clearImage, target: self, action: #selector(clearBackgroundImage))
    clearButton.bezelStyle = .push

    imageRow.addArrangedSubview(imageTitle)
    imageRow.addArrangedSubview(selectButton)
    imageRow.addArrangedSubview(clearButton)
    stackView.addArrangedSubview(imageRow)

    // 選択中のファイル名表示
    imagePathLabel = NSTextField(labelWithString: currentImageName())
    imagePathLabel.font = .systemFont(ofSize: 11)
    imagePathLabel.textColor = .secondaryLabelColor
    imagePathLabel.lineBreakMode = .byTruncatingMiddle
    stackView.addArrangedSubview(imagePathLabel)

    // 背景画像の透過
    let imageOpacityRow = makeRow()
    let imageOpacityTitle = NSTextField(labelWithString: L10n.imageOpacity)
    imageOpacityTitle.font = .systemFont(ofSize: 13)
    imageOpacityTitle.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    imageOpacitySlider = NSSlider(value: Double(settings.backgroundImageOpacity), minValue: 0.0, maxValue: 1.0, target: self, action: #selector(imageOpacityChanged))
    imageOpacitySlider.widthAnchor.constraint(equalToConstant: 150).isActive = true

    imageOpacityLabel = NSTextField(labelWithString: "\(Int(settings.backgroundImageOpacity * 100))%")
    imageOpacityLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    imageOpacityLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true

    imageOpacityRow.addArrangedSubview(imageOpacityTitle)
    imageOpacityRow.addArrangedSubview(imageOpacitySlider)
    imageOpacityRow.addArrangedSubview(imageOpacityLabel)
    stackView.addArrangedSubview(imageOpacityRow)

    // 非表示アプリ
    let hiddenRow = makeRow()
    let hiddenTitle = NSTextField(labelWithString: L10n.hiddenApps)
    hiddenTitle.font = .systemFont(ofSize: 13)
    hiddenTitle.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    let editButton = NSButton(title: L10n.editHiddenApps, target: self, action: #selector(openHiddenAppsEditor))
    editButton.bezelStyle = .push

    hiddenAppsCountLabel = NSTextField(labelWithString: hiddenAppsCountText())
    hiddenAppsCountLabel.font = .systemFont(ofSize: 11)
    hiddenAppsCountLabel.textColor = .secondaryLabelColor

    hiddenRow.addArrangedSubview(hiddenTitle)
    hiddenRow.addArrangedSubview(editButton)
    hiddenRow.addArrangedSubview(hiddenAppsCountLabel)
    stackView.addArrangedSubview(hiddenRow)

    // 区切り線
    let separator = NSBox()
    separator.boxType = .separator
    stackView.addArrangedSubview(separator)
    separator.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -40).isActive = true

    // ログイン時に自動起動
    launchAtLoginCheckbox = NSButton(checkboxWithTitle: L10n.launchAtLogin, target: self, action: #selector(launchAtLoginChanged))
    launchAtLoginCheckbox.state = LaunchAtLogin.isEnabled ? .on : .off
    stackView.addArrangedSubview(launchAtLoginCheckbox)
  }

  private func makeRow() -> NSStackView {
    let row = NSStackView()
    row.orientation = .horizontal
    row.alignment = .centerY
    row.spacing = 8
    return row
  }

  @objc private func languageChanged() {
    guard let rawValue = languagePopup.selectedItem?.representedObject as? String else { return }
    settings.language = rawValue

    // UIを再構築して即座に反映
    window?.title = L10n.settings
    setupUI()
  }

  @objc private func iconSizeChanged() {
    let value = CGFloat(Int(iconSizeSlider.doubleValue))
    iconSizeLabel.stringValue = "\(Int(value))px"
    settings.iconSize = value
  }

  @objc private func backgroundColorChanged() {
    settings.backgroundColor = colorWell.color
  }

  @objc private func opacityChanged() {
    let value = CGFloat(opacitySlider.doubleValue)
    opacityLabel.stringValue = "\(Int(value * 100))%"
    settings.backgroundOpacity = value
  }

  @objc private func imageOpacityChanged() {
    let value = CGFloat(imageOpacitySlider.doubleValue)
    imageOpacityLabel.stringValue = "\(Int(value * 100))%"
    settings.backgroundImageOpacity = value
  }

  @objc private func launchAtLoginChanged() {
    let enabled = launchAtLoginCheckbox.state == .on
    LaunchAtLogin.setEnabled(enabled)
    launchAtLoginCheckbox.state = LaunchAtLogin.isEnabled ? .on : .off
  }

  @objc private func selectBackgroundImage() {
    let panel = NSOpenPanel()
    panel.title = L10n.selectImageTitle
    panel.allowedContentTypes = [.image]
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = false

    if panel.runModal() == .OK, let url = panel.url {
      settings.backgroundImagePath = url.path
      imagePathLabel.stringValue = currentImageName()
    }
  }

  @objc private func clearBackgroundImage() {
    settings.backgroundImagePath = ""
    imagePathLabel.stringValue = currentImageName()
  }

  private func currentImageName() -> String {
    let path = settings.backgroundImagePath
    if path.isEmpty { return L10n.noImage }
    return (path as NSString).lastPathComponent
  }

  private func hiddenAppsCountText() -> String {
    let count = settings.hiddenApps.count
    return count == 0 ? L10n.noHiddenApps : "\(count)"
  }

  @objc private func openHiddenAppsEditor() {
    // 既存のウィンドウがあれば前面に
    if let existing = hiddenAppsWindow, existing.isVisible {
      existing.makeKeyAndOrderFront(nil)
      return
    }

    let editorWindow = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 360, height: 420),
      styleMask: [.titled, .closable, .resizable],
      backing: .buffered,
      defer: true
    )
    editorWindow.title = L10n.hiddenAppsWindowTitle
    editorWindow.minSize = NSSize(width: 300, height: 300)
    editorWindow.center()
    editorWindow.isReleasedWhenClosed = false
    hiddenAppsWindow = editorWindow

    buildHiddenAppsEditorContent(editorWindow)

    editorWindow.makeKeyAndOrderFront(nil)
  }

  private func buildHiddenAppsEditorContent(_ editorWindow: NSWindow) {
    guard let contentView = editorWindow.contentView else { return }
    // 既存のサブビューをクリア
    contentView.subviews.forEach { $0.removeFromSuperview() }

    // 説明ラベル
    let descLabel = NSTextField(wrappingLabelWithString: L10n.hiddenAppsDescription)
    descLabel.font = .systemFont(ofSize: 12)
    descLabel.textColor = .secondaryLabelColor
    descLabel.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(descLabel)

    // スクロールビュー + スタックビュー
    let scrollView = NSScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.hasVerticalScroller = true
    scrollView.borderType = .bezelBorder
    contentView.addSubview(scrollView)

    let listStack = NSStackView()
    listStack.orientation = .vertical
    listStack.alignment = .leading
    listStack.spacing = 4
    listStack.translatesAutoresizingMaskIntoConstraints = false
    listStack.edgeInsets = NSEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    let documentView = NSView()
    documentView.translatesAutoresizingMaskIntoConstraints = false
    documentView.addSubview(listStack)
    scrollView.documentView = documentView

    NSLayoutConstraint.activate([
      descLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
      descLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      descLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

      scrollView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 8),
      scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
      scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
      scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

      listStack.topAnchor.constraint(equalTo: documentView.topAnchor),
      listStack.leadingAnchor.constraint(equalTo: documentView.leadingAnchor),
      listStack.trailingAnchor.constraint(equalTo: documentView.trailingAnchor),
      listStack.bottomAnchor.constraint(equalTo: documentView.bottomAnchor),
      listStack.widthAnchor.constraint(equalTo: scrollView.contentView.widthAnchor),
    ])

    // 実行中アプリ一覧を取得
    let runningApps = NSWorkspace.shared.runningApplications
      .filter { $0.activationPolicy == .regular }
      .compactMap { AppInfo.from($0) }
      .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

    let hiddenSet = Set(settings.hiddenApps)

    for app in runningApps {
      let row = NSStackView()
      row.orientation = .horizontal
      row.alignment = .centerY
      row.spacing = 8

      let checkbox = NSButton(checkboxWithTitle: "", target: self, action: #selector(hiddenAppCheckboxChanged(_:)))
      checkbox.state = hiddenSet.contains(app.mruKey) ? .on : .off
      // mruKeyをidentifierに保存
      checkbox.identifier = NSUserInterfaceItemIdentifier(app.mruKey)

      let iconView = NSImageView(image: app.icon)
      iconView.widthAnchor.constraint(equalToConstant: 20).isActive = true
      iconView.heightAnchor.constraint(equalToConstant: 20).isActive = true

      let nameLabel = NSTextField(labelWithString: app.name)
      nameLabel.font = .systemFont(ofSize: 13)

      row.addArrangedSubview(checkbox)
      row.addArrangedSubview(iconView)
      row.addArrangedSubview(nameLabel)
      listStack.addArrangedSubview(row)
    }
  }

  @objc private func hiddenAppCheckboxChanged(_ sender: NSButton) {
    guard let mruKey = sender.identifier?.rawValue else { return }
    var hidden = settings.hiddenApps
    if sender.state == .on {
      if !hidden.contains(mruKey) {
        hidden.append(mruKey)
      }
    } else {
      hidden.removeAll { $0 == mruKey }
    }
    settings.hiddenApps = hidden
    hiddenAppsCountLabel?.stringValue = hiddenAppsCountText()
  }

  func showWindow() {
    window?.title = L10n.settings
    window?.center()
    window?.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
}
