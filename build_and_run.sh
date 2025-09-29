#!/bin/bash

# Build and Run ScanTailor Universal GUI Script

echo "=== Building ScanTailor Universal ==="

# Run the build script
./build_scantailor.sh

# Check if build succeeded
if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build completed successfully!"

echo "=== Launching ScanTailor Universal GUI ==="

# Run the GUI application in background
./build/src/app/scantailor-universal.app/Contents/MacOS/scantailor-universal &

echo "✅ GUI app launched!"
