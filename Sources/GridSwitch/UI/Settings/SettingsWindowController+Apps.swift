import AppKit

extension SettingsWindowController {
  func addHiddenAppsSection() {
    let row = SettingsUIBuilder.makeRow()

    let title = NSTextField(labelWithString: L10n.hiddenApps)
    title.font = .systemFont(ofSize: 13)
    title.setContentHuggingPriority(.defaultHigh, for: .horizontal)

    let editButton = NSButton(title: L10n.editHiddenApps, target: self, action: #selector(openHiddenAppsEditor))
    editButton.bezelStyle = .push

    hiddenAppsCountLabel = NSTextField(labelWithString: hiddenAppsCountText())
    hiddenAppsCountLabel.font = .systemFont(ofSize: 11)
    hiddenAppsCountLabel.textColor = .secondaryLabelColor

    row.addArrangedSubview(title)
    row.addArrangedSubview(editButton)
    row.addArrangedSubview(hiddenAppsCountLabel)
    stackView.addArrangedSubview(row)
  }

  func hiddenAppsCountText() -> String {
    let count = settings.hiddenApps.count
    return count == 0 ? L10n.noHiddenApps : "\(count)"
  }

  @objc func openHiddenAppsEditor() {
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
    contentView.subviews.forEach { $0.removeFromSuperview() }

    let descLabel = NSTextField(wrappingLabelWithString: L10n.hiddenAppsDescription)
    descLabel.font = .systemFont(ofSize: 12)
    descLabel.textColor = .secondaryLabelColor
    descLabel.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(descLabel)

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

  @objc func hiddenAppCheckboxChanged(_ sender: NSButton) {
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
}
