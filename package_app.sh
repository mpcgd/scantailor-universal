#!/bin/bash

# ScanTailor Universal App Packaging Script
# Copies the built app bundle to dist/ and fixes the Info.plist

SRCDIR="$(dirname "$0")"

echo "=== Packaging ScanTailor Universal App ==="

# Check if the build exists
if [ ! -d "$SRCDIR/build/src/app/scantailor-universal.app" ]; then
    echo "❌ Built app not found. Run ./build_scantailor.sh Release first."
    exit 1
fi

# Create dist directory
mkdir -p "$SRCDIR/dist"

# Copy the app bundle
echo "Copying app bundle..."
cp -r "$SRCDIR/build/src/app/scantailor-universal.app" "$SRCDIR/dist/"

# Fix the Info.plist executable name
PLIST="$SRCDIR/dist/scantailor-universal.app/Contents/Info.plist"
echo "Fixing Info.plist executable name..."
sed -i.bak 's|<string>ScanTailorUniversal</string>|<string>scantailor-universal</string>|g' "$PLIST"
rm "$PLIST.bak"

echo "✅ App packaged successfully in dist/scantailor-universal.app"
