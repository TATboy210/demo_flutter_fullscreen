# External Integrations

**Analysis Date:** 2026-06-29

## APIs & External Services

**None detected.**

This is a standalone demo application with no external API calls, HTTP clients, or third-party service integrations. The app operates entirely offline using local platform APIs.

## Data Storage

**Databases:**
- None - No database connections, ORM configurations, or data persistence layer

**File Storage:**
- Local filesystem only - No cloud storage integrations

**Caching:**
- None - No caching layer implemented

## Authentication & Identity

**Auth Provider:**
- None - No authentication system implemented

## Monitoring & Observability

**Error Tracking:**
- None - No error tracking services (Sentry, Crashlytics, etc.)

**Logs:**
- Standard Flutter debug console output only

## CI/CD & Deployment

**Hosting:**
- Desktop application - Runs locally on user's machine
- No cloud deployment configured

**CI Pipeline:**
- None detected - No `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, or similar CI configuration files

## Native Platform Integrations

**fullscreen_window plugin (v1.2.1):**
- Purpose: Controls native window fullscreen state across desktop platforms
- Platform implementations:
  - **Windows:** Native Win32 API integration via C++ plugin (`windows/runner/flutter_window.cpp`)
  - **Linux:** GTK-based implementation (`linux/runner/`)
  - **macOS:** Cocoa/AppKit implementation (`macos/Runner/`)
- API: `FullScreenWindow.setFullScreen(bool)` - Toggles fullscreen mode
- Registration:
  - Windows: `windows/flutter/generated_plugin_registrant.cc`
  - Linux: `linux/flutter/generated_plugin_registrant.cc`
  - macOS: `macos/Flutter/GeneratedPluginRegistrant.swift` (empty - plugin not registered for macOS)

## Environment Configuration

**Required env vars:**
- None - No environment variables required

**Secrets location:**
- None - No secrets or credentials needed

## Webhooks & Callbacks

**Incoming:**
- None

**Outgoing:**
- None

## Third-Party Packages Summary

| Package | Version | Type | Purpose |
|---------|---------|------|---------|
| fullscreen_window | ^1.2.1 | Direct | Native fullscreen window control |
| cupertino_icons | ^1.0.8 | Direct | iOS-style icon font |
| flutter_lints | ^6.0.0 | Dev | Static analysis rules |

## Platform-Specific Dependencies

**Windows:**
- Win32 API (via fullscreen_window plugin)
- CMake 3.14+
- Visual Studio C++ toolchain

**Linux:**
- GTK 3.0 (via `pkg_check_modules`)
- CMake 3.13+
- pkg-config

**macOS:**
- Cocoa/AppKit frameworks
- Xcode build tools

---

*Integration audit: 2026-06-29*
