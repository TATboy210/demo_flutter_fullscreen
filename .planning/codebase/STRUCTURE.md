# Codebase Structure

**Analysis Date:** 2026-06-29

## Directory Layout

```
demo_fullscreen/
├── lib/
│   └── main.dart              # Entire Dart application (single file)
├── test/
│   └── widget_test.dart       # Placeholder widget test (stale, tests nonexistent counter)
├── windows/
│   ├── runner/
│   │   ├── main.cpp           # Windows native entry point (wWinMain)
│   │   ├── flutter_window.cpp # Flutter engine window wrapper
│   │   ├── flutter_window.h
│   │   ├── win32_window.cpp   # Win32 window base class
│   │   ├── win32_window.h
│   │   ├── utils.cpp          # Console attach helper
│   │   ├── utils.h
│   │   ├── resource.h         # Win32 resource IDs
│   │   ├── runner.exe.manifest
│   │   ├── Runner.rc          # Windows resource file
│   │   └── resources/
│   │       └── app_icon.ico   # Application icon
│   ├── flutter/
│   │   ├── CMakeLists.txt     # Flutter engine CMake config
│   │   ├── generated_plugin_registrant.cc
│   │   ├── generated_plugin_registrant.h
│   │   └── generated_plugins.cmake
│   └── CMakeLists.txt         # Windows build configuration
├── linux/
│   ├── runner/
│   │   ├── main.cc            # Linux native entry point
│   │   ├── my_application.cc  # GTK application implementation
│   │   └── my_application.h
│   ├── flutter/
│   │   ├── CMakeLists.txt
│   │   ├── generated_plugin_registrant.cc
│   │   ├── generated_plugin_registrant.h
│   │   └── generated_plugins.cmake
│   └── CMakeLists.txt         # Linux build configuration
├── macos/
│   ├── Runner/
│   │   ├── AppDelegate.swift          # macOS app delegate
│   │   ├── MainFlutterWindow.swift    # macOS Flutter window
│   │   ├── Info.plist
│   │   ├── DebugProfile.entitlements
│   │   ├── Release.entitlements
│   │   ├── Assets.xcassets/           # App icons (16px-1024px)
│   │   ├── Base.lproj/
│   │   │   └── MainMenu.xib
│   │   └── Configs/
│   │       ├── AppInfo.xcconfig
│   │       ├── Debug.xcconfig
│   │       ├── Release.xcconfig
│   │       └── Warnings.xcconfig
│   ├── Runner.xcodeproj/
│   ├── Runner.xcworkspace/
│   ├── RunnerTests/
│   │   └── RunnerTests.swift
│   └── Flutter/
│       ├── Flutter-Debug.xcconfig
│       ├── Flutter-Release.xcconfig
│       ├── GeneratedPluginRegistrant.swift
│       └── ephemeral/
├── .dart_tool/
│   ├── package_config.json    # Resolved package dependencies
│   ├── package_graph.json
│   └── version
├── .idea/                     # IntelliJ/Android Studio project config
│   ├── libraries/
│   ├── modules.xml
│   ├── runConfigurations/
│   └── workspace.xml
├── .planning/
│   └── codebase/              # GSD analysis documents
├── pubspec.yaml               # Package manifest and dependencies
├── pubspec.lock               # Locked dependency versions
├── analysis_options.yaml      # Dart analyzer and linter config
├── .flutter-plugins-dependencies  # Generated plugin registry
├── .metadata                  # Flutter tool metadata
├── .gitignore
├── README.md                  # Default Flutter project README
└── demo_fullscreen.iml        # IntelliJ module file
```

## Directory Purposes

**`lib/`:**
- Purpose: Dart source code for the Flutter application
- Contains: All application logic and UI code
- Key files: `lib/main.dart` (sole Dart file)

**`test/`:**
- Purpose: Dart widget and unit tests
- Contains: Flutter widget test files
- Key files: `test/widget_test.dart` (currently stale/placeholder)

**`windows/`:**
- Purpose: Windows platform host application
- Contains: Win32 C++ runner code, CMake build files, Flutter engine integration
- Key files: `windows/runner/main.cpp` (entry), `windows/runner/flutter_window.cpp` (engine wrapper)

**`linux/`:**
- Purpose: Linux platform host application
- Contains: GTK C runner code, CMake build files
- Key files: `linux/runner/main.cc` (entry), `linux/runner/my_application.cc` (GTK app)

