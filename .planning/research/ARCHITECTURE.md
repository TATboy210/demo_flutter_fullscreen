# Architecture Research — Fullscreen Plugin Internals

**Analysis Date:** 2026-06-29
**Sources:** `fullscreen_window` 1.2.1 (pub cache), `flutter_fullscreen` 1.2.0 (pub cache)

---

## Overview

Two fundamentally different architectural approaches to the same problem: toggling fullscreen on desktop/mobile/web from Flutter.

| Dimension | `fullscreen_window` | `flutter_fullscreen` |
|-----------|-------------------|---------------------|
| **Plugin type** | Federated (native plugins per platform) | Pure Dart + dependency delegation |
| **Native code** | Yes — C++ (Windows), C (Linux) | No — delegates to `window_manager` |
| **Platform dispatch** | MethodChannel to native | Conditional import (`dart.library.js_util`) |
| **State model** | Stateless (fire-and-forget) | Stateful (observer pattern with listeners) |
| **Initialization** | None required | `FullScreen.ensureInitialized()` required |
| **Dependencies** | `plugin_platform_interface`, `web` | `window_manager`, `web` |

---

## Package 1: `fullscreen_window` 1.2.1

### Architecture Pattern: Federated Plugin

```text
┌──────────────────────────────────────────────────────────────┐
│  App-facing package: `fullscreen_window`                      │
│  lib/fullscreen_window.dart                                   │
│  Exports: `final FullScreenWindow = Platform.instance`        │
├──────────────────────────────────────────────────────────────┤
│  Platform interface: `FullScreenWindowPlatform`               │
│  lib/fullscreen_window_platform_interface.dart                │
│  Abstract class with `setFullScreen(bool)` + `getScreenSize`  │
│  Default: MethodChannelFullscreenWindow                       │
├──────────┬──────────┬──────────┬─────────────────────────────┤
│ Windows  │  Linux   │  Web     │  Android (Dart-only)        │
│ C++      │  C       │  Dart    │  Dart-only                  │
│ native   │  native  │  JS interop │ SystemChrome API         │
│ plugin   │  plugin  │  plugin  │  dartPluginClass            │
└──────────┴──────────┴──────────┴─────────────────────────────┘
```

### Component Boundaries

**Layer 1 — App-facing API** (`lib/fullscreen_window.dart`)
- Exports `FullScreenWindow` as a top-level final variable
- Type: `FullScreenWindowPlatform` (the platform interface)
- Exports `FullScreenWindowAndroid` (side effect — makes `dartPluginClass` registration work)
- Usage: `FullScreenWindow.setFullScreen(bool)` — static-like call, no instantiation needed

**Layer 2 — Platform interface** (`lib/fullscreen_window_platform_interface.dart`)
- Extends `PlatformInterface` from `plugin_platform_interface` package
- Token-verified singleton pattern (`_token`, `_instance`)
- Default instance: `MethodChannelFullscreenWindow`
- Two methods: `setFullScreen(bool) → Future<void>`, `getScreenSize(BuildContext?) → Future<Size>`
- Both throw `UnimplementedError` by default

**Layer 3 — MethodChannel implementation** (`lib/fullscreen_window_method_channel.dart`)
- Channel name: `"fullscreen_window"`
- `setFullScreen` → sends `{"isFullScreen": bool}` argument map
- `getScreenSize` → sends `{}`, receives `{"width": int, "height": int}`, divides by `devicePixelRatio`

**Layer 4 — Platform-specific implementations**

### Native Code: Windows (C++)

**File:** `windows/fullscreen_window_plugin.cpp`

**Registration:**
```cpp
// C API bridge: fullscreen_window_plugin_c_api.cpp
void FullscreenWindowPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
    FullscreenWindowPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarManager::GetInstance()
            ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
```
- Uses `flutter::MethodChannel<flutter::EncodableValue>` with channel name `"fullscreen_window"`
- Stores `m_NativeHWND` from registrar for window handle access

