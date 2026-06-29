# Features Research — Flutter Fullscreen Plugins

> **Purpose:** Feature comparison for requirements definition. Categorizes each capability as table stakes, differentiator, or anti-feature.

## Package Overview

| Attribute | fullscreen_window 1.2.1 | flutter_fullscreen 1.2.0 |
|-----------|------------------------|--------------------------|
| pub.dev likes | 30 | 13 |
| Monthly downloads | 23.3k | 4.9k |
| License | Apache-2.0 | MIT |
| Architecture | Federated plugin (native C++) | Conditional import (window_manager wrapper) |
| Dependencies | flutter, flutter_web_plugins, plugin_platform_interface, web | flutter, web, window_manager |
| Initialization | None required | `await FullScreen.ensureInitialized()` |
| SDK constraint | `>=2.17.0 <3.0.0` (no Dart 3.x) | Compatible with Dart 3.x |

## Complete API Surface

### fullscreen_window

```dart
// Set fullscreen on/off (void, no return value, no await)
FullScreenWindow.setFullScreen(bool isFullScreen);

// Get screen size (logical with context, physical with null)
Size screenSize = await FullScreenWindow.getScreenSize(BuildContext? context);
```

**Total public methods: 2**

### flutter_fullscreen

```dart
// Required initialization (must call before any other API)
await FullScreen.ensureInitialized();

// Set fullscreen on/off (void, synchronous)
FullScreen.setFullScreen(bool enabled);

// Query current fullscreen state
bool isFullScreen = FullScreen.isFullScreen;

// Listener registration
FullScreen.addListener(FullScreenListener listener);
FullScreen.removeListener(FullScreenListener listener);
```

**Listener callbacks (4 methods):**

```dart
abstract mixin class FullScreenListener {
  void onWindowEnterFullScreen(SystemUiMode? systemUiMode) {}
  void onWindowLeaveFullScreen(SystemUiMode? systemUiMode) {}
  void onFullScreenChanged(bool enabled, SystemUiMode? systemUiMode) {}
  void onFullScreenForcedChanged(bool forced) {}
}
```

**Total public methods/properties: 5 + 4 listener callbacks**

## Platform Support

| Platform | fullscreen_window | flutter_fullscreen | Notes |
|----------|:-:|:-:|-------|
| Windows | Yes | Yes | fullscreen_window: native Win32 C++; flutter_fullscreen: window_manager |
| Linux | Yes | Yes | fullscreen_window: native GTK C; flutter_fullscreen: window_manager |
| macOS | **No** | Yes | fullscreen_window has no macOS implementation at all |
| Web | Yes | Yes | Both use `document.documentElement.requestFullscreen()` |
| Android | Yes | Yes | Both use `SystemChrome.setEnabledSystemUIMode(immersiveSticky)` |
| iOS | Yes | Yes | Both use `SystemChrome.setEnabledSystemUIMode(immersiveSticky)` |

**Key gap:** `fullscreen_window` does not support macOS. The pub.dev platform table explicitly omits it. The INTEGRATIONS.md notes the macOS plugin registrant is empty.

## Feature Comparison Matrix

| Feature | fullscreen_window | flutter_fullscreen | Category |
|---------|:-:|:-:|----------|
| Toggle fullscreen on/off | Yes (void) | Yes (void) | TABLE STAKES |
| 6-platform support (Win/Linux/mac/Web/Android/iOS) | 5/6 (no macOS) | 6/6 | TABLE STAKES |
| Query fullscreen state | No | `isFullScreen` getter | TABLE STAKES |
| Listen to fullscreen changes | No | 4 callback mixin | DIFFERENTIATOR |
| No initialization required | Yes | No (needs `ensureInitialized`) | CONVENIENCE |
| Screen size query | `getScreenSize(context)` | No | DIFFERENTIATOR |
| Multi-window support | Yes (v1.2.1 + desktop_multi_window) | Unknown | DIFFERENTIATOR |
| Native code on desktop | Yes (C++/C) | No (uses window_manager) | TRADE-OFF |
| SystemUiMode exposure | No | Yes (via listener callbacks) | DIFFERENTIATOR |

## Categorization

### Table Stakes (must have or users leave)

These are non-negotiable for any fullscreen plugin:

1. **Toggle fullscreen on/off** — The core purpose. Both packages deliver this.
2. **All desktop platforms (Windows, Linux, macOS)** — A desktop fullscreen plugin that misses one OS is broken. `fullscreen_window` fails this on macOS.
3. **Query current state** — `isFullScreen` getter. Without this, UI must track state manually and risks desync. `fullscreen_window` lacks this entirely.
4. **Reliable state synchronization** — The fullscreen state must match reality at all times. Neither package guarantees this on failure paths (neither returns a success/failure indicator from `setFullScreen`).
5. **No crash on unsupported platform** — Graceful no-op or clear error, not a crash.

### Differentiators (competitive advantage)

These set a plugin apart from alternatives:

