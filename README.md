# DaysTracker

A privacy-first, offline Flutter app that tracks how many days you spend in each country and city. All data is stored locally and encrypted.

## Features

- 🌍 **Country & City Tracking**: Automatically track visits to countries and cities
- 🔒 **Privacy First**: All data encrypted and stored locally with `flutter_secure_storage`
- 📍 **Background Tracking**: Hourly location checks in the background (optional)
- 📊 **Summary Statistics**: View days spent per country/city with customizable periods
- 🗺️ **Interactive Map**: Visualize visited locations on Mapbox
- 🏠 **Home Widget**: Quick stats on your home screen
- 🌐 **Offline Support**: Works without internet (uses cached geocoding)
- 🎨 **Clean Architecture**: Domain/Data/Presentation layers with BLoC state management
- 🌍 **Multilingual**: English and Ukrainian support

## Tech Stack

- **Framework**: Flutter 3.0+
- **State Management**: flutter_bloc + freezed
- **Dependency Injection**: get_it + injectable
- **Navigation**: auto_route
- **Storage**: flutter_secure_storage (encrypted) + shared_preferences (settings)
- **Maps**: mapbox_maps_flutter
- **Background**: workmanager (Android)
- **Location**: geolocator + geocoding
- **Localization**: intl + ARB files

## Architecture

This project follows **Clean Architecture** principles:

```
lib/
├── core/
│   ├── constants/        # App-wide constants
│   ├── di/              # Dependency injection setup
│   ├── error/           # Error/failure classes
│   ├── router/          # Navigation configuration
│   └── utils/           # Utility functions
├── domain/
│   ├── entities/        # Business models (Visit, LocationPing)
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business logic use cases
├── data/
│   ├── models/          # Data models (same as entities with freezed)
│   ├── repositories/    # Repository implementations
│   └── services/        # Data services (storage, location, background)
└── presentation/
    ├── common/          # Shared widgets and BLoC utilities
    ├── visits/          # Visits screen + BLoC
    ├── summary/         # Summary screen + BLoC
    ├── map/             # Map screen + BLoC
    └── settings/        # Settings screen + BLoC
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- iOS 12.0+ / Android 5.0+ (API 21+)
- Mapbox account (free tier) for maps

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd country_tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   
   This generates:
   - Freezed models (*.freezed.dart)
   - JSON serialization (*.g.dart)
   - Injectable DI configuration (locator.config.dart)
   - Auto Route navigation (app_router.gr.dart)

4. **Configure Mapbox**
   
   Get your access token from [mapbox.com](https://www.mapbox.com/):
   - Sign up for free account
   - Go to Account → Access Tokens
   - Copy your public token (starts with `pk.`)
   - Enter token in app: Settings → Mapbox Configuration

5. **Platform Setup**

   See [PLATFORM_SETUP.md](PLATFORM_SETUP.md) for detailed instructions.

   **iOS:**
   - Copy required keys from `ios/Runner/Info.plist.example` to `ios/Runner/Info.plist`
   - Enable Background Modes capability in Xcode

   **Android:**
   - Copy required permissions from `android/app/src/main/AndroidManifest.xml.example`
   - Update your `AndroidManifest.xml`

   **Note:** The project uses `mapbox_maps_flutter` (official Mapbox SDK). See [MIGRATION_NOTES.md](MIGRATION_NOTES.md) for details.

6. **Run the app**
   ```bash
   flutter run
   ```

## Code Generation

This project uses code generation for several features. Run this command whenever you:
- Add/modify freezed models
- Add/modify injectable services
- Add/modify auto_route screens

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

For continuous watching during development:
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Configuration

### Background Tracking

The app supports automatic hourly background location tracking:

1. Open app → Settings
2. Toggle "Background Tracking"
3. Grant "Always" location permission when prompted
4. Adjust frequency (15-360 minutes)

**Note:** 
- iOS: Actual frequency depends on system (Background Fetch is not guaranteed)
- Android: Minimum 15 minutes due to WorkManager limitations
- Battery impact increases with higher frequency

### Day Counting Rules

Two methods for counting days:
1. **Any Presence** (default): Count any day you were present for at least 1 hour
2. **Full Day**: Count only days you were present for 24 hours (future feature)

Configure in: Settings → Day Counting Rule

### Data Management

**Export Data:**
- Settings → Export Data
- Saves all visits as encrypted JSON
- Share via any app

**Import Data:**
- Settings → Import Data
- Paste previously exported JSON

**Delete All Data:**
- Settings → Delete All Data
- Permanently removes all visits and location history
- Cannot be undone

## Privacy & Security

### Data Storage

- All location and visit data encrypted with `flutter_secure_storage`
- Uses AES encryption on iOS, Android Keystore on Android
- No data sent to external servers
- No analytics or tracking

### Permissions

**Required:**
- Location (When In Use): For manual location checks
- Location (Always): For background tracking (optional)

**Optional:**
- Notifications (Android 13+): For foreground service notification
- Background App Refresh (iOS): For periodic updates

### Battery Optimization

To minimize battery impact:
- Uses coarse location (±100m accuracy)
- Batches storage writes
- Configurable tracking frequency
- Can be disabled completely

## Background Tracking Implementation

### How It Works

1. **Hourly Check**: App attempts location check every hour (configurable)
2. **Reverse Geocoding**: Converts coordinates to city/country
3. **Visit Management**: 
   - Same location → extends current visit
   - New location → closes current, starts new visit
4. **Persistent Storage**: All changes saved to encrypted storage immediately

### Platform Details

**iOS:**
- Uses Background Fetch + Significant Location Change
- System controls actual frequency
- Limited to 30 seconds execution time
- May be throttled if battery low

**Android:**
- Uses WorkManager for periodic tasks
- Minimum 15-minute interval
- Battery optimization may affect reliability
- Foreground service option for continuous tracking

**Offline Behavior:**
- If no network: stores coordinates with `geocodingPending=true`
- When network available: retries geocoding automatically
- Visit recorded even without city/country info

## Development

### Project Structure

- `lib/domain/`: Pure Dart business logic
- `lib/data/`: Data layer with repository implementations
- `lib/presentation/`: UI screens and BLoCs
- `lib/core/`: Cross-cutting concerns (DI, navigation, constants)

### Adding a New Feature

1. **Domain Layer**: Define entity, repository interface, use case
2. **Data Layer**: Implement repository, add to DI
3. **Presentation Layer**: Create BLoC (events, state, bloc)
4. **UI Layer**: Build screen with BlocBuilder
5. **Navigation**: Add route to `app_router.dart`
6. **Generate Code**: Run build_runner

### Dependency Injection

Uses `get_it` + `injectable`:

```dart
// Register service
@lazySingleton
class MyService {
  // ...
}

