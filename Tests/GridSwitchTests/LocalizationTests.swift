import XCTest
@testable import GridSwitch

final class LocalizationTests: XCTestCase {
  private var originalLanguage: String!

  override func setUp() {
    super.setUp()
    originalLanguage = Settings.shared.language
  }

  override func tearDown() {
    Settings.shared.language = originalLanguage
    super.tearDown()
  }

  // MARK: - Language enum

  func testAllCasesHasBothLanguages() {
    XCTAssertEqual(Language.allCases.count, 2)
    XCTAssertTrue(Language.allCases.contains(.ja))
    XCTAssertTrue(Language.allCases.contains(.en))
  }

  func testRawValues() {
    XCTAssertEqual(Language.ja.rawValue, "ja")
    XCTAssertEqual(Language.en.rawValue, "en")
  }

  func testDisplayName() {
    XCTAssertEqual(Language.ja.displayName, "日本語")
    XCTAssertEqual(Language.en.displayName, "English")
  }

  func testInitFromRawValue() {
    XCTAssertEqual(Language(rawValue: "ja"), .ja)
    XCTAssertEqual(Language(rawValue: "en"), .en)
    XCTAssertNil(Language(rawValue: "fr"))
  }

  // MARK: - L10n.current

  func testCurrentFollowsSettings() {
    Settings.shared.language = "ja"
    XCTAssertEqual(L10n.current, .ja)

    Settings.shared.language = "en"
    XCTAssertEqual(L10n.current, .en)
  }

  func testCurrentFallsBackToJaForInvalidLanguage() {
    Settings.shared.language = "fr"
    XCTAssertEqual(L10n.current, .ja)
  }

  // MARK: - 全 L10n プロパティが両言語で空でない

  func testAllStringsAreNonEmptyInJa() {
    Settings.shared.language = "ja"
    assertAllL10nStringsNonEmpty(label: "ja")
  }

  func testAllStringsAreNonEmptyInEn() {
    Settings.shared.language = "en"
    assertAllL10nStringsNonEmpty(label: "en")
  }

  // MARK: - 日英で文字列が異なる（同じ翻訳キーの両言語ハードコード抜けを検出）

  func testJaAndEnDifferForKeyStrings() {
    Settings.shared.language = "ja"
    let ja = collectAllStrings()

    Settings.shared.language = "en"
    let en = collectAllStrings()

    // 全項目が日英完全一致だと、ハードコードが片方しかされていない可能性
    // ただし "GridSwitch" 等の固有名詞が含まれる可能性もあるため、
    // 過半数が異なれば良しとする
    var diffCount = 0
    for (key, jaValue) in ja {
      if jaValue != en[key] {
        diffCount += 1
      }
    }
    XCTAssertGreaterThan(diffCount, ja.count / 2, "日英で文字列が異なる項目が過半数あること")
  }

  // MARK: - updateMessage formatter

  func testUpdateMessageContainsVersionJa() {
    Settings.shared.language = "ja"
    let msg = L10n.updateMessage(newVersion: "1.5")
    XCTAssertTrue(msg.contains("1.5"))
    XCTAssertTrue(msg.contains("利用可能"))
  }

  func testUpdateMessageContainsVersionEn() {
    Settings.shared.language = "en"
    let msg = L10n.updateMessage(newVersion: "1.5")
    XCTAssertTrue(msg.contains("1.5"))
    XCTAssertTrue(msg.contains("available"))
  }

  // MARK: - ヘルパー

  /// 全L10nプロパティのスナップショット（テスト時の言語に依存）
  private func collectAllStrings() -> [String: String] {
    return [
      "settings": L10n.settings,
      "iconSize": L10n.iconSize,
      "maxColumns": L10n.maxColumns,
      "backgroundColor": L10n.backgroundColor,
      "backgroundOpacity": L10n.backgroundOpacity,
      "backgroundImage": L10n.backgroundImage,
      "imageOpacity": L10n.imageOpacity,
      "selectImage": L10n.selectImage,
      "clearImage": L10n.clearImage,
      "selectImageTitle": L10n.selectImageTitle,
      "noImage": L10n.noImage,
      "numberShortcuts": L10n.numberShortcuts,
      "launchAtLogin": L10n.launchAtLogin,
      "language": L10n.language,
      "hiddenApps": L10n.hiddenApps,
      "hiddenAppsDescription": L10n.hiddenAppsDescription,
      "editHiddenApps": L10n.editHiddenApps,
      "hiddenAppsWindowTitle": L10n.hiddenAppsWindowTitle,
      "noHiddenApps": L10n.noHiddenApps,
      "about": L10n.about,
      "settingsMenu": L10n.settingsMenu,
      "quit": L10n.quit,
      "aboutDescription": L10n.aboutDescription,
      "checkForUpdates": L10n.checkForUpdates,
      "updateAvailable": L10n.updateAvailable,
      "updateNow": L10n.updateNow,
      "updateLater": L10n.updateLater,
      "noUpdateAvailable": L10n.noUpdateAvailable,
      "downloading": L10n.downloading,
      "updateFailed": L10n.updateFailed,
      "accessibilityRequired": L10n.accessibilityRequired,
      "accessibilityMessage": L10n.accessibilityMessage,
    ]
  }

  private func assertAllL10nStringsNonEmpty(label: String) {
    for (key, value) in collectAllStrings() {
      XCTAssertFalse(value.isEmpty, "\(label) の L10n.\(key) が空文字列")
    }
  }
}