1. **Event listener system** — `flutter_fullscreen`'s `FullScreenListener` mixin with 4 callbacks. Enables reactive UI without polling. No equivalent in `fullscreen_window`.
2. **Screen size query** — `fullscreen_window`'s `getScreenSize()` returns logical and physical pixel dimensions. Useful for responsive layout in fullscreen mode. Absent from `flutter_fullscreen`.
3. **Zero initialization** — `fullscreen_window` works immediately. `flutter_fullscreen` requires `ensureInitialized()` in `main()`, which adds setup friction and a failure point.
4. **Multi-window awareness** — `fullscreen_window` v1.2.1 added `desktop_multi_window` support. Important for apps with multiple windows.
5. **SystemUiMode exposure** — `flutter_fullscreen` passes `SystemUiMode` through its callbacks, giving fine-grained control on mobile.
6. **Lightweight dependency tree** — `fullscreen_window` has zero transitive desktop dependencies. `flutter_fullscreen` pulls in `window_manager`, which brings its own surface area.

### Anti-features (deliberately NOT build)

Things that existing packages do but should be avoided:

1. **Window decoration control (title bar, borders, resize handles)** — This is `window_manager`'s domain. A fullscreen plugin should only control fullscreen state, not become a window manager. Scope creep into decoration control creates maintenance burden and API bloat.
2. **Window positioning/sizing** — Same rationale. Fullscreen means "fill the screen." Position and size management belong in a separate package.
3. **Always-on-top / pinning** — Orthogonal concern. Mixing it in creates a kitchen-sink API.
4. **macOS native Cocoa implementation** — `window_manager` already handles this well. Writing raw Cocoa fullscreen code adds maintenance cost with no benefit over the existing proven implementation.
5. **Web-specific fullscreen API passthrough** — The browser Fullscreen API has its own event model (`fullscreenchange`). Wrapping it adds complexity for marginal gain; `document.documentElement.requestFullscreen()` is sufficient.
6. **Custom animations for fullscreen transitions** — Platform-native transitions are the correct default. Custom animations add complexity and platform-specific bugs.

## Platform Implementation Analysis

### Desktop Fullscreen Semantics

There is a critical semantic difference between platforms:

| Platform | Fullscreen behavior | Title bar | Taskbar/Dock |
|----------|-------------------|-----------|--------------|
| Windows (Win32) | Borderless maximized (removes WS_CAPTION, WS_THICKFRAME) | Hidden | Visible (unless exclusive) |
| Linux (GTK) | `gtk_window_fullscreen()` — true fullscreen | Hidden | Hidden |
| macOS (Cocoa) | Native green-button fullscreen (separate Space) | Hidden | Auto-hide |
| Web | `requestFullscreen()` — element fullscreen | N/A | N/A |

**Implication:** "Fullscreen" means different things per platform. A good plugin should document this or provide a mode selector (borderless vs exclusive).

### Native vs Wrapper Trade-offs

| Aspect | Native (fullscreen_window) | Wrapper (flutter_fullscreen) |
|--------|---------------------------|------------------------------|
| Latency | Lower (direct C++ call) | Higher (Dart -> window_manager -> MethodChannel -> native) |
| Maintenance | Must maintain C++ per platform | Delegates to window_manager |
| Feature surface | Minimal (2 methods) | Richer (listener, state query) |
| Dependency risk | Self-contained | Depends on window_manager's stability |
| macOS support | Missing | Working |

## Edge Cases and Gaps

### Neither package handles:

1. **setFullScreen return value** — Both are `void`. Caller cannot know if the operation succeeded.
2. **Platform exceptions** — No documented error types. If the native call fails, behavior is undefined.
3. **Rapid toggling** — No debounce or queue. Calling `setFullScreen(true)` then `setFullScreen(false)` in quick succession has unpredictable results.
4. **Multi-monitor** — Neither package addresses which monitor to go fullscreen on.
5. **Exclusive fullscreen vs borderless** — Neither offers a mode selector. What you get is platform-dependent.

### fullscreen_window specific gaps:

1. **No macOS support** — Complete platform omission.
2. **No state query** — Cannot ask "am I fullscreen?"
3. **No event system** — Cannot react to external fullscreen changes (OS hotkey, etc.)
4. **Dart 3.x SDK constraint** — `>=2.17.0 <3.0.0` excludes modern Dart.

### flutter_fullscreen specific gaps:

1. **Initialization requirement** — Forgetting `ensureInitialized()` causes silent failure.
2. **No screen size query** — Cannot get display dimensions.
3. **Transitive dependency weight** — window_manager brings its own API surface and potential conflicts.

## Summary for Requirements

The ideal fullscreen plugin should combine:

- **From fullscreen_window:** Zero initialization, screen size query, lightweight dependencies, native performance
- **From flutter_fullscreen:** State query, listener system, all 6 platforms (especially macOS), SystemUiMode exposure
- **Neither provides:** Error reporting from `setFullScreen`, multi-monitor support, fullscreen mode selection (borderless vs exclusive)

---

*Research date: 2026-06-29*
*Sources: pub.dev packages, memory analysis files, INTEGRATIONS.md*
