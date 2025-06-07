import Combine
import Foundation
import os.log

private let log = Logger(subsystem: "NotificationSmuggler", category: "smuggling")

public extension Notification {
    /// Creates a `Notification` instance that smuggles the given `Smuggled` value.
    ///
    /// This method automatically configures the notification's `name` using the type's 
    /// ``Smuggled/notificationName`` and embeds the value in `userInfo` using the type's
    /// ``Smuggled/userInfoKey``.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct CoolEvent: Smuggled {
    ///     let message: String
    /// }
    ///
    /// let notification = Notification.smuggle(CoolEvent(message: "Hello"))
    /// NotificationCenter.default.post(notification)
    /// ```
    ///
    /// - Parameters:
    ///   - contraband: The `Smuggled` value to embed in the notification.
    ///   - object: An optional sender object to associate with the notification.
    /// - Returns: A configured `Notification` with `name`, `object`, and `userInfo`.
    ///
    /// ## See Also
    ///
    /// - ``NotificationCenter.smuggle(_:object:)``
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
    /// This method performs type-safe extraction by looking for the value using the type's
    /// ``Smuggled/userInfoKey`` and attempting to cast it to the expected type.
    ///
    /// ## Example
    ///
    /// ```swift
    /// func handleNotification(_ notification: Notification) {
    ///     if let event: MyEvent = notification.smuggled() {
    ///         print("Received: \(event.message)")
    ///     }
    /// }
    /// ```
    ///
    /// ## Error Handling
    ///
    /// - Missing values and type-casting failures are logged at `error` level since that means you tried something fancy and messed it up. No offence, them's the facts.
    ///
    /// - Returns: The extracted `Smuggled` value when found and properly typed, otherwise `nil`.
    ///
    /// ## See Also
    ///
    /// - ``NotificationCenter.notifications(for:object:)``
    /// - ``NotificationCenter.publisher(for:object:)``
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
    /// This is a convenience method that combines ``Notification.smuggle(_:object:)``
    /// and `post(_:)` into a single operation.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct AccountAuthenticated: Smuggled {
    ///     let accountID: String
    /// }
    ///
    /// // Instead of:
    /// // NotificationCenter.default.post(.smuggle(AccountAuthenticated(accountID: "abc123")))
    ///
    /// // You can write:
    /// NotificationCenter.default.smuggle(AccountAuthenticated(accountID: "abc123"))
    /// ```
    ///
    /// - Parameters:
    ///   - contraband: The `Smuggled` value to send.
    ///   - object: An optional sender object to associate with the notification.
    ///
    /// ## See Also
    ///
    /// - ``Notification.smuggle(_:object:)``
    func smuggle<Contraband: Smuggled>(_ contraband: Contraband, object: Any? = nil) {
        post(.smuggle(contraband, object: object))
    }

    /// Returns an `AsyncSequence` of notifications of a specific `Smuggled` type.
    ///
    /// This method provides async/await-compatible observation of notifications. It automatically
    /// filters for the specified type and extracts the values from `userInfo`, yielding only
    /// successfully extracted values.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct NetworkStatusChanged: Smuggled, Sendable {
    ///     let isOnline: Bool
    /// }
    ///
    /// Task {
    ///     for await status in NotificationCenter.default.notifications(for: NetworkStatusChanged.self) {
    ///         print("Network is \(status.isOnline ? "online" : "offline")")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter contrabandType: The `Smuggled` type to observe.
    /// - Returns: An `AsyncSequence` that yields extracted notification values.
    ///
    /// ## See Also
    ///
    /// - ``publisher(for:object:)``
    func notifications<Contraband: Smuggled>(
        for contrabandType: Contraband.Type,
        object: (AnyObject & Sendable)? = nil
    ) -> any AsyncSequence<Contraband, Never> {
        notifications(named: Contraband.notificationName, object: object)
            .compactMap { $0.smuggled() }
    }

    /// Returns a Combine publisher that emits `Smuggled` values of the given type.
    ///
    /// This method provides Combine-compatible observation of notifications from a specific sender.
    /// It automatically filters for the specified type and object, extracting values from `userInfo`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct DocumentSavedNotification: Smuggled {
    ///     let filename: String
    /// }
    ///
    /// let document = AwesomeDocument()
    /// var cancellables = Set<AnyCancellable>()
    ///
    /// NotificationCenter.default.publisher(for: DocumentSavedNotification.self, object: document)
    ///     .sink { saved in
    ///         print("Document \(saved.filename) was saved")
    ///     }
    ///     .store(in: &cancellables)
    /// ```
    ///
    /// - Parameters:
    ///   - contrabandType: The `Smuggled` type to observe.
    ///   - object: The optional object whose notifications you want to receive. Must be a class instance.
    /// - Returns: A publisher emitting `Smuggled` values.
    ///
    /// ## See Also
    ///
    /// - ``notifications(for:object:)``
    func publisher<Contraband: Smuggled>(
        for contrabandType: Contraband.Type,
        object: AnyObject? = nil
    ) -> AnyPublisher<Contraband, Never> {
        publisher(for: contrabandType.notificationName, object: object)
            .compactMap { $0.smuggled() }
            .eraseToAnyPublisher()
    }
}
