# Build and Run Instructions

Step-by-step instructions to build and run DaysTracker.

## Prerequisites

Ensure you have:
- ✅ Flutter SDK 3.0.0+ installed
- ✅ Xcode (for iOS) or Android Studio (for Android)
- ✅ Physical device or simulator/emulator
- ✅ Mapbox account (optional, for maps)

## Quick Build & Run

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Run on connected device
flutter run
```

## Detailed Steps

### Step 1: Setup Environment

```bash
# Navigate to project
cd country_tracker

# Verify Flutter installation
flutter doctor -v

# Install dependencies
flutter pub get
```

### Step 2: Generate Required Code

The project uses code generation for:
- Freezed models (immutable classes)
- JSON serialization
- Dependency injection
- Auto-route navigation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Expected output:**
```
[INFO] Generating build script completed, took 303ms
[INFO] Creating build script snapshot... completed, took 8.2s
[INFO] Building new asset graph completed, took 894ms
[INFO] Checking for unexpected pre-existing outputs completed, took 1ms
[INFO] Running build completed, took 15.3s
[INFO] Caching finalized dependency graph completed, took 45ms
[INFO] Succeeded after 15.4s with 156 outputs
```

### Step 3: Platform Configuration

#### iOS Setup

1. **Configure Info.plist:**
   ```bash
   # Open iOS project
   open ios/Runner.xcworkspace
   ```

2. **Add location permissions** to `ios/Runner/Info.plist`:
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>DaysTracker needs your location to track visits</string>
   
   <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
   <string>DaysTracker needs continuous access for background tracking</string>
   
   <key>UIBackgroundModes</key>
   <array>
       <string>location</string>
       <string>fetch</string>
   </array>
   ```

3. **Enable capabilities in Xcode:**
   - Target: Runner
   - Signing & Capabilities
   - Add "Background Modes"
   - Check: Location updates, Background fetch

#### Android Setup

1. **Add permissions** to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
   <uses-permission android:name="android.permission.INTERNET" />
   ```

2. **Update minSdkVersion** in `android/app/build.gradle`:
   ```gradle
   defaultConfig {
       minSdkVersion 21
       targetSdkVersion 34
   }
   ```

### Step 4: Run the App

#### Option A: Using Command Line

```bash
# List available devices
flutter devices

# Run on first available device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run in release mode
flutter run --release
```

#### Option B: Using IDE

**VS Code:**
1. Open project in VS Code
2. Press F5 or click "Run and Debug"
3. Select device from bottom-right corner

**Android Studio:**
1. Open project
2. Select device from device dropdown
3. Click Run button (green play icon)

**Xcode:**
1. Open `ios/Runner.xcworkspace`
2. Select device/simulator
3. Click Run button

### Step 5: First Launch Setup

On first launch:

1. **Grant Location Permission**
   - Tap "Allow While Using App"
   - For background tracking: "Allow Always" (later in Settings)

2. **Configure Mapbox (Optional)**
   - Go to Settings tab
   - Tap "Mapbox Configuration"
   - Enter your token from [mapbox.com](https://www.mapbox.com/)

3. **Test Basic Functionality**
   - Tap location icon in Visits tab
   - Should detect your current location
   - Add a manual visit using + button

## Building for Release

### Android APK

```bash
# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)

```bash
# Build app bundle
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

**Before building:**
1. Create signing key:
   ```bash
   keytool -genkey -v -keystore ~/my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
   ```

2. Create `android/key.properties`:
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=my-key-alias
   storeFile=/path/to/my-release-key.jks
   ```

3. Update `android/app/build.gradle`:
   ```gradle
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }
   
   android {
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

### iOS IPA

```bash
# Build iOS
flutter build ios --release

# Or build and archive in Xcode
open ios/Runner.xcworkspace
# Product → Archive → Distribute App
```

**Before building:**
1. Configure signing in Xcode
2. Select team and provisioning profile
3. Bump version in `pubspec.yaml` and Xcode

### Web

```bash
# Build web
flutter build web --release

# Output: build/web/
```

## Development Builds

### Debug Mode (Default)

```bash
flutter run
```

Features:
- Hot reload (press 'r')
- Hot restart (press 'R')
- DevTools
- Debug logging

### Profile Mode

```bash
flutter run --profile
```

Features:
- Performance monitoring
- Some optimizations
- DevTools

### Release Mode

```bash
flutter run --release
```

Features:
- Full optimizations
- No debugging
- Smallest size
- Best performance

## Troubleshooting Builds

### iOS Build Issues

**Error: CocoaPods not installed**
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

**Error: Signing certificate issues**
- Open Xcode
- Select Runner target
- Go to Signing & Capabilities
- Select your team

**Error: Module not found**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

### Android Build Issues

**Error: Gradle sync failed**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Error: SDK not found**
- Open Android Studio
- Tools → SDK Manager
- Install Android SDK
- Set ANDROID_HOME environment variable

**Error: minSdkVersion mismatch**
- Update `android/app/build.gradle`
- Set `minSdkVersion 21` or higher

### Code Generation Issues

**Error: Conflicting outputs**
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

**Error: Missing generated files**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Common Build Errors

**Error: `Unable to find bundled Java version`**
```bash
# Set JAVA_HOME to bundled JDK
export JAVA_HOME=/Applications/Android\ Studio.app/Contents/jbr/Contents/Home
```

**Error: `flutter: command not found`**
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"
```

**Error: `Waiting for another flutter command to release the startup lock`**
```bash
rm -rf /path/to/flutter/bin/cache/lockfile
```

## Performance Optimization

### Reduce App Size

```bash
# Split APKs by ABI
flutter build apk --split-per-abi

# Output:
# - app-armeabi-v7a-release.apk
# - app-arm64-v8a-release.apk
# - app-x86_64-release.apk
```

### Enable R8 (Android)

In `android/gradle.properties`:
```properties
android.enableR8=true
```

### Tree Shaking (iOS)

Already enabled in release builds.

## Testing Builds

### Run Tests

```bash
# All tests
flutter test

# Specific test
flutter test test/unit/usecases/calculate_visit_summary_test.dart

# With coverage
flutter test --coverage

# Integration tests
flutter test integration_test/
```

### Test on Real Devices

**iOS:**
```bash
# Install on connected device
flutter install -d <device-id>

# View logs
flutter logs
```

**Android:**
```bash
# Install APK
flutter install -d <device-id>

# Or manually
adb install build/app/outputs/flutter-apk/app-release.apk

# View logs
flutter logs
# Or
adb logcat | grep flutter
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: Build and Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter pub run build_runner build --delete-conflicting-outputs
      - run: flutter test
      - run: flutter build apk --release
```

## Next Steps

After successful build:
1. ✅ Test all features on device
2. ✅ Enable background tracking and test overnight
3. ✅ Check battery usage
4. ✅ Test with airplane mode (offline)
5. ✅ Test data export/import
6. ✅ Prepare for distribution

## Distribution

### Android - Google Play Store
1. Build app bundle: `flutter build appbundle`
2. Create Play Store listing
3. Upload AAB file
4. Complete store listing (screenshots, description)
5. Submit for review

### iOS - App Store
1. Build in Xcode: Product → Archive
2. Open Organizer
3. Distribute App → App Store Connect
4. Create App Store listing in App Store Connect
5. Submit for review

### Direct Distribution
- **Android**: Share APK file directly
- **iOS**: Use TestFlight for beta testing

## Support

For build issues:
- Check [README.md](README.md) troubleshooting section
- Review Flutter documentation
- Check platform-specific guides (iOS/Android)

---

**Ready to ship!** 🚀

