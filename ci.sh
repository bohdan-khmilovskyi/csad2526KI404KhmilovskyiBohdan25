#!/usr/bin/env bash
set -euo pipefail

cmake -S . -B build
cmake --build build --config Release
ctest --test-dir build -C Release --output-on-failure

mkdir -p dist

if [ -f build/hello ]; then
    cp build/hello dist/hello
elif [ -f build/Release/hello.exe ]; then
    cp build/Release/hello.exe dist/hello.exe
else
    echo "Built executable not found in build/ or build/Release/." >&2
    exit 1
fi
