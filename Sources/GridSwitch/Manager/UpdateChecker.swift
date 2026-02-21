import AppKit
import Foundation

// GitHub Releases APIを使ったアップデートチェッカー
final class UpdateChecker {
  static let shared = UpdateChecker()

  private let repoOwner = "hisashihirajo"
  private let repoName = "GridSwitch"

  private var isChecking = false

  private init() {}

  // MARK: - 公開API

  // メニューから手動でチェック（結果を常にダイアログ表示）
  func checkForUpdatesManually() {
    checkForUpdates(silent: false)
  }

  // 起動時のバックグラウンドチェック（新バージョンがある場合のみ通知）
  func checkForUpdatesInBackground() {
    checkForUpdates(silent: true)
  }

  // MARK: - チェック処理

  private func checkForUpdates(silent: Bool) {
    guard !isChecking else { return }
    isChecking = true

    let urlString = "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases/latest"
    guard let url = URL(string: urlString) else {
      isChecking = false
      return
    }

    var request = URLRequest(url: url)
    request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

    URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
      DispatchQueue.main.async {
        self?.handleResponse(data: data, response: response, error: error, silent: silent)
      }
    }.resume()
  }

  private func handleResponse(data: Data?, response: URLResponse?, error: Error?, silent: Bool) {
    defer { isChecking = false }

    if let error = error {
      if !silent {
        showError(L10n.updateFailed + "\n\(error.localizedDescription)")
      }
      return
    }

    guard let data = data,
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let tagName = json["tag_name"] as? String,
      let assets = json["assets"] as? [[String: Any]]
    else {
      if !silent {
        showError(L10n.updateFailed)
      }
      return
    }

    let latestVersion = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName
    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"

    if compareVersions(latestVersion, isNewerThan: currentVersion) {
      // zipアセットを探す
      let zipAsset = assets.first { asset in
        guard let name = asset["name"] as? String else { return false }
        return name.hasSuffix(".zip")
      }

      guard let downloadURLString = zipAsset?["browser_download_url"] as? String,
        let downloadURL = URL(string: downloadURLString)
      else {
        if !silent {
          showError(L10n.updateFailed)
        }
        return
      }

      showUpdateAvailableDialog(newVersion: latestVersion, downloadURL: downloadURL)
    } else {
      if !silent {
        showUpToDateDialog()
      }
    }
  }

  // MARK: - バージョン比較

  // latestがcurrentより新しいかどうか
  func compareVersions(_ latest: String, isNewerThan current: String) -> Bool {
    let latestParts = latest.split(separator: ".").compactMap { Int($0) }
    let currentParts = current.split(separator: ".").compactMap { Int($0) }

    let maxCount = max(latestParts.count, currentParts.count)
    for i in 0..<maxCount {
      let l = i < latestParts.count ? latestParts[i] : 0
      let c = i < currentParts.count ? currentParts[i] : 0
      if l > c { return true }
      if l < c { return false }
    }
    return false
  }

  // MARK: - ダイアログ

  private func showUpdateAvailableDialog(newVersion: String, downloadURL: URL) {
    let alert = NSAlert()
    alert.messageText = L10n.updateAvailable
    alert.informativeText = L10n.updateMessage(newVersion: newVersion)
    alert.alertStyle = .informational
    alert.addButton(withTitle: L10n.updateNow)
    alert.addButton(withTitle: L10n.updateLater)

    let response = alert.runModal()
    if response == .alertFirstButtonReturn {
      downloadAndInstall(from: downloadURL, version: newVersion)
    }
  }

  private func showUpToDateDialog() {
    let alert = NSAlert()
    alert.messageText = "GridSwitch"
    alert.informativeText = L10n.noUpdateAvailable
    alert.alertStyle = .informational
    alert.runModal()
  }

  private func showError(_ message: String) {
    let alert = NSAlert()
    alert.messageText = "GridSwitch"
    alert.informativeText = message
    alert.alertStyle = .warning
    alert.runModal()
  }

  // MARK: - ダウンロード＆インストール

  private func downloadAndInstall(from url: URL, version: String) {
    // プログレスダイアログ表示
    let progressAlert = NSAlert()
    progressAlert.messageText = "GridSwitch"
    progressAlert.informativeText = L10n.downloading
    progressAlert.alertStyle = .informational
    progressAlert.addButton(withTitle: "")
    // ボタンを非表示にする
    progressAlert.buttons.first?.isHidden = true

    let indicator = NSProgressIndicator(frame: NSRect(x: 0, y: 0, width: 300, height: 20))
    indicator.isIndeterminate = true
    indicator.style = .bar
    indicator.startAnimation(nil)
    progressAlert.accessoryView = indicator

    // 非同期でダイアログ表示
    progressAlert.beginSheetModal(for: NSWindow()) { _ in }

    let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

    do {
      try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    } catch {
      progressAlert.window.orderOut(nil)
      showError(L10n.updateFailed + "\n\(error.localizedDescription)")
      return
    }

    let zipPath = tempDir.appendingPathComponent("GridSwitch.zip")

    URLSession.shared.downloadTask(with: url) { [weak self] tempURL, response, error in
      DispatchQueue.main.async {
        progressAlert.window.orderOut(nil)

        guard let self = self else { return }

        if let error = error {
          self.showError(L10n.updateFailed + "\n\(error.localizedDescription)")
          self.cleanup(tempDir)
          return
        }

        guard let tempURL = tempURL else {
          self.showError(L10n.updateFailed)
          self.cleanup(tempDir)
          return
        }

        do {
          try FileManager.default.moveItem(at: tempURL, to: zipPath)
        } catch {
          self.showError(L10n.updateFailed + "\n\(error.localizedDescription)")
          self.cleanup(tempDir)
          return
        }

        self.extractAndReplace(zipPath: zipPath, tempDir: tempDir)
      }
    }.resume()
  }

  private func extractAndReplace(zipPath: URL, tempDir: URL) {
    let extractDir = tempDir.appendingPathComponent("extracted")

    do {
      try FileManager.default.createDirectory(at: extractDir, withIntermediateDirectories: true)
    } catch {
      showError(L10n.updateFailed + "\n\(error.localizedDescription)")
      cleanup(tempDir)
      return
    }

    // dittoでzip展開
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
    process.arguments = ["-xk", zipPath.path, extractDir.path]

    do {
      try process.run()
      process.waitUntilExit()
    } catch {
      showError(L10n.updateFailed + "\n\(error.localizedDescription)")
      cleanup(tempDir)
      return
    }

    guard process.terminationStatus == 0 else {
      showError(L10n.updateFailed)
      cleanup(tempDir)
      return
    }

    // 展開された.appバンドルを探す
    guard let newAppPath = findAppBundle(in: extractDir) else {
      showError(L10n.updateFailed)
      cleanup(tempDir)
      return
    }

    // 現在のアプリを置換
    let currentAppPath = Bundle.main.bundlePath
    let backupPath = currentAppPath + ".bak"
    let fm = FileManager.default

    do {
      // バックアップ作成
      if fm.fileExists(atPath: backupPath) {
        try fm.removeItem(atPath: backupPath)
      }
      try fm.moveItem(atPath: currentAppPath, toPath: backupPath)

      // 新バージョンを配置
      try fm.moveItem(atPath: newAppPath.path, toPath: currentAppPath)

      // バックアップ削除
      try? fm.removeItem(atPath: backupPath)

      // 一時ディレクトリ削除
      cleanup(tempDir)

      // 新バージョンを起動して自分を終了
      relaunchApp(at: currentAppPath)
    } catch {
      // 失敗時はバックアップを復元
      if fm.fileExists(atPath: backupPath) && !fm.fileExists(atPath: currentAppPath) {
        try? fm.moveItem(atPath: backupPath, toPath: currentAppPath)
      }
      showError(L10n.updateFailed + "\n\(error.localizedDescription)")
      cleanup(tempDir)
    }
  }

  // ディレクトリ内の.appバンドルを再帰的に探す
  private func findAppBundle(in directory: URL) -> URL? {
    let fm = FileManager.default
    guard let enumerator = fm.enumerator(at: directory, includingPropertiesForKeys: nil) else {
      return nil
    }

    for case let fileURL as URL in enumerator {
      if fileURL.pathExtension == "app" {
        return fileURL
      }
    }
    return nil
  }

  private func relaunchApp(at path: String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    process.arguments = ["-n", path]

    do {
      try process.run()
    } catch {
      NSLog("[GridSwitch] 再起動に失敗: \(error)")
    }

    // 現在のプロセスを終了
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      NSApplication.shared.terminate(nil)
    }
  }

  private func cleanup(_ directory: URL) {
    try? FileManager.default.removeItem(at: directory)
  }
}
