# Testing Patterns

**Analysis Date:** 2026-06-29

## Test Framework

**Runner:**
- Flutter Test SDK (built-in)
- Config: `pubspec.yaml` dev_dependencies (line 40-41)

**Assertion Library:**
- `flutter_test` package (from Flutter SDK)
- Matchers: `findsOneWidget`, `findsNothing`, `findsWidgets`

**Run Commands:**
```bash
flutter test                    # Run all tests
flutter test --watch            # Watch mode (not built-in, use external watcher)
flutter test --coverage         # Generate coverage report
flutter test test/widget_test.dart  # Run specific test file
```

## Test File Organization

**Location:**
- Test directory: `test/` (separate from lib/)
- Single test file: `test/widget_test.dart`
- Naming: `*_test.dart` suffix

**Structure:**
```
demo_fullscreen/
├── lib/
│   └── main.dart           # Application code
└── test/
    └── widget_test.dart    # Widget tests
```

## Test Structure

**Suite Organization:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_fullscreen/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build
    await tester.pumpWidget(const MyApp());

    // Act
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Assert
    expect(find.text('1'), findsOneWidget);
  });
}
```

**Pattern: AAA (Arrange-Act-Assert):**
1. **Arrange:** Build the widget with `pumpWidget()`
2. **Act:** Interact using `tester.tap()`, `tester.scroll()`, etc.
3. **Assert:** Verify with `expect()` and finders
- Location: `test/widget_test.dart` (lines 14-29)

**Naming Convention:**
- Descriptive test names explaining behavior
- Current: `'Counter increments smoke test'`
- Preferred: `'toggles fullscreen when button is tapped'`

## Widget Testing

**Test Structure:**
- Use `testWidgets()` for widget tests
- WidgetTester provided as parameter
- Async test body with `await`
- Location: `test/widget_test.dart` (line 14)

**Common Finders:**
```dart
find.text('some text')           // Find by text content
find.byIcon(Icons.fullscreen)    // Find by icon
find.byType(ElevatedButton)      // Find by widget type
find.byKey(Key('unique_key'))    // Find by key
```

**Common Matchers:**
```dart
expect(finder, findsOneWidget)   // Exactly one widget
expect(finder, findsNothing)     // No widgets found
expect(finder, findsWidgets)     // One or more widgets
expect(finder, findsNWidgets(2)) // Exactly N widgets
```

## Pumping Widgets

**Basic Pump:**
```dart
await tester.pumpWidget(const MyApp());  // Build and render
await tester.pump();                      // Trigger frame rebuild
await tester.pumpAndSettle();            // Wait for animations to complete
```

**With Duration:**
```dart
await tester.pump(Duration(seconds: 1));  // Advance clock by duration
```

## Mocking

**Current State:**
- No mocking framework detected
- No mock classes defined
- Tests run against real widget implementations

**Recommended for fullscreen_window:**
- Use `mockito` or `mocktail` package
- Create mock for `FullScreenWindow` static methods
- Add to `pubspec.yaml` dev_dependencies:
```yaml
dev_dependencies:
  mocktail: ^1.0.0
```

**Mock Pattern:**
```dart
import 'package:mocktail/mocktail.dart';

class MockFullScreenWindow extends Mock
    implements FullScreenWindow {}

void main() {
  late MockFullScreenWindow mockFullScreen;

  setUp(() {
    mockFullScreen = MockFullScreenWindow();
    when(() => FullScreenWindow.setFullScreen(any()))
        .thenAnswer((_) async {});
  });

  testWidgets('toggles fullscreen', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    verify(() => FullScreenWindow.setFullScreen(true)).called(1);
  });
}
```

## Test Coverage

**Requirements:**
- Minimum 80% coverage (per project rules)
- Current coverage: Not measured (no coverage reports found)

**Generate Coverage:**
```bash
flutter test --coverage              # Generates coverage/lcov.info
genhtml coverage/lcov.info -o coverage/html  # Generate HTML report
open coverage/html/index.html        # View in browser
```

## Test Types

**Unit Tests:**
- Not present in current codebase
- Recommended: Test business logic separately from UI
- Location: `test/unit/` (recommended)

**Widget Tests:**
- Primary test type in current codebase
- Tests widget rendering and interaction
- Location: `test/widget_test.dart`

**Integration Tests:**
- Not present in current codebase
- Recommended for fullscreen toggle flow
- Location: `integration_test/` (recommended)

## Current Test Issues

**Template Test:**
- The existing test (`test/widget_test.dart`) is a leftover from Flutter counter template
- Does NOT test the actual fullscreen functionality
- Tests counter increment (not present in app)
- Should be replaced with fullscreen-specific tests

**Missing Test Coverage:**
- Fullscreen toggle button behavior
- AppBar visibility in fullscreen mode
- Icon changes based on state
- Text label changes based on state
- Async error handling

## Recommended Test Structure

```dart
// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_fullscreen/main.dart';

void main() {
  group('FullscreenDemoPage', () {
    testWidgets('shows window mode by default', (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.text('窗口模式'), findsOneWidget);
      expect(find.text('点击按钮进入全屏'), findsOneWidget);
      expect(find.byIcon(Icons.fullscreen), findsWidgets);
    });

    testWidgets('toggles to fullscreen mode on button tap', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('全屏模式'), findsOneWidget);
      expect(find.byIcon(Icons.fullscreen_exit), findsWidgets);
    });

    testWidgets('hides AppBar in fullscreen mode', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.byType(AppBar), findsNothing);
    });
  });
}
```

---

*Testing analysis: 2026-06-29*
