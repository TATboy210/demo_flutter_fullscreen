# Pitfalls & Gotchas: fullscreen_window vs flutter_fullscreen

**Research Date:** 2026-06-29

## Summary

Both packages have distinct pitfalls rooted in their architecture choices. `fullscreen_window` suffers from fire-and-forget semantics and platform-specific native code quirks. `flutter_fullscreen` suffers from initialization requirements and transitive dependency complexity. The most dangerous pitfall common to both: **state desync when the platform call fails**.

---

## Pitfall 1: State Desync (BOTH packages)

**Severity:** CRITICAL

**The Problem:**
Both packages can leave the UI showing "fullscreen" while the window is not fullscreen, or vice versa.

**fullscreen_window:**
```dart
// WRONG: State toggled BEFORE async call completes
Future<void> _toggleFullscreen() async {
  setState(() { _isFullscreen = !_isFullscreen; });  // Optimistic update
  await FullScreenWindow.setFullScreen(_isFullscreen); // If this fails, state is wrong
}
```

The `setFullScreen` method returns `Future<void>` -- if the platform call throws, the `_isFullscreen` boolean is already toggled. There is no return value to indicate success/failure.

**flutter_fullscreen:**
```dart
// WRONG: setFullScreen returns void, not Future
FullScreen.setFullScreen(true);  // Fire-and-forget on desktop
// No way to know if it actually worked
```

On desktop, `windowManager.setFullScreen(state)` is called but the result is not awaited or checked. The listener pattern (`onWindowEnterFullScreen`) fires asynchronously, creating a window where state is inconsistent.

**Warning Signs:**
- UI shows fullscreen text/icon but window has borders
- Toggling rapidly causes visual glitches
- AppBar appears/disappears at wrong time

**Prevention:**
```dart
// fullscreen_window: Wrap in try-catch, revert on failure
Future<void> _toggleFullscreen() async {
  final previousState = _isFullscreen;
  setState(() { _isFullscreen = !_isFullscreen; });
  try {
    await FullScreenWindow.setFullScreen(_isFullscreen);
  } catch (e) {
    setState(() { _isFullscreen = previousState; }); // Revert
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fullscreen failed: $e')),
      );
    }
  }
}

// flutter_fullscreen: Use listener to confirm state change
FullScreen.addListener(MyListener(
  onConfirmed: (isFullscreen) {
    setState(() { _isFullscreen = isFullscreen; });
  },
));
FullScreen.setFullScreen(true);
// State updates only when listener fires
```

---

## Pitfall 2: Missing Initialization (flutter_fullscreen only)

**Severity:** HIGH

**The Problem:**
`flutter_fullscreen` requires `await FullScreen.ensureInitialized()` before any other API call. Forgetting this throws a string exception at runtime.

```dart
// WRONG: Using API without initialization
FullScreen.setFullScreen(true);  // Throws: "FullScreen is not initialized..."

// CORRECT:
await FullScreen.ensureInitialized();
FullScreen.setFullScreen(true);
```

**fullscreen_window has no such requirement** -- it works immediately because the platform instance is resolved at import time.

**Warning Signs:**
- App crashes on startup with unhelpful string exception
- Works in some code paths but not others (initialization order matters)

