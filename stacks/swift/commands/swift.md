# Swift Commands

## Build

- `swift build` -- debug build
- `swift build -c release` -- optimized release build
- `swift build --arch arm64 --arch x86_64` -- universal binary (macOS)
- `swift build -Xswiftc -strict-concurrency=complete` -- with strict concurrency

## Test

- `swift test` -- run all tests
- `swift test --filter TestSuiteName` -- run specific suite
- `swift test --filter TestSuiteName/testMethodName` -- run single test
- `swift test --enable-code-coverage` -- generate coverage data
- `swift test --parallel` -- run tests in parallel

## Coverage

- `xcrun llvm-cov report .build/debug/YourPackageTests.xctest/Contents/MacOS/YourPackageTests --instr-profile .build/debug/codecov/default.profdata` -- summary
- `xcrun llvm-cov export ... --format lcov > coverage.lcov` -- export to lcov

## Package Management

- `swift package init --type library` -- new library package
- `swift package init --type executable` -- new executable package
- `swift package resolve` -- fetch/update dependencies
- `swift package update` -- update to latest allowed versions
- `swift package show-dependencies` -- dependency tree

## Lint / Format

- `swift-format format --in-place --recursive Sources/` -- format all source files
- `swift-format lint --recursive Sources/` -- check formatting without modifying

## Xcode

- `swift package generate-xcodeproj` -- generate Xcode project (legacy)
- `xcodebuild -scheme MyScheme -destination 'platform=macOS' build` -- build via xcodebuild
- `xcodebuild test -scheme MyScheme -destination 'platform=macOS'` -- test via xcodebuild
- `open Package.swift` -- open SwiftPM package in Xcode directly

## Diagnostics

- `swift package diagnose-api-breaking-changes <baseline>` -- check API stability
- `swift -print-target-info` -- show target triple and platform info
- `swift package dump-symbol-graph` -- generate symbol graph for documentation
