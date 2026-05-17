# Releasing NotificationSmuggler

There's no schedule here. Ship bug fixes whenever, features when they're ready, and breaking changes as rarely as you can stand.

NotificationSmuggler is a Swift package and a release is just a git tag. SwiftPM resolves versions directly from tags.

## Before You Cut a Release

Run the tests and make sure they pass.

```shell
swift test
```

Check that you're on `main` with a clean working tree, and that nothing looks weird in the recent history.

```shell
git status
git log -5 --oneline
```

## Update the Changelog

Find the `[Unreleased]` section in [Changelog.md](./Changelog.md), rename it to the new version, and stamp it with today's date.

```markdown
## [0.3.0] - 2026-05-17

[Compare with 0.2.1](https://github.com/samsonjs/NotificationSmuggler/compare/0.2.1...0.3.0)

### Changed
- Description of changes

### Fixed
- Description of fixes

### Added
- Description of additions
```

Drop the "Your change here." placeholder, and drop any of the Changed/Fixed/Added sections that don't actually have anything in them.

Commit and push.

```shell
git add Changelog.md
git commit -m "Prepare for release 0.3.0"
git push origin main
```

## Tag and Release on GitHub

Tag it, push the tag, and cut the release. GitHub will generate notes from merged PRs and commits since the last tag:

```shell
git tag 0.3.0
git push origin 0.3.0
gh release create 0.3.0 --verify-tag --generate-notes
```

If you'd rather use your changelog entry as the release body, this pulls just that section out:

```shell
gh release create 0.3.0 --verify-tag --notes "$(awk '/^## \[0\.3\.0\]/,/^## \[/' Changelog.md | sed '$d')"
```

## Start the Next Version

Drop a fresh `[Unreleased]` section at the top of [Changelog.md](./Changelog.md) so there's somewhere to write down the next round of changes.

```markdown
## [Unreleased]

- Your change here.

[Unreleased]: https://github.com/samsonjs/NotificationSmuggler/compare/0.3.0...HEAD
```

Commit and push and you're done.

```shell
git add Changelog.md
git commit -m "Start next changelog entry"
git push origin main
```