**Fullscreen toggle — Win32 API approach:**
```cpp
// Global state to save/restore window configuration
struct {
    bool fullscreen, maximized;
    LONG style, ex_style;
    RECT window_rect;
    WINDOWPLACEMENT placement;
} g_saved_window_info;

void setFullScreen(HWND hwnd, bool fullscreen) {
    // Save current state before entering fullscreen
    if (!g_saved_window_info.fullscreen) {
        g_saved_window_info.maximized = !!IsZoomed(hwnd);
        g_saved_window_info.style = GetWindowLong(hwnd, GWL_STYLE);
        g_saved_window_info.ex_style = GetWindowLong(hwnd, GWL_EXSTYLE);
        GetWindowPlacement(hwnd, &g_saved_window_info.placement);
    }

    if (fullscreen) {
        // Strip caption, thick frame, maximize style
        SetWindowLong(hwnd, GWL_STYLE,
            style & ~(WS_CAPTION | WS_THICKFRAME | WS_MAXIMIZE));
        // Add topmost, strip dialog/client/static edges
        SetWindowLong(hwnd, GWL_EXSTYLE,
            ex_style | WS_EX_TOPMOST & ~(WS_EX_DLGMODALFRAME | ...));
        SendMessage(hwnd, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
    } else {
        // Restore all saved styles and placement
        if (!maximized) SendMessage(hwnd, WM_SYSCOMMAND, SC_RESTORE, 0);
        SetWindowLong(hwnd, GWL_STYLE, saved_style);
        SetWindowLong(hwnd, GWL_EXSTYLE, saved_ex_style);
        SetWindowPlacement(hwnd, &saved_placement);
        // Force re-layout workaround
        GetWindowRect(hwnd, &bounds);
        SetWindowPos(hwnd, 0, ..., SWP_NOZORDER | SWP_NOACTIVATE | SWP_FRAMECHANGED);
    }
}
```

**Key Win32 APIs used:**
- `GetWindowLong` / `SetWindowLong` with `GWL_STYLE`, `GWL_EXSTYLE` — manipulate window styles
- `WS_CAPTION`, `WS_THICKFRAME`, `WS_MAXIMIZE` — strip title bar and resize borders
- `WS_EX_TOPMOST`, `WS_EX_DLGMODALFRAME`, `WS_EX_WINDOWEDGE`, etc. — edge styles
- `SendMessage(WM_SYSCOMMAND, SC_MAXIMIZE)` — trigger maximize
- `GetWindowPlacement` / `SetWindowPlacement` — save/restore position
- `GetWindowRect` / `SetWindowPos` — force re-layout after exit
- `IsZoomed` — check if window is maximized
- `GetDesktopWindow` — for `getScreenSize`

**Known issue:** Comment in source notes Flutter layout is incorrect after exit fullscreen, requiring a forced re-layout via `SetWindowPos`. Sometimes still has layout issues.

### Native Code: Linux (C/GTK)

**File:** `linux/fullscreen_window_plugin.cc`

**Registration:**
- Uses `FlMethodChannel` with `FlStandardMethodCodec`
- Channel name: `"fullscreen_window"`
- Gets GTK window via `gtk_widget_get_toplevel()` from the plugin registrar's view

**Fullscreen toggle — GTK API approach:**
```c
if (strcmp(method, "setFullScreen") == 0) {
    bool isFullScreen = fl_value_get_bool(fl_value_lookup_string(args, "isFullScreen"));
    if (isFullScreen) {
        gtk_window_fullscreen(get_window(self));
    } else {
        gtk_window_unfullscreen(get_window(self));
    }
}
```

**Key GTK APIs used:**
- `gtk_window_fullscreen()` — makes window fullscreen (compositor handles it)
- `gtk_window_unfullscreen()` — restores window
- `gdk_display_get_monitor_at_window()` — for `getScreenSize`
- `gdk_monitor_get_geometry()` — get monitor dimensions

**Key difference from Windows:** GTK handles fullscreen natively through the window manager/compositor. No need to manually save/restore window styles. Much simpler implementation.

### Platform Implementations: Dart-only

**Android** (`lib/fullscreen_window_android.dart`):
- Uses `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)` for fullscreen
- Uses `SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values)` to exit
- `getScreenSize` requires non-null `BuildContext`, reads from `MediaQuery`
- Registered as `dartPluginClass` in pubspec (no native code needed)

**Web** (`lib/fullscreen_window_web.dart`):
- Uses `package:web` (JS interop) to call `document.documentElement.requestFullscreen()` / `document.exitFullscreen()`
- `getScreenSize` reads `window.screen.width/height`
- Registered as `pluginClass` with `flutter_web_plugins`

