# Changelog

All notable changes to Wopener are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-06-28

### Changed
- Releases are now Developer ID-signed, notarized, and stapled — no more
  Gatekeeper "unidentified developer" warning on first launch.
- App ships unsandboxed (Developer ID distribution), ensuring reliable link
  interception and per-profile Chromium launches.

### Added
- Automated notarized-release pipeline (signed archive → notarize → DMG →
  GitHub release) and dormant Homebrew-cask bump workflow.
- Animated "built with kimchi" chip and Product Hunt badge in the website footer.
- Architecture docs (`docs/architecture.md`), changelog, and expanded README.

## [1.0.0] - 2026-06-18

First stable release.

### Added
- Liquid Glass browser picker shown on every intercepted `http`/`https` link.
- Browser discovery via `NSWorkspace`, A→Z sort, custom drag-reorder, and
  per-browser enable toggles (Browsers pane).
- Per-profile launch for Chromium-family browsers, with signed-in account
  photo/monogram badges.
- "Save for later": stash a link instead of opening; reopen from the Saved pane.
- Keyboard control in the picker: `1`–`9` open, `←`/`→` select, `↩` open
  selected, `Esc` cancel, rebindable save key (default `` ` ``).
- General pane preferences: number hints, URL chip position, picker location.
- Menu-bar status item entry point; background agent (`LSUIElement`) with no
  Dock icon.
- Open-at-login via `SMAppService`, toggleable in the General pane.
- Set-as-default-browser flow and status in the Browsers pane.
- Download tracking on the website via thank-you page + analytics beacon.

## [0.1.0] - 2026-06-16

Initial release.

[1.1.0]: https://github.com/xkaper001/wopener/releases/tag/v1.1.0
[1.0.0]: https://github.com/xkaper001/wopener/releases/tag/v1.0.0
[0.1.0]: https://github.com/xkaper001/wopener/releases/tag/v0.1.0
