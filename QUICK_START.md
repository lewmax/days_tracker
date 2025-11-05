# Quick Start Guide

Get DaysTracker up and running in 5 minutes!

## Prerequisites Check

```bash
# Check Flutter version
flutter --version  # Should be 3.0.0+

# Check Dart version
dart --version     # Should be 3.0.0+
```

## Setup Steps

### 1. Install Dependencies (1 min)

```bash
cd country_tracker
flutter pub get
```

### 2. Generate Code (2 min)

This generates all the freezed models, DI configuration, and routes:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**What this generates:**
- `*.freezed.dart` - Immutable models with copyWith, equality
- `*.g.dart` - JSON serialization
- `locator.config.dart` - Dependency injection setup
- `app_router.gr.dart` - Navigation routes

### 3. Platform Configuration (2 min)

**iOS:**
```bash
# Copy Info.plist configuration
cat ios/Runner/Info.plist.example

# Add the location permission keys to ios/Runner/Info.plist
# Required keys:
#   - NSLocationWhenInUseUsageDescription
#   - NSLocationAlwaysAndWhenInUseUsageDescription
#   - UIBackgroundModes (location, fetch)
```

**Android:**
```bash
# Copy AndroidManifest configuration
cat android/app/src/main/AndroidManifest.xml.example

# Add the location permissions to android/app/src/main/AndroidManifest.xml
# Required permissions:
#   - ACCESS_FINE_LOCATION
#   - ACCESS_COARSE_LOCATION
#   - ACCESS_BACKGROUND_LOCATION
#   - FOREGROUND_SERVICE
```

### 4. Get Mapbox Token (Optional, 1 min)

1. Go to [mapbox.com](https://www.mapbox.com/) and sign up (free)
2. Copy your public token from dashboard
3. You'll enter this in the app later (Settings → Mapbox Configuration)

**Or skip:** App works without Mapbox token using device geocoding

### 5. Run the App!

```bash
# Connect device or start simulator
flutter devices

# Run
flutter run

# Or for specific device
flutter run -d <device-id>
```

## First Use

1. **Grant Location Permission**
   - App will request "When In Use" permission
   - Grant to use location features

2. **Optional: Configure Mapbox**
   - Open Settings tab
   - Tap "Mapbox Configuration"
   - Paste your token

3. **Optional: Enable Background Tracking**
   - Open Settings tab
   - Toggle "Background Tracking"
   - Grant "Always" location permission
   - Adjust frequency (default: 60 minutes)

4. **Add Your First Visit**
   - Go to Visits tab
   - Tap + button
   - Select country, enter city, dates
   - Or use "Refresh Location" button for automatic detection

## Verify Everything Works

### Test Manual Location
```
1. Open Visits tab
2. Tap location icon in toolbar
3. Wait a few seconds
4. Should show your current location
```

### Test Background Tracking
```
1. Enable in Settings
2. Put app in background
3. Wait 1-2 hours
4. Check Visits tab for new entry
```

### Test Summary
```
1. Go to Summary tab
2. Should show days per country/city
3. Try different time periods (menu icon)
```

### Test Map
```
1. Go to Map tab  
2. Should show map with markers
3. Check legend at bottom
```

## Troubleshooting

### Code Generation Fails
```bash
# Clean and retry
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Location Not Working
- Check permissions granted in Settings app
- Enable Location Services
- Try on physical device (simulator has limitations)

### Background Tracking Not Working
- See detailed troubleshooting in [PLATFORM_SETUP.md](PLATFORM_SETUP.md)
- Test on physical device (required for background)
- Disable battery optimization (Android)

### Build Errors
```bash
# iOS
cd ios && pod install && cd ..
flutter clean
flutter pub get

# Android
cd android && ./gradlew clean && cd ..
flutter clean
flutter pub get
```

## Development Workflow

### Making Changes

1. **Edit code**
   ```bash
   # Edit your files
   ```

2. **Hot reload** (for UI changes)
   ```bash
   # Press 'r' in terminal or use IDE hot reload
   ```

3. **Restart** (for code/logic changes)
   ```bash
   # Press 'R' in terminal or use IDE restart
   ```

4. **Regenerate** (after model/DI changes)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Watching for Changes

For continuous code generation:
```bash
flutter pub run build_runner watch
```

## Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/unit/usecases/calculate_visit_summary_test.dart

# With coverage
flutter test --coverage
```

## What's Next?

- 📖 Read full [README.md](README.md) for detailed documentation
- 🔧 Check [PLATFORM_SETUP.md](PLATFORM_SETUP.md) for platform-specific details
- 🧪 Run tests: `flutter test`
- 🚀 Build release: `flutter build apk` or `flutter build ios`

## Common Commands Reference

```bash
# Development
flutter run                    # Run app
flutter run -d chrome         # Run on web
flutter pub get               # Install dependencies
flutter clean                 # Clean build cache

# Code Generation
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run build_runner watch  # Watch mode

# Testing
flutter test                   # Run all tests
flutter test --coverage       # With coverage

# Building
flutter build apk             # Android APK
flutter build appbundle       # Android App Bundle
flutter build ios             # iOS build
flutter build web             # Web build

# Analysis
flutter analyze               # Lint check
dart format .                 # Format code
```

## Need Help?

1. Check [README.md](README.md) troubleshooting section
2. Review [PLATFORM_SETUP.md](PLATFORM_SETUP.md) for platform issues
3. Check logs: `flutter logs` while app is running
4. Open an issue on GitHub

---

**You're all set!** 🎉 Start tracking your travels with DaysTracker!

