# Objective-C Build & Test

Run with xcodebuild or xctool:
- `xcodebuild build -scheme MyApp` — build the project
- `xcodebuild test -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 15'` — run tests
- `xcodebuild clean build` — clean and rebuild
- `pod install` — install CocoaPods dependencies
- `pod update` — update dependencies
- `clang-format -i Sources/**/*.m` — format source files
- `xcodebuild -showBuildSettings` — show current build configuration
