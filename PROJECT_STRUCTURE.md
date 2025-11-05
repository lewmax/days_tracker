# Project Structure

Complete overview of the DaysTracker codebase.

## Directory Tree

```
country_tracker/
├── lib/
│   ├── core/                          # Core functionality
│   │   ├── constants/
│   │   │   └── app_constants.dart     # App-wide constants
│   │   ├── di/
│   │   │   ├── locator.dart           # DI container setup
│   │   │   └── modules/
│   │   │       └── storage_module.dart # Storage module
│   │   ├── error/
│   │   │   └── failures.dart          # Error classes
│   │   ├── router/
│   │   │   └── app_router.dart        # Navigation config
│   │   └── utils/
│   │       ├── country_utils.dart     # Country code helpers
│   │       └── date_utils.dart        # Date utilities
│   │
│   ├── domain/                        # Business logic layer
│   │   ├── entities/
│   │   │   ├── visit.dart             # Visit entity
│   │   │   ├── location_ping.dart     # Location ping entity
│   │   │   └── visit_summary.dart     # Summary entity
│   │   ├── repositories/
│   │   │   ├── visits_repository.dart      # Visits repo interface
│   │   │   ├── location_repository.dart    # Location repo interface
│   │   │   └── settings_repository.dart    # Settings repo interface
│   │   └── usecases/
│   │       ├── calculate_visit_summary.dart      # Summary calculation
│   │       └── update_visit_from_location.dart   # Visit update logic
│   │
│   ├── data/                          # Data layer
│   │   ├── repositories/
│   │   │   ├── visits_repository_impl.dart    # Visits implementation
│   │   │   ├── location_repository_impl.dart  # Location implementation
│   │   │   └── settings_repository_impl.dart  # Settings implementation
│   │   └── services/
│   │       ├── secure_storage_service.dart    # Encrypted storage
│   │       ├── location_service.dart          # Location tracking
│   │       ├── background_manager.dart        # Background tasks
│   │       └── home_widget_service.dart       # Widget updates
│   │
│   ├── presentation/                  # UI layer
│   │   ├── common/
│   │   │   ├── bloc/
│   │   │   │   ├── bloced_widget.dart         # Base BLoC widget
│   │   │   │   └── bloced_state.dart          # Base BLoC state
│   │   │   └── widgets/
│   │   │       ├── loading_widget.dart        # Loading indicator
│   │   │       └── error_widget.dart          # Error display
│   │   │
│   │   ├── home/
│   │   │   └── home_screen.dart               # Main tab scaffold
│   │   │
│   │   ├── visits/
│   │   │   ├── bloc/
│   │   │   │   ├── visits_bloc.dart
│   │   │   │   ├── visits_event.dart
│   │   │   │   └── visits_state.dart
│   │   │   ├── widgets/
│   │   │   │   ├── visit_item.dart            # Visit list item
│   │   │   │   └── add_visit_dialog.dart      # Add visit form
│   │   │   └── visits_screen.dart             # Visits screen
│   │   │
│   │   ├── summary/
│   │   │   ├── bloc/
│   │   │   │   ├── summary_bloc.dart
│   │   │   │   ├── summary_event.dart
│   │   │   │   └── summary_state.dart
│   │   │   └── summary_screen.dart            # Summary screen
│   │   │
│   │   ├── map/
│   │   │   ├── bloc/
│   │   │   │   ├── map_bloc.dart
│   │   │   │   ├── map_event.dart
│   │   │   │   └── map_state.dart
│   │   │   └── map_screen.dart                # Map screen
│   │   │
│   │   └── settings/
│   │       ├── bloc/
│   │       │   ├── settings_bloc.dart
│   │       │   ├── settings_event.dart
│   │       │   └── settings_state.dart
│   │       └── settings_screen.dart           # Settings screen
│   │
│   ├── l10n/                          # Localization
│   │   ├── app_en.arb                 # English translations
│   │   └── app_uk.arb                 # Ukrainian translations
│   │
│   └── main.dart                      # App entry point
│
├── test/                              # Tests
│   ├── unit/
│   │   ├── usecases/
│   │   │   ├── calculate_visit_summary_test.dart
│   │   │   └── update_visit_from_location_test.dart
│   │   └── utils/
│   │       ├── date_utils_test.dart
│   │       └── country_utils_test.dart
│   ├── widget/                        # Widget tests (add as needed)
│   └── integration/                   # Integration tests (add as needed)
│
├── ios/                               # iOS platform code
│   └── Runner/
│       └── Info.plist.example         # iOS config example
│
├── android/                           # Android platform code
│   └── app/
│       └── src/
│           └── main/
│               └── AndroidManifest.xml.example  # Android config
│
├── assets/                            # Static assets
│   ├── images/                        # Image assets
│   └── mapbox/                        # Mapbox resources
│
├── README.md                          # Main documentation
├── QUICK_START.md                     # Quick setup guide
├── PLATFORM_SETUP.md                  # Platform-specific setup
├── PROJECT_STRUCTURE.md               # This file
├── pubspec.yaml                       # Dependencies
├── analysis_options.yaml              # Linter config
└── l10n.yaml                          # Localization config
```

