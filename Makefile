.PHONY: run clean format watch_build build start

run:
    fvm flutter run

clean:
    fvm flutter clean
    rm -rf ios/.symlinks ios/Pods ios/Podfile.lock
    fvm flutter pub get
    cd ios && pod install --repo-update || pod install

format:
    fvm dart format . --line-length=100

watch_build:
    fvm flutter pub run build_runner watch --delete-conflicting-outputs

build:
    fvm flutter pub run build_runner build --delete-conflicting-outputs

localization:
    fvm dart run umc_localization:generate --domain nj.betinia.com --version v3 --mainLang en

start:
    $(MAKE) clean
    $(MAKE) run

mcps:
    npx -y @penpot/mcp@latest