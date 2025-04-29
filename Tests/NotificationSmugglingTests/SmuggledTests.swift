import Foundation
@testable import NotificationSmuggler
import Testing

struct SmuggledTests {
    @Test func notificationName() {
        #expect(HitchhikersNotification.notificationName.rawValue == "NotificationSmuggler:HitchhikersNotification")
    }

    @Test func userInfoKey() {
        #expect(HitchhikersNotification.userInfoKey == "NotificationSmuggler:HitchhikersNotification")
    }
}
