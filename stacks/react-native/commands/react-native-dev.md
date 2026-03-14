# React Native Dev & Build

Run with Expo or React Native CLI:
- `npx expo start` -- start Metro bundler (Expo)
- `npx expo start --clear` -- start with cleared Metro cache
- `npx expo run:ios` -- build and run on iOS simulator
- `npx expo run:android` -- build and run on Android emulator
- `npx react-native run-ios` -- build and run with bare RN (iOS)
- `npx react-native run-android` -- build and run with bare RN (Android)
- `npx react-native start --reset-cache` -- start Metro with cleared cache
- `npx jest` -- run unit and component tests
- `npx jest --coverage` -- run tests with coverage report
- `npx jest --watch` -- run tests in watch mode
- `npx eslint .` -- lint all files
- `tsc --noEmit` -- type-check without emitting
- `npx prettier --check .` -- check formatting
- `npx prettier --write .` -- auto-format all files
- `npx eas build --platform ios` -- build iOS with EAS Build
- `npx eas build --platform android` -- build Android with EAS Build
- `npx eas build --platform all` -- build both platforms
- `npx detox test --configuration ios.sim.debug` -- run Detox E2E tests
