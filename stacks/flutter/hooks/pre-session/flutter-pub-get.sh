#!/bin/bash
# Ensure Flutter dependencies are up to date
if [ -f "pubspec.yaml" ]; then
    flutter pub get 2>/dev/null
fi
