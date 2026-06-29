<!-- refreshed: 2026-06-29 -->
# Architecture

**Analysis Date:** 2026-06-29

## System Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                   Flutter Framework Layer                     │
│              `MaterialApp` + Material 3 Theme                │
├──────────────────┬──────────────────────────────────────────┤
│  MyApp           │  FullscreenDemoPage (StatefulWidget)      │
│  (Stateless)     │  `lib/main.dart`                          │
│  Entry wrapper   │  All UI + business logic                  │
└──────────────────┴──────────────────┬───────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────┐
│              fullscreen_window ^1.2.1 (pub package)          │
│         `FullScreenWindow.setFullScreen(bool)`               │
└─────────────────────────────────────────────────────────────┘
         │                  │                  │
         ▼                  ▼                  ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐
│ Windows      │  │ Linux        │  │ iOS / Android / Web  │
│ (native C++) │  │ (native C)   │  │ (Dart-only impl)     │
│ Win32 API    │  │ GTK API      │  │ Platform channels    │
└──────────────┘  └──────────────┘  └──────────────────────┘
```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| `MyApp` | Root widget; configures MaterialApp, theme, and routes | `lib/main.dart:8` |
| `FullscreenDemoPage` | Main screen; holds fullscreen state, renders toggle UI | `lib/main.dart:24` |
| `_FullscreenDemoPageState` | Mutable state; handles fullscreen toggle logic | `lib/main.dart:31` |
| `FullScreenWindow` | Platform-abstracted fullscreen API (external package) | Package: `fullscreen_window` |

## Pattern Overview

**Overall:** Single-file Flutter app with direct plugin consumption

**Key Characteristics:**
- Single widget tree with no separation into features/modules
- All logic lives in one file (`lib/main.dart`, 83 lines)
- Stateful widget manages fullscreen toggle via `setState`
- Direct call to `FullScreenWindow.setFullScreen()` from UI layer
- No state management library, no routing, no DI

## Layers

**UI Layer:**
- Purpose: Renders the fullscreen demo interface with toggle button
- Location: `lib/main.dart`
- Contains: Widget definitions, build methods, event handlers
- Depends on: Flutter Material, `fullscreen_window` package
- Used by: Flutter runtime (entry point)

**Platform Layer (external):**
- Purpose: Provides native fullscreen toggling per OS
- Location: `fullscreen_window` package in pub cache
- Contains: Platform-specific C++ (Windows), C (Linux), Dart (others) implementations
- Depends on: OS window management APIs
- Used by: `_FullscreenDemoPageState._toggleFullscreen()`

**Runner Layer (platform shells):**
- Purpose: Native host application that embeds the Flutter engine
- Location: `windows/runner/`, `linux/runner/`, `macos/Runner/`
- Contains: OS-specific entry points and window setup
- Depends on: Flutter engine, OS APIs
- Used by: Operating system at app launch

## Data Flow

### Primary Request Path

1. User taps "进入全屏" / "退出全屏" button (`lib/main.dart:70`)
2. `_toggleFullscreen()` called (`lib/main.dart:34`)
3. `setState()` flips `_isFullscreen` boolean (`lib/main.dart:35`)
4. `FullScreenWindow.setFullScreen(_isFullscreen)` invoked (`lib/main.dart:38`)
5. Platform plugin delegates to native OS API (Win32 `SetWindowLong` / GTK window state)
6. UI rebuilds via `build()` with updated `_isFullscreen` state (`lib/main.dart:42`)
7. AppBar hidden/shown, icon and text updated to reflect new state

**State Management:**
- Single `bool _isFullscreen` field in `_FullscreenDemoPageState`
- Reactive via `setState()` triggering widget rebuild
- No external state management (no Provider, Bloc, Riverpod, etc.)

## Key Abstractions

**`FullScreenWindow` (external):**
- Purpose: Cross-platform fullscreen toggling abstraction
- Pattern: Static method API (`FullScreenWindow.setFullScreen(bool)`)
- Platform dispatch: Uses Flutter method channels / FFI to call native code

**`FullscreenDemoPage` (StatefulWidget):**
- Purpose: Encapsulates fullscreen state and UI in a single widget
- Pattern: Classic StatefulWidget with mutable `_isFullscreen` state
- Lifecycle: No custom `initState`/`dispose` logic needed

## Entry Points

**Flutter entry (`main()`):**
- Location: `lib/main.dart:4`
- Triggers: `flutter run` / compiled binary
- Responsibilities: Calls `runApp(const MyApp())`

**Windows native entry (`wWinMain`):**
- Location: `windows/runner/main.cpp:8`
- Triggers: OS process launch
- Responsibilities: COM init, creates `FlutterWindow`, runs Win32 message loop

**Linux native entry (`main`):**
- Location: `linux/runner/main.cc:3`
- Triggers: OS process launch
- Responsibilities: Creates `MyApplication`, runs GTK event loop

**macOS native entry (`AppDelegate`):**
- Location: `macos/Runner/AppDelegate.swift:4`
- Triggers: OS process launch
- Responsibilities: Configures NSApplication lifecycle

## Architectural Constraints

- **Single-file architecture:** All Dart code lives in `lib/main.dart`. No modules, no separation of concerns beyond widget boundaries.
- **No routing:** Single-page app with no `Navigator` usage or named routes.
- **No abstraction layers:** Business logic (fullscreen toggle) directly in UI code.
- **Plugin dependency:** Fullscreen functionality entirely delegated to `fullscreen_window` package; no fallback if plugin fails.
- **Synchronous state:** `_isFullscreen` is set optimistically before the async `setFullScreen` completes. No error handling if the platform call fails.

## Anti-Patterns

### Stale Test File

**What happens:** `test/widget_test.dart` tests a counter increment flow (tap "+", verify "0" -> "1") that does not exist in the actual app.
**Why it's wrong:** The test will fail on `find.byIcon(Icons.add)` because no add icon exists in the current UI. The test was auto-generated by `flutter create` and never updated.
**Do this instead:** Replace with tests that verify fullscreen toggle button presence, text changes, and icon state transitions.

### Optimistic State Update Without Error Handling

**What happens:** `_toggleFullscreen()` sets `_isFullscreen = true` via `setState` before awaiting `FullScreenWindow.setFullScreen()`. If the platform call fails, the UI shows fullscreen mode while the window is not actually fullscreen.
**Why it's wrong:** UI and actual window state become desynchronized on platform errors.
**Do this instead:** Await the platform call first, then update state. Add try/catch to handle failures gracefully.

## Error Handling

**Strategy:** None implemented

**Patterns:**
- No try/catch blocks anywhere in the codebase
- No error boundaries or fallback UI
- Platform call failures are silently ignored

## Cross-Cutting Concerns

**Logging:** Not implemented. No logging framework or debug output.
**Validation:** Not applicable (no user input beyond button taps).
**Authentication:** Not applicable.
**Theming:** Material 3 with `ColorScheme.fromSeed(seedColor: Colors.deepPurple)` in `lib/main.dart:15`.
**Localization:** Chinese strings hardcoded inline in `lib/main.dart:61-66`. No i18n framework.

---

*Architecture analysis: 2026-06-29*
