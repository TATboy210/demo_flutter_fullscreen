# Technology Stack

**Analysis Date:** 2026-06-29

## Languages

**Primary:**
- Dart >=3.12.2 <4.0.0 - Application logic, UI, state management

**Secondary:**
- C++17 - Windows native runner (`windows/runner/main.cpp`, `windows/runner/flutter_window.cpp`)
- C++14 - Linux native runner (`linux/runner/main.cc`, `linux/runner/my_application.cc`)
- Swift - macOS native runner (`macos/Runner/AppDelegate.swift`, `macos/Runner/MainFlutterWindow.swift`)
- CMake - Build system for Windows and Linux platforms

## Runtime

**Environment:**
- Dart SDK ^3.12.2
- Flutter SDK >=3.18.0-18.0.pre.54 (stable channel)

**Package Manager:**
- pub (Dart built-in)
- Lockfile: `pubspec.lock` (present)

## Frameworks

**Core:**
- Flutter - UI framework for cross-platform application
- Material Design 3 - UI component library (enabled via `useMaterial3: true`)
- ColorScheme.fromSeed - Dynamic theming with seed color `Colors.deepPurple`

**Testing:**
- flutter_test (SDK) - Widget and unit testing framework

**Build/Dev:**
- flutter_lints ^6.0.0 - Linting rules for Flutter projects
- CMake 3.14+ - Windows/Linux native build system
- Xcode - macOS native build system

## Key Dependencies

**Critical:**
- fullscreen_window ^1.2.1 - Native fullscreen window control (the core dependency for this demo)
  - pub.dev: https://pub.dev/packages/fullscreen_window
  - Provides `FullScreenWindow.setFullScreen(bool)` API
  - Native plugin with platform implementations for Windows, Linux, macOS

**Infrastructure:**
- cupertino_icons ^1.0.8 - iOS-style icon font (used for fullscreen/exit icons)

## Transitive Dependencies

The following packages are pulled in transitively by Flutter SDK and fullscreen_window:
- async, characters, clock, collection, meta, path, vector_math - Core Dart utilities
- leak_tracker, leak_tracker_flutter_testing, leak_tracker_testing, vm_service - Flutter testing infrastructure
- plugin_platform_interface - Plugin federation interface
- flutter_web_plugins - Web plugin support (transitive, not actively used)
- web - Dart web interop

## Configuration

**Environment:**
- No `.env` files present
- No environment variables required
- No API keys or secrets needed

**Build:**
- `pubspec.yaml` - Dart/Flutter package configuration
- `analysis_options.yaml` - Dart analyzer configuration (uses `package:flutter_lints/flutter.yaml`)
- `windows/CMakeLists.txt` - Windows build configuration (C++17, Unicode enabled)
- `linux/CMakeLists.txt` - Linux build configuration (C++14, GTK 3.0 required)
- `macos/Runner.xcodeproj/` - macOS Xcode project configuration

**Project Metadata:**
- `.metadata` - Flutter tool metadata (project_type: app, stable channel)

## Platform Requirements

**Development:**
- Flutter SDK >=3.18.0
- Dart SDK >=3.12.2
- For Windows: Visual Studio with C++ workload, CMake 3.14+
- For Linux: GTK 3.0 development libraries, CMake 3.13+, pkg-config
- For macOS: Xcode, macOS deployment target as configured

**Production:**
- Desktop application (Windows, Linux, macOS)
- No web or mobile platform targets configured
- Application ID: `com.example.demo_fullscreen`

## Build Commands

```bash
flutter pub get                    # Install dependencies
flutter run                        # Run in debug mode
flutter build windows              # Build for Windows
flutter build linux                # Build for Linux
flutter build macos                # Build for macOS
flutter test                       # Run tests
flutter analyze                    # Run static analysis
```

---

*Stack analysis: 2026-06-29*
