# Platform-Specific Setup Guide

This document provides detailed instructions for setting up platform-specific configurations for iOS and Android.

## iOS Setup

### 1. Info.plist Configuration

Copy the required keys from `ios/Runner/Info.plist.example` to your `ios/Runner/Info.plist`:

**Required Location Keys:**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>DaysTracker needs your location to track which countries and cities you visit.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>DaysTracker needs continuous location access to automatically track your visits even when the app is in the background.</string>

<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>fetch</string>
    <string>processing</string>
</array>
```

### 2. Background Fetch Setup

iOS uses Background Fetch and Significant Location Change for background tracking:

- **Background Fetch**: Attempts to wake the app periodically (system-controlled, ~15min minimum)
- **Significant Location Change**: Triggers when user moves significantly (~500m)

**Limitations:**
- iOS may throttle background fetch if battery is low
- Background execution time is limited (30 seconds max)
- System decides when to trigger background tasks based on user behavior

### 3. Testing Background Tracking on iOS

Use Xcode's debugging features:

```bash
# Simulate background fetch
Debug -> Simulate Background Fetch

# Or use command line
xcrun simctl spawn booted log stream --predicate 'subsystem == "your.bundle.id"'
```

### 4. Capabilities in Xcode

Enable these capabilities in Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select Runner target
3. Go to "Signing & Capabilities"
4. Add "Background Modes"
   - ✅ Location updates
   - ✅ Background fetch
   - ✅ Background processing

## Android Setup

### 1. AndroidManifest.xml Configuration

Copy the required permissions from `android/app/src/main/AndroidManifest.xml.example`:

**Required Permissions:**
```xml
<!-- Location permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

<!-- Background work -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

### 2. Android Version Considerations

**Android 10+ (API 29+):**
- Must request `ACCESS_BACKGROUND_LOCATION` separately from fine/coarse location
- User must explicitly grant "Allow all the time" permission
- App should explain why it needs background location

**Android 12+ (API 31+):**
- Must declare `FOREGROUND_SERVICE_LOCATION` for location foreground services
- WorkManager minimum interval is 15 minutes

### 3. Build.gradle Configuration

Update `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### 4. Testing Background Tracking on Android

Use ADB commands to test:

```bash
# Check if WorkManager tasks are scheduled
adb shell dumpsys jobscheduler | grep -A 20 "your.package.name"

# Simulate low battery (which may affect background work)
adb shell dumpsys battery set level 5

# Reset battery
adb shell dumpsys battery reset

# Force background work execution (testing)
adb shell cmd jobscheduler run -f your.package.name 1

# Check logs
adb logcat | grep -i "DaysTracker\|WorkManager\|Location"
```

### 5. Battery Optimization

Android may restrict background work for battery optimization. Users should:

1. Go to Settings → Apps → DaysTracker
2. Battery → Battery optimization
3. Select "Don't optimize"

**Note:** Request this in-app with explanation of why it's needed.

## Mapbox Configuration

### 1. Get Mapbox Access Token

1. Sign up at [mapbox.com](https://www.mapbox.com/)
2. Go to Account → Tokens
3. Create a new token or copy the default public token
4. Token should start with `pk.`

### 2. Configure Token in App

The token can be set in two ways:

**Option 1: Settings Screen (Recommended)**
- Open app → Settings
- Tap "Mapbox Configuration"
- Enter your token
- Token is stored securely

**Option 2: Environment Variable**
- Create `.env` file in project root
- Add: `MAPBOX_ACCESS_TOKEN=pk.your_token_here`
- Token is loaded at build time

### 3. iOS Mapbox Setup

Add your token to `Info.plist`:
```xml
<key>MBXAccessToken</key>
<string>YOUR_MAPBOX_TOKEN_HERE</string>
```

Or set it at runtime (already done in the app).

### 4. Android Mapbox Setup

Add your token to `android/app/src/main/res/values/strings.xml`:
```xml
<resources>
    <string name="mapbox_access_token">YOUR_MAPBOX_TOKEN_HERE</string>
</resources>
```

Or set it at runtime (already done in the app).

**Note**: The app uses `mapbox_maps_flutter` v2.3.0+, which is the official Flutter SDK from Mapbox.

## Home Widget Setup

### iOS Widget Configuration

1. Create widget extension in Xcode:
   ```bash
   File → New → Target → Widget Extension
   ```

2. Name it "DaysTrackerWidget"

3. Use SwiftUI to display stats from UserDefaults:
   ```swift
   let widgetData = UserDefaults(suiteName: "group.your.bundle.id")?.string(forKey: "widget_data")
   ```

### Android Widget Configuration

1. Widget layout defined in `android/app/src/main/res/xml/home_widget_info.xml`
2. Widget updates automatically via HomeWidget plugin
3. No additional configuration needed

## Permissions Flow

### First Launch Flow

1. **Location Permission (When In Use)**
   - Requested on first location check
   - Required for basic functionality

2. **Background Location Permission**
   - Requested when user enables background tracking
   - Explain benefits before requesting

3. **Notification Permission (Android 13+)**
   - Requested for foreground service notification
   - Required to show "tracking in background" notification

### Permission Request Best Practices

- ✅ Explain why before requesting
- ✅ Show clear benefits
- ✅ Allow opting out
- ✅ Provide settings to disable later
- ❌ Don't request all permissions at once
- ❌ Don't request without context

## Troubleshooting

### Background Tracking Not Working (iOS)

1. Check Info.plist has all required keys
2. Verify Background Modes capability is enabled
3. Check console for errors: `log stream --predicate 'subsystem contains "days_tracker"'`
4. Ensure device is not in Low Power Mode
5. Test with device (simulator has limitations)

### Background Tracking Not Working (Android)

1. Check all permissions in AndroidManifest
2. Disable battery optimization for app
3. Check WorkManager logs: `adb logcat | grep WorkManager`
4. Ensure device manufacturer doesn't have aggressive battery management
5. Test on different Android version

### Common Issues

**Issue:** Location not updating in background
**Solution:** 
- iOS: Check Background Modes and permissions
- Android: Disable battery optimization, check manufacturer restrictions

**Issue:** App crashes on background task
**Solution:** 
- Check DI is properly initialized in background isolate
- Ensure storage operations work in background context
- Review logs for specific error

**Issue:** High battery drain
**Solution:**
- Reduce tracking frequency in settings
- Use coarse location instead of fine
- Consider using significant location change only (iOS)

## Platform-Specific Limitations

### iOS Limitations
- Background fetch frequency controlled by system (not guaranteed hourly)
- Limited execution time in background (30 seconds)
- Low Power Mode disables background fetch
- System learns user patterns and optimizes scheduling

### Android Limitations
- Minimum 15-minute interval for periodic work
- Doze mode restricts background work
- Manufacturer-specific battery optimizations may kill background work
- Must use foreground service for reliable continuous tracking

## Recommended Approach

For best results across platforms:

1. **Periodic Background Tasks (Default)**
   - Use WorkManager (Android) / Background Fetch (iOS)
   - Set 60-minute interval (actual interval may vary by system)
   - Low battery impact
   - Less reliable but acceptable for most users

2. **Continuous Tracking (Optional)**
   - Use foreground service (Android) / Always location (iOS)
   - More reliable
   - Higher battery impact
   - Requires user consent and understanding
   - Should be optional feature

## Next Steps

1. ✅ Copy platform configurations from `.example` files
2. ✅ Get Mapbox token and configure in app
3. ✅ Test location permissions flow
4. ✅ Test background tracking on physical device
5. ✅ Monitor battery usage during testing
6. ✅ Adjust tracking frequency based on user feedback

