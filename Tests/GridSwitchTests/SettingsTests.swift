import XCTest
import AppKit
@testable import GridSwitch

final class SettingsTests: XCTestCase {
  private var defaults: UserDefaults!
  private var settings: Settings!
  private let suiteName = "GridSwitchTests.Settings"

  override func setUp() {
    super.setUp()
    // テスト用の独立した UserDefaults スイートを使う
    UserDefaults().removePersistentDomain(forName: suiteName)
    defaults = UserDefaults(suiteName: suiteName)!
    settings = Settings(defaults: defaults)
  }

  override func tearDown() {
    defaults.removePersistentDomain(forName: suiteName)
    super.tearDown()
  }

  // MARK: - デフォルト値

  func testIconSizeDefault() {
    XCTAssertEqual(settings.iconSize, 64.0)
  }

  func testBackgroundOpacityDefault() {
    XCTAssertEqual(settings.backgroundOpacity, 0.85, accuracy: 0.001)
  }

  func testBackgroundImageOpacityDefault() {
    XCTAssertEqual(settings.backgroundImageOpacity, 1.0, accuracy: 0.001)
  }

  func testLanguageDefault() {
    XCTAssertEqual(settings.language, "ja")
  }

  func testMaxColumnsDefault() {
    XCTAssertEqual(settings.maxColumns, 8)
  }

  func testShowNumberShortcutsDefault() {
    XCTAssertTrue(settings.showNumberShortcuts)
  }

  func testBackgroundImagePathDefaultEmpty() {
    XCTAssertEqual(settings.backgroundImagePath, "")
  }

  func testHiddenAppsDefaultEmpty() {
    XCTAssertTrue(settings.hiddenApps.isEmpty)
  }

  func testAppMruOrderDefaultEmpty() {
    XCTAssertTrue(settings.appMruOrder.isEmpty)
  }

  // MARK: - 永続化

  func testIconSizeRoundtrip() {
    settings.iconSize = 96
    XCTAssertEqual(settings.iconSize, 96)
  }

  func testLanguageRoundtrip() {
    settings.language = "en"
    XCTAssertEqual(settings.language, "en")
  }

  func testBackgroundImagePathRoundtrip() {
    settings.backgroundImagePath = "/tmp/test.png"
    XCTAssertEqual(settings.backgroundImagePath, "/tmp/test.png")
  }

  func testHiddenAppsRoundtrip() {
    settings.hiddenApps = ["com.apple.Safari:Safari", "com.apple.Mail:Mail"]
    XCTAssertEqual(settings.hiddenApps, ["com.apple.Safari:Safari", "com.apple.Mail:Mail"])
  }

  func testAppMruOrderRoundtrip() {
    settings.appMruOrder = ["a", "b", "c"]
    XCTAssertEqual(settings.appMruOrder, ["a", "b", "c"])
  }

  // MARK: - 値域制約

  func testMaxColumnsClampedToMin() {
    settings.maxColumns = 1
    XCTAssertEqual(settings.maxColumns, 4)
  }

  func testMaxColumnsClampedToMax() {
    settings.maxColumns = 100
    XCTAssertEqual(settings.maxColumns, 12)
  }

  func testMaxColumnsInRange() {
    settings.maxColumns = 7
    XCTAssertEqual(settings.maxColumns, 7)
  }

  // MARK: - 背景色

  func testBackgroundColorRoundtrip() {
    let input = NSColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1.0)
    settings.backgroundColor = input

    let output = settings.backgroundColor.usingColorSpace(.sRGB)!
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    output.getRed(&r, green: &g, blue: &b, alpha: &a)

    XCTAssertEqual(r, 0.3, accuracy: 0.001)
    XCTAssertEqual(g, 0.6, accuracy: 0.001)
    XCTAssertEqual(b, 0.9, accuracy: 0.001)
  }

  // MARK: - セル寸法（iconSize連動）

  func testCellSizeFollowsIconSize() {
    settings.iconSize = 64
    XCTAssertEqual(settings.cellWidth, 100)
    XCTAssertEqual(settings.cellHeight, 100)

    settings.iconSize = 32
    XCTAssertEqual(settings.cellWidth, 68)
    XCTAssertEqual(settings.cellHeight, 68)
  }

  // MARK: - 変更通知

  func testNotificationPostedOnIconSizeChange() {
    let expectation = XCTNSNotificationExpectation(name: Settings.changedNotification)
    settings.iconSize = 100
    wait(for: [expectation], timeout: 1.0)
  }

  func testNotificationPostedOnLanguageChange() {
    let expectation = XCTNSNotificationExpectation(name: Settings.changedNotification)
    settings.language = "en"
    wait(for: [expectation], timeout: 1.0)
  }
}