**`macos/`:**
- Purpose: macOS platform host application
- Contains: Swift/Xcode project, entitlements, asset catalogs
- Key files: `macos/Runner/AppDelegate.swift` (entry), `macos/Runner/MainFlutterWindow.swift`

**`.dart_tool/`:**
- Purpose: Flutter/Dart toolchain generated files
- Contains: Package resolution results
- Generated: Yes
- Committed: No (in `.gitignore`)

**`.planning/`:**
- Purpose: GSD workflow analysis documents and planning artifacts
- Contains: Codebase analysis markdown files
- Generated: Yes (by GSD agents)
- Committed: Yes (for team reference)

## Key File Locations

**Entry Points:**
- `lib/main.dart`: Dart `main()` — Flutter app entry, calls `runApp()`
- `windows/runner/main.cpp`: Windows `wWinMain` — native process entry
- `linux/runner/main.cc`: Linux `main()` — GTK app entry
- `macos/Runner/AppDelegate.swift`: macOS `AppDelegate` — NSApplication delegate

**Configuration:**
- `pubspec.yaml`: Dependencies, Flutter SDK constraints, asset declarations
- `analysis_options.yaml`: Dart linter rules (uses `package:flutter_lints/flutter.yaml`)
- `.metadata`: Flutter tool version tracking (auto-generated)

**Core Logic:**
- `lib/main.dart`: Entire application — `MyApp` widget, `FullscreenDemoPage` widget, fullscreen toggle

**Testing:**
- `test/widget_test.dart`: Widget test (currently tests nonexistent counter UI)

**Build System:**
- `windows/CMakeLists.txt`: Windows build configuration
- `linux/CMakeLists.txt`: Linux build configuration
- `macos/Runner.xcodeproj/project.pbxproj`: Xcode project for macOS

## Naming Conventions

**Files:**
- Dart files: `snake_case.dart` (standard Flutter convention)
- C++ files: `snake_case.cpp` / `snake_case.h`
- Swift files: `PascalCase.swift` (class-named)
- Config files: lowercase with extensions (`.yaml`, `.plist`, `.xcconfig`)

**Directories:**
- `lib/`, `test/`: lowercase (Flutter standard)
- `Runner/`, `RunnerTests/`: PascalCase (Xcode convention)
- `runner/`: lowercase (CMake convention for Windows/Linux)

**Classes:**
- `PascalCase`: `MyApp`, `FullscreenDemoPage`, `FlutterWindow`, `Win32Window`

**State fields:**
- `_camelCase` with underscore prefix for private: `_isFullscreen`

## Where to Add New Code

**New Feature (Dart):**
- Primary code: `lib/main.dart` (currently the only Dart file; for any non-trivial feature, create `lib/features/<feature_name>/`)
- Tests: `test/` directory, file named `<feature>_test.dart`

**New Screen/Page:**
- Create: `lib/pages/<page_name>.dart` or `lib/screens/<screen_name>.dart`
- Register in: `lib/main.dart` (add route or replace `home:` in `MaterialApp`)

**New Utility/Service:**
- Create: `lib/utils/<utility_name>.dart` or `lib/services/<service_name>.dart`

**New Widget:**
- Create: `lib/widgets/<widget_name>.dart`

**Platform-Specific Code:**
- Windows: `windows/runner/` (C++)
- Linux: `linux/runner/` (C)
- macOS: `macos/Runner/` (Swift)

## Special Directories

**`.dart_tool/`:**
- Purpose: Dart toolchain cache and package resolution
- Generated: Yes (by `flutter pub get`)
- Committed: No

**`.idea/`:**
- Purpose: JetBrains IDE project settings
- Generated: Yes (by IntelliJ/Android Studio)
- Committed: Typically no (check `.gitignore`)

**`.planning/`:**
- Purpose: GSD workflow documents (architecture, conventions, concerns, etc.)
- Generated: Yes (by GSD analysis agents)
- Committed: Yes

**`linux/flutter/`, `windows/flutter/`, `macos/Flutter/ephemeral/`:**
- Purpose: Flutter engine integration files, plugin registrants
- Generated: Yes (by Flutter tooling)
- Committed: Partially (generated plugin registrants are committed; ephemeral files are not)

---

*Structure analysis: 2026-06-29*