// Register repository
@LazySingleton(as: MyRepository)
class MyRepositoryImpl implements MyRepository {
  // ...
}

// Inject in BLoC
@injectable
class MyBloc extends Bloc<MyEvent, MyState> {
  final MyRepository repository;
  
  MyBloc(this.repository) : super(MyState.initial());
}

// Use in UI
final bloc = locator<MyBloc>();
```

### Testing Background Tasks

**iOS Simulator:**
```bash
# Simulate background fetch
Debug → Simulate Background Fetch (Xcode)
```

**Android Emulator:**
```bash
# Force WorkManager execution
adb shell cmd jobscheduler run -f com.example.days_tracker 1

# Check logs
adb logcat | grep "DaysTracker\|WorkManager"
```

**Production Testing:**
- Test on physical device
- Leave app in background for several hours
- Check visit logs in app

## Troubleshooting

### Build Errors

**Error: Missing generated files**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Error: Dependency conflicts**
```bash
flutter pub upgrade
flutter clean
flutter pub get
```

### Location Issues

**Location not updating:**
1. Check permissions granted
2. Enable location services
3. Disable battery optimization (Android)
4. Check Info.plist/AndroidManifest configuration

**Background tracking not working:**
- See [PLATFORM_SETUP.md](PLATFORM_SETUP.md) troubleshooting section
- Check platform-specific logs
- Test on physical device (simulators have limitations)

### Storage Issues

**Data not persisting:**
- Check secure storage initialization
- Review logs for encryption errors
- Try uninstall/reinstall (warning: loses data)

## Known Limitations

### iOS
- Background fetch not guaranteed hourly (system-controlled)
- Low Power Mode disables background work
- Limited background execution time (30 seconds)

### Android
- Minimum 15-minute interval for WorkManager
- Manufacturer battery optimizations may interfere
- Doze mode restricts background work

### General
- Offline geocoding less accurate than online
- City detection depends on Mapbox/device geocoder
- Historical data cannot be edited (by design)

## Roadmap

- [ ] Manual visit editing
- [ ] Visit notes and photos
- [ ] Export to PDF/CSV
- [ ] Multiple devices sync (via encrypted cloud)
- [ ] Visit categories (business/leisure)
- [ ] Notifications for milestones
- [ ] Dark mode enhancements
- [ ] iPad/tablet optimized UI

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Follow existing code style and architecture
4. Add tests for new features
5. Update documentation
6. Submit pull request

## License

[Add your license here]

## Support

For issues, questions, or feature requests:
- Open an issue on GitHub
- Check [PLATFORM_SETUP.md](PLATFORM_SETUP.md) for platform-specific help
- Review troubleshooting section above

## Acknowledgments

- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) for encrypted storage
- [Mapbox](https://www.mapbox.com/) for mapping services
- [mapbox_maps_flutter](https://pub.dev/packages/mapbox_maps_flutter) for Flutter Mapbox SDK
- [workmanager](https://pub.dev/packages/workmanager) for background tasks
- Flutter and Dart teams for excellent framework

---

**Note:** This is a privacy-first application. No telemetry, no analytics, no external data transmission. Your location data stays on your device, encrypted and secure.
