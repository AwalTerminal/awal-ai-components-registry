# Objective-C Build & Test Commands

## Xcode Build (xcodebuild)

- `xcodebuild build -scheme MyApp` — build the project
- `xcodebuild build -scheme MyApp -configuration Release` — build in release mode
- `xcodebuild clean build -scheme MyApp` — clean and rebuild
- `xcodebuild build -workspace MyApp.xcworkspace -scheme MyApp` — build with workspace (CocoaPods)
- `xcodebuild -showBuildSettings -scheme MyApp` — show build configuration
- `xcodebuild -list` — list available schemes and targets

## Testing

- `xcodebuild test -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 15'` — run unit tests
- `xcodebuild test -scheme MyApp -destination 'platform=macOS'` — run tests on macOS
- `xcodebuild test -scheme MyApp -only-testing:MyAppTests/UserManagerTests` — run specific test class
- `xcodebuild test -scheme MyApp -skip-testing:MyAppTests/SlowTests` — skip specific tests
- `xcodebuild test -scheme MyApp -enableCodeCoverage YES` — run with coverage
- `xcrun xccov view --report Build/Logs/Test/*.xcresult` — view coverage report

## Dependency Management

- `pod install` — install CocoaPods dependencies
- `pod update` — update all pods
- `pod update AFNetworking` — update a specific pod
- `pod outdated` — check for outdated pods
- `pod deintegrate` — remove CocoaPods from project
- `carthage update --platform iOS` — update Carthage dependencies
- `swift package resolve` — resolve SPM dependencies

## Linting and Formatting

- `clang-format -i Sources/**/*.m Sources/**/*.h` — format source files
- `clang-format --dry-run --Werror Sources/**/*.m` — check formatting (CI)
- `oclint Sources/*.m -- -c` — run OCLint static analysis
- `xcodebuild analyze -scheme MyApp` — run Xcode static analyzer

## Debugging and Profiling

- `instruments -t "Time Profiler" -D trace.trace MyApp.app` — profile with Instruments
- `leaks --atExit -- ./MyApp` — check for memory leaks
- `xcrun simctl list` — list available simulators
- `xcrun simctl boot "iPhone 15"` — boot a simulator

## Archive and Distribution

- `xcodebuild archive -scheme MyApp -archivePath build/MyApp.xcarchive` — create archive
- `xcodebuild -exportArchive -archivePath build/MyApp.xcarchive -exportPath build/ -exportOptionsPlist ExportOptions.plist` — export IPA
