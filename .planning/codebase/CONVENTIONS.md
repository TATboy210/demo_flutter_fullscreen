# Coding Conventions

**Analysis Date:** 2026-06-29

## Naming Patterns

**Files:**
- Use `snake_case` for all Dart files (Dart convention)
- Single entry point: `lib/main.dart`
- Example: `main.dart`, `fullscreen_demo_page.dart`

**Classes:**
- Use `PascalCase` for all class names
- Public classes: `MyApp`, `FullscreenDemoPage`
- Private state classes: underscore prefix + PascalCase: `_FullscreenDemoPageState`
- Location: `lib/main.dart` (lines 8-83)

**Variables:**
- Instance variables: camelCase with underscore prefix for private: `_isFullscreen`
- Use `const` constructors whenever possible for widgets
- Location: `lib/main.dart` (line 32)

**Functions:**
- Use `camelCase` for all functions
- Private methods: underscore prefix: `_toggleFullscreen()`
- Async methods: return `Future<void>` with `async/await`
- Location: `lib/main.dart` (lines 34-39)

**Booleans:**
- Use descriptive names: `_isFullscreen` (is + noun pattern)
- Location: `lib/main.dart` (line 32)

## Code Style

**Formatting:**
- Default Dart formatter (`dart format`)
- 2-space indentation (standard Dart/Flutter)
- Trailing commas on multi-line widget constructors

**Linting:**
- Uses `flutter_lints` package (version ^6.0.0)
- Config: `analysis_options.yaml` (line 10: `include: package:flutter_lints/flutter.yaml`)
- Default rule set applied (no custom overrides active)
- Run: `flutter analyze`

## Import Organization

**Order:**
1. Flutter SDK imports (`package:flutter/material.dart`)
2. Third-party package imports (`package:fullscreen_window/fullscreen_window.dart`)
3. Local imports (`package:demo_fullscreen/main.dart`)

**Style:**
- Single-line imports only
- No relative imports in lib/ (use package: imports)
- Test files may use relative imports for test utilities

## Widget Architecture

**Stateless vs Stateful:**
- StatelessWidget for simple display: `MyApp` (`lib/main.dart:8`)
- StatefulWidget for interactive state: `FullscreenDemoPage` (`lib/main.dart:24`)

**Constructor Pattern:**
- Always use `const` constructors with `super.key`:
```dart
const MyApp({super.key});
```
- Location: `lib/main.dart` (line 9)

**Build Method:**
- Return widget tree directly (no intermediate variables unless needed for readability)
- Use `Theme.of(context)` for theme access
- Location: `lib/main.dart` (lines 42-82)

## State Management

**Pattern:**
- Direct `setState()` for simple state changes
- Mutation inside `setState()` callback:
```dart
setState(() {
  _isFullscreen = !_isFullscreen;
});
```
- Location: `lib/main.dart` (lines 35-38)

**Async State:**
- `async/await` pattern for async operations
- No error handling on async calls (potential concern)
- Location: `lib/main.dart` (lines 34-39)

## Theming

**Material Design:**
- Material 3 enabled: `useMaterial3: true`
- ColorScheme from seed: `ColorScheme.fromSeed(seedColor: Colors.deepPurple)`
- Theme access: `Theme.of(context).colorScheme`, `Theme.of(context).textTheme`
- Location: `lib/main.dart` (lines 15-18)

## Localization

**Current State:**
- UI strings are in Chinese (中文)
- No internationalization framework detected
- Hardcoded strings in widget tree
- Location: `lib/main.dart` (lines 61, 67, 73)

## Error Handling

**Current State:**
- No explicit error handling in async operations
- No try-catch blocks detected
- Async method `_toggleFullscreen()` lacks error handling
- Location: `lib/main.dart` (lines 34-39)

**Recommended Pattern:**
```dart
Future<void> _toggleFullscreen() async {
  try {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    await FullScreenWindow.setFullScreen(_isFullscreen);
  } catch (e) {
    // Handle error, revert state if needed
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    debugPrint('Fullscreen toggle failed: $e');
  }
}
```

## Comments

**Current State:**
- No inline comments in application code
- Standard Flutter template comments in config files
- No JSDoc/TSDoc style documentation

**When to Comment:**
- Complex business logic
- Non-obvious widget behavior
- Platform-specific workarounds

## Code Quality Checklist

Before marking work complete:
- [ ] Use `const` constructors for all widgets
- [ ] Use `super.key` in constructors (not `Key? key`)
- [ ] Handle errors in async operations
- [ ] Use `Theme.of(context)` for consistent theming
- [ ] Keep widget build methods focused
- [ ] Extract reusable widgets when tree gets deep

---

*Convention analysis: 2026-06-29*