**No macOS or iOS implementation** — not listed in pubspec `platforms`.

---

## Package 2: `flutter_fullscreen` 1.2.0

### Architecture Pattern: Conditional Import + Dependency Delegation

```text
┌──────────────────────────────────────────────────────────────┐
│  FullScreen (static facade)                                   │
│  lib/src/full_screen.dart                                     │
│  Conditional import: full_screen_instance.dart                 │
│    if (dart.library.js_util) → full_screen_instance_web.dart   │
├──────────────────────────────────────────────────────────────┤
│                    │                                          │
│  ┌─────────────────┴─────────────────┐                        │
│  │  Desktop + Mobile (non-web)       │  Web                    │
│  │  full_screen_instance.dart        │  full_screen_instance_web.dart │
│  │  Delegates to `window_manager`    │  Direct JS interop      │
│  │  + SystemChrome (mobile)          │  Fullscreen API         │
│  └───────────────────────────────────┘  └─────────────────────┘
├──────────────────────────────────────────────────────────────┤
│  FullScreenListener (mixin)                                   │
│  lib/src/full_screen_listener.dart                            │
│  Observer pattern: add/remove listeners for state changes     │
└──────────────────────────────────────────────────────────────┘
```

### Component Boundaries

**Layer 1 — Static facade** (`lib/src/full_screen.dart`)
- `FullScreen` class with all static members
- Platform detection: `supportWeb` (kIsWeb), `supportWindowManager` (!web && Windows/macOS/Linux), `supportMobile` (!web && Android/iOS)
- Requires `FullScreen.ensureInitialized()` before use (throws string if not initialized)
- Conditional import selects `FullScreenInstance` implementation at compile time