**Prevention:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FullScreen.ensureInitialized();  // Always first
  runApp(const MyApp());
}
```

---

## Pitfall 3: Windows Layout Glitch After Exit Fullscreen (fullscreen_window)

**Severity:** HIGH

**The Problem:**
The Windows native implementation has a known layout bug documented in the source code and changelog (v1.0.1 fix, but still present):

```cpp
// NOTE: flutter layout is not correct after exit fullscreen, so we change window size
// to force re-layout but sometimes it still has layout issues...
RECT bounds;
GetWindowRect(hwnd, &bounds);
SetWindowPos(hwnd, 0, bounds.left, bounds.top, ...);
```

The workaround forces a window resize to trigger Flutter re-layout, but the comment admits "sometimes it still has layout issues."

**Specific scenarios:**
- Maximize -> Enter fullscreen -> Exit fullscreen -> Layout broken
- Rapid toggling causes visual artifacts
- Widget tree may not rebuild correctly after style changes

**Warning Signs:**
- Content appears shifted or clipped after exiting fullscreen
- Padding/margins look wrong after toggle
- AppBar height incorrect after exit

**Prevention:**
```dart
// Force a frame rebuild after exiting fullscreen
Future<void> _toggleFullscreen() async {
  await FullScreenWindow.setFullScreen(false);
  // Force layout recalculation
  WidgetsBinding.instance.addPostFrameCallback((_) {
    setState(() {});
  });
}
```

---

## Pitfall 4: Global Mutable State in Native Code (fullscreen_window)

**Severity:** MEDIUM

**The Problem:**
The Windows C++ implementation uses a file-scope global struct:

```cpp
struct {
    bool fullscreen;
    bool maximized;
    LONG style;
    LONG ex_style;
    RECT window_rect;      // Declared but never used!
    WINDOWPLACEMENT placement;
} g_saved_window_info;
```

Issues:
1. **Multi-window conflict**: If using `desktop_multi_window` (supported since v1.2.1), all windows share this single global state. Toggling fullscreen on window A corrupts the saved state for window B.
2. **Unused field**: `window_rect` is declared but never read or written -- dead code.
3. **No thread safety**: The struct is accessed without synchronization.

**Warning Signs:**
- Second window fullscreen toggle restores wrong window dimensions
- Window size jumps unexpectedly after fullscreen cycle

**Prevention:**
- Avoid using multiple windows with `fullscreen_window`
- If multi-window is needed, use `flutter_fullscreen` (which delegates to `window_manager` with per-window state)

---

## Pitfall 5: WS_EX_TOPMOST Stays Applied (fullscreen_window Windows)

**Severity:** MEDIUM

**The Problem:**
The Windows implementation adds `WS_EX_TOPMOST` when entering fullscreen:

```cpp
SetWindowLong(hwnd, GWL_EXSTYLE,
    g_saved_window_info.ex_style | WS_EX_TOPMOST & ~(WS_EX_DLGMODALFRAME | ...));
```

When exiting fullscreen, it restores `g_saved_window_info.ex_style`. However, if the window was already topmost before fullscreen, or if another plugin modifies the extended style, the restoration may be incorrect.

Additionally, the bitwise operation has operator precedence issues: `WS_EX_TOPMOST & ~(...)` may not produce the intended mask.

**Warning Signs:**
- Window stays on top of other windows after exiting fullscreen
- Alt-Tab behavior changes after fullscreen toggle

**Prevention:**
- Test with `Always on Top` features of other plugins
- Verify window Z-order after fullscreen cycle

---

## Pitfall 6: Transitive Dependency Chain (flutter_fullscreen)

**Severity:** MEDIUM

**The Problem:**
`flutter_fullscreen` depends on `window_manager: ^0.5.0`, which itself has significant native code and dependencies:

```
flutter_fullscreen
  └── window_manager ^0.5.0
        └── native code (Windows/macOS/Linux)
        └── potential version conflicts
```

Issues:
1. **Version conflicts**: If your project already uses `window_manager` at a different version, you get version solving failures.
2. **Native code bloat**: You inherit all of `window_manager`'s native code even if you only need fullscreen toggle.
3. **Update lag**: `flutter_fullscreen` updates depend on `window_manager` releases.

**fullscreen_window** has minimal dependencies: `plugin_platform_interface`, `web`, `flutter_web_plugins`.

**Warning Signs:**
- `flutter pub get` fails with version conflict
- Unexpected native code in build output
- Plugin initialization conflicts with other window management plugins

**Prevention:**
```yaml
# Check for conflicts before adding flutter_fullscreen
dependency_overrides:
  window_manager: ^0.5.0  # Pin if needed
```

---

## Pitfall 7: Async vs Void Return Type Confusion

**Severity:** MEDIUM

**The Problem:**
The two packages have different return type semantics for the same conceptual operation:

| Package | Method | Return Type | Implication |
|---------|--------|-------------|-------------|
| fullscreen_window | `setFullScreen(bool)` | `Future<void>` | Awaitable, can catch errors |
| flutter_fullscreen | `setFullScreen(bool)` | `void` | Fire-and-forget, errors lost |

**fullscreen_window** returns a Future, so you can `await` it and wrap in try-catch. But the actual platform implementation on Windows/Linux calls `result->Success()` immediately -- the Future resolves before the native window state change is visually complete.

**flutter_fullscreen** returns void on desktop because `windowManager.setFullScreen(state)` is called without awaiting. The actual state change arrives via the `WindowListener` callback.

**Warning Signs:**
- `await` doesn't actually wait for visual change (fullscreen_window)
- Cannot catch errors from platform call (flutter_fullscreen)
- Race conditions in rapid toggle sequences

**Prevention:**
```dart
// fullscreen_window: Add artificial delay for visual confirmation
await FullScreenWindow.setFullScreen(true);
await Future.delayed(const Duration(milliseconds: 100)); // Wait for WM

