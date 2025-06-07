import Combine
import Foundation
@testable import NotificationSmuggler
import Testing

struct SmugglingTests {

    // MARK: Notification extensions

    @Test func buildNotification() {
        let contraband = HitchhikersNotification(answer: 42)
        let notification = Notification.smuggle(contraband)
        #expect(notification.name == HitchhikersNotification.notificationName)
        #expect(notification.userInfo?.count == 1)
        let key = HitchhikersNotification.userInfoKey
        let userInfoValue = notification.userInfo?[key] as? HitchhikersNotification
        #expect(userInfoValue == contraband)
    }

    @Test func extractContraband() {
        let contraband = HitchhikersNotification(answer: 42)
        let notification = Notification.smuggle(contraband)
        let extracted: HitchhikersNotification? = notification.smuggled()
        #expect(extracted == contraband)
    }

    @Test func extractContrabandFailsOnWrongType() {
        let imposter = Notification(
            name: HitchhikersNotification.notificationName,
            object: nil,
            userInfo: [HitchhikersNotification.userInfoKey: "imposter"]
        )
        let extracted: HitchhikersNotification? = imposter.smuggled()
        #expect(extracted == nil)
    }

    @Test func extractContrabandFailsOnMissingPayload() {
        let incompleteNotification = Notification(name: HitchhikersNotification.notificationName)
        let extracted: HitchhikersNotification? = incompleteNotification.smuggled()
        #expect(extracted == nil)
    }

    // MARK: NotificationCenter extensions

    @Test(.timeLimit(.minutes(1)))
    @MainActor func notificationCenterSmuggle() async {
        let center = NotificationCenter()
        let task = Task {
            for await contraband in center.notifications(for: HitchhikersNotification.self) {
                #expect(contraband.answer == 42)
                return
            }
        }
        await Task.yield()

        let contraband = HitchhikersNotification(answer: 42)
        center.smuggle(contraband)
        await task.value
    }

    // It's important that the tests and the notification-observing tasks are not on the same actor,
    // so we make the tests @MainActor and observe notifications on another actor. Otherwise it's
    // a deadlock.

    @Test(.timeLimit(.minutes(1)))
    @MainActor func notificationCenterAsyncSequence() async throws {
        let center = NotificationCenter()
        nonisolated(unsafe) var received = false
        Task {
            for await contraband in center.notifications(for: HitchhikersNotification.self) {
                #expect(contraband.answer == 42)
                received = true
                break
            }
        }
        await Task.yield()

        let contraband = HitchhikersNotification(answer: 42)
        center.smuggle(contraband)
        while !received { await Task.yield() }
    }

    @Test(.timeLimit(.minutes(1)))
    @MainActor func notificationCenterAsyncSequenceIgnoresInvalidPayloads() async throws {
        let center = NotificationCenter()
        nonisolated(unsafe) var received = false
        let task = Task {
            for await _ in center.notifications(for: HitchhikersNotification.self) {
                received = true
            }
        }
        defer { task.cancel() }
        await Task.yield()

        // Post an invalid one that should be ignored.
        let imposter = Notification(
            name: HitchhikersNotification.notificationName,
            object: nil,
            userInfo: [HitchhikersNotification.userInfoKey: "imposter"]
        )
        center.post(imposter)

        try await Task.sleep(for: .milliseconds(10))
        #expect(!received)
    }

    @Test(.timeLimit(.minutes(1)))
    @MainActor func notificationCenterPublisher() async {
        var cancellables = Set<AnyCancellable>()
        let center = NotificationCenter()
        nonisolated(unsafe) var received = false
        center.publisher(for: HitchhikersNotification.self)
            .sink { hitchhikers in
                #expect(hitchhikers.answer == 42)
                received = true
            }.store(in: &cancellables)
        await Task.yield()

        let contraband = HitchhikersNotification(answer: 42)
        center.smuggle(contraband)
        while !received { await Task.yield() }
    }

    @Test(.timeLimit(.minutes(1)))
    @MainActor func notificationCenterPublisherIgnoresInvalidPayloads() async throws {
        var cancellables = Set<AnyCancellable>()
        let center = NotificationCenter()
        nonisolated(unsafe) var received = false
        center.publisher(for: HitchhikersNotification.self)
            .sink { contraband in
                #expect(contraband.answer == 42)
                received = true
            }.store(in: &cancellables)
        await Task.yield()

        // Post an invalid one that should be ignored.
        let imposter = Notification(
            name: HitchhikersNotification.notificationName,
            object: nil,
            userInfo: [HitchhikersNotification.userInfoKey: "imposter"]
        )
        center.post(imposter)

        try await Task.sleep(for: .milliseconds(10))
        #expect(!received)
    }

    // MARK: Object-specific notifications

    final class SenderObject: NSObject, Sendable {}

    @Test(.timeLimit(.minutes(1)))
    @MainActor func notificationCenterAsyncSequenceWithObject() async throws {
        let center = NotificationCenter()
        let senderObject = SenderObject()
        let decoyObject = NSObject()
        
        let task = Task {
            for await contraband in center.notifications(for: HitchhikersNotification.self, object: senderObject) {
                #expect(contraband.answer == 42)
                return
            }
        }
        await Task.yield()

        // Post from decay object, should be ignored
        center.post(.smuggle(HitchhikersNotification(answer: 99), object: decoyObject))
        try await Task.sleep(for: .milliseconds(10))

        // Post from sender object, should be received
        center.post(.smuggle(HitchhikersNotification(answer: 42), object: senderObject))
        await task.value
    }

    @Test(.timeLimit(.minutes(1)))
    @MainActor func notificationCenterPublisherWithObject() async throws {
        var cancellables = Set<AnyCancellable>()
        let center = NotificationCenter()
        let senderObject = SenderObject()
        let decoyObject = NSObject()
        nonisolated(unsafe) var received = false
        
        center.publisher(for: HitchhikersNotification.self, object: senderObject)
            .sink { contraband in
                #expect(contraband.answer == 42)
                received = true
            }.store(in: &cancellables)
        await Task.yield()

        // Post from decoy object, should be ignored
        center.post(.smuggle(HitchhikersNotification(answer: 99), object: decoyObject))
        try await Task.sleep(for: .milliseconds(10))
        #expect(!received)

        // Post from sender object, should be received
        center.post(.smuggle(HitchhikersNotification(answer: 42), object: senderObject))
        while !received { await Task.yield() }
    }
}
