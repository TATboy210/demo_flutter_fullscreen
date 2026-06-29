# Stack Research — Fullscreen Plugins Comparison

**Research Date:** 2026-06-29
**Researcher:** Claude Code
**Sources:** pub.dev, pub.dev API docs, GitHub

---

## Package 1: fullscreen_window

### Identity

| Field | Value |
|-------|-------|
| **Package** | `fullscreen_window` |
| **Version** | 1.2.1 (latest) |
| **pub.dev** | https://pub.dev/packages/fullscreen_window |
| **License** | Apache-2.0 |
| **Publisher** | Unverified uploader (no org) |
| **Likes** | 30 |
| **Pub Points** | 140 |
| **Downloads** | 23.3k (all-time) |
| **Published** | ~November 2025 |
| **Repository** | Not publicly linked on pub.dev |

### API Surface

**Architecture:** Federated plugin using `plugin_platform_interface`. Three platform implementations:
- `MethodChannelFullscreenWindow` — Desktop (Windows/Linux/macOS via method channel)
- `FullScreenWindowAndroid` — Android (pure Flutter API)
- `FullScreenWindowWeb` — Web (JS interop)

**Core Class: `FullScreenWindow`** (static accessor to platform implementation)

```dart
import 'package:fullscreen_window/fullscreen_window.dart';

// Primary API — single method
Future<void> FullScreenWindow.setFullScreen(bool isFullScreen)

// Bonus — screen size query
Future<Size> FullScreenWindow.getScreenSize(BuildContext? context)
```

**Usage Pattern:**
```dart
// Enter fullscreen
await FullScreenWindow.setFullScreen(true);

// Exit fullscreen
await FullScreenWindow.setFullScreen(false);
```

**Characteristics:**
- Fire-and-forget API (returns `Future<void>`, no result/error info)
- No state query method (no `isFullScreen` getter)
- No event listener/callback mechanism
- No `SystemUiMode` control on mobile
- Minimal surface: 1 class, 2 methods

### Dependencies

| Dependency | Version | Purpose |
|-----------|---------|---------|
| flutter | SDK | Core framework |
| flutter_web_plugins | SDK | Web plugin federation |
| plugin_platform_interface | ^2.0.2 | Federated plugin interface |
| web | ^1.0.0 | Dart web interop (for Web platform) |

**Transitive dependency weight:** Light — only platform interface + web interop.

### Platform Support

| Platform | Support | Implementation |
|----------|---------|---------------|
| Windows | Yes | Method channel (native C++) |
| Linux | Yes | Method channel (native C++) |
| macOS | Yes* | Method channel (native Swift/ObjC) |
| Android | Yes | Pure Flutter API (SystemUiMode) |
| iOS | Yes* | Pure Flutter API (SystemUiMode) |
| Web | Yes | JS Fullscreen API interop |

*Note: macOS listed via method channel impl; iOS noted as "not tested but should work" in docs.

### Maintenance Status

- Last published: ~7 months ago (relative to 2026-06-29)
- No verified publisher
- No public GitHub repository found
- Changelog details not rendering on pub.dev (possible formatting issue)
- **Risk:** Unverified publisher, no public source code, moderate community trust

---

## Package 2: flutter_fullscreen

### Identity

| Field | Value |
|-------|-------|
| **Package** | `flutter_fullscreen` |
| **Version** | 1.2.0 (latest) |
| **pub.dev** | https://pub.dev/packages/flutter_fullscreen |
| **License** | MIT |
| **Publisher** | j7126.dev (verified publisher) |
| **Likes** | 13 |
| **Pub Points** | 150 |
| **Downloads** | 4.9k (all-time) |
| **Published** | ~May 2025 |
| **Repository** | https://github.com/j7126/full_screen |
| **GitHub Stars** | 3 |
| **GitHub Forks** | 0 |

### API Surface

**Architecture:** Uses `window_manager` for desktop platforms, direct Flutter APIs for mobile. Not federated — single implementation with conditional platform logic.

**Core Class: `FullScreen`** (static methods and properties)

```dart
import 'package:flutter_fullscreen/flutter_fullscreen.dart';

// Static Properties (read-only state)
static bool FullScreen.isFullScreen           // Current fullscreen state
static bool FullScreen.isFullScreenForced     // Forced by environment (kiosk, etc.)
static bool FullScreen.supportMobile          // Mobile platform support flag
static bool FullScreen.supportWindowManager   // window_manager available flag
static SystemUiMode? FullScreen.systemUiMode  // Current SystemUiMode (mobile only)

// Static Methods (control)
// Note: Method names inferred from class structure — 
// actual method signatures not fully captured from API docs.
// Based on pub.dev description: "setting fullscreen mode"
```

**Listener Mixin: `FullScreenListener`** (abstract mixin for state change callbacks)

```dart
mixin FullScreenListener {
  // Called when fullscreen enabled/disabled
  void onFullScreenChanged(bool enabled, SystemUiMode? systemUiMode)

  // Called when forced fullscreen state changes
  void onFullScreenForcedChanged(bool forced)

  // Called when entering fullscreen
  void onWindowEnterFullScreen(SystemUiMode? systemUiMode)

  // Called when leaving fullscreen
  void onWindowLeaveFullScreen(SystemUiMode? systemUiMode)
}
```

