# Project Research Summary

> Synthesis of STACK.md, FEATURES.md, ARCHITECTURE.md, and PITFALLS.md research documents.
> Purpose: Guide implementation of a side-by-side comparison test page for two Flutter fullscreen plugins.

---

## Key Findings

### Stack & Identity

- **fullscreen_window 1.2.1**: Federated plugin with native C++ (Windows) and C (Linux). 23.3k downloads, 30 likes, 140 pub points. Unverified publisher, no public source. Apache-2.0.
- **flutter_fullscreen 1.2.0**: Conditional import wrapping `window_manager`. 4.9k downloads, 13 likes, 150 pub points. Verified publisher (j7126.dev), public GitHub. MIT.
- Both are lightweight in API but `flutter_fullscreen` pulls in `window_manager ^0.5.0` transitively, bringing native GTK, screen_retriever, and other platform code.

### Features

- **fullscreen_window**: 2 methods total (`setFullScreen`, `getScreenSize`). No state query, no listeners, no SystemUiMode. Missing macOS support entirely.
- **flutter_fullscreen**: 5 properties + 4 listener callbacks. State query (`isFullScreen`), observer pattern (`FullScreenListener` mixin), SystemUiMode exposure. Full 6-platform coverage.
- **Critical gap in both**: `setFullScreen` returns void/future-void with no success/failure indicator. Neither handles errors from platform calls.

### Architecture

- **fullscreen_window** uses the federated plugin model: pubspec declares per-platform plugin classes, Flutter tooling auto-registers. Native code on Windows (Win32 API manipulation) and Linux (GTK `gtk_window_fullscreen`). Dart-only on Android (SystemChrome) and Web (JS interop). Fire-and-forget state model.
- **flutter_fullscreen** uses conditional import (`dart.library.js_util`): web path uses direct JS interop; desktop/mobile delegates to `window_manager`. Maintains internal state via `WindowListener` observer pattern. Requires `ensureInitialized()` before any API call.
- **Data flow difference**: fullscreen_window is unidirectional (UI -> Dart -> Native -> OS, no feedback). flutter_fullscreen is bidirectional (UI -> Dart -> window_manager -> Native -> OS -> Event -> Listeners -> UI).

### Pitfalls

- **CRITICAL -- State desync (both)**: Both packages can leave UI out of sync with actual window state. fullscreen_window has no feedback path; flutter_fullscreen's void return means no error propagation.
- **HIGH -- Missing init (flutter_fullscreen)**: Forgetting `ensureInitialized()` throws a raw string at runtime.
- **HIGH -- Windows layout glitch (fullscreen_window)**: Known bug where exiting fullscreen breaks Flutter layout. Source code comment admits "sometimes it still has layout issues."
- **MEDIUM -- Global mutable state (fullscreen_window)**: Windows C++ uses a file-scope global struct for saved window state. Breaks with multi-window scenarios.
- **MEDIUM -- Transitive deps (flutter_fullscreen)**: window_manager brings significant native code and potential version conflicts.
- **MEDIUM -- Listener memory leaks (flutter_fullscreen)**: Must manually call `removeListener` in dispose or face setState-after-dispose errors.
- **MEDIUM -- macOS missing handler (fullscreen_window)**: Package lists macOS support but the native implementation file does not exist. Likely throws `MissingPluginException`.
- **MEDIUM -- Rapid toggle races (both)**: Neither package debounces or queues rapid toggle calls.

---

## Implications for Roadmap

### For the Comparison Test Page

1. **Use both packages simultaneously** -- they coexist without channel conflicts (different MethodChannel names). Toggle with one at a time, then test concurrent usage.
2. **Initialize flutter_fullscreen in main()** -- call `await FullScreen.ensureInitialized()` before `runApp()`. fullscreen_window needs no init.
3. **Wrap all fullscreen calls in try-catch** -- both packages can fail silently or throw unexpected errors.
4. **Debounce toggle buttons** -- prevent rapid toggle race conditions on both packages.
5. **Use flutter_fullscreen listeners for state** -- do not rely on optimistic setState. The listener pattern is the only reliable feedback path.
6. **Track state manually for fullscreen_window** -- it provides no `isFullScreen` getter; the app must maintain its own boolean.
7. **Test on Windows specifically** -- fullscreen_window has a known layout glitch after exit. May need `addPostFrameCallback` forced rebuild.
8. **Guard against missing macOS handler** -- fullscreen_window may throw `MissingPluginException` on macOS. Wrap in try-catch with user-visible fallback.
9. **Handle web user-gesture requirement** -- both packages' web implementations silently fail if `requestFullscreen()` is called outside a user gesture handler.
10. **Document "fullscreen" semantics per platform** -- Windows (borderless maximized), Linux (GTK true fullscreen), macOS (separate Space with animation), Web (element fullscreen). They are not equivalent.

### For Production Selection (if ever needed)

- **Minimal deps + simple toggle**: fullscreen_window (but lacks macOS, state query, listeners)
- **Rich state + event listening + full platform coverage**: flutter_fullscreen (but heavier deps, requires init)
- **Neither provides**: error reporting, multi-monitor support, fullscreen mode selection (borderless vs exclusive)

### What NOT To Do

- Do not use `window_manager` directly for just fullscreen -- it is a 300+ API surface window management suite.
- Do not mix both packages in production -- pick one. The demo uses both for comparison only.
- Do not call fullscreen toggle from initState, timers, or async callbacks on web -- browser requires user gesture.

---

## Sources

| Document | Path | Content |
|----------|------|---------|
| STACK.md | `.planning/research/STACK.md` | Package identity, pub.dev metrics, dependencies, platform support, head-to-head comparison |
| FEATURES.md | `.planning/research/FEATURES.md` | Complete API surface, feature matrix, platform implementation analysis, edge cases |
| ARCHITECTURE.md | `.planning/research/ARCHITECTURE.md` | Federated vs conditional import patterns, native code internals, data flow diagrams |
| PITFALLS.md | `.planning/research/PITFALLS.md` | 16 documented pitfalls with severity ratings, code examples, and prevention strategies |
| pub.dev | pub.dev/packages/fullscreen_window, pub.dev/packages/flutter_fullscreen | Package metadata, API docs, changelogs |
| GitHub | github.com/j7126/full_screen | flutter_fullscreen source code |
| Local pub cache | `.dart_tool/package_config.json` resolved paths | Source code analysis of both packages |

---

*Research completed: 2026-06-29*
