import XCTest
import AppKit
@testable import GridSwitch

final class AppInfoTests: XCTestCase {
  private func makeAppInfo(
    name: String = "Safari",
    pid: pid_t = 1234,
    bundleIdentifier: String? = "com.apple.Safari"
  ) -> AppInfo {
    return AppInfo(
      name: name,
      icon: NSImage(),
      pid: pid,
      bundleIdentifier: bundleIdentifier
    )
  }

  // MARK: - mruKey

  func testMruKeyCombinesBundleIdAndName() {
    let info = makeAppInfo(name: "Safari", bundleIdentifier: "com.apple.Safari")
    XCTAssertEqual(info.mruKey, "com.apple.Safari:Safari")
  }

  func testMruKeyUsesUnknownForNilBundleId() {
    let info = makeAppInfo(name: "MyApp", bundleIdentifier: nil)
    XCTAssertEqual(info.mruKey, "unknown:MyApp")
  }

  func testMruKeyDistinguishesPwaApps() {
    // PWAアプリは同じbundleIdでも名前で区別される
    let gmail = makeAppInfo(name: "Gmail", pid: 100, bundleIdentifier: "com.google.Chrome.app.gmail")
    let slack = makeAppInfo(name: "Slack", pid: 200, bundleIdentifier: "com.google.Chrome.app.gmail")
    XCTAssertNotEqual(gmail.mruKey, slack.mruKey)
  }

  // MARK: - Equatable

  func testEqualByPid() {
    let a = makeAppInfo(pid: 100)
    let b = makeAppInfo(pid: 100)
    XCTAssertEqual(a, b)
  }

  func testNotEqualByDifferentPid() {
    let a = makeAppInfo(pid: 100)
    let b = makeAppInfo(pid: 200)
    XCTAssertNotEqual(a, b)
  }

  func testEqualEvenIfOtherFieldsDiffer() {
    // Equatableはpidのみで判定
    let a = makeAppInfo(name: "A", pid: 100, bundleIdentifier: "com.a")
    let b = makeAppInfo(name: "B", pid: 100, bundleIdentifier: "com.b")
    XCTAssertEqual(a, b)
  }

  // MARK: - Hashable

  func testSamePidProducesSameHash() {
    let a = makeAppInfo(name: "A", pid: 100)
    let b = makeAppInfo(name: "B", pid: 100)
    XCTAssertEqual(a.hashValue, b.hashValue)
  }

  func testSetDeduplicatesByPid() {
    let a = makeAppInfo(name: "Safari", pid: 100)
    let b = makeAppInfo(name: "Different", pid: 100)
    let c = makeAppInfo(name: "Other", pid: 200)
    let set = Set([a, b, c])
    XCTAssertEqual(set.count, 2)
  }

  // MARK: - badgeLabel は変更可能

  func testBadgeLabelMutable() {
    var info = makeAppInfo()
    XCTAssertNil(info.badgeLabel)
    info.badgeLabel = "5"
    XCTAssertEqual(info.badgeLabel, "5")
  }
}