**Usage Pattern:**
```dart
// State query
if (FullScreen.isFullScreen) { ... }

// Listen for changes (mixin on State class)
class _MyState extends State<MyWidget> with FullScreenListener {
  @override
  void onFullScreenChanged(bool enabled, SystemUiMode? mode) {
    setState(() { ... });
  }
}
```

**Characteristics:**
- Rich state query (isFullScreen, isFullScreenForced, systemUiMode)
- Event listener mixin pattern (4 callback methods)
- SystemUiMode awareness on mobile (Android/iOS)
- Forced fullscreen detection (kiosk mode)
- Larger surface: 2 classes, multiple properties + methods

### Dependencies

| Dependency | Version | Purpose |
|-----------|---------|---------|
| flutter | SDK | Core framework |
| web | ^1.1.0 | Dart web interop |
| window_manager | ^0.5.0 | Desktop window management |

**Transitive dependency weight:** HEAVY — `window_manager` pulls in significant transitive deps:
- `screen_retriever` (screen info)
- `gtk` (Linux native)
- Various platform-specific native code

### Platform Support

| Platform | Support | Implementation |
|----------|---------|---------------|
| Windows | Yes | via window_manager |
| Linux | Yes | via window_manager |
| macOS | Yes | via window_manager |
| Android | Yes | Flutter SystemUiMode API |
| iOS | Yes | Flutter SystemUiMode API |
| Web | Yes | JS Fullscreen API |

### Maintenance Status

- Last published: ~13 months ago (relative to 2026-06-29)
- Verified publisher (j7126.dev)
- Public GitHub: https://github.com/j7126/full_screen (3 stars)
- Higher pub points (150 vs 140)
- **Risk:** Low GitHub activity (3 stars, 0 forks), but verified publisher provides some trust signal

---

## Head-to-Head Comparison

### API Design Philosophy

| Aspect | fullscreen_window | flutter_fullscreen |
|--------|-------------------|-------------------|
| **API Style** | Minimal, imperative | Rich, stateful |
| **State Query** | None (caller must track) | `isFullScreen`, `isFullScreenForced` |
| **Event Listening** | None | `FullScreenListener` mixin (4 callbacks) |
| **Mobile SystemUI** | Not exposed | `SystemUiMode` control |
| **Forced Detection** | No | Yes (`isFullScreenForced`) |
| **Screen Size** | `getScreenSize()` | Not available |
| **Learning Curve** | Trivial | Moderate |

### Dependency Footprint

| Aspect | fullscreen_window | flutter_fullscreen |
|--------|-------------------|-------------------|
| **Direct Deps** | 4 (light) | 3 (but heavy) |
| **window_manager** | No | Yes (^0.5.0) — brings native GTK, screen_retriever |
| **Federated** | Yes (plugin_platform_interface) | No |
| **Native Code** | Own minimal native | Inherits window_manager's native code |
| **Disk/Build Impact** | Small | Larger (window_manager native libs) |

### Platform & Maturity

| Aspect | fullscreen_window | flutter_fullscreen |
|--------|-------------------|-------------------|
| **Platform Coverage** | 5/6 (macOS uncertain) | 6/6 (all claimed) |
| **Pub Points** | 140 | 150 |
| **Downloads** | 23.3k | 4.9k |
| **Likes** | 30 | 13 |
| **Publisher** | Unverified | Verified (j7126.dev) |
| **Source Code** | Not public | Public GitHub |
| **Last Update** | ~Nov 2025 | ~May 2025 |
| **Community Trust** | Higher adoption, lower transparency | Lower adoption, higher transparency |

---

## Recommendation

### For This Demo Project

**Use BOTH** — that is the project's purpose. Add `flutter_fullscreen: ^1.2.0` alongside `fullscreen_window: ^1.2.1` to enable side-by-side comparison.

### For Production Selection

**If you need minimal deps + simple toggle:** `fullscreen_window`
- Single method API, tiny footprint
- 4.7x more downloads (community validation)
- Tradeoff: no state query, no listeners, no public source

**If you need rich state management + event listening:** `flutter_fullscreen`
- State properties, listener mixin, SystemUiMode control
- Verified publisher, public source code
- Tradeoff: heavy `window_manager` dependency, lower adoption

### What NOT To Use

- **Do NOT use `window_manager` directly** for just fullscreen — it is a full window management suite (300+ API surface) when you only need fullscreen toggle. Both packages wrap it appropriately.
- **Do NOT use `bitsdojo_window`** for fullscreen — it focuses on custom window frames, not fullscreen mode.
- **Do NOT mix both in production** — pick one based on your API needs. The demo project uses both for comparison only.

---

## Version Pinning for This Project

```yaml
# pubspec.yaml — recommended additions
dependencies:
  fullscreen_window: ^1.2.1     # Already present
  flutter_fullscreen: ^1.2.0    # Add for comparison
```

**Note:** Adding `flutter_fullscreen` will pull in `window_manager ^0.5.0` transitively, which adds `screen_retriever`, GTK bindings (Linux), and platform-specific native code. This increases build time and binary size but is acceptable for a demo/learning project.

---

*Research: 2026-06-29 — Sources: pub.dev, pub.dev API docs, GitHub*
