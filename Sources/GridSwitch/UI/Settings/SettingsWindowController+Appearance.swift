import AppKit
import UniformTypeIdentifiers

extension SettingsWindowController {
  func addAppearanceSections() {
    addIconSizeRow()
    addMaxColumnsRow()
    addBackgroundColorRow()
    addBackgroundOpacityRow()
    addBackgroundImageRow()
    addBackgroundImagePathLabel()
    addImageOpacityRow()
  }

  private func addIconSizeRow() {
    let row = SettingsUIBuilder.makeRow()
    let title = NSTextField(labelWithString: L10n.iconSize)
    title.font = .systemFont(ofSize: 13)
    title.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    iconSizeSlider = NSSlider(
      value: Double(settings.iconSize),
      minValue: 32,
      maxValue: 128,
      target: self,
      action: #selector(iconSizeChanged)
    )
    iconSizeSlider.widthAnchor.constraint(equalToConstant: 150).isActive = true

    iconSizeLabel = NSTextField(labelWithString: "\(Int(settings.iconSize))px")
    iconSizeLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    iconSizeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true

    row.addArrangedSubview(title)
    row.addArrangedSubview(iconSizeSlider)
    row.addArrangedSubview(iconSizeLabel)
    stackView.addArrangedSubview(row)
  }

  private func addMaxColumnsRow() {
    let row = SettingsUIBuilder.makeRow()
    let title = NSTextField(labelWithString: L10n.maxColumns)
    title.font = .systemFont(ofSize: 13)
    title.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    maxColumnsSlider = NSSlider(
      value: Double(settings.maxColumns),
      minValue: 4,
      maxValue: 12,
      target: self,
      action: #selector(maxColumnsChanged)
    )
    maxColumnsSlider.numberOfTickMarks = 9
    maxColumnsSlider.allowsTickMarkValuesOnly = true
    maxColumnsSlider.widthAnchor.constraint(equalToConstant: 150).isActive = true

    maxColumnsLabel = NSTextField(labelWithString: "\(settings.maxColumns)")
    maxColumnsLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    maxColumnsLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true

    row.addArrangedSubview(title)
    row.addArrangedSubview(maxColumnsSlider)
    row.addArrangedSubview(maxColumnsLabel)
    stackView.addArrangedSubview(row)
  }

  private func addBackgroundColorRow() {
    let row = SettingsUIBuilder.makeRow()
    let title = NSTextField(labelWithString: L10n.backgroundColor)
    title.font = .systemFont(ofSize: 13)
    title.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    colorWell = NSColorWell(style: .default)
    colorWell.color = settings.backgroundColor
    colorWell.target = self
    colorWell.action = #selector(backgroundColorChanged)
    colorWell.widthAnchor.constraint(equalToConstant: 44).isActive = true
    colorWell.heightAnchor.constraint(equalToConstant: 28).isActive = true

    row.addArrangedSubview(title)
    row.addArrangedSubview(colorWell)
    stackView.addArrangedSubview(row)
  }

  private func addBackgroundOpacityRow() {
    let row = SettingsUIBuilder.makeRow()
    let title = NSTextField(labelWithString: L10n.backgroundOpacity)
    title.font = .systemFont(ofSize: 13)
    title.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    opacitySlider = NSSlider(
      value: Double(settings.backgroundOpacity),
      minValue: 0.1,
      maxValue: 1.0,
      target: self,
      action: #selector(opacityChanged)
    )
    opacitySlider.widthAnchor.constraint(equalToConstant: 150).isActive = true

    opacityLabel = NSTextField(labelWithString: "\(Int(settings.backgroundOpacity * 100))%")
    opacityLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    opacityLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true

    row.addArrangedSubview(title)
    row.addArrangedSubview(opacitySlider)
    row.addArrangedSubview(opacityLabel)
    stackView.addArrangedSubview(row)
  }

  private func addBackgroundImageRow() {
    let row = SettingsUIBuilder.makeRow()
    let title = NSTextField(labelWithString: L10n.backgroundImage)
    title.font = .systemFont(ofSize: 13)
    title.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    let selectButton = NSButton(title: L10n.selectImage, target: self, action: #selector(selectBackgroundImage))
    selectButton.bezelStyle = .push

    let clearButton = NSButton(title: L10n.clearImage, target: self, action: #selector(clearBackgroundImage))
    clearButton.bezelStyle = .push

    row.addArrangedSubview(title)
    row.addArrangedSubview(selectButton)
    row.addArrangedSubview(clearButton)
    stackView.addArrangedSubview(row)
  }

  private func addBackgroundImagePathLabel() {
    imagePathLabel = NSTextField(labelWithString: currentImageName())
    imagePathLabel.font = .systemFont(ofSize: 11)
    imagePathLabel.textColor = .secondaryLabelColor
    imagePathLabel.lineBreakMode = .byTruncatingMiddle
    stackView.addArrangedSubview(imagePathLabel)
  }

  private func addImageOpacityRow() {
    let row = SettingsUIBuilder.makeRow()
    let title = NSTextField(labelWithString: L10n.imageOpacity)
    title.font = .systemFont(ofSize: 13)
    title.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    imageOpacitySlider = NSSlider(
      value: Double(settings.backgroundImageOpacity),
      minValue: 0.0,
      maxValue: 1.0,
      target: self,
      action: #selector(imageOpacityChanged)
    )
    imageOpacitySlider.widthAnchor.constraint(equalToConstant: 150).isActive = true

    imageOpacityLabel = NSTextField(labelWithString: "\(Int(settings.backgroundImageOpacity * 100))%")
    imageOpacityLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    imageOpacityLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true

    row.addArrangedSubview(title)
    row.addArrangedSubview(imageOpacitySlider)
    row.addArrangedSubview(imageOpacityLabel)
    stackView.addArrangedSubview(row)
  }

  func currentImageName() -> String {
    let path = settings.backgroundImagePath
    if path.isEmpty { return L10n.noImage }
    return (path as NSString).lastPathComponent
  }

  @objc func iconSizeChanged() {
    let value = CGFloat(Int(iconSizeSlider.doubleValue))
    iconSizeLabel.stringValue = "\(Int(value))px"
    settings.iconSize = value
  }

  @objc func maxColumnsChanged() {
    let value = Int(maxColumnsSlider.doubleValue)
    maxColumnsLabel.stringValue = "\(value)"
    settings.maxColumns = value
  }

  @objc func backgroundColorChanged() {
    settings.backgroundColor = colorWell.color
  }

  @objc func opacityChanged() {
    let value = CGFloat(opacitySlider.doubleValue)
    opacityLabel.stringValue = "\(Int(value * 100))%"
    settings.backgroundOpacity = value
  }

  @objc func imageOpacityChanged() {
    let value = CGFloat(imageOpacitySlider.doubleValue)
    imageOpacityLabel.stringValue = "\(Int(value * 100))%"
    settings.backgroundImageOpacity = value
  }

  @objc func selectBackgroundImage() {
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

  @objc func clearBackgroundImage() {
    settings.backgroundImagePath = ""
    imagePathLabel.stringValue = currentImageName()
  }
}