## Layer Responsibilities

### Core Layer (`lib/core/`)

**Purpose:** Shared functionality used across all layers

- **Constants**: App-wide configuration values
- **DI (Dependency Injection)**: Setup get_it container with injectable
- **Error**: Common error/failure classes
- **Router**: Auto-route navigation configuration
- **Utils**: Helper functions (dates, countries, etc.)

**Key Files:**
- `locator.dart` - DI container initialization
- `app_constants.dart` - Configuration constants
- `app_router.dart` - Navigation routes

### Domain Layer (`lib/domain/`)

**Purpose:** Pure business logic (no Flutter dependencies)

- **Entities**: Core business models (Visit, LocationPing, etc.)
  - Use `freezed` for immutability
  - Contain only business fields and logic
  
- **Repositories**: Abstract interfaces
  - Define contracts for data operations
  - Implemented in data layer
  
- **Use Cases**: Business operations
  - Single responsibility per use case
  - Orchestrate repository calls
  - Contain domain logic

**Key Files:**
- `visit.dart` - Visit entity with freezed
- `visits_repository.dart` - Repository contract
- `calculate_visit_summary.dart` - Summary calculation logic

### Data Layer (`lib/data/`)

**Purpose:** Data access and external service integration

- **Repositories**: Concrete implementations
  - Implement domain repository interfaces
  - Use `@LazySingleton` for DI
  - Handle data persistence
  
- **Services**: External integrations
  - Storage (encrypted)
  - Location tracking
  - Background tasks
  - Widget updates

**Key Files:**
- `visits_repository_impl.dart` - Visit storage implementation
- `secure_storage_service.dart` - Encrypted storage wrapper
- `location_service.dart` - Location tracking logic
- `background_manager.dart` - Background task orchestration

### Presentation Layer (`lib/presentation/`)

**Purpose:** UI and user interaction

- **BLoCs**: State management
  - Event → BLoC → State pattern
  - Use `@injectable` for DI
  - Handle UI logic
  
- **Screens**: Full-screen views
  - Use `@RoutePage()` for routing
  - BlocProvider at root
  - BlocBuilder for reactive UI
  
- **Widgets**: Reusable components
  - Stateless where possible
  - Extracted for reusability

**Key Files:**
- `visits_bloc.dart` - Visits state management
- `visits_screen.dart` - Visits UI
- `home_screen.dart` - Main navigation scaffold

## Data Flow

### Read Operation
```
UI (Screen)
  → BLoC (event)
    → Use Case (business logic)
      → Repository Interface (domain)
        → Repository Implementation (data)
          → Storage Service
  ← BLoC (state)
← UI (rebuild)
```

### Write Operation
```
UI (user action)
  → BLoC (event)
    → Repository (save)
      → Storage Service (encrypt & persist)
    → BLoC (emit new state)
  → UI (rebuild)
```

