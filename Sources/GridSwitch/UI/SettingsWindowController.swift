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

  convenience init() {
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 420, height: 370),
      styleMask: [.titled, .closable],
      backing: .buffered,
      defer: true
    )
    window.title = "設定"
    window.center()
    window.isReleasedWhenClosed = false
    self.init(window: window)
    setupUI()
  }

  private func setupUI() {
    guard let contentView = window?.contentView else { return }

    let stackView = NSStackView()
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

    // アイコンサイズ
    let iconRow = makeRow()
    let iconTitle = NSTextField(labelWithString: "アイコンサイズ:")
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
    let colorTitle = NSTextField(labelWithString: "背景色:")
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
    let opacityTitle = NSTextField(labelWithString: "背景の透過:")
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
    let imageTitle = NSTextField(labelWithString: "背景画像:")
    imageTitle.font = .systemFont(ofSize: 13)
    imageTitle.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    let selectButton = NSButton(title: "選択...", target: self, action: #selector(selectBackgroundImage))
    selectButton.bezelStyle = .push

    let clearButton = NSButton(title: "クリア", target: self, action: #selector(clearBackgroundImage))
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
    let imageOpacityTitle = NSTextField(labelWithString: "画像の透過:")
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

    // 区切り線
    let separator = NSBox()
    separator.boxType = .separator
    stackView.addArrangedSubview(separator)
    separator.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -40).isActive = true

    // ログイン時に自動起動
    launchAtLoginCheckbox = NSButton(checkboxWithTitle: "Mac起動時に自動で起動する", target: self, action: #selector(launchAtLoginChanged))
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
    // 実際の状態を反映（権限不足等で変更できなかった場合）
    launchAtLoginCheckbox.state = LaunchAtLogin.isEnabled ? .on : .off
  }

  @objc private func selectBackgroundImage() {
    let panel = NSOpenPanel()
    panel.title = "背景画像を選択"
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
    if path.isEmpty { return "未設定" }
    return (path as NSString).lastPathComponent
  }

  func showWindow() {
    window?.center()
    window?.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
}