// flutter_fullscreen: Use listener for confirmation
FullScreen.setFullScreen(true);
// State confirmed when onWindowEnterFullScreen fires
```

---

## Pitfall 8: macOS Fullscreen Animation Behavior

**Severity:** MEDIUM

**The Problem:**
macOS has a system-level fullscreen animation (the green button zoom effect). Both packages interact with this differently:

**fullscreen_window**: Uses MethodChannel but has **no macOS-specific native implementation file** (the Swift file path doesn't exist in the package). The default `MethodChannelFullscreenWindow` calls `invokeMethod` but there's no native handler registered on macOS. This means:
- On macOS, the method channel call may silently fail or throw `MissingPluginException`
- The package lists macOS support but the native implementation is absent

**flutter_fullscreen**: Delegates to `windowManager.setFullScreen()` which properly handles macOS fullscreen via NSWindow's `toggleFullScreen:`. This includes the system animation.

**Warning Signs:**
- `MissingPluginException` on macOS with fullscreen_window
- No fullscreen animation on macOS (abrupt state change)
- Dock and menu bar behavior inconsistent

**Prevention:**
- Test on macOS specifically before shipping
- For fullscreen_window on macOS: verify the method channel handler exists
- For flutter_fullscreen: the macOS animation works but is system-controlled (cannot be disabled)

---

## Pitfall 9: No Platform Capability Detection (BOTH packages)

**Severity:** MEDIUM

**The Problem:**
Neither package provides a way to check if fullscreen is supported on the current platform before calling the API.

**fullscreen_window**: `setFullScreen` will call `SystemChrome.setEnabledSystemUIMode` on Android/iOS, `document.documentElement.requestFullscreen()` on Web, and the native method channel on desktop. If the platform is not supported, it throws `UnimplementedError` from the platform interface.

**flutter_fullscreen**: Has `supportWeb`, `supportWindowManager`, `supportMobile` static fields, but `ensureInitialized()` throws a string exception if none are true. There's no `isSupported` getter.

**Warning Signs:**
- App crashes on unsupported platforms
- No graceful degradation

**Prevention:**
```dart
// flutter_fullscreen: Check before use
if (FullScreen.supportWindowManager || FullScreen.supportWeb || FullScreen.supportMobile) {
  await FullScreen.ensureInitialized();
} else {
  // Hide fullscreen button or show warning
}

// fullscreen_window: Wrap in try-catch
try {
  await FullScreenWindow.setFullScreen(true);
} on UnimplementedError {
  // Platform not supported
}
```

---

## Pitfall 10: Listener Memory Leaks (flutter_fullscreen)

**Severity:** MEDIUM

**The Problem:**
`flutter_fullscreen` uses an `ObserverList<FullScreenListener>` for event dispatch. Listeners must be manually removed:

```dart
class _MyWidgetState extends State<MyWidget> {
  void initState() {
    super.initState();
    FullScreen.addListener(_listener);  // Added
  }
  
  void dispose() {
    FullScreen.removeListener(_listener);  // Must manually remove!
    super.dispose();
  }
}
```

If you forget `removeListener`, the listener stays in the `ObserverList` and:
1. The widget cannot be garbage collected
2. Callbacks fire on a disposed widget
3. `setState()` called after dispose throws

**fullscreen_window has no listener system**, so this pitfall doesn't apply.

**Warning Signs:**
- "setState() called after dispose" errors
- Memory usage grows over time
- Callbacks fire for widgets that no longer exist

**Prevention:**
```dart
// Always pair addListener/removeListener
late final FullScreenListener _listener;

@override
void initState() {
  super.initState();
  _listener = MyListener();
  FullScreen.addListener(_listener);
}

