#!/bin/bash
# Format and analyze Dart code
if [ -f "pubspec.yaml" ]; then
    dart format . 2>/dev/null
    dart analyze 2>/dev/null
fi
