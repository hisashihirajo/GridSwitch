import XCTest
@testable import GridSwitch

final class AppSwitcherManagerTests: XCTestCase {
  // MARK: - indexForNumberKey

  func testNumberKey1MapsToIndex0() {
    XCTAssertEqual(AppSwitcherManager.indexForNumberKey(1), 0)
  }

  func testNumberKey9MapsToIndex8() {
    XCTAssertEqual(AppSwitcherManager.indexForNumberKey(9), 8)
  }

  func testNumberKey0MapsToIndex9() {
    XCTAssertEqual(AppSwitcherManager.indexForNumberKey(0), 9)
  }

  func testAllDigitsMapToExpectedIndices() {
    let expected = [
      0: 9, 1: 0, 2: 1, 3: 2, 4: 3,
      5: 4, 6: 5, 7: 6, 8: 7, 9: 8,
    ]
    for (input, want) in expected {
      XCTAssertEqual(AppSwitcherManager.indexForNumberKey(input), want, "input=\(input)")
    }
  }

  // MARK: - movedToFront

  func testMovedToFrontInsertsNewKey() {
    let result = AppSwitcherManager.movedToFront(mruKey: "a", in: [])
    XCTAssertEqual(result, ["a"])
  }

  func testMovedToFrontMovesExistingKey() {
    let result = AppSwitcherManager.movedToFront(mruKey: "b", in: ["a", "b", "c"])
    XCTAssertEqual(result, ["b", "a", "c"])
  }

  func testMovedToFrontKeepsOrderIfAlreadyFirst() {
    let result = AppSwitcherManager.movedToFront(mruKey: "a", in: ["a", "b", "c"])
    XCTAssertEqual(result, ["a", "b", "c"])
  }

  func testMovedToFrontDeduplicates() {
    // 重複登録を許さない（古いリスト全体で同じキーは1回のみ）
    let result = AppSwitcherManager.movedToFront(mruKey: "a", in: ["a", "b", "a", "c"])
    XCTAssertEqual(result, ["a", "b", "c"])
  }

  func testMovedToFrontPreservesOtherOrder() {
    let result = AppSwitcherManager.movedToFront(mruKey: "d", in: ["a", "b", "c"])
    XCTAssertEqual(result, ["d", "a", "b", "c"])
  }
}
