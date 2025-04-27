import Combine
import Foundation

/// A marker protocol for types that represent notifications with associated data. Conforming types gain a default notification name and
/// user info key. They can be used with extension methods like ``NotificationCenter.notifications(for:)`` and
/// ``NotificationCenter.publisher(for:)`` which automatically extract and cast this type from user info.
///
/// When posting better notifications you can use ``Notification.better(:object:)`` to build up a notification with the correct
/// user info automatically.
public protocol BetterNotification {}

public extension BetterNotification {
    /// The notification name associated with the conforming type.
    ///
    /// Uses the type's name to create a unique raw value in the format:
    /// `"BetterNotification:{SelfType}"`.
    static var notificationName: Notification.Name {
        Notification.Name(rawValue: "BetterNotification:\(Self.self)")
    }

    /// The key used in the notification's `userInfo` dictionary to store the notification value.
    ///
    /// Matches the raw value of `notificationName`.
    static var userInfoKey: String { notificationName.rawValue }
}

// MARK: -

public extension Notification {
    /// Creates a `Notification` instance for the given `BetterNotification` value.
    ///
    /// - Parameters:
    ///   - betterNotification: The `BetterNotification` value to send.
    ///   - object: An optional sender object.
    /// - Returns: A configured `Notification` with `name`, `object`, and `userInfo`.
    static func better<BN: BetterNotification>(
        _ betterNotification: BN,
        object: Any? = nil
    ) -> Notification {
        Notification(
            name: BN.notificationName,
            object: object,
            userInfo: [BN.userInfoKey: betterNotification]
        )
    }

    /// Extracts a `BetterNotification` value of the specified type from this `Notification`'s `userInfo`.
    ///
    /// - Returns: The extracted `BetterNotification` value when found, otherwise `nil`.
    func better<BN: BetterNotification>() -> BN? {
        guard let object = userInfo?[BN.userInfoKey] else {
            NSLog("[\(BN.self)] Object missing from userInfo[\"\(BN.userInfoKey)\"]")
            return nil
        }
        guard let betterNotification = object as? BN else {
            NSLog("[\(BN.self)] Failed to cast \(object) to \(BN.self)")
            return nil
        }

        return betterNotification
    }
}

// MARK: -

public extension NotificationCenter {
    /// Returns an `AsyncSequence` of notifications of a specific `BetterNotification` type.
    ///
    /// Each element of the sequence is a `BetterNotification` value.
    ///
    /// - Parameter betterType: The `BetterNotification` type to observe..
    /// - Returns: An `AsyncSequence` of `BetterNotification` values.
    func notifications<BN: BetterNotification>(
        for betterType: BN.Type
    ) -> any AsyncSequence<BN, Never> {
        notifications(named: BN.notificationName)
            .compactMap { $0.better() }
    }

    /// Returns a Combine publisher that emits `BetterNotification` values of the given type.
    ///
    /// - Parameter betterType: The `BetterNotification` type to observe.
    /// - Returns: A publisher emitting `BetterNotification` values.
    func publisher<BN: BetterNotification>(
        for betterType: BN.Type
    ) -> AnyPublisher<BN, Never> {
        publisher(for: betterType.notificationName)
            .compactMap { $0.better() }
            .eraseToAnyPublisher()
    }
}
