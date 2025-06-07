import Foundation

/// A marker protocol for types that represent notifications with associated data.
///
/// Conforming types automatically gain a default notification name and user-info key to facilitate
/// type-safe notification handling. The protocol enables strongly-typed notification posting and
/// observation without manual `userInfo` dictionary manipulation.
///
/// ## Basic Usage
///
/// Define a notification type:
///
/// ```swift
/// struct AccountAuthenticatedNotification: Smuggled, Sendable {
///     let accountID: String
///     let timestamp: Date
/// }
/// ```
///
/// Post the notification:
///
/// ```swift
/// NotificationCenter.default.smuggle(AccountAuthenticatedNotification(
///     accountID: "abc123", 
///     timestamp: .now
/// ))
/// ```
///
/// Observe notifications:
///
/// ```swift
/// for await authentication in NotificationCenter.default.notifications(for: AccountAuthenticatedNotification.self) {
///     print("Account \(authentication.accountID) authenticated")
/// }
/// ```
///
/// ## Sendable Considerations
///
/// For Swift 6 concurrency, consider making your notification types `Sendable` when they might 
/// cross actor boundaries. Value types with `Sendable` properties are automatically `Sendable`.
///
/// ## Available Methods
///
/// - ``NotificationCenter.smuggle(_:object:)`` - Post notification directly
/// - ``Notification.smuggle(_:object:)`` - Create notification instance
/// - ``NotificationCenter.notifications(for:object:)`` - Async observation
/// - ``NotificationCenter.publisher(for:object:)`` - Combine observation
/// - ``Notification.smuggled()`` - Manual extraction
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