@override
void dispose() {
  FullScreen.removeListener(_listener);
  super.dispose();
}
```

---

## Pitfall 11: String Exceptions Instead of Typed Errors (flutter_fullscreen)

**Severity:** LOW

**The Problem:**
`flutter_fullscreen` throws raw strings instead of typed exceptions:

```dart
// In full_screen.dart
throw "FullScreen is not initialized. Please await FullScreen.ensureInitialized() first!";

// In full_screen.dart
throw "This platform is not supported.";
```

This makes error handling fragile:
```dart
try {
  FullScreen.setFullScreen(true);
} catch (e) {
  // e is a String, not an Exception
  // Cannot use 'on Exception catch' or 'on PlatformException catch'
  if (e.toString().contains('not initialized')) { ... }
}
```

**fullscreen_window** throws `UnimplementedError` from the platform interface, which is a proper typed exception.

**Warning Signs:**
- `catch (e)` catches strings instead of exceptions
- Cannot use typed catch clauses
- Stack traces may be missing

**Prevention:**
```dart
try {
  FullScreen.setFullScreen(true);
} catch (e) {
  if (e is String) {
    // Handle flutter_fullscreen string errors
  } else if (e is PlatformException) {
    // Handle platform errors
  }
}
```

---

## Pitfall 12: Web Fullscreen API Browser Restrictions

**Severity:** MEDIUM (Web only)

**The Problem:**
Both packages use the browser's Fullscreen API (`requestFullscreen()`), which has strict browser restrictions:

1. **User gesture required**: `requestFullscreen()` must be called from a user-initiated event handler (click, keypress). Calling it from a timer, fetch callback, or `initState` silently fails.
2. **Permission prompt**: Some browsers show "Press Esc to exit fullscreen" overlay on first use.
3. **iframe restrictions**: If the Flutter app runs in an iframe, `allow="fullscreen"` attribute is required.

**fullscreen_window web implementation:**
```dart
// Silently fails if not in user gesture context
web.window.document.documentElement?.requestFullscreen();
```

**flutter_fullscreen web implementation:**
```dart
// Same issue
window.document.documentElement?.requestFullscreen();
```

Neither package checks the returned `Promise` from `requestFullscreen()` for rejection.

**Warning Signs:**
- Fullscreen works on click but not from programmatic trigger
- Browser console shows "Permissions check failed"
- Works in Chrome but not in Safari

**Prevention:**
- Only call fullscreen toggle from direct user gesture handlers (onPressed, onTap)
- Never call from initState, timers, or async callbacks
- Test in Safari (stricter enforcement)

---

## Pitfall 13: `getScreenSize` Platform Differences (fullscreen_window)

**Severity:** LOW

**The Problem:**
`fullscreen_window.getScreenSize()` returns different values per platform:

| Platform | Returns | Notes |
|----------|---------|-------|
| Windows | `GetDesktopWindow()` bounds | Primary monitor only |
| Linux | `gdk_display_get_primary_monitor` geometry | Primary monitor only |
| Android/iOS | `MediaQuery.of(context).size` | Requires BuildContext, returns logical pixels |
| Web | `window.screen.width/height` | Physical pixels, no DPR adjustment |

The Dart method applies `devicePixelRatio` correction only when a `BuildContext` is provided:
```dart
var size = Size(width.toDouble() / devicePixelRatio, height.toDouble() / devicePixelRatio);
```

But on desktop, the native code returns raw pixel counts without DPR consideration.

**Warning Signs:**
- Screen size differs between platforms
- Widget positioning off by DPR factor
- Multi-monitor returns only primary monitor size

**Prevention:**
```dart
// Always provide context for consistent DPR handling
final size = await FullScreenWindow.getScreenSize(context);
// On desktop, manually apply DPR if needed
final dpr = View.of(context).devicePixelRatio;
```

---

## Pitfall 14: Rapid Toggle Race Conditions (BOTH packages)

**Severity:** MEDIUM

**The Problem:**
Both packages can enter inconsistent states when toggling fullscreen rapidly:

**fullscreen_window:**
- Windows: `SetWindowLong` + `SendMessage(SC_MAXIMIZE)` is not atomic. Rapid calls interleave.
- Linux: `gtk_window_fullscreen` / `gtk_window_unfullscreen` may queue and execute out of order.

**flutter_fullscreen:**
- Desktop: `windowManager.setFullScreen(state)` calls are async but the method is void. Multiple rapid calls create race conditions in `window_manager`.
- The `onWindowEnterFullScreen` / `onWindowLeaveFullScreen` callbacks may fire in unexpected order.

**Warning Signs:**
- Window flickers between fullscreen and windowed
- Final state doesn't match last toggle command
- Visual artifacts during rapid toggling

**Prevention:**
```dart
// Debounce or disable button during toggle
bool _isToggling = false;

