import Foundation

/// A marker protocol for types that represent notifications with associated data. Conforming types gain a default notification name and
/// user info key to facilitate smuggling. They can be used with extension methods like
/// ``NotificationCenter.notifications(for:)`` and ``NotificationCenter.publisher(for:)`` which
/// automatically extract and cast this type from user info.
///
/// If you want to extract the contraband manually you can use the extension method ``Notification.smuggled()``.
///
/// When smuggling notifications you can use ``Notification.smuggle(:object:)`` to build up a notification with the correct
/// user info automatically.
public protocol Smuggled {}

public extension Smuggled {
    /// The notification name associated with the conforming type.
    ///
    /// Uses the type's name to create a unique raw value in the format:
    /// `"NotificationSmuggler:{SelfType}"`.
    static var notificationName: Notification.Name {
        Notification.Name(rawValue: "NotificationSmuggler:\(Self.self)")
    }

    /// The key used in the notification's `userInfo` dictionary to store the notification value.
    ///
    /// Matches the raw value of `notificationName`.
    static var userInfoKey: String { notificationName.rawValue }
}
