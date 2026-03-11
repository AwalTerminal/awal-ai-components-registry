#!/bin/bash
# Format staged .dart files before commit
staged=$(git diff --cached --name-only --diff-filter=ACM -- '*.dart' 2>/dev/null)
if [ -n "$staged" ]; then
    echo "$staged" | xargs dart format 2>/dev/null
    echo "$staged" | xargs git add
fi
