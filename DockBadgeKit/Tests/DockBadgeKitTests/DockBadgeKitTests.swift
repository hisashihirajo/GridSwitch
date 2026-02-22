import Testing
@testable import DockBadgeKit

@Test func testGetAllBadgesReturnsEmptyInitially() {
  let kit = DockBadgeKit.shared
  let badges = kit.getAllBadges()
  #expect(badges.isEmpty)
}

@Test func testGetBadgesReturnsEmptyForNoCache() {
  let kit = DockBadgeKit.shared
  let app = DockBadgeApp(name: "TestApp", pid: 999, bundleIdentifier: nil)
  let result = kit.getBadges(for: [app])
  #expect(result.isEmpty)
}
