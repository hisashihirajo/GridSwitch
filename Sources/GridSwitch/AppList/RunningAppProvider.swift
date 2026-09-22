import AppKit

// 実行中アプリの取得・監視
class RunningAppProvider {
  private(set) var apps: [AppInfo] = []
  var onAppsChanged: (() -> Void)?

  // pid ごとに覚えておくアプリ情報。info が nil なら通常のGUIアプリではない。
  // NSWorkspace は問い合わせのたびに新しい NSRunningApplication を返し、
  // activationPolicy とアイコンの取得がそのたびに macOS への問い合わせになる。
  // 48個で数百ms かかり、メモリが逼迫するとさらに延びるため、Cmd+Tab のたびには問い合わせない。
  private struct Entry {
    let launchDate: Date?
    let bundleIdentifier: String?
    let info: AppInfo?

    // 同じ pid でも別のアプリに使い回されていないか
    func matches(_ app: NSRunningApplication) -> Bool {
      return launchDate == app.launchDate && bundleIdentifier == app.bundleIdentifier
    }
  }

  private var entries: [pid_t: Entry] = [:]
  private let revalidateQueue = DispatchQueue(label: "jp.lifescape.gridswitch.app-list", qos: .utility)
  // 確かめ直しは切り替えのたびに頼まれるので、走っている間の依頼は1回にまとめる
  private var isRevalidating = false
  private var needsRevalidate = false

  init() {
    apply(Self.scan(previous: [:]))
    setupObservers()
  }

  deinit {
    NSWorkspace.shared.notificationCenter.removeObserver(self)
  }

  // Cmd+Tab のたびに呼ぶ。macOS には問い合わせず（一覧を舐めるだけで数十ms かかる）、
  // 覚えている一覧から終了済みのプロセスだけを外す。新しいアプリは起動通知から裏で拾う。
  func refreshApps() {
    let alive = entries.filter { pid, _ in
      kill(pid, 0) == 0 || errno == EPERM
    }
    if alive.count != entries.count {
      apply(alive)
    }
  }

  // 全アプリを確かめ直す。覚えている pid はアイコン等を取り直さず、Dock に出るかだけ見直す。
  private static func scan(previous: [pid_t: Entry]) -> [pid_t: Entry] {
    var next: [pid_t: Entry] = [:]
    for app in NSWorkspace.shared.runningApplications {
      let pid = app.processIdentifier
      let isRegular = app.activationPolicy == .regular
      if let entry = previous[pid], entry.matches(app), (entry.info != nil) == isRegular {
        next[pid] = entry
      } else {
        next[pid] = Entry(
          launchDate: app.launchDate,
          bundleIdentifier: app.bundleIdentifier,
          info: isRegular ? AppInfo.from(app) : nil
        )
      }
    }
    return next
  }

  // 起動後に Dock へ出るようになるアプリもあるため、裏で全アプリを確かめ直す
  func revalidateInBackground() {
    guard !isRevalidating else {
      needsRevalidate = true
      return
    }
    isRevalidating = true
    let snapshot = entries
    revalidateQueue.async { [weak self] in
      let next = Self.scan(previous: snapshot)
      DispatchQueue.main.async {
        guard let self else { return }
        let before = self.apps
        self.apply(next)
        if self.apps.map(\.pid) != before.map(\.pid) {
          self.onAppsChanged?()
        }
        self.isRevalidating = false
        if self.needsRevalidate {
          self.needsRevalidate = false
          self.revalidateInBackground()
        }
      }
    }
  }

  // 覚えているアプリ情報（アクティブ化のたびにアイコンを取り直さないため）
  func cachedInfo(for app: NSRunningApplication) -> AppInfo? {
    guard let entry = entries[app.processIdentifier], entry.matches(app) else { return nil }
    return entry.info
  }

  private func apply(_ next: [pid_t: Entry]) {
    entries = next
    apps = next.values
      .compactMap(\.info)
      .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
  }

  // 現在アクティブなアプリを先頭にしたリストを返す
  func appsWithActiveFirst() -> [AppInfo] {
    return Self.sortWithActiveFirst(
      apps: apps,
      activePid: NSWorkspace.shared.frontmostApplication?.processIdentifier
    )
  }

  // MRU順（最近使った順）でアプリリストを返す
  func appsWithMruOrder() -> [AppInfo] {
    return Self.orderByMru(
      apps: apps,
      mruOrder: Settings.shared.appMruOrder,
      hidden: Settings.shared.hiddenApps,
      activePid: NSWorkspace.shared.frontmostApplication?.processIdentifier
    )
  }

  // アクティブアプリを先頭にする純粋ロジック
  static func sortWithActiveFirst(apps: [AppInfo], activePid: pid_t?) -> [AppInfo] {
    var sorted = apps
    if let activePid,
       let index = sorted.firstIndex(where: { $0.pid == activePid })
    {
      let active = sorted.remove(at: index)
      sorted.insert(active, at: 0)
    }
    return sorted
  }

  // 非表示除外 + MRU順 + アクティブ先頭の純粋ロジック
  static func orderByMru(
    apps: [AppInfo],
    mruOrder: [String],
    hidden: [String],
    activePid: pid_t?
  ) -> [AppInfo] {
    var ordered: [AppInfo] = []
    var remaining = apps

    // 非表示アプリを除外
    let hiddenSet = Set(hidden)
    remaining.removeAll { hiddenSet.contains($0.mruKey) }

    // MRU順に並べる（mruKeyで同一bundleIdのPWAアプリも区別）
    for key in mruOrder {
      if let index = remaining.firstIndex(where: { $0.mruKey == key }) {
        ordered.append(remaining.remove(at: index))
      }
    }

    // MRUに含まれない新規アプリはアルファベット順で末尾に追加
    ordered.append(contentsOf: remaining)

    // アクティブアプリを先頭に
    if let activePid,
       let index = ordered.firstIndex(where: { $0.pid == activePid })
    {
      let active = ordered.remove(at: index)
      ordered.insert(active, at: 0)
    }

    return ordered
  }

  private func setupObservers() {
    let nc = NSWorkspace.shared.notificationCenter
    for name in [
      NSWorkspace.didLaunchApplicationNotification,
      NSWorkspace.didTerminateApplicationNotification,
      NSWorkspace.didActivateApplicationNotification,
    ] {
      nc.addObserver(self, selector: #selector(appsMayHaveChanged(_:)), name: name, object: nil)
    }
  }

  @objc private func appsMayHaveChanged(_ notification: Notification) {
    // 終了したアプリはその場で外す（裏での確かめ直しを待たない）
    if notification.name == NSWorkspace.didTerminateApplicationNotification,
      let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
    {
      var next = entries
      next.removeValue(forKey: app.processIdentifier)
      apply(next)
    }
    revalidateInBackground()
  }
}
