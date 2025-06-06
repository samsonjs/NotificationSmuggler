import Combine
import Foundation
import os.log

private let log = Logger(subsystem: "NotificationSmuggler", category: "smuggling")

public extension Notification {
    /// Creates a `Notification` instance that smuggles the given `Smuggled` value.
    ///
    /// - Parameters:
    ///   - contraband: The `Smuggled` value to send.
    ///   - object: An optional sender object.
    /// - Returns: A configured `Notification` with `name`, `object`, and `userInfo`.
    static func smuggle<Contraband: Smuggled>(
        _ contraband: Contraband,
        object: Any? = nil
    ) -> Notification {
        Notification(
            name: Contraband.notificationName,
            object: object,
            userInfo: [Contraband.userInfoKey: contraband]
        )
    }

    /// Extracts a `Smuggled` value (contraband) of the specified type from this `Notification`'s `userInfo`.
    ///
    /// - Returns: The extracted `Smuggled` value when found, otherwise `nil`.
    func smuggled<Contraband: Smuggled>() -> Contraband? {
        guard let instance = userInfo?[Contraband.userInfoKey] else {
            log.error("Value not found in userInfo[\"\(Contraband.userInfoKey)\"] for \(Contraband.notificationName.rawValue)")
            return nil
        }
        guard let contraband = instance as? Contraband else {
            log.error("Failed to cast \(String(describing: instance)) as \(Contraband.notificationName.rawValue)")
            return nil
        }

        return contraband
    }
}

// MARK: -

public extension NotificationCenter {
    /// Posts a notification that smuggles the given `Smuggled` value.
    ///
    /// - Parameter contraband: The `Smuggled` value to send.
    func smuggle<Contraband: Smuggled>(_ contraband: Contraband) {
        post(.smuggle(contraband))
    }

    /// Returns an `AsyncSequence` of notifications of a specific `Smuggled` type.
    ///
    /// Each element of the sequence is a `Smuggled` value.
    ///
    /// - Parameter contrabandType: The `Smuggled` type to observe..
    /// - Returns: An `AsyncSequence` of `NotificationSmuggler` values.
    func notifications<Contraband: Smuggled>(
        for contrabandType: Contraband.Type
    ) -> any AsyncSequence<Contraband, Never> {
        notifications(named: Contraband.notificationName)
            .compactMap { $0.smuggled() }
    }

    /// Returns a Combine publisher that emits `Smuggled` values of the given type.
    ///
    /// - Parameter contrabandType: The `Smuggled` type to observe.
    /// - Returns: A publisher emitting `Smuggled` values.
    func publisher<Contraband: Smuggled>(
        for contrabandType: Contraband.Type
    ) -> AnyPublisher<Contraband, Never> {
        publisher(for: contrabandType.notificationName)
            .compactMap { $0.smuggled() }
            .eraseToAnyPublisher()
    }
}
