# Changelog

## [Unreleased]

- Your change here.

[Unreleased]: https://github.com/samsonjs/NotificationSmuggler/compare/0.2.1...HEAD

## [0.2.1] - 2025-06-06

[Compare with 0.2.0](https://github.com/samsonjs/NotificationSmuggler/compare/0.2.0...0.2.1)

### Added
- Support for optional object parameter in notification posting
- Comprehensive DocC documentation with examples and best practices
- Enhanced API documentation with usage examples

### Changed
- Improved documentation throughout the codebase
- Enhanced test coverage for new functionality

## [0.2.0] - 2025-06-06

[Compare with 0.1.2](https://github.com/samsonjs/NotificationSmuggler/compare/0.1.2...0.2.0)

### Added
- [#1](https://github.com/samsonjs/NotificationSmuggler/pull/1): `NotificationCenter.smuggle` extension method for improved ergonomics - [@samsonjs](https://github.com/samsonjs).
- Better API for posting notifications directly from NotificationCenter

### Changed
- Improved logging using `os.log` instead of `NSLog`
- Enhanced overall package documentation

## [0.1.2] - 2025-04-29

[Compare with 0.1.1](https://github.com/samsonjs/NotificationSmuggler/compare/0.1.1...0.1.2)

### Changed
- Updated documentation and version references

## [0.1.1] - 2025-04-29

[Compare with 0.1.0](https://github.com/samsonjs/NotificationSmuggler/compare/0.1.0...0.1.1)

### Changed
- Fixed deployment targets for iOS 18.0+ and macOS 15.0+
- Updated README with comprehensive usage examples and documentation

## [0.1.0] - 2025-04-29

### Added
- Initial release of NotificationSmuggler
- `Smuggled` protocol for type-safe notification handling
- `Notification` and `NotificationCenter` extensions for smuggling notifications
- Support for async/await and Combine notification observation
- Swift 6 concurrency support with `Sendable` conformance
- Comprehensive test suite using Swift Testing framework
- iOS 18.0+ and macOS 15.0+ platform support
