import XCTest
import AppKit
@testable import GridSwitch

final class RunningAppProviderTests: XCTestCase {
  // テスト用の AppInfo を作る（icon は中身不問）
  private func app(_ name: String, pid: pid_t, bundleId: String? = nil) -> AppInfo {
    return AppInfo(
      name: name,
      icon: NSImage(),
      pid: pid,
      bundleIdentifier: bundleId ?? "com.test.\(name.lowercased())"
    )
  }

  // MARK: - sortWithActiveFirst

  func testSortWithActiveFirstMovesActiveToFront() {
    let apps = [app("A", pid: 1), app("B", pid: 2), app("C", pid: 3)]
    let sorted = RunningAppProvider.sortWithActiveFirst(apps: apps, activePid: 2)
    XCTAssertEqual(sorted.map(\.pid), [2, 1, 3])
  }

  func testSortWithActiveFirstKeepsOrderIfActiveAlreadyFirst() {
    let apps = [app("A", pid: 1), app("B", pid: 2)]
    let sorted = RunningAppProvider.sortWithActiveFirst(apps: apps, activePid: 1)
    XCTAssertEqual(sorted.map(\.pid), [1, 2])
  }

  func testSortWithActiveFirstUnchangedIfNoActive() {
    let apps = [app("A", pid: 1), app("B", pid: 2)]
    let sorted = RunningAppProvider.sortWithActiveFirst(apps: apps, activePid: nil)
    XCTAssertEqual(sorted.map(\.pid), [1, 2])
  }

  func testSortWithActiveFirstUnchangedIfActivePidNotInList() {
    let apps = [app("A", pid: 1), app("B", pid: 2)]
    let sorted = RunningAppProvider.sortWithActiveFirst(apps: apps, activePid: 999)
    XCTAssertEqual(sorted.map(\.pid), [1, 2])
  }

  func testSortWithActiveFirstEmpty() {
    let sorted = RunningAppProvider.sortWithActiveFirst(apps: [], activePid: 1)
    XCTAssertTrue(sorted.isEmpty)
  }

  // MARK: - orderByMru

  func testOrderByMruRespectsMruOrder() {
    let a = app("A", pid: 1)
    let b = app("B", pid: 2)
    let c = app("C", pid: 3)
    let result = RunningAppProvider.orderByMru(
      apps: [a, b, c],
      mruOrder: [c.mruKey, a.mruKey, b.mruKey],
      hidden: [],
      activePid: nil
    )
    XCTAssertEqual(result.map(\.pid), [3, 1, 2])
  }

  func testOrderByMruPutsNonMruAppsAtEnd() {
    let a = app("A", pid: 1)
    let b = app("B", pid: 2)
    let c = app("C", pid: 3) // MRU未登録
    let result = RunningAppProvider.orderByMru(
      apps: [a, b, c],
      mruOrder: [b.mruKey, a.mruKey],
      hidden: [],
      activePid: nil
    )
    // MRUにあるb, aの後にc
    XCTAssertEqual(result.map(\.pid), [2, 1, 3])
  }

  func testOrderByMruExcludesHidden() {
    let a = app("A", pid: 1)
    let b = app("B", pid: 2)
    let c = app("C", pid: 3)
    let result = RunningAppProvider.orderByMru(
      apps: [a, b, c],
      mruOrder: [],
      hidden: [b.mruKey],
      activePid: nil
    )
    XCTAssertEqual(result.map(\.pid), [1, 3])
  }

  func testOrderByMruActiveAppGoesToFrontAfterMru() {
    let a = app("A", pid: 1)
    let b = app("B", pid: 2)
    let c = app("C", pid: 3)
    // MRU: [b, a, c]、activeはc
    let result = RunningAppProvider.orderByMru(
      apps: [a, b, c],
      mruOrder: [b.mruKey, a.mruKey, c.mruKey],
      hidden: [],
      activePid: 3
    )
    // active(c)が先頭、その後 MRU 順から c を除いた [b, a]
    XCTAssertEqual(result.map(\.pid), [3, 2, 1])
  }

  func testOrderByMruEmptyApps() {
    let result = RunningAppProvider.orderByMru(
      apps: [],
      mruOrder: ["x"],
      hidden: ["y"],
      activePid: 1
    )
    XCTAssertTrue(result.isEmpty)
  }

  func testOrderByMruIgnoresMruEntriesNotInApps() {
    let a = app("A", pid: 1)
    let result = RunningAppProvider.orderByMru(
      apps: [a],
      mruOrder: ["ghost.app:Ghost", a.mruKey],
      hidden: [],
      activePid: nil
    )
    XCTAssertEqual(result.map(\.pid), [1])
  }

  func testOrderByMruHiddenTakesPrecedenceOverActive() {
    let a = app("A", pid: 1)
    let b = app("B", pid: 2)
    let result = RunningAppProvider.orderByMru(
      apps: [a, b],
      mruOrder: [],
      hidden: [a.mruKey], // aを非表示
      activePid: 1        // でも a がアクティブ
    )
    XCTAssertEqual(result.map(\.pid), [2])
  }
}