**Layer 2 — Desktop/Mobile instance** (`lib/src/full_screen_instance.dart`)
- Mixes in `WindowListener` from `window_manager` package
- Desktop (Windows/macOS/Linux): delegates to `windowManager.setFullScreen()` / `windowManager.isFullScreen()`
- Mobile (Android/iOS): uses `SystemChrome.setEnabledSystemUIMode()` (same as `fullscreen_window`'s Android impl)
- Maintains `_state` (bool) and `_systemUiMode` (SystemUiMode?)
- Initializes by calling `windowManager.ensureInitialized()` and `windowManager.addListener(this)`
- Reads initial state via `windowManager.isFullScreen()`

**Layer 2 — Web instance** (`lib/src/full_screen_instance_web.dart`)
- Uses `package:web` JS interop with custom extensions on `Element` and `Document`
- `requestFullscreen()` / `exitFullscreen()` / `fullscreenElement`
- Listens to DOM `fullscreenchange` and `resize` events via `EventStreamProvider`
- Detects "forced fullscreen" by comparing `window.screen` dimensions to `window.innerWidth/Height`
- Returns `systemUiMode` as `null` (not applicable on web)

**Layer 3 — Listener interface** (`lib/src/full_screen_listener.dart`)
- Abstract mixin class `FullScreenListener`
- Four callbacks:
  - `onWindowEnterFullScreen(SystemUiMode? systemUiMode)` — fullscreen enabled
  - `onWindowLeaveFullScreen(SystemUiMode? systemUiMode)` — fullscreen disabled
  - `onFullScreenChanged(bool enabled, SystemUiMode? systemUiMode)` — any state change
  - `onFullScreenForcedChanged(bool forced)` — environment forces fullscreen
- All have default empty implementations (optional override)
- Usage: mix into StatefulWidget's State, call `FullScreen.addListener(this)` in `initState`

### State Synchronization: Observer Pattern

```text
┌─────────────────┐    setState()     ┌──────────────────┐
│  window_manager  │ ───────────────► │  FullScreenInstance │
│  (native events) │  WindowListener  │  _state, _systemUiMode │
└─────────────────┘                  └────────┬─────────┘
                                              │
                                    _onStateChanged()
                                              │
                                              ▼
                                   ┌──────────────────┐
                                   │  ObserverList     │
                                   │  <FullScreenListener> │
                                   └────────┬─────────┘
                                            │
                              ┌──────────────┼──────────────┐
                              ▼              ▼              ▼
                        Listener A     Listener B     Listener C
                        (Widget State) (Widget State) (Widget State)
```

- `window_manager` fires native window events (enter/leave fullscreen)
- `FullScreenInstance` receives via `WindowListener` mixin
- Calls `_onStateChanged()` which iterates `_eventListeners` (ObserverList)
- Each listener gets `onFullScreenChanged`, `onWindowEnterFullScreen`/`onWindowLeaveFullScreen`
- Web variant listens to DOM `fullscreenchange` event instead

### The `window_manager` Dependency Chain

`flutter_fullscreen` does NOT write native code. It delegates desktop fullscreen to `window_manager` (v0.5.0+):

```text
flutter_fullscreen
  └─ window_manager ^0.5.0
       ├─ Windows: Win32 API via C++ plugin (similar approach to fullscreen_window)
       ├─ macOS: NSWindow via Swift plugin
       ├─ Linux: GTK via C plugin
       └─ Provides: WindowManager.setFullScreen(bool), isFullScreen(), WindowListener
```

This means `flutter_fullscreen` on desktop has **two levels of plugin indirection**: Dart → `window_manager` Dart API → `window_manager` native plugin → OS API.

---

## Key Architectural Differences

### 1. Native Code Ownership

| Aspect | `fullscreen_window` | `flutter_fullscreen` |
|--------|-------------------|---------------------|
| Writes native code | Yes (C++, C) | No |
| Native surface area | 2 platforms (Windows, Linux) | 0 (delegates to `window_manager`) |
| Dependency depth | 1 (direct) | 2 (→ `window_manager` → native) |
| Maintenance burden | Owns native code | Depends on upstream |

### 2. Platform Dispatch Mechanism

**`fullscreen_window` — Federated Plugin Model:**
```text
pubspec.yaml declares:
  windows: pluginClass: FullscreenWindowPluginCApi    → C++ native
  linux:   pluginClass: FullScreenWindowPlugin         → C native
  web:     pluginClass: FullScreenWindowWeb            → Dart + JS interop
  android: dartPluginClass: FullScreenWindowAndroid    → Dart-only
```
- Flutter tooling auto-registers the correct implementation per platform
- MethodChannel is the bridge for Windows/Linux (native code handles it)
- Web/Android override the platform interface directly (no MethodChannel)

**`flutter_fullscreen` — Conditional Import Model:**
```text
full_screen.dart:
  import 'full_screen_instance.dart'
    if (dart.library.js_util) 'full_screen_instance_web.dart'
```
- Dart compiler selects the correct file at build time based on target
- No pubspec `pluginClass` declarations — it's a pure Dart package
- Desktop/mobile path delegates to `window_manager` (which itself is a federated plugin)
- Web path uses direct JS interop

### 3. State Management

**`fullscreen_window` — Fire-and-Forget:**
- `setFullScreen(bool)` returns `Future<void>` but caller has no way to know current state
- No event system — if external code changes fullscreen, caller is unaware
- The app must maintain its own state (as the demo does with `_isFullscreen`)

**`flutter_fullscreen` — Observer Pattern:**
- Maintains internal `_state` boolean, synced from native events
- `FullScreen.isFullScreen` — read current state at any time
- `FullScreenListener` mixin — receive callbacks when state changes
- Works bidirectionally: programmatic changes AND external changes (e.g., OS shortcut, browser ESC) both trigger listeners

### 4. Initialization

**`fullscreen_window`:** No initialization needed. Call `FullScreenWindow.setFullScreen()` anytime.

**`flutter_fullscreen`:** Requires `await FullScreen.ensureInitialized()` in `main()` before `runApp()`. This initializes `window_manager` and queries initial fullscreen state.

### 5. Error Handling

**`fullscreen_window`:** Native code returns `result->Success()` / `result->Success(value)`. No error cases handled. Dart side has no try/catch.

**`flutter_fullscreen`:** Throws a string (not an Exception) if not initialized: `throw "FullScreen is not initialized..."`. No platform-level error handling beyond that.

---

## Data Flow Comparison

### `fullscreen_window` — Enter Fullscreen on Windows

```text
1. Dart: FullScreenWindow.setFullScreen(true)
2. Dart: MethodChannel.invokeMethod('setFullScreen', {isFullScreen: true})
3. C++:  HandleMethodCall → extracts bool from EncodableMap
4. C++:  GetAncestor(m_NativeHWND, GA_ROOT) → HWND
5. C++:  Save current styles (GWL_STYLE, GWL_EXSTYLE, placement)
6. C++:  SetWindowLong(GWL_STYLE, style & ~(WS_CAPTION | WS_THICKFRAME | WS_MAXIMIZE))
7. C++:  SetWindowLong(GWL_EXSTYLE, style | WS_EX_TOPMOST & ~edges)
8. C++:  SendMessage(WM_SYSCOMMAND, SC_MAXIMIZE, 0)
9. C++:  result->Success() → Dart Future completes
```

### `flutter_fullscreen` — Enter Fullscreen on Windows

```text
1. Dart: FullScreen.setFullScreen(true, ...)
2. Dart: FullScreenInstance.setState(true, null, null)
3. Dart: windowManager.setFullScreen(true)  [window_manager package]
4. Dart→Native: window_manager's MethodChannel → C++ plugin
5. C++: window_manager's native code manipulates Win32 window
6. C++→Dart: window_manager fires WindowListener.onEnterFullScreen()
7. Dart: FullScreenInstance._onStateChanged(true, ...)
8. Dart: Iterates ObserverList<FullScreenListener>
9. Dart: Each listener.onFullScreenChanged(true, ...) called
```

### `fullscreen_window` — Enter Fullscreen on Linux

```text
1. Dart: FullScreenWindow.setFullScreen(true)
2. Dart: MethodChannel.invokeMethod('setFullScreen', {isFullScreen: true})
3. C:    method_call_cb → handle_method_call
4. C:    fl_value_get_bool(args["isFullScreen"])
5. C:    gtk_window_fullscreen(get_window(self))
6. C:    GTK/compositor handles the rest
7. C:    result → FlMethodSuccessResponse
```

### `flutter_fullscreen` — Enter Fullscreen on Web

```text
1. Dart: FullScreen.setFullScreen(true)
2. Dart: FullScreenInstance.setState(true, ...)
3. JS:   document.documentElement.requestFullscreen()
4. JS:   Browser enters fullscreen mode
5. JS:   'fullscreenchange' DOM event fires
6. Dart: _handleFullScreenChange() → _onStateChanged(true)
7. Dart: Iterates listeners → onFullScreenChanged(true, null)
```

---

## Implications for Comparison Test Page

### Component Boundaries to Test

1. **API surface:** `FullScreenWindow.setFullScreen(bool)` vs `FullScreen.setFullScreen(bool, ...)`
2. **State readback:** `fullscreen_window` has none vs `FullScreen.isFullScreen`
3. **Event listening:** `fullscreen_window` has none vs `FullScreenListener` mixin
4. **Initialization:** Nothing vs `FullScreen.ensureInitialized()`
5. **Return value:** `Future<void>` (no meaningful return) vs void (state in observer)

### Data Flow to Observe

- **Unidirectional (fullscreen_window):** UI → Dart → Native → OS. No feedback path.
- **Bidirectional (flutter_fullscreen):** UI → Dart → window_manager → Native → OS → Event → Dart → Listeners → UI

### Key Differences to Document in Test Page

| Behavior | `fullscreen_window` | `flutter_fullscreen` |
|----------|-------------------|---------------------|
| Call to enter | `FullScreenWindow.setFullScreen(true)` | `FullScreen.setFullScreen(true)` |
| Read current state | Not available | `FullScreen.isFullScreen` |
| React to changes | Manual polling or setState | `FullScreenListener.onFullScreenChanged` |
| Init required | No | Yes (`ensureInitialized()`) |
| External change detection | No | Yes (native events propagate) |
| macOS support | No | Yes (via `window_manager`) |
| iOS support | No | Yes (via `SystemChrome`) |
| getScreenSize | Built-in (`getScreenSize(context)`) | Not provided |

### Integration Concerns

- Both packages can coexist in the same app (different MethodChannel names, no conflicts)
- `flutter_fullscreen` initializing `window_manager` may affect window behavior globally (e.g., window size, title bar)
- `fullscreen_window`'s Win32 style manipulation could conflict with `window_manager`'s window management if both are active
- Testing should toggle with one package at a time, then test simultaneous usage

---

*Architecture research: 2026-06-29*
