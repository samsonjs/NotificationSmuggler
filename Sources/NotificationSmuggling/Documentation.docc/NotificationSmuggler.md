# NotificationSmuggler

A Swift 6 package for type-safe notification handling with strongly-typed values with strict concurrency, using async/await or Combine publishers.

Never touch a `userInfo` dictionary again for your own notifications.

## Overview

NotificationSmuggler makes it easy to embed strongly-typed values in `Notification`s and extract them on the receiving end. It "smuggles" your contraband payload through the `userInfo` dictionary while providing a clean, type-safe API.

Each conforming type gets its own unique notification name and userInfo key, automatically generated from the type name. There are convenience methods for posting and observing your contraband. Structs are recommended because you may want these to be `Sendable`, and inheritance isn't supported so hierarchies may pose pitfalls if you try to get fancy.

## Getting Started

### Define your contraband

Create a type that conforms to the ``Smuggled`` protocol:

```swift
struct AccountAuthenticated: Smuggled, Sendable {
    let accountID: String
    let timestamp: Date
}
```

### Post Notifications

Use the convenience method to post directly:

```swift
NotificationCenter.default.smuggle(AccountAuthenticatedNotification(
    accountID: "abc123", 
    timestamp: .now
))
```

Or create a notification first if that's more convenient:

```swift
let notification = Notification.smuggle(AccountAuthenticatedNotification(
    accountID: "abc123", 
    timestamp: .now
))
NotificationCenter.default.post(notification)
```

### Observe Notifications

With async/await (recommended for Sendable types):

```swift
Task {
    for await authenticated in NotificationCenter.default.notifications(for: AccountAuthenticatedNotification.self) {
        print("Account \(authenticated.accountID) authenticated at \(authenticated.timestamp)")
    }
}
```

With Combine:

```swift
NotificationCenter.default.publisher(for: AccountAuthenticatedNotification.self)
    .sink { authenticated in
        print("Account \(authenticated.accountID) authenticated")
    }
    .store(in: &cancellables)
```

### Object-Specific Observation

Filter notifications by sender object:

```swift
let document = AwesomeDocument()

// Only receive notifications from this specific document
for await saved in NotificationCenter.default.notifications(for: DocumentSavedNotification.self, object: document) {
    print("Document saved: \(saved.filename)")
}
```

## Topics

### Essential Types

- ``Smuggled``

### Notification Creation

- ``Foundation/Notification/smuggle(_:object:)``
- ``Foundation/NotificationCenter/smuggle(_:object:)``

### Notification Observation

- ``Foundation/NotificationCenter/notifications(for:object:)``
- ``Foundation/NotificationCenter/publisher(for:object:)``

### Extracting Values

- ``Foundation/Notification/smuggled()``
