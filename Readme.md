# NotificationSmuggler

[![0 dependencies!](https://0dependencies.dev/0dependencies.svg)](https://0dependencies.dev)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsamsonjs%2FNotificationSmuggler%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/samsonjs/NotificationSmuggler)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsamsonjs%2FNotificationSmuggler%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/samsonjs/NotificationSmuggler)

## Overview

NotificationSmuggler is a tiny Swift package that makes it easy to embed strongly-typed values in `Notification`s, and extract them out on the receiving end as well. Nothing elaborate, it sneaks the contraband in the `userInfo` dictionary.

Declare a type conforming to `Smuggled` and then use the static method `Notification.smuggle(_:object:)` when posting the notification. On the receiving side of things you can use the extension methods `NotificationCenter.notifications(for:)` and `NotificationCenter.publisher(for:)` to observe the strongly-typed values without manually mapping them yourself.

If you have `Sendable` contraband then all of this will work nicely with Swift 6 and complete concurrency checking.

This package pairs nicely with [AsyncMonitor](https://github.com/samsonjs/AsyncMonitor) for a complete notification handling system in the Swift 6 concurrency world.

## Usage

### Define a smuggled payload

```swift
struct SomeNotification: Smuggled, Sendable {
    let answer: Int
}
```

Your payload doesn't have to be Sendable but if it is then you have more flexibility.

The `Smuggled` protocol provides static `notificationName` and `userInfoKey` properties for you, should you need them. Generally you don't though.

### Post a notification

```swift
NotificationCenter.default.post(.smuggle(SomeNotification(answer: 42)))
```

This automatically sets the `.name`, `userInfo`, and optionally `.object` for the notification.

### Observe and extract contraband

```swift
Task {
    // This is fine because SomeNotification is Sendable
    for await notification in NotificationCenter.default.notifications(for: SomeNotification.self) {
        print(notification.answer)
    }
}
```

## Installation

The only way to install this package is with Swift Package Manager (SPM). Please [file a new issue][] or submit a pull-request if you want to use something else.

[file a new issue]: https://github.com/samsonjs/NotificationSmuggler/issues/new

### Supported Platforms

This package is supported on iOS 16.0+ and macOS 12.0+.

### Xcode

When you're integrating this into an app with Xcode then go to your project's Package Dependencies and enter the URL `https://github.com/samsonjs/NotificationSmuggler` and then go through the usual flow for adding packages.

### Swift Package Manager (SPM)

When you're integrating this using SPM on its own then add this to the list of dependencies your Package.swift file:

```swift
.package(url: "https://github.com/samsonjs/NotificationSmuggler.git", .upToNextMajor(from: "0.1.1"))
```

and then add `"NotificationSmuggler"` to the list of dependencies in your target as well.

## License

Copyright © 2025 [Sami Samhuri](https://samhuri.net) <sami@samhuri.net>. Released under the terms of the [MIT License][MIT].

[MIT]: https://sjs.mit-license.org
