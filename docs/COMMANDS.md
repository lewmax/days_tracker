# Flutter Project Commands
Run from project root. Use `fvm` for Flutter/Dart.

## FVM
| Install & use Flutter | `fvm install 3.38.0 && fvm use 3.38.0` |
## Packages
| Dependencies | `fvm flutter pub get` |
| Check outdated | `fvm flutter pub outdated` |
| Upgrade | `fvm flutter pub upgrade` |
| Repair pub cache | `fvm dart pub cache repair` |
## Utilities
| Flutter doctor | `fvm flutter doctor -v` |
| List devices | `fvm flutter devices` |
| Take screenshot | `fvm flutter screenshot` |
## Clean
| Clean + get | `fvm flutter clean && fvm flutter pub get` |
| Full (incl. iOS) | `fvm flutter clean && cd ios && rm -rf Pods Podfile.lock .symlinks && cd .. && fvm flutter pub get && cd ios && pod install --repo-update && cd ..` |
## Code Generation
| Generate | `fvm flutter pub run build_runner watch -d` |
| Clear build_runner cache | `fvm dart run build_runner clean` |
## Building
| Run app (uat) | `fvm flutter run --flavor uat --dart-define=environment=uat` |
| Android AAB (Play Store) | `fvm flutter build appbundle --flavor prod --dart-define=environment=prod --release` |

## Localization
| Generate from `lib/l10n/*.arb` | `fvm flutter gen-l10n` |
## Assets & Splash
| Regenerate app icons | `fvm dart run flutter_launcher_icons` |
| Regenerate splash | `fvm dart run flutter_native_splash:create` |

## Analyze & lint
| Analyze | `fvm dart analyze` |
| Custom lint | `fvm dart run custom_lint` |
| Auto-fix issues | `fvm dart fix --apply` |
| Format (lib, excl. generated) | `find lib -name "*.dart" -not -path "lib/generated/*" -not -name "*.freezed.dart" -not -name "*.g.dart" -not -name "*.config.dart" -not -name "*.gen.dart" -not -name "*.gr.dart" -print0 \| xargs -0 fvm dart format --line-length=100` |

## Scripts
| **build_all** — Android + iOS | `fvm dart run scripts/build_all.dart uat --upload` |
| **build_android** — APK, optional Firebase upload | `fvm dart run scripts/build_android.dart uat --upload` |
| **build_ios** — IPA, optional TestFlight upload | `fvm dart run scripts/build_ios.dart uat --upload` |
| **fix_bundle_ids** — Set/restore iOS bundle ID | `fvm dart run scripts/fix_bundle_ids.dart uat` |

| **lint_report** — Custom lint report | `fvm dart run scripts/lint_report.dart` |
| **check_package_updates** — Outdated packages + changelogs | `fvm dart run scripts/check_package_updates.dart` |
| **create_env_files** — Create .dev.env, .uat.env, .prod.env templates | `fvm dart run scripts/create_env_files.dart` |
| **pre_commit** — Format, analyze, lint | `fvm dart run scripts/pre_commit.dart` |
| **version_bump** — Bump version (major/minor/patch) | `fvm dart run scripts/version_bump.dart patch` |

## Global Tools
| FlutterFire CLI | `dart pub global activate flutterfire_cli` |
| FlutterFire configure | `flutterfire configure` (requires `firebase-tools`: `npm install -g firebase-tools`) |
| FVM | `dart pub global activate fvm` |
| DevTools | `fvm flutter pub global activate devtools` |
| Run DevTools | `dart run devtools` |
