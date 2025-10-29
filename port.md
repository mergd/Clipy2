# Port Clipy to Apple Silicon (Universal Binary)

## Overview

Convert Clipy from Intel-only to a Universal Binary supporting both Apple Silicon (arm64) and Intel (x86_64), with macOS 13.0 Ventura as the minimum deployment target. Modernize login item functionality using SMAppService.

## Current State

- Deployment target: macOS 10.10
- No explicit architecture configuration (defaults to Intel only)
- Swift 5.0 with CocoaPods dependencies
- Uses deprecated LoginServiceKit for login items

## Changes Required

### 1. Update Podfile

**File:** `Podfile`

- Change `platform :osx, '10.10'` to `platform :osx, '13.0'`
- Remove `BartyCrouch` (Apple Silicon build issues)
- Remove `LoginServiceKit` (deprecated APIs, replacing with modern SMAppService)
- Optional: Update `SwiftLint` to latest for native arm64 performance

### 2. Update Xcode Project Build Settings

**File:** `Clipy.xcodeproj/project.pbxproj`

Update all build configurations (Debug/Release for both targets):

- Set `MACOSX_DEPLOYMENT_TARGET = 13.0` (4 locations - lines 1075, 1125, 1149, 1177)
- Add `ARCHS = "$(ARCHS_STANDARD)"` to use Apple's standard architectures (arm64 + x86_64)
- Ensure no legacy `VALID_ARCHS` settings (deprecated in modern Xcode)

### 3. Replace LoginServiceKit with SMAppService

**File:** `Clipy/Sources/AppDelegate.swift`

Replace login item functionality:

```swift
// Remove: import LoginServiceKit
// Add: import ServiceManagement (already available in macOS SDK)

// Replace toggleAddingToLoginItems method (lines 154-159):
private func toggleAddingToLoginItems(_ isEnable: Bool) {
    let service = SMAppService.mainApp
    do {
        if isEnable {
            if service.status == .notRegistered {
                try service.register()
            }
        } else {
            if service.status == .enabled {
                try service.unregister()
            }
        }
    } catch {
        print("Failed to \(isEnable ? "register" : "unregister") login item: \(error)")
    }
}
```

**Benefits of SMAppService:**

- Modern macOS 13+ API
- No helper app required
- Simpler implementation
- Future-proof (recommended by Apple)
- Better security and user control

### 4. Update CocoaPods Dependencies

- Run `pod install` after Podfile changes
- All remaining dependencies are arm64-compatible:
  - **Realm 10.7.2** - includes arm64 binaries
  - **RxSwift/RxCocoa 5.x** - pure Swift, automatic arm64 support
  - **Sparkle 1.26.0** - XCFramework with arm64 slice
  - **All other pods** - pure Swift/ObjC, build for arm64 automatically

### 5. Build Configuration

The project will build as a Universal Binary automatically with `ARCHS_STANDARD`, which includes:

- `arm64` - Apple Silicon native
- `x86_64` - Intel native

### 6. Verification

After changes, verify:

- Project builds successfully for both architectures
- App runs natively on Apple Silicon (Activity Monitor shows "Apple" not "Intel")
- Login item functionality works correctly on macOS 13+
- All features work correctly
- File size will be larger (~2x) as it contains both architectures

## Dependency Changes Summary

**Removed:**

- ❌ **BartyCrouch** - Build issues on Apple Silicon
- ❌ **LoginServiceKit** - Deprecated APIs, replaced with SMAppService

**Optional Update:**

- ⬆️ **SwiftLint** - 0.40.3 → latest (native arm64 binary)

**Remaining (all arm64-compatible):**

- ✅ RxSwift, RxCocoa, RxRelay, RxScreeen - Pure Swift
- ✅ Realm, RealmSwift 10.7.2 - Has arm64 binaries
- ✅ Sparkle 1.26.0 - XCFramework with arm64
- ✅ Magnet, KeyHolder, Sauce - Pure Swift
- ✅ PINCache, AEXML, LetsMove - Compatible
- ✅ Quick, Nimble - Test frameworks

## Feasibility Assessment

**Highly Doable** - This is a clean migration because:

1. Swift 5.0 fully supports Apple Silicon
2. All dependencies verified arm64-compatible
3. SMAppService is simpler than LoginServiceKit (no helper app needed)
4. Modern Xcode handles Universal Binary builds automatically
5. Standard AppKit/Cocoa frameworks work identically on both architectures
6. macOS 13.0 still provides good market coverage (2022+)

## macOS Version Impact

**macOS 13.0 Ventura (October 2022) minimum:**

- Covers majority of active Mac users
- All Apple Silicon Macs can run 13.0+
- Enables modern APIs like SMAppService
- Intel Macs from ~2017+ supported