Future<void> _toggleFullscreen() async {
  if (_isToggling) return;
  _isToggling = true;
  try {
    await FullScreenWindow.setFullScreen(!_isFullscreen);
    setState(() { _isFullscreen = !_isFullscreen; });
  } finally {
    _isToggling = false;
  }
}
```

---

## Pitfall 15: `fullscreen_window` Variable Naming Convention

**Severity:** LOW (Code quality)

**The Problem:**
The package exports a global variable with PascalCase naming:
```dart
final FullScreenWindow = FullScreenWindowPlatform.instance;
```

Dart convention reserves PascalCase for classes and type names. This looks like a class but is actually a variable. Common mistakes:
```dart
// Developer thinks this is a class constructor
FullScreenWindow();  // Error: not a function

// Import confusion
import 'package:fullscreen_window/fullscreen_window.dart';
// 'FullScreenWindow' could be a class or variable -- ambiguous
```

**Prevention:**
- Treat `FullScreenWindow` as a singleton instance, not a class
- Use it only for method calls: `FullScreenWindow.setFullScreen(true)`

---

## Pitfall 16: window_manager Initialization Side Effects (flutter_fullscreen)

**Severity:** MEDIUM

**The Problem:**
`flutter_fullscreen.ensureInitialized()` calls `windowManager.ensureInitialized()` which:
1. Creates a hidden window manager overlay
2. Registers platform-specific window hooks
3. May conflict with other window management plugins (`bitsdojo_window`, `desktop_window`)

If your app uses multiple window management plugins, the initialization order matters and can cause:
- Platform channel conflicts
- Duplicate window event listeners
- Unexpected window behavior

**Warning Signs:**
- Window title bar disappears
- Window resize behavior changes after adding flutter_fullscreen
- Other window plugins stop working

**Prevention:**
- Use only one window management plugin at a time
- If mixing plugins, initialize in a consistent order
- Test window behavior after adding flutter_fullscreen

---

## Quick Reference: Pitfall Matrix

| Pitfall | fullscreen_window | flutter_fullscreen | Severity |
|---------|:-:|:-:|:-:|
| 1. State desync | YES | YES | CRITICAL |
| 2. Missing initialization | NO | YES | HIGH |
| 3. Windows layout glitch | YES | NO | HIGH |
| 4. Global native state | YES | NO | MEDIUM |
| 5. WS_EX_TOPMOST stays | YES | NO | MEDIUM |
| 6. Transitive dependencies | NO | YES | MEDIUM |
| 7. Async vs void confusion | YES | YES | MEDIUM |
| 8. macOS animation | YES | NO | MEDIUM |
| 9. No capability detection | YES | YES | MEDIUM |
| 10. Listener memory leaks | NO | YES | MEDIUM |
| 11. String exceptions | NO | YES | LOW |
| 12. Web browser restrictions | YES | YES | MEDIUM |
| 13. getScreenSize differences | YES | NO | LOW |
| 14. Rapid toggle races | YES | YES | MEDIUM |
| 15. Naming convention | YES | NO | LOW |
| 16. window_manager side effects | NO | YES | MEDIUM |

---

## Recommendations for Demo Project

1. **Wrap all fullscreen calls in try-catch** -- both packages can fail silently
2. **Use listeners with flutter_fullscreen** -- don't rely on optimistic state updates
3. **Debounce toggle button** -- prevent rapid toggle race conditions
4. **Test on all three desktop platforms** -- behavior differs significantly
5. **Check macOS support** -- fullscreen_window may have missing native handler
6. **Add artificial delay after toggle** -- wait for window manager to settle
7. **Handle missing initialization** -- always call ensureInitialized() for flutter_fullscreen

---

*Research based on source code analysis of fullscreen_window 1.2.1 and flutter_fullscreen 1.2.0*
*Sources: pub.dev package pages, local pub cache source files, project CONCERNS.md*
