#!/bin/bash

# ScanTailor Universal App Install Script
# Copies the packaged app bundle to /Applications

SRCDIR="$(dirname "$0")"

echo "=== Installing ScanTailor Universal App to /Applications ==="

# Check if the packaged app exists
if [ ! -d "$SRCDIR/dist/scantailor-universal.app" ]; then
    echo "❌ Packaged app not found. Run ./package_app.sh first."
    exit 1
fi

echo "Installing app... (requires admin privileges)"
sudo cp -r "$SRCDIR/dist/scantailor-universal.app" /Applications/

if [ $? -eq 0 ]; then
    echo "✅ App successfully installed to /Applications/scantailor-universal.app"
    echo "You can now launch it from the Applications folder or Dock."
else
    echo "❌ Installation failed."
    exit 1
fi