### Background Location Check
```
OS (trigger)
  → Background Manager
    → Location Service
      → Location Repository (get coordinates)
      → Location Repository (geocode)
      → Update Visit Use Case
        → Visits Repository (save)
          → Storage Service (persist)
```

## Key Patterns

### Dependency Injection
```dart
// 1. Define injectable service
@lazySingleton
class MyService { }

// 2. Inject in consumer
@injectable
class MyBloc {
  final MyService service;
  MyBloc(this.service);
}

// 3. Get from locator
final bloc = locator<MyBloc>();
```

### BLoC Pattern
```dart
// 1. Define events
@freezed
class MyEvent with _$MyEvent {
  const factory MyEvent.load() = Load;
}

// 2. Define states
@freezed
class MyState with _$MyState {
  const factory MyState.loading() = Loading;
  const factory MyState.loaded(Data data) = Loaded;
}

// 3. Implement BLoC
@injectable
class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(MyState.loading()) {
    on<Load>(_onLoad);
  }
}

// 4. Use in UI
BlocBuilder<MyBloc, MyState>(
  builder: (context, state) => state.when(
    loading: () => LoadingWidget(),
    loaded: (data) => DataWidget(data),
  ),
)
```

### Repository Pattern
```dart
// 1. Domain interface
abstract class MyRepository {
  Future<List<Item>> getItems();
}

// 2. Data implementation
@LazySingleton(as: MyRepository)
class MyRepositoryImpl implements MyRepository {
  final StorageService storage;
  
  @override
  Future<List<Item>> getItems() async {
    // Implementation
  }
}
```

## File Naming Conventions

- **Screens**: `*_screen.dart` (e.g., `visits_screen.dart`)
- **BLoCs**: `*_bloc.dart`, `*_event.dart`, `*_state.dart`
- **Repositories**: `*_repository.dart` (interface), `*_repository_impl.dart` (implementation)
- **Services**: `*_service.dart`
- **Use Cases**: Descriptive names (e.g., `calculate_visit_summary.dart`)
- **Entities/Models**: Singular nouns (e.g., `visit.dart`, `location_ping.dart`)
- **Widgets**: Descriptive names (e.g., `visit_item.dart`, `add_visit_dialog.dart`)
- **Tests**: `*_test.dart` matching source file name

## Code Generation

Generated files (should not be edited manually):
- `*.freezed.dart` - Freezed generated code
- `*.g.dart` - JSON serialization
- `locator.config.dart` - Injectable configuration
- `app_router.gr.dart` - Auto-route generated routes
- `app_localizations.dart` - Flutter localization

Regenerate with:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Adding New Features

### Example: Add "Trip" Feature

1. **Domain Layer**
   ```
   lib/domain/entities/trip.dart           # Entity
   lib/domain/repositories/trip_repository.dart  # Interface
   lib/domain/usecases/create_trip.dart    # Use case
   ```

2. **Data Layer**
   ```
   lib/data/repositories/trip_repository_impl.dart  # Implementation
   ```

3. **Presentation Layer**
   ```
   lib/presentation/trips/bloc/trip_bloc.dart     # BLoC
   lib/presentation/trips/bloc/trip_event.dart
   lib/presentation/trips/bloc/trip_state.dart
   lib/presentation/trips/trips_screen.dart       # UI
   ```

4. **Navigation**
   ```
   lib/core/router/app_router.dart         # Add route
   ```

5. **Generate Code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Testing Strategy

- **Unit Tests**: Domain logic (use cases, entities)
- **Widget Tests**: UI components in isolation
- **Integration Tests**: Full feature flows
- **Mock**: External dependencies (repositories, services)

Test file mirrors source structure:
```
lib/domain/usecases/calculate_visit_summary.dart
test/unit/usecases/calculate_visit_summary_test.dart
```

## Next Steps

- Read [README.md](README.md) for full documentation
- Check [QUICK_START.md](QUICK_START.md) for setup
- Review [PLATFORM_SETUP.md](PLATFORM_SETUP.md) for platform details

