# Flutter Dev & Build

Run with Flutter CLI:
- `flutter run` -- run on connected device/emulator with hot reload
- `flutter run --release` -- run release build on device
- `flutter build apk --release` -- build Android APK
- `flutter build ios --release` -- build iOS (requires Xcode)
- `flutter build appbundle` -- build Android App Bundle for Play Store
- `flutter test` -- run all unit and widget tests
- `flutter test --coverage` -- run tests with lcov coverage report
- `flutter test test/widget_test.dart` -- run a single test file
- `flutter test --update-goldens` -- update golden test snapshots
- `dart analyze` -- run static analysis (zero warnings expected)
- `dart format .` -- format all Dart files
- `dart format --set-exit-if-changed .` -- check formatting in CI
- `flutter pub get` -- install dependencies
- `flutter pub upgrade --major-versions` -- upgrade to latest major versions
- `flutter clean && flutter pub get` -- clean rebuild when dependencies or codegen are stale
- `dart run build_runner build --delete-conflicting-outputs` -- run code generation (freezed, json_serializable)
- `flutter gen-l10n` -- generate localization files from ARB
