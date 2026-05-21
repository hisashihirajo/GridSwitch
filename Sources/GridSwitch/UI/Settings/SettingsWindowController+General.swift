import AppKit

extension SettingsWindowController {
  func addLanguageSection() {
    let row = SettingsUIBuilder.makeRow()

    let title = NSTextField(labelWithString: L10n.language)
    title.font = .systemFont(ofSize: 13)
    title.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    languagePopup = NSPopUpButton(frame: .zero, pullsDown: false)
    for lang in Language.allCases {
      languagePopup.addItem(withTitle: lang.displayName)
      languagePopup.lastItem?.representedObject = lang.rawValue
    }
    let currentLang = Language(rawValue: settings.language) ?? .ja
    if let index = Language.allCases.firstIndex(of: currentLang) {
      languagePopup.selectItem(at: index)
    }
    languagePopup.target = self
    languagePopup.action = #selector(languageChanged)

    row.addArrangedSubview(title)
    row.addArrangedSubview(languagePopup)
    stackView.addArrangedSubview(row)
  }

  func addNumberShortcutsCheckbox() {
    numberShortcutsCheckbox = NSButton(
      checkboxWithTitle: L10n.numberShortcuts,
      target: self,
      action: #selector(numberShortcutsChanged)
    )
    numberShortcutsCheckbox.state = settings.showNumberShortcuts ? .on : .off
    stackView.addArrangedSubview(numberShortcutsCheckbox)
  }

  func addLaunchAtLoginCheckbox() {
    launchAtLoginCheckbox = NSButton(
      checkboxWithTitle: L10n.launchAtLogin,
      target: self,
      action: #selector(launchAtLoginChanged)
    )
    launchAtLoginCheckbox.state = LaunchAtLogin.isEnabled ? .on : .off
    stackView.addArrangedSubview(launchAtLoginCheckbox)
  }

  @objc func languageChanged() {
    guard let rawValue = languagePopup.selectedItem?.representedObject as? String else { return }
    settings.language = rawValue
    window?.title = L10n.settings
    setupUI()
  }

  @objc func numberShortcutsChanged() {
    settings.showNumberShortcuts = numberShortcutsCheckbox.state == .on
  }

  @objc func launchAtLoginChanged() {
    let enabled = launchAtLoginCheckbox.state == .on
    LaunchAtLogin.setEnabled(enabled)
    launchAtLoginCheckbox.state = LaunchAtLogin.isEnabled ? .on : .off
  }
}
